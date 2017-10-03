# DBus API Service

An application to get user attributes and groups via the DBus API

## Installation

```sh
git clone git@github.com:ManageIQ/dbus_api_service.git
cd dbus_api_service
```

## Usage

Run the service:

```sh
bin/dbus_api_service
```

## Entrypoints

- `GET /api/user_attrs/:user_id?attributes=x,y`

  Fetches the attributes of the specified user.  If specific attributes are specified,
  then only those will be returned.  By default, only the following attributes are
  returned:

  - mail
  - givenname
  - sn
  - displayname
  - domainname

- `GET /api/user_groups/:user_id`

  Fetches the groups of the specified user.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
