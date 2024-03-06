#!/usr/bin/with-contenv bashio
WOOB_DIR="/woob"
KRESUS_INI_FILE="/etc/kresus/config.ini"

# ==============================================================================
# Pull latest Woob version
# ==============================================================================
cd "${WOOB_DIR}" || bashio::exit.nok

bashio::log.info "Clear woob install"
rm -rf {,.[!.],..?}*

bashio::log.info "Add clean woob install"
wget -qO- https://gitlab.com/woob/woob/-/archive/master/woob-master.tar.gz | tar xz --strip-components=1

bashio::log.info "Updating Woob dependencies..."
pip3 install --no-cache-dir --prefix .py-deps .
PYTHONPATH=$(python3 -c "import sys, os; print(os.sep.join(['$(pwd)', '.py-deps', 'lib', f'python{sys.version_info.major}.{sys.version_info.minor}', 'site-packages']))")
export PYTHONPATH
bashio::log.info "Done updating Woob dependencies."

# ==============================================================================
# Set-up environment variables
# ==============================================================================

# Basic Kresus options
export PORT=9876
export HOST=0.0.0.0
export KRESUS_PYTHON_EXEC=python3
export KRESUS_WOOB_DIR="${WOOB_DIR}"

KRESUS_SALT="$(cat /data/kresus_salt)"
export KRESUS_SALT

# Kresus Basic auth
if bashio::config.has_value 'http_basicauth'; then
  KRESUS_AUTH="$(bashio::config 'http_basicauth')"
  export KRESUS_AUTH
fi

# Kresus database
export KRESUS_DB_TYPE="postgres"

KRESUS_DB_HOST="$(bashio::config 'postgres_hostname')"
KRESUS_DB_PORT="$(bashio::config 'postgres_port')"
KRESUS_DB_USERNAME="$(bashio::config 'postgres_user')"
KRESUS_DB_PASSWORD="$(bashio::config 'postgres_password')"
KRESUS_DB_NAME="$(bashio::config 'postgres_database')"
export KRESUS_DB_HOST KRESUS_DB_PORT KRESUS_DB_USERNAME \
       KRESUS_DB_PASSWORD KRESUS_DB_NAME

# ==============================================================================
# Start Kresus
# ==============================================================================
kresus -c ${KRESUS_INI_FILE}
