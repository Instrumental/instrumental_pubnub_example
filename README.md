An example Instrumental relay using data received via PubNub. Run via command line, `instrumental_pubnub_relay`.

Will receive messages from your PubNub channel and try to coerce them to Instrumental measurements. By default, each metric
will be prefixed by the hostname of the machine you are running the relay on. You can specify a different prefix via the `-p`
command.

Metrics will be suffixed with the index that they appear in if they are in a Hash or Array. That is to say, if your PubNub message looks like this:

```
{ "foo": 20.0, "baz": [10.0, 5.0] }
```

the metrics sent will look like this:

```
hostname.foo
hostname.baz.0
hostname.baz.1
```

## Command line usage

From help:
```sh
Usage: instrumental_pubnub_relay [options]
    -k, --pubnub-subscribe-key KEY   Your PubNub subscribe key
    -c, --pubnub-channel CHANNEL     Your PubNub channel
    -i API_KEY,                      Your Instrumental API key
        --instrumental-api-key
    -p, --key-prefix PREFIX          String to prefix all received metrics with (default: my.machine)
    -l, --log-level LEVEL            Log level for output, valid values are: ["debug", "warn", "info", "fatal"]
```
