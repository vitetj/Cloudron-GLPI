FROM cloudron/base:5.0.0

ENV GLPI_VERSION=11.0.4
ENV DEBIAN_FRONTEND=noninteractive

# ------------------------------
# System & PHP dependencies
# ------------------------------
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

# ------------------------------
# Apache Cloudron conventions
# ------------------------------
RUN sed -i 's/Listen 80/Listen 8000/' /etc/apache2/ports.conf \
 && a2disconf other-vhosts-access-log \
 && a2enmod php8.3 rewrite headers env

# Logs -> stdout/stderr
COPY apache/cloudron-global.conf /etc/apache2/conf-available/cloudron-global.conf
RUN a2enconf cloudron-global

# GLPI VirtualHost
COPY apache/glpi.conf /etc/apache2/sites-available/glpi.conf
RUN a2dissite 000-default.conf \
 && a2ensite glpi.conf

# ------------------------------
# Install GLPI
# ------------------------------
RUN curl -fL https://github.com/glpi-project/glpi/releases/download/${GLPI_VERSION}/glpi-${GLPI_VERSION}.tgz \
    | tar xz -C /var/www/html \
 && mv /var/www/html/glpi /var/www/html/app

# ------------------------------
# Cloudron persistent layout (BUILD TIME)
# IMPORTANT: only directories, no files
# ------------------------------
RUN rm -rf /var/www/html/app/files \
           /var/www/html/app/plugins \
           /var/www/html/app/marketplace \
 && mkdir -p /app/data/files /app/data/plugins /app/data/marketplace /app/data/config \
 && ln -s /app/data/files       /var/www/html/app/files \
 && ln -s /app/data/plugins     /var/www/html/app/plugins \
 && ln -s /app/data/marketplace /var/www/html/app/marketplace

# Ownership (does NOT make writable at runtime, just clean)
RUN chown -R www-data:www-data /var/www/html/app /app/data

# ------------------------------
# Startup
# ------------------------------
COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 8000
CMD ["/start.sh"]
