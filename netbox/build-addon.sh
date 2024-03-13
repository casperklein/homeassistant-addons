#!/bin/bash

set -ueo pipefail

DIR=${0%/*}
cd "$DIR"

VERSION=$(jq -er '.version'		< config.json)
IMAGE=$(jq -er '.image'			< config.json)
TAG=$(jq -er '"\(.image):\(.version)"'	< config.json)

ARCH=$(dpkg --print-architecture)
[ "$ARCH" == "arm64" ] && ARCH="aarch64"

echo "Building: $TAG"
echo
docker build -t "$TAG" --build-arg VERSION="$VERSION" --build-arg BUILD_ARCH="$ARCH" --provenance=false .
docker tag "$TAG" "$IMAGE:latest"
