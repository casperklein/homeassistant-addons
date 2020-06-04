# Netbox for Home Assistant

![version][version-shield]
![Supports amd64 architecture][amd64-shield]
![Supports aarch64 architecture][aarch64-shield]
![Supports armhf architecture][armhf-shield]
![Supports armv7 architecture][armv7-shield]
![Docker image size][image-size-shield]

[Netbox](https://github.com/netbox-community/netbox) is an open source web application designed to help manage and document computer networks. 

## Installation:

1. Add [this](https://github.com/casperklein/homeassistant-addons) Home Assistant add-ons repository to your Home Assistant instance.
1. Install the netbox add-on.
1. Set *user* and *password* in the add-on options.
    * This will add a new superuser to netbox after the add-on starts.
    * The credentials can be safely removed from the add-on options afterwards.
1. Start the add-on.
1. Click on the "OPEN WEB UI" button to open Netbox.

## Configuration:

**Note**: _Remember to restart the add-on when the configuration is changed._

Example add-on configuration:

    {
      "user": "admin",
      "password": "insecure"
    }

**Note**: _This is just an example, don't copy and paste it! Create your own!_

## Screenshots:

### Main page
![Screenshot of main page](https://raw.githubusercontent.com/netbox-community/netbox/develop/docs/media/screenshot1.png "Main page")

### Rack elevation
![Screenshot of rack elevation](https://raw.githubusercontent.com/netbox-community/netbox/develop/docs/media//screenshot2.png "Rack elevation")

### Prefix hierarchy
![Screenshot of prefix hierarchy](https://raw.githubusercontent.com/netbox-community/netbox/develop/docs/media/screenshot3.png "Prefix hierarchy")

[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-blue.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-blue.svg
[armhf-shield]: https://img.shields.io/badge/armhf-yes-blue.svg
[armv7-shield]: https://img.shields.io/badge/armv7-yes-blue.svg
[version-shield]: https://img.shields.io/badge/dynamic/json?color=blue&label=version&query=version&url=https%3A%2F%2Fraw.githubusercontent.com%2Fcasperklein%2Fhomeassistant-addons%2Fmaster%2Fnetbox%2Fconfig.json
[image-size-shield]: https://img.shields.io/docker/image-size/casperklein/homeassistant-netbox/latest
