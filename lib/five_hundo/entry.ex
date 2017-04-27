defmodule FiveHundo.Entry do
  use Ecto.Schema
  import Ecto.{Changeset, Query}
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

  def create!(params) do
    params
    |> create
    |> elem(1)
  end

  def get_or_create_todays do
    today = DateTime.current_working_day()
    today
    |> get_by
    |> case do
      nil   -> create!(today)
      entry -> entry
    end
  end

  def get_by(params) do
    __MODULE__
    |> Repo.get_by(params |> Map.to_list)
  end

  def delete_all do
    __MODULE__
    |> Repo.delete_all
  end

  def count do
    (from e in __MODULE__, select: count("*"))
    |> Repo.one
  end

end
