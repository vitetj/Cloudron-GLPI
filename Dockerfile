FROM cloudron/base:5.0.0

ENV GLPI_VERSION=11.0.4

RUN apt-get update && apt-get install -y \
    apache2 \
    php \
    libapache2-mod-php \
    php-cli \
    php-mysql \
    php-gd \
    php-curl \
    php-intl \
    php-ldap \
    php-xml \
    php-mbstring \
    php-zip \
    php-bz2 \
    php-apcu \
    php-imap \
    curl \
    ca-certificates \
 && rm -rf /var/lib/apt/lists/*

# Apache Cloudron rules
RUN sed -i 's/Listen 80/Listen 8000/' /etc/apache2/ports.conf
RUN a2disconf other-vhosts-access-log
RUN a2enmod php8.3 rewrite headers env

# Logs Apache -> stdout/stderr
COPY apache/cloudron-global.conf /etc/apache2/conf-available/cloudron-global.conf
RUN a2enconf cloudron-global

# VirtualHost GLPI
COPY apache/glpi.conf /etc/apache2/sites-available/glpi.conf
RUN a2dissite 000-default.conf \
 && a2ensite glpi.conf

# GLPI
RUN curl -fL https://github.com/glpi-project/glpi/releases/download/${GLPI_VERSION}/glpi-${GLPI_VERSION}.tgz \
    | tar xz -C /var/www/html \
 && mv /var/www/html/glpi /var/www/html/app

RUN chown -R www-data:www-data /var/www/html/app

COPY init-glpi.sh /app/code/init-glpi.sh
RUN chmod +x /app/code/init-glpi.sh

COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 8000
CMD ["/start.sh"]
