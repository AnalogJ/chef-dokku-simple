# chef-dokku-simple cookbook

[Dokku](https://github.com/progrium/dokku) is simple software. It
should have a simple cookbook.

This cookbook just runs dokku's default
[bootstrap script](https://github.com/progrium/dokku/blob/master/bootstrap.sh),
and installs your ssh keys for access to dokku. If you need more
power, you should check out
[chef-dokku](https://github.com/fgrehm/chef-dokku).

## Attributes

Attribute | Description | Type | Default
----------|-------------|------|--------
`[:dokku][:tag]` | git tag to install | String | `v0.2.2`
`[:dokku][:root]` | home dir for dokku | String | `/home/dokku`
`[:dokku][:ssh_keys]` | hash of usernames - ssh key pairs | Hash | {}
`[:dokku][:vhost]` | domain for virtual hosting | String | nil
`[:dokku][:apps]` | hash of apps to configure with env vars | Hash | {}
`[:dokku][:plugins]` | hash of plugin `name: repo url` to install | Hash | {}

## Domain

You will need to setup a wildcard domain pointing to your host (unless
you want each app on a different port). Unless `dig +short $(hostname -f)`
gives the correct answer, you need to configure with `[:dokku][:vhost]`.

## Environment variables

To pre-configure environment for an application, add to the `apps`
attribute as shown below in Usage.

## Usage

Just include `dokku-simple` in your node's `run_list`:

```json
{
  "dokku": {
    "tag": "v0.2.2",
    "root": "/home/dokku",
    "ssh_keys": {
                  'awesome_user' => 'awesome_users_pubkey',
                  'superb_user' => 'superb_users_pubkey'
                },
    "vhost": "dokku.me",
    "apps": {
      "my_app": {
        "env": { "TOKEN": "123" }
      }
    }
  },

  "run_list": [
    "recipe[dokku-simple]"
  ]
}
```

## Plugins

To install [dokku plugins](https://github.com/progrium/dokku/wiki/Plugins) use
the `dokku-simple::plugins` recipe:

```json
{
  "dokku": {
    "plugins": {
      "postgresql": "https://github.com/Kloadut/dokku-pg-plugin"
    }
  },

  "run_list": [
    "recipe[dokku-simple]",
    "recipe[dokku-simple::plugins]"
  ]
}
```
