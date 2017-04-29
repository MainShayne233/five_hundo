defmodule FiveHundo.Auth do
  import Comeonin.Bcrypt, only: [checkpw: 2, dummy_checkpw: 0]

  def correct_password?(password) do
    password_digest()
    |> case do
      nil ->
        dummy_checkpw()
        false
      env_password_digest ->
        checkpw(password, env_password_digest)
    end
  end

  def encrypt(password) do
    password
    |> Comeonin.Bcrypt.hashpwsalt
  end

  def password_digest do
    :five_hundo
    |> Application.get_env(:password_digest)
  end
end
