# Netbox for Home Assistant

![version][version-shield]
![Supports amd64 architecture][amd64-shield]
![Supports aarch64 architecture][aarch64-shield]
![Supports armhf architecture][armhf-shield]
![Supports armv7 architecture][armv7-shield]
![Docker image size][image-size-shield]

[Netbox](https://github.com/netbox-community/netbox) is an open source web application designed to help manage and document computer networks.

## Installation

1. Add [this](https://github.com/casperklein/homeassistant-addons) Home Assistant add-ons repository to your Home Assistant instance.
1. Install the netbox add-on.
1. Set *user* and *password* in the add-on options.
    * This will add a new superuser to netbox after the add-on starts.
    * The credentials must be removed from the add-on options afterwards, otherwise the addon will not start.
1. Start the add-on.
1. Click on the "OPEN WEB UI" button to open Netbox.

## Configuration

**Note**: *Remember to restart the add-on when the configuration is changed.*

Example add-on configuration:

    "user": "admin"
    "password": "insecure"
    "https": true
    "certfile": "fullchain.pem"
    "keyfile": "privatekey.pem"

**Note**: *This is just an example, don't copy and paste it! Create your own!*

### Option: `user` / `password`

If set, a new netbox superuser is created on add-on start.

**Note**: *Use this options only once. Don't forget to remove the credentials afterwards.*

### Option: `https`

Enables/Disables HTTPS on the web interface. Set it `true` to enable it, `false` otherwise.

### Option: `certfile`

A file containing a certificate, including its chain. If this file doesn't exist, the add-on start will fail.

**Note**: *The file MUST be stored in the Home Assistant `/ssl` directory, which is the default for Home Assistant.*

### Option: `keyfile`

A file containing the private key. If this file doesn't exist, the add-on start will fail.

**Note**: *The file MUST be stored in the Home Assistant `/ssl` directory, which is the default for Home Assistant.*

## Plugins

To use [Netbox plugins](https://github.com/netbox-community/netbox/wiki/Plugins), create the directory `/config/netbox` and the two files: `configuration.py` and `requirements.txt`.

For example:

`/config/netbox/configuration.py`:

    PLUGINS = ['netbox_bgp','netbox_dns','netbox_ipcalculator','netbox_qrcode']

`/config/netbox/requirements.txt`:

    netbox-bgp
    netbox-dns
    netbox-ipcalculator
    netbox-qrcode

The *requirements* are downloaded on addon start, so an internet connection is mandatory.

## Screenshots

### Main page

![Screenshot of main page](https://github.com/netbox-community/netbox/raw/develop/docs/media/screenshots/home-light.png "Main page")

### Rack elevation

![Screenshot of rack elevation](https://github.com/netbox-community/netbox/raw/develop/docs/media/screenshots/rack.png "Rack elevation")

### Prefix hierarchy

![Screenshot of prefix hierarchy](https://github.com/netbox-community/netbox/raw/develop/docs/media/screenshots/prefixes-list.png "Prefix hierarchy")

### Cable Trace

![Screenshot of cable trace](https://github.com/netbox-community/netbox/raw/develop/docs/media/screenshots/cable-trace.png "Cable Trace")

[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-blue.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-blue.svg
[armhf-shield]: https://img.shields.io/badge/armhf-yes-blue.svg
[armv7-shield]: https://img.shields.io/badge/armv7-yes-blue.svg
[version-shield]: https://img.shields.io/badge/dynamic/json?color=blue&label=version&query=version&url=https%3A%2F%2Fraw.githubusercontent.com%2Fcasperklein%2Fhomeassistant-addons%2Fmaster%2Fnetbox%2Fconfig.json
[image-size-shield]: https://img.shields.io/docker/image-size/casperklein/homeassistant-netbox/latest
