defmodule Mix.Tasks.Auth.Digest do
  use Mix.Task
  alias FiveHundo.Auth

  def run([password]) do
    Mix.Shell.IO.info "Creating encrypted key..."

    digest = password
    |> Auth.encrypt

    Mix.Shell.IO.info "\n" <> digest <> "\n"

    Mix.Shell.IO.info """
    Complete jibberish. Nice!

    If this is just for development, place in config/dev.exs like so:

    config :five_hundo,
      password_digest: "#{digest}"

    If it's for production, place it in config/prod.secret.exs the same way.
    """
  end

  def run(_) do
    Mix.Shell.IO.info """
    You didn't supply a password to encrypt, or passed too many arguments.

    Run like this:
    mix auth.digest my_super_secure_password
    """
  end
end
