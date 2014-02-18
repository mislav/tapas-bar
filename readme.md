# Tapas Bar

A [silly tiny webapp](http://up.mislav.net/Msvf) for watching RubyTapas that you
run locally. You need to be a RubyTapas subscriber.

Add your credentials to `~/.netrc`:

```
machine rubytapas.dpdcart.com
  login mislav@example.com
  password heytherelittlelarry
```

Now refresh:

```
NO_DOWNLOAD=1 ./refresh
```

The list of episodes will be downloaded and stored, but not media files.
In future you should run just `./refresh` to fetch new episodes + media.
If you want a copy of the media for all the back episodes,
then skip the step with `NO_DOWNLOAD=1`.

You can now run the webapp and should see the episodes, from the most recent to the oldest.

## Bonus points: use Pow on Mac

Install pow from http://pow.cx if you haven't already.

```
bundle install
ln -s $PWD ~/.pow/rubytapas
```

Find your IP on the local network:

```
ifconfig -a | grep 'inet ' | grep broadcast | awk '{ print $2 }'
```

Watch http://rubytapas.YOUR-IP.xip.io from any device on your network.

## Use rackup

```
bundle install --binstubs
bin/rackup
```

Find your IP on the local network:

```
ifconfig -a | grep 'inet ' | grep cast | awk '{ print $2 }'
```

Watch http://YOUR-IP:9292 from any device on your network.
