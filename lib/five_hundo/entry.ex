defmodule FiveHundo.Entry do
  use Ecto.Schema
  import Ecto.{Changeset, Query}
  alias FiveHundo.{
    DateTime,
    Repo,
    Word,
  }

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


  def all do
    __MODULE__
    |> Repo.all
  end


  def todays_entry do
    get_or_create_todays()
    |> Map.get(:text)
  end


  def update_todays_text(text) do
    get_or_create_todays()
    |> __MODULE__.update(%{
      text: text,
      word_count: Word.count(text),
    })
  end


  def breakdown_and_index do
    week = DateTime.current_week()

    breakdown =
      week
      |> Enum.map(&get_by/1)
      |> Enum.map(&entry_grade/1)

    index =
      week
      |> Enum.find_index(fn day -> 
        day == DateTime.current_working_day() 
      end)

    {breakdown, index}
  end


  defp entry_grade(nil), do: "gutter"
  defp entry_grade(%__MODULE__{word_count: nil}), do: "gutter"
  defp entry_grade(%__MODULE__{word_count: word_count}) do
    if word_count < word_count_goal() do
      "spare"
    else
      "strike"
    end
  end


  def create(params) do
    %__MODULE__{}
    |> changeset(params)
    |> Repo.insert
  end


  def update(entry, params) do
    entry
    |> changeset(params)
    |> Repo.update
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


  def word_count_goal do
    :five_hundo
    |> Application.get_env(:word_count_goal)
  end
end
