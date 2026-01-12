#!/bin/bash
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
if [ -n "$CLOUDRON_LDAP_URL" ] && [ -n "$CLOUDRON_LDAP_BASE_DN" ]; then
  echo
  echo "=== Configuring LDAP directory ==="
  
  php bin/console glpi:ldap:create \
    --default \
    --active \
    --name="Cloudron LDAP" \
    --host="${CLOUDRON_LDAP_URL#ldap://}" \
    --port=389 \
    --basedn="ou=users,${CLOUDRON_LDAP_BASE_DN}" \
    --rootdn="${CLOUDRON_LDAP_BIND_DN}" \
    --rootdn-pass="${CLOUDRON_LDAP_BIND_PASSWORD}" \
    --login-field="username" \
    --email-field="mail" \
    --firstname-field="givenName" \
    --realname-field="sn" \
    --use-tls=0
  
  echo "LDAP directory configured successfully."
else
  echo
  echo "LDAP environment variables not available. Skipping LDAP configuration."
fi
