#!/bin/bash
set -eu

# ==============================
# Directories
# ==============================
GLPI_DIR="/var/www/html/app"
DATA_DIR="/app/data"

CONFIG_DIR="${DATA_DIR}/config"
FILES_DIR="${DATA_DIR}/files"
PLUGINS_DIR="${DATA_DIR}/plugins"
MARKETPLACE_DIR="${DATA_DIR}/marketplace"

# ==============================
# Create persistent directories
# ==============================
mkdir -p "$CONFIG_DIR" "$FILES_DIR" "$PLUGINS_DIR" "$MARKETPLACE_DIR"

# ==============================
# Symlinks expected by GLPI
# ==============================
ln -sf "$CONFIG_DIR/config_db.php" "$GLPI_DIR/config/config_db.php"
ln -sf "$FILES_DIR"              "$GLPI_DIR/files"
ln -sf "$PLUGINS_DIR"            "$GLPI_DIR/plugins"
ln -sf "$MARKETPLACE_DIR"        "$GLPI_DIR/marketplace"

# ==============================
# Database configuration
# ==============================
CONFIG_DB="${CONFIG_DIR}/config_db.php"

if [ ! -f "$CONFIG_DB" ]; then
  cat > "$CONFIG_DB" <<EOF
<?php
class DB extends DBmysql {
   public \$dbhost     = '${CLOUDRON_MYSQL_HOST}';
   public \$dbuser     = '${CLOUDRON_MYSQL_USERNAME}';
   public \$dbpassword = '${CLOUDRON_MYSQL_PASSWORD}';
   public \$dbdefault  = '${CLOUDRON_MYSQL_DATABASE}';
   public \$dbport     = ${CLOUDRON_MYSQL_PORT};
}
EOF
fi

# ==============================
# Permissions (Cloudron-safe)
# ==============================
chown -R www-data:www-data "$DATA_DIR"

# ==============================
# Start Apache
# ==============================
exec apachectl -D FOREGROUND
