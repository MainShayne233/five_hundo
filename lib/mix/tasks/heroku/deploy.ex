defmodule Mix.Tasks.Heroku.Deploy do use Mix.Task

  def run([app_name, password]) do
    checkout_heroku()
    db_secret = new_db_secret()
    create_prod_secret(db_secret, password)
    new_gitignore()
    commit_secrets()
    setup_heroku(app_name, db_secret)
    checkout_master()
    print_conclusion_message(app_name)
  end

  def run(_) do
    Mix.Shell.IO.info """
    You must supply an app_name and a password.

    Example:

    mix heroku.deploy my_app_name my_password
    """
  end

  def checkout_heroku do
    Mix.Shell.IO.cmd "git add -A"
    Mix.Shell.IO.cmd "git commit -m \"changes prior to heroku deploy\""
    Mix.Shell.IO.cmd "git checkout -b heroku"
  end

  def new_db_secret do
    :crypto.strong_rand_bytes(64)
    |> Base.encode64
    |> binary_part(0, 64)
  end

  def create_prod_secret(secret_key, password) do
    file = """
     use Mix.Config

     config :five_hundo,
       password_digest: "#{password |> FiveHundo.Auth.encrypt}"
       # create with mix auth.digest your_password

     config :five_hundo, FiveHundo.Web.Endpoint,
       secret_key_base: "#{secret_key}"
       # create with mix phx.gen.secret

     config :five_hundo, FiveHundo.Repo,
       adapter: Ecto.Adapters.Postgres,
       url: System.get_env("DATABASE_URL"), # leave this as is
       username: System.get_env("DATABASE_USERNAME"), # leave this as is
       password: System.get_env("DATABASE_PASSWORD"), # leave this as is
       database: "five_hundo_prod",
       pool_size: 5
    """
    File.write("config/prod.secret.exs", file)
  end

  def new_gitignore do
    file = File.read!(".gitignore")
    |> String.split("\n")
    |> Enum.reject(&( &1 |> String.contains?("secret") ))
    |> Enum.join("\n")

    File.write(".gitignore", file)
  end

  def commit_secrets do
    [
      "git add config/prod.secret.exs",
      "git commit -m \"adds prod.secret.exs\" "
    ]
    |> Enum.each(&Mix.Shell.IO.cmd/1)
  end


  def setup_heroku(app_name, secret_key) do
    [
      "heroku create #{app_name}",
      "heroku buildpacks:set https://github.com/HashNuke/heroku-buildpack-elixir",
      "heroku buildpacks:add https://github.com/MainShayne233/heroku-buildpack-phoenix-static",
      "heroku addons:create heroku-postgresql:hobby-dev",
      "heroku config:set SECRET_KEY_BASE=#{secret_key}",
      "git push heroku heroku:master",
      "heroku run mix ecto.migrate",
    ]
    |> Enum.each(&Mix.Shell.IO.cmd/1)
  end

  def checkout_master do
    [
      "git stash",
      "git checkout master",
      "git add -A",
      "git reset --hard",
    ]
    |> Enum.each(&Mix.Shell.IO.cmd/1)
  end

  def print_conclusion_message(app_name) do
  Mix.Shell.IO.info """
  You did it! Nice!

  You can visit your app at http://#{app_name}.herokuapp.com

  Enjoy!
  """
  end
end
