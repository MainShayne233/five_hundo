# FiveHundo

A [750words.com](http://750words.com) clone for personal use, and maybe yours?

Demo: http://fivehundo.herokuapp.com (password is `five_hundo`)

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

First, create a new branch for your heroku deploys (so you don't push your secret keys to Github):

```bash
# create a branch for your heroku deploys
git checkout -b heroku
```

Then create your `./config/prod.secret.exs` file, which should look something like this:

```elixir
use Mix.Config

config :five_hundo,
  password_digest: "$2b$12$RaqGYrkw/6bgF/1.2v4j6uu86XdpvPfxLUP9NbJi/p3QiCnDFxPLu"
  # create with mix auth.digest your_password

config :five_hundo, FiveHundo.Web.Endpoint,
  secret_key_base: "WWLcNAWtGoO2OAiP72U5bR3zRIgC/ql2Tf0/0Ahg3eprIR4KOmKSWHCXVAEVX6wK"
  # create with mix phx.gen.secret

config :five_hundo, FiveHundo.Repo,
  adapter: Ecto.Adapters.Postgres,
  url: System.get_env("DATABASE_URL"), # leave this as is
  username: System.get_env("DATABASE_USERNAME"), # leave this as is
  password: System.get_env("DATABASE_PASSWORD"), # leave this as is
  database: "five_hundo_prod",
  pool_size: 5
```

Then remove `/config/*.secret.exs` from `./.gitignore`, and commit `./config/prod.secret.exs`

```bash
git add config/prod.secret.exs
git commit -m "adds db secret"
```

Then setup Heroku

```bash
# create app
heroku create your_app_name

# set buildpacks
heroku buildpacks:set https://github.com/HashNuke/heroku-buildpack-elixir
heroku buildpacks:add https://github.com/MainShayne233/heroku-buildpack-phoenix-static

# add postgres
heroku addons:create heroku-postgresql:hobby-dev

# set db secret key
heroku config:set SECRET_KEY_BASE="WWLcNAWtGoO2OAiP72U5bR3zRIgC/ql2Tf0/0Ahg3eprIR4KOmKSWHCXVAEVX6wK"
# the secret key from your ./config/prod.secret.exs

# make your first deploys
git push heroku heroku:master
```

Once it's done, you'll need to migrate the database:
```bash
heroku run mix ecto.migrate
```

Then visit your app at [your_app_name.herokuapp.com](https://your_app_name.herokuapp.com)

Note: I'd be happy to receive issues if these steps did not work for you.
In the mean time, the command `heroku logs --tail` is very useful in debugging
Heroku deploy issues
