FROM	alpine:3.17 AS build

ENV	GIT_COMMIT="f349a2686c336420b8e2dc4c9a2a9fc12dd4e358"
ENV	GIT_ARCHIVE="https://github.com/milaq/YCast/archive/$GIT_COMMIT.tar.gz"

ENV	PACKAGES="python3 jq"

# Check if build args are not empty ################################################################
ARG	BUILD_ARCH
ARG	VERSION
RUN	[ -z "$BUILD_ARCH" ] && echo "Error: Build argument 'BUILD_ARCH' is missing" && exit 1 || true
RUN	[ -z "$VERSION" ] && echo "Error: Build argument 'VERSION' is missing" && exit 1 || true

# Get ycast
WORKDIR	/ycast
ADD	$GIT_ARCHIVE /
RUN	tar --strip-component 1 -xzvf /$GIT_COMMIT.tar.gz && rm /$GIT_COMMIT.tar.gz

# Install packages
RUN	apk upgrade --no-cache \
&&	apk add --no-cache $PACKAGES

COPY	--from=ghcr.io/astral-sh/uv:latest /uv /usr/bin/uv

# Create and activate python virtual environment
ENV	VIRTUAL_ENV=/ycast/.venv
RUN	uv venv "$VIRTUAL_ENV"
ENV	PATH="$VIRTUAL_ENV/bin:$PATH"

# Install python packages
RUN	uv pip install --no-cache-dir requests flask PyYAML Pillow

# Copy root filesystem
COPY	rootfs /

# Cleanup
RUN	rm /usr/bin/uv
RUN	find /usr/ -type f -name '*.pyc' -delete

# Build final image ################################################################################
FROM	scratch

ARG	BUILD_ARCH
ARG	VERSION
LABEL	io.hass.name="YCast"
LABEL	io.hass.description="Self hosted vTuner internet radio service emulation"
LABEL	io.hass.arch="${BUILD_ARCH}"
LABEL	io.hass.type="app"
LABEL	io.hass.version="${VERSION}"
LABEL	image="casperklein/homeassistant-ycast:${VERSION}"
LABEL	maintainer="Casper Klein"
LABEL	url="https://github.com/casperklein/homeassistant-addons/tree/master/ycast"

# If this is set to a non-empty string, Python won’t try to write .pyc files on the import of source modules.
ENV     PYTHONDONTWRITEBYTECODE=1
# Show python output immediately, not buffered.
ENV     PYTHONUNBUFFERED=1

# Activate python virtual environment
ENV	VIRTUAL_ENV=/ycast/.venv
ENV	PATH="$VIRTUAL_ENV/bin:$PATH"

WORKDIR	/ycast
CMD	["/run.sh"]

EXPOSE	80

COPY	--from=build / /
