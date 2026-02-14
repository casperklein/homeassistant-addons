# Netbox for Home Assistant

![version][version-shield]
![Supports amd64 architecture][amd64-shield]
![Supports aarch64 architecture][aarch64-shield]
![Docker image size][image-size-shield]

[Netbox](https://github.com/netbox-community/netbox) is an open source web application designed to help manage and document computer networks.

## Support

If you like the app and would like to support my work, you might [![Buy me a coffee][coffee-shield]][paypal]

## Installation

[![Open this app in your Home Assistant instance.][addon-shield]][addon]

1. Add [this](https://github.com/casperklein/homeassistant-addons) Home Assistant apps repository to your Home Assistant instance or use the button above.
1. Install the netbox app.
1. Set *user* and *password* in the app options.
    * This will add a new superuser to netbox after the app starts.
    * The credentials must be removed from the app options afterwards, otherwise the app will not start.
1. Start the app.
1. Click on the "OPEN WEB UI" button to open Netbox.

## Configuration

**Note**: *Remember to restart the app when the configuration is changed.*

Example app configuration:

    user: "admin"
    password: "insecure"
    LOGIN_REQUIRED: true
    debug: false

**Note**: *This is just an example, don't copy and paste it! Create your own!*

### Option: `user` / `password`

If set, a new netbox superuser is created on app start.

**Important: Use these options only once. Check the log and after successful creation of the user, remove the credentials from the configuration.**

### Option: `LOGIN_REQUIRED`

Setting this to `false` will permit anonymous users to access most data in NetBox, but not make any changes. By default, anonymous users are not permitted to access any data in NetBox.

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

The *requirements* are downloaded during the app startup, so an internet connection is necessary.

## Screenshots

### Main page

![Screenshot of main page](https://github.com/netbox-community/netbox/raw/main/docs/media/screenshots/home-light.png "Main page")

### Rack elevation

![Screenshot of rack elevation](https://github.com/netbox-community/netbox/raw/main/docs/media/screenshots/rack.png "Rack elevation")

### Prefix hierarchy

![Screenshot of prefix hierarchy](https://github.com/netbox-community/netbox/raw/main/docs/media/screenshots/prefixes-list.png "Prefix hierarchy")

### Cable Trace

![Screenshot of cable trace](https://github.com/netbox-community/netbox/raw/main/docs/media/screenshots/cable-trace.png "Cable Trace")

[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-blue.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-blue.svg
[version-shield]: https://img.shields.io/badge/dynamic/json?color=blue&label=version&query=version&url=https%3A%2F%2Fraw.githubusercontent.com%2Fcasperklein%2Fhomeassistant-addons%2Fmaster%2Fnetbox%2Fconfig.json
[image-size-shield]: https://img.shields.io/docker/image-size/casperklein/homeassistant-netbox/latest
[addon-shield]: https://img.shields.io/badge/Show%20add--on%20on%20my-Home%20Assistant-blue?style=for-the-badge&logo=home-assistant

[addon]: https://my.home-assistant.io/redirect/supervisor_addon/?addon=0da538cf_netbox&repository_url=https%3A%2F%2Fgithub.com%2Fcasperklein%2Fhomeassistant-addons
[coffee-shield]: https://img.shields.io/badge/Buy_me_a_coffee-blue?logo=paypal&color=blue
[paypal]: https://www.paypal.com/donate/?hosted_button_id=7C95GXVEQFE8C
