#!/usr/bin/env bash
set -x

# DO NOT EDIT THIS FILE BY HAND -- FILE IS SYNCHRONIZED REGULARLY

# Available environment variables
#
# BUILD_OPTS
# REPOSITORY
# VERSION

# Set default values

CREATED=$(gdate --rfc-3339=ns)
BUILD_OPTS=${BUILD_OPTS:-}
REVISION=$(git rev-parse --short HEAD)
VERSION=${VERSION:-latest}

docker build \
    --build-arg "VERSION=$VERSION" \
    --tag "$REPOSITORY:$VERSION" \
    --label "org.opencontainers.image.created=$CREATED" \
    --label "org.opencontainers.image.revision=$REVISION" \
    --label "org.opencontainers.image.version=$VERSION" \
    --squash \
    $BUILD_OPTS .