# Netbox for Home Assistant

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
