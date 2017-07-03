# FiveHundo

A [750words.com](http://750words.com) clone for personal use, and maybe yours?

Demo: http://fivehundo.herokuapp.com (password is `five_hundo`)

Exquisite art was created with [make 8-bit art](https://make8bitart.com/)

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

Then init the app:
```bash
mix deps.get # elixir fetch dependencies
mix assets.install # fetch node/elm dependencies
mix ecto.create # create your database

# one liner
mix do deps.get, assets.install, ecto.create
```

Then create your password digest for development and/or production.

(default dev password is `five_hundo`)
```bash
mix auth.digest your_super_secure_password
```

and place it in `config/dev.exs` for development and/or `config/prod.secret.exs`
for production, like so:

```elixir
config :five_hundo,
  password_digest: "crazy_long_key_of_jibberish"
```

Then start the server
```bash
mix phx.server
```

Then visit [localhost:4000](http://localhost:4000)

Note: This app is a Phoenix 1.3 app, and Phoenix 1.3 uses `phx` instead of `phoenix` for mix tasks.
`phoenix` should still work, but I recommend you [install Phoenix 1.3](https://github.com/phoenixframework/phoenix/blob/master/installer/README.md)

## Deploy to Heroku

There is a handy mix task for deploying to Heroku.

Make sure you have [Heroku installed](https://devcenter.heroku.com/articles/heroku-cli) and all set up.

Then run the mix task with the Heroku app name you want, and password for the app:
```bash
mix deps.get # if you haven't already
mix heroku.deploy my-app-name my_password
```

Note: This procedure automatically does everything in a git branch called `heroku`,
and then checks back out to `master`
