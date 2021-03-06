#!/bin/bash

set +x

# Build singular service if specified in first argument.
# http://tldp.org/LDP/Bash-Beginners-Guide/html/sect_07_01.html
#
if [ $1 ]; then

  docker-compose -f ./build/${1}/docker-compose.yml build

else
  # Follow Alpine releases @ https://alpinelinux.org/releases.
  export ALPINE_MAJOR=3
  export ALPINE_MINOR=13
  export ALPINE_PATCH=2

  # Specify --no-cache to bust cache.
  USE_CACHE=""

  docker-compose --file ./build/nginx/docker-compose.yml build ${USE_CACHE}

  ### BEGIN IMAGES DEPENDENT ON NOBODY ###

  # If there is any base image, build first.
  docker-compose --file ./build/nobody/docker-compose.yml build ${USE_CACHE} \
    --build-arg ALPINE_MAJOR=${ALPINE_MAJOR} \
    --build-arg ALPINE_MINOR=${ALPINE_MINOR} \
    --build-arg ALPINE_PATCH=${ALPINE_PATCH}

  docker tag alexanderallen/nobody:alpine-${ALPINE_MAJOR}.${ALPINE_MINOR}.${ALPINE_PATCH} \
    alexanderallen/nobody:latest

  docker-compose --file ./build/mariadb-alpine/docker-compose.yml build ${USE_CACHE}
  docker-compose --file ./build/varnish/docker-compose.yml build ${USE_CACHE}
  docker-compose --file ./build/php-fpm/docker-compose.yml build ${USE_CACHE}

  docker tag alexanderallen/php7-fpm.dev:alpine-${ALPINE_MAJOR}.${ALPINE_MINOR}.${ALPINE_PATCH} \
    alexanderallen/php7-fpm.dev:latest

  docker-compose --file ./build/php-cli/docker-compose.yml build ${USE_CACHE}

  docker tag alexanderallen/varnish alexanderallen/varnish:6
  docker tag alexanderallen/varnish alexanderallen/varnish:alpine-${ALPINE_MAJOR}.${ALPINE_MINOR}.${ALPINE_PATCH}

  docker-compose --file ./build/proxy/docker-compose.yml build ${USE_CACHE} \
    --build-arg TRAEFIK_MAJOR=1 \
    --build-arg TRAEFIK_MINOR=7 \
    --build-arg TRAEFIK_PATCH=28

  ### END IMAGES DEPENDENT ON NOBODY ###

  docker images | grep alexanderallen
fi

# && docker-compose -f ./build/xhprof-viewer/docker-compose.yml build \

# Cleanup <3
#
# Remove dangling/intermidiate images from build.
# https://docs.docker.com/config/pruning/

docker image prune --force
