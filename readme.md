# Tapas Bar

A silly tiny webapp for watching Ruby Tapas. You need to be a subscriber.

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

You can now run the webapp, for example via Pow:

```
bundle install
ln -s $PWD ~/.pow/rubytapas
```
