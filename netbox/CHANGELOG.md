# Changelog

## 4.2.6

- [netbox 4.2.6](https://github.com/netbox-community/netbox/releases/tag/v4.2.6)

## 4.2.5.1

- Run `manage.py collectstatic` on add-on start, regardless of whether the database requires migration ([#28](https://github.com/casperklein/homeassistant-addons/issues/28)).
- Include the `setuptools` and `wheel`  pip packages ([#29](https://github.com/casperklein/homeassistant-addons/issues/29)).

## 4.2.5

- [netbox 4.2.5](https://github.com/netbox-community/netbox/releases/tag/v4.2.5)

## 4.2.4

- [netbox 4.2.4](https://github.com/netbox-community/netbox/releases/tag/v4.2.4)

## 4.2.3

- [netbox 4.2.3](https://github.com/netbox-community/netbox/releases/tag/v4.2.3)

## 4.2.2

- [netbox 4.2.2](https://github.com/netbox-community/netbox/releases/tag/v4.2.2)

## 4.2.1

- [netbox 4.2.1](https://github.com/netbox-community/netbox/releases/tag/v4.2.1)

## 4.1.11

- [netbox 4.1.11](https://github.com/netbox-community/netbox/releases/tag/v4.1.11)

## 4.1.10

- [netbox 4.1.10](https://github.com/netbox-community/netbox/releases/tag/v4.1.10)

## 4.1.9

- [netbox 4.1.9](https://github.com/netbox-community/netbox/releases/tag/v4.1.9)

## 4.1.8

- [netbox 4.1.8](https://github.com/netbox-community/netbox/releases/tag/v4.1.8)

## 4.1.7

- [netbox 4.1.7](https://github.com/netbox-community/netbox/releases/tag/v4.1.7)

## 4.1.6

- [netbox 4.1.6](https://github.com/netbox-community/netbox/releases/tag/v4.1.6)

## 4.1.5

- [netbox 4.1.5](https://github.com/netbox-community/netbox/releases/tag/v4.1.5)

## 4.1.4

- [netbox 4.1.4](https://github.com/netbox-community/netbox/releases/tag/v4.1.4)
- Image size reduced
- Using 'uv' instead of 'pip'

## 4.1.3

- [netbox 4.1.3](https://github.com/netbox-community/netbox/releases/tag/v4.1.3)

## 4.1.2

- [netbox 4.1.2](https://github.com/netbox-community/netbox/releases/tag/v4.1.2)

## 4.1.1

- [netbox 4.1.1](https://github.com/netbox-community/netbox/releases/tag/v4.1.1)

## 4.1.0

- [netbox 4.1.0](https://github.com/netbox-community/netbox/releases/tag/v4.1.0)

## 4.0.10

- [netbox 4.0.10](https://github.com/netbox-community/netbox/releases/tag/v4.0.10)

## 4.0.9

- [netbox 4.0.9](https://github.com/netbox-community/netbox/releases/tag/v4.0.9)

## 4.0.8

- [netbox 4.0.8](https://github.com/netbox-community/netbox/releases/tag/v4.0.8)

## 4.0.7

- [netbox 4.0.7](https://github.com/netbox-community/netbox/releases/tag/v4.0.7)

## 4.0.6

- [netbox 4.0.6](https://github.com/netbox-community/netbox/releases/tag/v4.0.6)
- Add-on log colored
- [LOGIN_REQUIRED now defaults to true](https://github.com/netbox-community/netbox/issues/16107)

## 4.0.5

- [netbox 4.0.5](https://github.com/netbox-community/netbox/releases/tag/v4.0.5)

## 4.0.3

- [netbox 4.0.3](https://github.com/netbox-community/netbox/releases/tag/v4.0.3)
- [netbox 4.0.2](https://github.com/netbox-community/netbox/releases/tag/v4.0.2)
- [netbox 4.0.1](https://github.com/netbox-community/netbox/releases/tag/v4.0.1)
- [netbox 4.0.0](https://github.com/netbox-community/netbox/releases/tag/v4.0.0) (⚠️Breaking Changes!)

## 3.7.8

- [netbox 3.7.8](https://github.com/netbox-community/netbox/releases/tag/v3.7.8)

## 3.7.7

- [netbox 3.7.7](https://github.com/netbox-community/netbox/releases/tag/v3.7.7)

## 3.7.6

- [netbox 3.7.6](https://github.com/netbox-community/netbox/releases/tag/v3.7.6)

## 3.7.5

- [netbox 3.7.5](https://github.com/netbox-community/netbox/releases/tag/v3.7.5)

## 3.7.4

- [netbox 3.7.4](https://github.com/netbox-community/netbox/releases/tag/v3.7.4)

## 3.7.3

- [netbox 3.7.3](https://github.com/netbox-community/netbox/releases/tag/v3.7.3)
- Base image updated to Debian 12
- PostgreSQL 13 updated to 15. The database migration can take some time on the first add-on start.
- Improved startup time
  - Netbox database migrations are only run, when needed.
  - First Housekeeping background job run is delayed for 5 minutes.
- A lot of internal code optimizations.

## 3.7.2

- [netbox 3.7.2](https://github.com/netbox-community/netbox/releases/tag/v3.7.2)
- ⚠️ Starting with this release, custom Netbox configurations (e.g. for plugins) must be placed in `addon_configs/0da538cf_netbox`. Support for the old location `config/netbox` will be removed soon.
- New debug option added.

## 3.7.1

- [netbox 3.7.1](https://github.com/netbox-community/netbox/releases/tag/v3.7.1)

## 3.7.0

- [netbox 3.7.0](https://github.com/netbox-community/netbox/releases/tag/v3.7.0)

## 3.6.9

- [netbox 3.6.9](https://github.com/netbox-community/netbox/releases/tag/v3.6.9)

## 3.6.8

- [netbox 3.6.8](https://github.com/netbox-community/netbox/releases/tag/v3.6.8)

## 3.6.7

- [netbox 3.6.7](https://github.com/netbox-community/netbox/releases/tag/v3.6.7)

## 3.6.6

- [netbox 3.6.6](https://github.com/netbox-community/netbox/releases/tag/v3.6.6)

## 3.6.5

- [netbox 3.6.5](https://github.com/netbox-community/netbox/releases/tag/v3.6.5)

## 3.6.4

- [netbox 3.6.4](https://github.com/netbox-community/netbox/releases/tag/v3.6.4)

## 3.6.3

- [netbox 3.6.3](https://github.com/netbox-community/netbox/releases/tag/v3.6.3)

## 3.6.2

- [netbox 3.6.2](https://github.com/netbox-community/netbox/releases/tag/v3.6.2)

## 3.6.1

- [netbox 3.6.1](https://github.com/netbox-community/netbox/releases/tag/v3.6.1)

## 3.6.0

- [netbox 3.6.0](https://github.com/netbox-community/netbox/releases/tag/v3.6.0)

## 3.5.9

- [netbox 3.5.9](https://github.com/netbox-community/netbox/releases/tag/v3.5.9)

## 3.5.8

- [netbox 3.5.8](https://github.com/netbox-community/netbox/releases/tag/v3.5.8)

## 3.5.7

- [netbox 3.5.7](https://github.com/netbox-community/netbox/releases/tag/v3.5.7)

## 3.5.6

- [netbox 3.5.6](https://github.com/netbox-community/netbox/releases/tag/v3.5.6)

## 3.5.4

- [netbox 3.5.4](https://github.com/netbox-community/netbox/releases/tag/v3.5.4)

## 3.5.3

- [netbox 3.5.3](https://github.com/netbox-community/netbox/releases/tag/v3.5.3)
- Better process control with supervisord
- Improved error handling

## 3.5.2

- [netbox 3.5.2](https://github.com/netbox-community/netbox/releases/tag/v3.5.2)

## 3.5.1.1

- [new option: `LOGIN_REQUIRED`](https://github.com/casperklein/homeassistant-addons/blob/master/netbox/README.md#option-login_required)

## 3.5.1

- [netbox 3.5.1](https://github.com/netbox-community/netbox/releases/tag/v3.5.1)

## 3.5.0

- [netbox 3.5.0](https://github.com/netbox-community/netbox/releases/tag/v3.5.0)

## 3.4.10

- [netbox 3.4.10](https://github.com/netbox-community/netbox/releases/tag/v3.4.10)

## 3.4.9

- [netbox 3.4.9](https://github.com/netbox-community/netbox/releases/tag/v3.4.9)

## 3.4.8

- [netbox 3.4.8](https://github.com/netbox-community/netbox/releases/tag/v3.4.8)

## 3.4.7

- [netbox 3.4.7](https://github.com/netbox-community/netbox/releases/tag/v3.4.7)

## 3.4.6

- [netbox 3.4.6](https://github.com/netbox-community/netbox/releases/tag/v3.4.6)

## 3.4.5.1

- Bugfix: Make media files persistant ([#11](https://github.com/casperklein/homeassistant-addons/issues/11))

## 3.4.5

- [netbox 3.4.5](https://github.com/netbox-community/netbox/releases/tag/v3.4.5)

## 3.4.4

- [netbox 3.4.4](https://github.com/netbox-community/netbox/releases/tag/v3.4.4)

## 3.4.3

- [netbox 3.4.3](https://github.com/netbox-community/netbox/releases/tag/v3.4.3)

## 3.4.2

- [netbox 3.4.2](https://github.com/netbox-community/netbox/releases/tag/v3.4.2)
- UX: Username and password configuration is now optional ([#9](https://github.com/casperklein/homeassistant-addons/pull/9))

## 3.4.1

- [netbox 3.4.1](https://github.com/netbox-community/netbox/releases/tag/v3.4.1)

## 3.4.0

- [netbox 3.4.0](https://github.com/netbox-community/netbox/releases/tag/v3.4.0)

## 3.3.10

- [netbox 3.3.10](https://github.com/netbox-community/netbox/releases/tag/v3.3.10)

## 3.3.9

- [netbox 3.3.9](https://github.com/netbox-community/netbox/releases/tag/v3.3.9)
- Bind mount "media" and "share" directories ([b70aab3](https://github.com/casperklein/homeassistant-addons/commit/b70aab399019939c5831958b2a530f1b1346062e))

## 3.3.8

- [netbox 3.3.8](https://github.com/netbox-community/netbox/releases/tag/v3.3.8)
- [Plugin support added](https://github.com/casperklein/homeassistant-addons/tree/master/netbox#plugins)

## 3.3.7

- [netbox 3.3.7](https://github.com/netbox-community/netbox/releases/tag/v3.3.7)

## 3.3.6

- [netbox 3.3.6](https://github.com/netbox-community/netbox/releases/tag/v3.3.6)

## 3.3.5

- [netbox 3.3.5](https://github.com/netbox-community/netbox/releases/tag/v3.3.5)

## 3.3.4

- [netbox 3.3.4](https://github.com/netbox-community/netbox/releases/tag/v3.3.4)

## 3.3.3

- [netbox 3.3.3](https://github.com/netbox-community/netbox/releases/tag/v3.3.3)

## 3.3.2

- [netbox 3.3.2](https://github.com/netbox-community/netbox/releases/tag/v3.3.2)

## 3.3.1

- [netbox 3.3.1](https://github.com/netbox-community/netbox/releases/tag/v3.3.1)

## 3.3.0

- [netbox 3.3.0](https://github.com/netbox-community/netbox/releases/tag/v3.3.0)

## 3.2.9

- [netbox 3.2.9](https://github.com/netbox-community/netbox/releases/tag/v3.2.9)

## 3.2.8

- [netbox 3.2.8](https://github.com/netbox-community/netbox/releases/tag/v3.2.8)

## 3.2.7

- [netbox 3.2.7](https://github.com/netbox-community/netbox/releases/tag/v3.2.7)

## 3.2.6

- [netbox 3.2.6](https://github.com/netbox-community/netbox/releases/tag/v3.2.6)

## 3.2.5

- [netbox 3.2.5](https://github.com/netbox-community/netbox/releases/tag/v3.2.5)

## 3.2.4

- [netbox 3.2.4](https://github.com/netbox-community/netbox/releases/tag/v3.2.4)

## 3.2.3

- [netbox 3.2.3](https://github.com/netbox-community/netbox/releases/tag/v3.2.3)

## 3.2.2

- [netbox 3.2.2](https://github.com/netbox-community/netbox/releases/tag/v3.2.2)

## 3.2.1

- [netbox 3.2.1](https://github.com/netbox-community/netbox/releases/tag/v3.2.1)

## 3.2.0

- [netbox 3.2.0](https://github.com/netbox-community/netbox/releases/tag/v3.2.0)

## 3.1.11

- [netbox 3.1.11](https://github.com/netbox-community/netbox/releases/tag/v3.1.11)

## 3.1.10

- [netbox 3.1.10](https://github.com/netbox-community/netbox/releases/tag/v3.1.10)

## 3.1.9

- [netbox 3.1.9](https://github.com/netbox-community/netbox/releases/tag/v3.1.9)

## 3.1.8

- [netbox 3.1.8](https://github.com/netbox-community/netbox/releases/tag/v3.1.8)

## 3.1.7

- [netbox 3.1.7](https://github.com/netbox-community/netbox/releases/tag/v3.1.7)

## 3.1.6

- [netbox 3.1.6](https://github.com/netbox-community/netbox/releases/tag/v3.1.6)

## 3.1.5

- [netbox 3.1.5](https://github.com/netbox-community/netbox/releases/tag/v3.1.5)

## 3.1.4

- [netbox 3.1.4](https://github.com/netbox-community/netbox/releases/tag/v3.1.4)

## 3.1.3

- [netbox 3.1.3](https://github.com/netbox-community/netbox/releases/tag/v3.1.3)

## 3.1.2

- [netbox 3.1.2](https://github.com/netbox-community/netbox/releases/tag/v3.1.2)

## 3.1.1

- [netbox 3.1.1](https://github.com/netbox-community/netbox/releases/tag/v3.1.1)

## 3.1.0

- [netbox 3.1.0](https://github.com/netbox-community/netbox/releases/tag/v3.1.0)

## 3.0.12

- [netbox 3.0.12](https://github.com/netbox-community/netbox/releases/tag/v3.0.12)

## 3.0.11

- [netbox 3.0.11](https://github.com/netbox-community/netbox/releases/tag/v3.0.11)

## 3.0.10

- [netbox 3.0.10](https://github.com/netbox-community/netbox/releases/tag/v3.0.10)

## 3.0.9

- [netbox 3.0.9](https://github.com/netbox-community/netbox/releases/tag/v3.0.9)

## 3.0.8

- [netbox 3.0.8](https://github.com/netbox-community/netbox/releases/tag/v3.0.8)

## 3.0.7

- [netbox 3.0.7](https://github.com/netbox-community/netbox/releases/tag/v3.0.7)

## 3.0.6

- [netbox 3.0.6](https://github.com/netbox-community/netbox/releases/tag/v3.0.6)

## 3.0.5

- [netbox 3.0.5](https://github.com/netbox-community/netbox/releases/tag/v3.0.5)

## 3.0.4

- [netbox 3.0.4](https://github.com/netbox-community/netbox/releases/tag/v3.0.4)

## 3.0.3

- [netbox 3.0.3](https://github.com/netbox-community/netbox/releases/tag/v3.0.3)

## 3.0.2

This is a major release update. It might be worth, reading the changelogs :wink:

- [netbox 3.0.2](https://github.com/netbox-community/netbox/releases/tag/v3.0.2)
- [netbox 3.0.1](https://github.com/netbox-community/netbox/releases/tag/v3.0.1)
- **[netbox 3.0.0](https://github.com/netbox-community/netbox/releases/tag/v3.0.0)**

## 2.11.13

- Base image upgraded to Debian 11 (PostgreSQL 11 --> 13, Redis 5.0.3 --> 6.0.5)
- This and future releases migrates the netbox DB from PostgreSQL 11 to 13.
- Make sure, to make a backup/snapshot of this add-on before you update.

## 2.11.12

- [netbox 2.11.12](https://github.com/netbox-community/netbox/releases/tag/v2.11.12)
- Error handling for superuser creation improved

## 2.11.11

- [netbox 2.11.11](https://github.com/netbox-community/netbox/releases/tag/v2.11.11)

## 2.11.10

- [netbox 2.11.10](https://github.com/netbox-community/netbox/releases/tag/v2.11.10)

## 2.11.9

- [netbox 2.11.9](https://github.com/netbox-community/netbox/releases/tag/v2.11.9)

## 2.11.8

- [netbox 2.11.8](https://github.com/netbox-community/netbox/releases/tag/v2.11.8)

## 2.11.7

- [netbox 2.11.7](https://github.com/netbox-community/netbox/releases/tag/v2.11.7)

## 2.11.6

- [netbox 2.11.6](https://github.com/netbox-community/netbox/releases/tag/v2.11.6)

## 2.11.4

- [netbox 2.11.4](https://github.com/netbox-community/netbox/releases/tag/v2.11.4)

## 2.11.3

- [netbox 2.11.3](https://github.com/netbox-community/netbox/releases/tag/v2.11.3)

## 2.11.2

- [netbox 2.11.2](https://github.com/netbox-community/netbox/releases/tag/v2.11.2)

## 2.11.1

- [netbox 2.11.1](https://github.com/netbox-community/netbox/releases/tag/v2.11.1)

## 2.11.0

- [netbox 2.11.0](https://github.com/netbox-community/netbox/releases/tag/v2.11.0)

## 2.10.10

- [netbox 2.10.10](https://github.com/netbox-community/netbox/releases/tag/v2.10.10)

## 2.10.9

- [netbox 2.10.9](https://github.com/netbox-community/netbox/releases/tag/v2.10.9)

## 2.10.8

- [netbox 2.10.8](https://github.com/netbox-community/netbox/releases/tag/v2.10.8)

## 2.10.7

- [netbox 2.10.7](https://github.com/netbox-community/netbox/releases/tag/v2.10.7)

## 2.10.6

- [netbox 2.10.6](https://github.com/netbox-community/netbox/releases/tag/v2.10.6)

## 2.10.5

- [netbox 2.10.5](https://github.com/netbox-community/netbox/releases/tag/v2.10.5)

## 2.10.4.1

- PostgreSQL can now be exposed to the network
- HTTPS options added

## 2.10.4

- [netbox 2.10.4](https://github.com/netbox-community/netbox/releases/tag/v2.10.4)

## 2.10.3.1

- [netbox 2.10.3](https://github.com/netbox-community/netbox/releases/tag/v2.10.3)

## 2.10.3

- [netbox 2.10.1](https://github.com/netbox-community/netbox/releases/tag/v2.10.1)

## 2.10.2

- fix permissions after snapshot restore

## 2.10.1

- maintenance release

## 2.10.0

- [netbox 2.10.0](https://github.com/netbox-community/netbox/releases/tag/v2.10.0)

## 2.9.11

- [netbox 2.9.11](https://github.com/netbox-community/netbox/releases/tag/v2.9.11)

## 2.9.10

- [netbox 2.9.10](https://github.com/netbox-community/netbox/releases/tag/v2.9.10)

## 2.9.7

- [netbox 2.9.7](https://github.com/netbox-community/netbox/releases/tag/v2.9.7)

## 2.9.6

- [netbox 2.9.6](https://github.com/netbox-community/netbox/releases/tag/v2.9.6)

## 2.9.1

- [netbox 2.9.1](https://github.com/netbox-community/netbox/releases/tag/v2.9.1)

## 2.8.7

- [netbox 2.8.7](https://github.com/netbox-community/netbox/releases/tag/v2.8.7)
- version bug fixed

## 2.8.6

- [netbox 2.8.6](https://github.com/netbox-community/netbox/releases/tag/v2.8.6)

## 2.8.5

- [netbox 2.8.5](https://github.com/netbox-community/netbox/releases/tag/v2.8.5)
- labels added

## 2.8.4

- rebrand from hassio-netbox to homeassistant-netbox
- netbox 2.8.4

## 2.7.12

- netbox 2.7.12

## 2.7.4

- new Redis configuration
- netbox 2.7.4

## 2.7.3

- netbox 2.7.3

## 2.6.12

- netbox 2.6.12

## 2.6.6

- image size improved
- netbox 2.6.6

## 2.6.5

- netbox 2.6.5

## 2.6.3

- initial release
