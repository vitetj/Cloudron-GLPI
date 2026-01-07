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
