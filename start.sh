#!/bin/bash
set -eu

# ==============================
# Cloudron directories
# ==============================
DATA_DIR="/app/data"
CONFIG_DIR="${DATA_DIR}/config"
FILES_DIR="${DATA_DIR}/files"
PLUGINS_DIR="${DATA_DIR}/plugins"

mkdir -p "$CONFIG_DIR" "$FILES_DIR" "$PLUGINS_DIR"

# ==============================
# GLPI database configuration
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
# Tell GLPI where mutable dirs are
# ==============================
export GLPI_CONFIG_DIR="$CONFIG_DIR"
export GLPI_VAR_DIR="$FILES_DIR"
export GLPI_PLUGINS_DIR="$PLUGINS_DIR"

# ==============================
# Permissions (Cloudron-safe)
# ==============================
chown -R www-data:www-data "$DATA_DIR"

if [ ! -f "$DATA_DIR/.glpi_initialized" ]; then
  echo "GLPI is not initialized yet. Run init-glpi.sh via Cloudron." >&2
fi

# ==============================
# Start Apache
# ==============================
exec apachectl -D FOREGROUND
