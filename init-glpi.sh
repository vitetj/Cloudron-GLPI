#!/bin/sh
set -e

echo "=== GLPI post-install initialization ==="

export GLPI_CONFIG_DIR=/app/data/config
export GLPI_VAR_DIR=/app/data/files
export GLPI_PLUGINS_DIR=/app/data/plugins

cd /var/www/html/app

php bin/console glpi:database:install \
  --db-host="$CLOUDRON_MYSQL_HOST" \
  --db-user="$CLOUDRON_MYSQL_USERNAME" \
  --db-password="$CLOUDRON_MYSQL_PASSWORD" \
  --db-name="$CLOUDRON_MYSQL_DATABASE" \
  --allow-superuser

echo
echo "GLPI database initialized successfully."
echo "Default credentials:"
echo "  Login    : glpi"
echo "  Password : glpi"
echo
echo "IMPORTANT: Change the password immediately after first login."

# Configure LDAP directory if CLOUDRON_LDAP environment variables are available
if [ -n "$CLOUDRON_LDAP_HOST" ] && [ -n "$CLOUDRON_LDAP_USERS_BASE_DN" ]; then
  echo
  echo "=== Configuring LDAP directory ==="
  
  LDAP_NAME="Cloudron LDAP"
  
  MYSQL_CMD="mysql \
    --user=${CLOUDRON_MYSQL_USERNAME} \
    --password=${CLOUDRON_MYSQL_PASSWORD} \
    --host=${CLOUDRON_MYSQL_HOST} \
    ${CLOUDRON_MYSQL_DATABASE}"
  
  echo "[+] Injection LDAP GLPI (schéma exact)"
  
  ${MYSQL_CMD} <<SQL
DELETE FROM glpi_authldaps WHERE name = '${LDAP_NAME}';

INSERT INTO glpi_authldaps (
    name,
    host,
    port,
    basedn,
    rootdn,
    rootdn_passwd,

    login_field,
    email1_field,
    firstname_field,
    realname_field,

    use_tls,
    use_dn,
    use_bind,

    is_active,
    is_default,
    ldap_maxlimit,
    timeout
) VALUES (
    '${LDAP_NAME}',
    '${CLOUDRON_LDAP_HOST}',
    ${CLOUDRON_LDAP_PORT},
    '${CLOUDRON_LDAP_USERS_BASE_DN}',
    '${CLOUDRON_LDAP_BIND_DN}',
    '${CLOUDRON_LDAP_BIND_PASSWORD}',

    'username',
    'mail',
    'givenName',
    'sn',

    0,
    1,
    1,

    1,
    1,
    0,
    10
);
SQL
  
  echo "[+] Nettoyage du cache GLPI"
  sudo -u www-data php /var/www/html/app/bin/console cache:clear
  
  echo "[+] Synchronisation LDAP"
  sudo -u www-data php /var/www/html/app/bin/console ldap:sync
  
  echo "[✓] LDAP Cloudron configuré et synchronisé"
else
  echo
  echo "LDAP environment variables not available. Skipping LDAP configuration."
fi
