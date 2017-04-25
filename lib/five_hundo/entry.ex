defmodule FiveHundo.Entry do
  use Ecto.Schema
  import Ecto.Changeset
  alias FiveHundo.{DateTime, Repo}

  schema "entries" do
    field :text, :string
    field :word_count, :integer
    field :year, :integer
    field :month, :integer
    field :day, :integer

    timestamps()
  end

  @fields [
    :text,
    :word_count,
    :year,
    :month,
    :day,
    :hours,
    :minutes,
    :seconds,
    :meridiem,
  ]

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @fields)
  end

  def create(params) do
    %__MODULE__{}
    |> changeset(params)
    |> Repo.insert
  end

  def get_or_create_todays do
    today = DateTime.today()
  end

  def delete_all do
    __MODULE__
    |> Repo.delete_all
  end

end
