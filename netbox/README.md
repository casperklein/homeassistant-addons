# Netbox for Hass.io

[Netbox](https://github.com/netbox-community/netbox) is an open source web application designed to help manage and document computer networks. 

## Installation:

1. Add [this](https://github.com/casperklein/hassio-addons) Hass.io add-ons repository to your Hass.io instance.
1. Install the netbox add-on.
1. Set *user* and *password* in the add-on options.
  * This will add a new superuser to netbox after the add-on starts.
  * The credentials can be safely removed from the add-on options afterwards.
1. Start the add-on.
1. Click on the "OPEN WEB UI" button to open Netbox.

## Screenshots:

### Main page
![Screenshot of main page](https://raw.githubusercontent.com/netbox-community/netbox/develop/docs/media/screenshot1.png "Main page")

### Rack elevation
![Screenshot of rack elevation](https://raw.githubusercontent.com/netbox-community/netbox/develop/docs/media//screenshot2.png "Rack elevation")

### Prefix hierarchy
![Screenshot of prefix hierarchy](https://raw.githubusercontent.com/netbox-community/netbox/develop/docs/media/screenshot3.png "Prefix hierarchy")
