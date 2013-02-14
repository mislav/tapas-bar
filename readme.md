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

You can now run the webapp and should see the episodes.

## Bonus points: Pow

```
bundle install
ln -s $PWD ~/.pow/rubytapas
```

Find your IP on the local network:

```
ifconfig -a | grep 'inet ' | grep broadcast | awk '{ print $2 }'
```

Watch http://rubytapas.YOUR-IP.xip.io from any device on your network.
