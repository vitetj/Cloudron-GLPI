#!/bin/bash
set -eu

echo "=== GLPI Cloudron Startup ==="

# Directories Cloudron
DATA_DIR="/app/data"
CONFIG_DIR="${DATA_DIR}/config"
FILES_DIR="${DATA_DIR}/files"
PLUGINS_DIR="${DATA_DIR}/plugins"

mkdir -p "$CONFIG_DIR" "$FILES_DIR" "$PLUGINS_DIR"

# GLPI directories override
export GLPI_CONFIG_DIR="$CONFIG_DIR"
export GLPI_VAR_DIR="$FILES_DIR"
export GLPI_PLUGINS_DIR="$PLUGINS_DIR"

# Permissions (Cloudron-safe)
chown -R www-data:www-data "$DATA_DIR"

# -----------------------------
# Background initialization
# -----------------------------
CONFIG_DB="${CONFIG_DIR}/config_db.php"

if [ ! -f "$CONFIG_DB" ]; then
  echo "[!] GLPI not initialized - Starting initialization in background"
  
  # Run initialization in background
  (
    sleep 2  # Give Apache time to start
    
    echo ""
    echo "=== GLPI post-install initialization (background) ==="
    
    cd /var/www/html/app
    
    # Run as www-data to avoid permission issues
    sudo -u www-data php bin/console glpi:database:install \
      --db-host="$CLOUDRON_MYSQL_HOST" \
      --db-user="$CLOUDRON_MYSQL_USERNAME" \
      --db-password="$CLOUDRON_MYSQL_PASSWORD" \
      --db-name="$CLOUDRON_MYSQL_DATABASE" \
      --allow-superuser
    
    echo ""
    echo "GLPI database initialized successfully."
    echo "Default credentials:"
    echo "  Login    : glpi"
    echo "  Password : glpi"
    
    # Configure LDAP directory if CLOUDRON_LDAP environment variables are available
    if [ -n "${CLOUDRON_LDAP_HOST:-}" ] && [ -n "${CLOUDRON_LDAP_USERS_BASE_DN:-}" ]; then
      echo ""
      echo "=== Configuring LDAP directory ==="
      
      LDAP_NAME="Cloudron LDAP"
      
      MYSQL_CMD="mysql \
        --user=${CLOUDRON_MYSQL_USERNAME} \
        --password=${CLOUDRON_MYSQL_PASSWORD} \
        --host=${CLOUDRON_MYSQL_HOST} \
        ${CLOUDRON_MYSQL_DATABASE}"
      
      echo "[+] Injection LDAP GLPI"
      
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
      
      echo "[+] Cache clear"
      sudo -u www-data php /var/www/html/app/bin/console cache:clear
      
      echo "[+] LDAP synchronization"
      sudo -u www-data php /var/www/html/app/bin/console ldap:synchronize_users --no-interaction
      
      echo "[✓] LDAP configured"
    fi
    
    # Ensure proper permissions on all data files
    chown -R www-data:www-data "$DATA_DIR"
    
    echo ""
    echo "[✓] GLPI initialization complete"
  ) &
  
  echo "[✓] Initialization started in background (PID: $!)"
else
  echo "[✓] GLPI already initialized"
fi

echo "[✓] Starting Apache..."
exec apachectl -D FOREGROUND
