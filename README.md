# FiveHundo

A [750words.com](http://750words.com) clone for personal use, and maybe yours?

## Use
Clone this repo and enter the app's directory
```bash
git clone https://www.github.com/MainShayne233/five_hundo.git
cd five_hundo
```
Then set your timezone and preferred cuttoff time (the time the app will consider the end of the day) in `config/config.exs`
```elixir
config :five_hundo,
  timezone: "America/New_York",
  cutoff_time: {1, 30, :AM}
```

Then start the app itself:
```bash
mix deps.get # elixir fetch dependencies
mix assets.install # fetch node/elm dependencies
mix ecto.create # create your database
mix phx.server # start the server

# one liner
mix do deps.get, assets.install, ecto.create, phx.server
```

Then visit [localhost:4000](http://localhost:4000)

Note: This app is a Phoenix 1.3 app, and Phoenix 1.3 uses `phx` instead of `phoenix` for mix tasks.
`phoenix` should still work, but I recommend you [install Phoenix 1.3](https://github.com/phoenixframework/phoenix/blob/master/installer/README.md)
