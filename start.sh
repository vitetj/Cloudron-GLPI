#!/bin/bash
set -eu

# Directories Cloudron
DATA_DIR="/app/data"
CONFIG_DIR="${DATA_DIR}/config"
FILES_DIR="${DATA_DIR}/files"
PLUGINS_DIR="${DATA_DIR}/plugins"

mkdir -p "$CONFIG_DIR" "$FILES_DIR" "$PLUGINS_DIR"

# -----------------------------
# DB config (persistant)
# -----------------------------
CONFIG_DB="${CONFIG_DIR}/config_db.php"
if [ ! -f "$CONFIG_DB" ]; then
cat > "$CONFIG_DB" <<EOF
<?php
class DB extends DBmysql {
   public \$dbhost     = '${CLOUDRON_DB_HOST}';
   public \$dbuser     = '${CLOUDRON_DB_USER}';
   public \$dbpassword = '${CLOUDRON_DB_PASSWORD}';
   public \$dbdefault  = '${CLOUDRON_DB_NAME}';
   public \$dbport     = 3306;
}
EOF
fi

# -----------------------------
# GLPI directories override
# -----------------------------
export GLPI_CONFIG_DIR="$CONFIG_DIR"
export GLPI_VAR_DIR="$FILES_DIR"
export GLPI_PLUGINS_DIR="$PLUGINS_DIR"

# Permissions (Cloudron-safe)
chown -R www-data:www-data "$DATA_DIR"

exec apachectl -D FOREGROUND
