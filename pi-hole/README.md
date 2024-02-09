# Pi-hole for Home Assistant

![version][version-shield]
![Supports amd64 architecture][amd64-shield]
![Supports aarch64 architecture][aarch64-shield]
![Supports armhf architecture][armhf-shield]
![Supports armv7 architecture][armv7-shield]
![Docker image size][image-size-shield]

[Network-wide Ad Blocking - A black hole for Internet advertisements](https://pi-hole.net/)

## Installation

[![Open this add-on in your Home Assistant instance.][addon-badge]][addon]

1. Add [this](https://github.com/casperklein/homeassistant-addons) Home Assistant add-ons repository to your Home Assistant instance or use the button above.
1. Install the Pi-hole add-on.
1. Start the add-on.

## How to use DNSCrypt or DNS over HTTPS (DoH) with Pi-hole

This is achieved by using [dnscrypt-proxy](https://github.com/DNSCrypt/dnscrypt-proxy). You have to configure one or more DNS server for use with dnscrypt-proxy. To use Cloudflare DNS for example, put this in the add-on configuration:

    dnscrypt:
      - name: "Cloudflare 1.1.1.1"
        stamp: "sdns://AgcAAAAAAAAABzEuMS4xLjEAEmNsb3VkZmxhcmUtZG5zLmNvbQovZG5zLXF1ZXJ5"
      - name: "Cloudflare 1.0.0.1"
        stamp: "sdns://AgcAAAAAAAAABzEuMC4wLjEAEmNsb3VkZmxhcmUtZG5zLmNvbQovZG5zLXF1ZXJ5"

DNS stamps contain all the parameters required to connect to a secure DNS server as a single string. To create own stamps, you can use: [https://dnscrypt.info/stamps/](https://dnscrypt.info/stamps/). Or you can just use any of these [public servers](https://dnscrypt.info/public-servers).

In Pi-hole the following **must** be configured:

- Custom DNS server: `127.0.0.1#5353`
- Disable all other configured DNS servers

To test your setup, visit [https://1.1.1.1/help](https://1.1.1.1/help). If you see "Using DNS over HTTPS (DoH): yes", all should be fine :)

## Not implemented

- Pi-hole DHCP server functionality

[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-blue.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-blue.svg
[armhf-shield]: https://img.shields.io/badge/armhf-yes-blue.svg
[armv7-shield]: https://img.shields.io/badge/armv7-yes-blue.svg
[version-shield]: https://img.shields.io/badge/dynamic/json?color=blue&label=version&query=version&url=https%3A%2F%2Fraw.githubusercontent.com%2Fcasperklein%2Fhomeassistant-addons%2Fmaster%2Fpi-hole%2Fconfig.json
[image-size-shield]: https://img.shields.io/docker/image-size/casperklein/homeassistant-pihole/latest
[addon-badge]: https://my.home-assistant.io/badges/supervisor_addon.svg
[addon]: https://my.home-assistant.io/redirect/supervisor_addon/?addon=0da538cf_pihole&repository_url=https%3A%2F%2Fgithub.com%2Fcasperklein%2Fhomeassistant-addons
