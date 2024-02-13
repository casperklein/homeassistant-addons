# Netbox for Home Assistant

![version][version-shield]
![Supports amd64 architecture][amd64-shield]
![Supports aarch64 architecture][aarch64-shield]
![Docker image size][image-size-shield]

[Netbox](https://github.com/netbox-community/netbox) is an open source web application designed to help manage and document computer networks.

## Installation

[![Open this add-on in your Home Assistant instance.][addon-badge]][addon]

1. Add [this](https://github.com/casperklein/homeassistant-addons) Home Assistant add-ons repository to your Home Assistant instance or use the button above.
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

### Option: `LOGIN_REQUIRED`

Setting this to `true` will permit only authenticated users to access any part of NetBox. By default, anonymous users are permitted to access most data in NetBox but not make any changes.

### Option: `debug`

If enabled, the merged Netbox configuration (default + custom) is stored in `addon_configs/0da538cf_netbox/configuration-merged.py`.

## Custom Netbox configuration

You can extend the default Netbox configuration, e.g. for [plugins](https://github.com/netbox-community/netbox/wiki/Plugins):

* If the file `addon_configs/0da538cf_netbox/configuration.py` exists, it's content will be appended to the Netbox default configuration.
* If the file `addon_configs/0da538cf_netbox/requirements.txt` exists, the packages listed in that file will be installed by `pip`.

For example:

`addon_configs/0da538cf_netbox/configuration.py`:

    PLUGINS = ['netbox_bgp','netbox_ipcalculator','netbox_qrcode', 'netbox_metatype_importer']

    PLUGINS_CONFIG = {
        'netbox_metatype_importer': {
            'github_token': 'change-me'
        }
    }

`addon_configs/0da538cf_netbox/requirements.txt`:

    netbox-bgp
    netbox-ipcalculator
    netbox-qrcode
    netbox-metatype-importer

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
[version-shield]: https://img.shields.io/badge/dynamic/json?color=blue&label=version&query=version&url=https%3A%2F%2Fraw.githubusercontent.com%2Fcasperklein%2Fhomeassistant-addons%2Fmaster%2Fnetbox%2Fconfig.json
[image-size-shield]: https://img.shields.io/docker/image-size/casperklein/homeassistant-netbox/latest
[addon-badge]: https://my.home-assistant.io/badges/supervisor_addon.svg
[addon]: https://my.home-assistant.io/redirect/supervisor_addon/?addon=0da538cf_netbox&repository_url=https%3A%2F%2Fgithub.com%2Fcasperklein%2Fhomeassistant-addons
