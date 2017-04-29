use Mix.Config

config :five_hundo,
  timezone: "America/New_York",
  cutoff_time: {5, 0, :AM}

config :five_hundo,
  ecto_repos: [FiveHundo.Repo]

config :five_hundo, FiveHundo.Web.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "ndCyM9pF6weCp0Q1KJ+UEN7q3T+zs5zrKIlDJSB5lC3ZQCD7W+My6S2wigcf0hb5",
  render_errors: [view: FiveHundo.Web.ErrorView, accepts: ~w(html json)],
  pubsub: [name: FiveHundo.PubSub,
           adapter: Phoenix.PubSub.PG2]

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :guardian, Guardian,
  issuer: "Genie",
  ttl: {30, :days},
  secret_key: "qqUynzWxnE7KG4as8Q3oZXJYD8tCfKzDBQJJKW/kZoE9l421pJsIvI340+fKEXW7",
  serializer: Genie.GuardianSerializer

import_config "#{Mix.env}.exs"
