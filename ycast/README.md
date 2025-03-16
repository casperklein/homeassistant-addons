# YCast for Home Assistant

![version][version-shield]
![Supports amd64 architecture][amd64-shield]
![Supports aarch64 architecture][aarch64-shield]
![Supports armhf architecture][armhf-shield]
![Supports armv7 architecture][armv7-shield]
![Docker image size][image-size-shield]

YCast is a self hosted replacement for the vTuner internet radio service which many AVRs use. It emulates a vTuner backend to provide your AVR with the necessary information to play self defined categorized internet radio stations and listen to Radio stations listed in the [Community Radio Browser index](http://www.radio-browser.info).

Visit [YCast project page](https://github.com/milaq/YCast) for more information.

## Support

If you like the add-on and would like to support my work, you might [![Buy me a coffee][coffee-shield]][paypal]

## Installation

[![Open this add-on in your Home Assistant instance.][addon-shield]][addon]

1. Add [this](https://github.com/casperklein/homeassistant-addons) Home Assistant add-ons repository to your Home Assistant instance or use the button above.
1. Install the YCast add-on.
1. Configure bookmarks (optional):

       bookmarks:
         - 'Rock Antenne: https://mp3channels.webradio.rockantenne.de/rockantenne'
         - 'SWR1 BW: https://liveradio.swr.de/sw282p3/swr1bw/play.mp3'

1. Start the add-on.

## Your Yamaha internet radio stopped working?

Visit [Yamaha News](https://de.yamaha.com/de/news_events/2019/0305_av_update_on_internet_radio_station_access.html) for more information.

[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-blue.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-blue.svg
[armhf-shield]: https://img.shields.io/badge/armhf-yes-blue.svg
[armv7-shield]: https://img.shields.io/badge/armv7-yes-blue.svg
[version-shield]: https://img.shields.io/badge/dynamic/json?color=blue&label=version&query=version&url=https%3A%2F%2Fraw.githubusercontent.com%2Fcasperklein%2Fhomeassistant-addons%2Fmaster%2Fycast%2Fconfig.json
[image-size-shield]: https://img.shields.io/docker/image-size/casperklein/homeassistant-ycast/latest
[addon-shield]: https://img.shields.io/badge/Show%20add--on%20on%20my-Home%20Assistant-blue?style=for-the-badge&logo=home-assistant
[addon]: https://my.home-assistant.io/redirect/supervisor_addon/?addon=0da538cf_ycast&repository_url=https%3A%2F%2Fgithub.com%2Fcasperklein%2Fhomeassistant-addons
[coffee-shield]: https://img.shields.io/badge/Buy_me_a_coffee-blue?logo=paypal&color=blue
[paypal]: https://www.paypal.com/donate/?hosted_button_id=7C95GXVEQFE8C
