#!/bin/bash

set -ueo pipefail

USER=$(grep USER= Dockerfile | cut -d'"' -f2)
NAME=$(grep NAME= Dockerfile | cut -d'"' -f2)
VERSION=$(grep VERSION= Dockerfile | cut -d'"' -f2)
TAG="$USER/$NAME:$VERSION"

DIR=${0%/*}
cd "$DIR"

echo "Building: $NAME $VERSION"
echo
docker build -t "$TAG" .
