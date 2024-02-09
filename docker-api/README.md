# Docker API

![version][version-shield]
![Supports amd64 architecture][amd64-shield]
![Supports aarch64 architecture][aarch64-shield]
![Supports armhf architecture][armhf-shield]
![Supports armv7 architecture][armv7-shield]
![Docker image size][image-size-shield]

Expose Home Assistant OS Docker API via network

## WARNING

The usage of this addon is very unsecure and probably no good idea. Exposing the Docker API, is like giving everyone on the network root access to your Home Assistant OS.

A more secure solution is to enable [SSH](https://developers.home-assistant.io/docs/operating-system/debugging/#ssh-access-to-the-host) and access the Docker API with something like:

    docker -H ssh://root@homeassistant.local:22222 info

## Installation

[![Open this add-on in your Home Assistant instance.][addon-badge]][addon]

1. Add [this](https://github.com/casperklein/homeassistant-addons) Home Assistant add-ons repository to your Home Assistant instance or use the button above.
1. Install the Docker API add-on.
1. Set the "Protection mode" switch to off.
1. Start the add-on.

## Usage

    docker -H tcp://homeassistant.local:2375 <command>

## Example

    docker -H tcp://homeassistant.local:2375 version

[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-blue.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-blue.svg
[armhf-shield]: https://img.shields.io/badge/armhf-yes-blue.svg
[armv7-shield]: https://img.shields.io/badge/armv7-yes-blue.svg
[version-shield]: https://img.shields.io/badge/dynamic/json?color=blue&label=version&query=version&url=https%3A%2F%2Fraw.githubusercontent.com%2Fcasperklein%2Fhomeassistant-addons%2Fmaster%2Fdocker-api%2Fconfig.json
[image-size-shield]: https://img.shields.io/docker/image-size/casperklein/homeassistant-docker-api/latest
[addon-badge]: https://my.home-assistant.io/badges/supervisor_addon.svg
[addon]: https://my.home-assistant.io/redirect/supervisor_addon/?addon=0da538cf_docker-api&repository_url=https%3A%2F%2Fgithub.com%2Fcasperklein%2Fhomeassistant-addons
