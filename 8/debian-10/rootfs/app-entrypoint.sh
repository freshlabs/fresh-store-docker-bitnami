#!/bin/bash

set -o errexit
set -o pipefail
# set -o xtrace

# Load libraries
# shellcheck disable=SC1091
. /opt/bitnami/base/functions

# Constants
INIT_SEM=/tmp/initialized.sem

# Functions

########################
# Replace a regex in a file
# Arguments:
#   $1 - filename
#   $2 - match regex
#   $3 - substitute regex
#   $4 - regex modifier
# Returns: none
#########################
replace_in_file() {
    local filename="${1:?filename is required}"
    local match_regex="${2:?match regex is required}"
    local substitute_regex="${3:?substitute regex is required}"
    local regex_modifier="${4:-}"
    local result

    # We should avoid using 'sed in-place' substitutions
    # 1) They are not compatible with files mounted from ConfigMap(s)
    # 2) We found incompatibility issues with Debian10 and "in-place" substitutions
    result="$(sed "${regex_modifier}s@${match_regex}@${substitute_regex}@g" "$filename")"
    echo "$result" >"$filename"
}

########################
# Wait for database to be ready
# Globals:
#   DATABASE_HOST
#   DB_PORT
# Arguments: none
# Returns: none
#########################
wait_for_db() {
    log "Getting host value"
    local -r db_host="${DB_HOST:-mariadb}"
    log "Host value $db_host"
    log "Getting port value"
    local -r db_port="${DB_PORT:-3306}"
    log "Port value $db_port"
    local db_address
    #db_address=$(getent hosts "$db_host" | awk '{ print $1 }')
    db_address=$db_host
    local counter=0
    log "Connecting to database at $db_address"
    while ! nc -z "$db_address" "$db_port" >/dev/null; do
        counter=$((counter + 1))
        if [ $counter == 30 ]; then
            log "Error: Couldn't connect to database."
            exit 1
        fi
        log "Trying to connect to database at $db_address. Attempt $counter."
        sleep 5
    done
}

########################
# Setup the database configuration
# Arguments: none
# Returns: none
#########################
setup_db() {
    log "Setting up the database for the first time"
    php artisan migrate:fresh --seed
    log "Database setup finished"
}

print_welcome_page


if [[ -f /app/.installed ]]; then

    log "This is an existing Fresh Store"
    log "No further action needed"
    #log "Updating Fresh Store dependencies (composer)"
    #composer update

else

    log "This is a new install"
    log "Downloading zip of Fresh Store latest version from Github"
    curl -L -o /tmp/fresh-store-github.zip https://"$GITHUB_TOKEN":x-oauth-basic@github.com/"$GITHUB_REPOSITORY"/archive/"$GITHUB_BRANCH".zip

    log "Extracting zip files to the temp directory"
    mkdir -p /tmp/freshstorefiles
    unzip -o -q /tmp/fresh-store-github.zip -d /tmp/freshstorefiles

    log "Copying Fresh Store files to the live directory"
    shopt -s dotglob
    REPO_NAME="$(cut -d'/' -f2 <<<"$GITHUB_REPOSITORY")"
    rsync -r /tmp/freshstorefiles/"$REPO_NAME"-"$GITHUB_BRANCH"/ /app/

    log "Removing Fresh Store temp zip file and folder"
    unlink /tmp/fresh-store-github.zip
    rm -rf /tmp/freshstorefiles/"$REPO_NAME"-"$GITHUB_BRANCH"

    log "Finished getting Fresh Store files from Github ($GITHUB_REPOSITORY:$GITHUB_BRANCH)"

    log "Installing Fresh Store dependencies (composer)"
    composer install

    log "Creating a blank .env file from the env template"
    cp /app/.env.example /app/.env

    log "Generating APP_KEY for Laravel"
    php artisan key:generate --ansi

    log "Waiting for the database"
    wait_for_db
    log "Starting database setup"
    setup_db

    log "Adding the .installed file to flag this Fresh Store is now installed"
    touch /app/.installed

fi

exec tini -- "$@"
