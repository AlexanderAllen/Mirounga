#!/bin/bash

export COMPOSE_NETWORK=VSD

export XDEBUG_REMOTE_HOST=`ip addr show eth0 | grep -oE '\d+(\.\d+){3}' | head -n 1`
echo "XDebug will contact IDE at ${XDEBUG_REMOTE_HOST}"

# Source code directory, assumed to be the current directory.
export PROJECT_SOURCE=`readlink -f .`
echo "Project location is ${PROJECT_SOURCE}"

# Must mount source into same location as PHP-FPM and Nginx.
export PROJECT_DEST="/vsdroot"

PROJECT_NAME="${PWD##*/}"
LOCALENV_HOME="/home/wsl/Sites/localenv/docker"

# Sharing SSH socket from WSL2 into containers.
export SSH_AUTH_SOCK=${SSH_AUTH_SOCK}


# Start local stack on which to run Drush on.
# ./scripts/start.sh

# Merge Drush compose onto existing stack definition.
# Paths are relative to project root, when invoking script from project root.
docker-compose \
--project-name $PROJECT_NAME \
--file ${LOCALENV_HOME}/docker-compose.shared.yml \
--file ${LOCALENV_HOME}/docker-compose.override.yml \
--file ${LOCALENV_HOME}/run/drupal/docker-compose.vsd.yml \
--file ${LOCALENV_HOME}/run/drush/docker-compose.vsd.yml \
run \
--entrypoint=ash --rm --user=root \
drush



#run --rm drush "$@"
# run --rm --user=root drush "$@"

# To connect to database use:
# mariadb -h mysql
