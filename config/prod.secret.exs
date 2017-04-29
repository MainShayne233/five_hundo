 use Mix.Config
 
 config :five_hundo,
   password_digest: "$2b$12$83opuVO95WcMfm8LDz8AAuHc4MjgqMGP6EyE/v.31o9sZjLjchg82"
   # create with mix auth.digest your_password
 
 config :five_hundo, FiveHundo.Web.Endpoint,
   secret_key_base: "K2+IxCvHXbuoUYtlxEhaV0xovhOxRvvg05IT+3Fl0JhudyKwARKbRMgvyjoA2+4o"
   # create with mix phx.gen.secret
 
 config :five_hundo, FiveHundo.Repo,
   adapter: Ecto.Adapters.Postgres,
   url: System.get_env("DATABASE_URL"), # leave this as is
   username: System.get_env("DATABASE_USERNAME"), # leave this as is
   password: System.get_env("DATABASE_PASSWORD"), # leave this as is
   database: "five_hundo_prod",
   pool_size: 5
