Ssherminator
============

This small spike is meant as a quick and dirty demonstration on how
you could use Elixir to concurrently connect with a bunch of ssh
devices and execute a command.

With the default settings, 5000 ssh servers and 5000 clients will be
started (one client per server).

This spike is extremely basic in that it ignores a lot of error
scenarios. For instance, timeouts are infinite, and thus the
controller will never terminate if any of the ssh client processes
never send an `:ok` message back.

Running
=======

clone the repo and run`ERL_MAX_ETS_TABLES=20000 iex -S mix` inside it,
which should compile it and give you an Elixir shell. The
`ERL_MAX_ETS_TABLES=20000` is required because either the ssh clients
or servers make heavy use of ETS tables. You might also need to
increase your file limits (`ulimit -n xxxxx`).

After entering the Elixir shell, you should be able to start the spike
by calling `Ssherminator.go`.

```elixir
lhc@georgia ~/dev/ssherminator (master *+) $ ERL_MAX_ETS_TABLES=20000 iex -S mix
Erlang/OTP 17 [erts-6.4] [source] [64-bit] [smp:4:4] [async-threads:10] [hipe] [kernel-poll:false]

Interactive Elixir (1.0.4) - press Ctrl+C to exit (type h() ENTER for help)
iex(1)> Ssherminator.go

20:33:26.065 [info]  5000 devices ok
#PID<0.15097.0>
iex(2)>
20:33:26.113 [info]  Waiting for 5000 devices to report back

20:33:33.341 [warn]  Logger dropped 1026 OTP/SASL messages as it exceeded the amount of 500 messages/second

20:33:38.797 [warn]  Logger dropped 8737 OTP/SASL messages as it exceeded the amount of 500 messages/second

20:34:18.618 [info]  Received results in: 52.476214
```

On my core i7 laptop, the entire thing takes about 53 seconds
(excluding starting the ssh servers).

Running the spike peaks at about *5.7GB* of memory, but drastically
drops back down to about a 100MB after a while. I suppose it might
have something to do with the ssh connection handshakes. It would be
interesting to run the servers on a separate machine to see if the
memory usage is server side or client side.
