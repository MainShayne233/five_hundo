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
    |> Kernel.||("")
  end


  def update_todays_text(text) do
    get_or_create_todays()
    |> __MODULE__.update(%{
      text: text,
      word_count: Word.count(text),
    })
  end


  def breakdown(
    breakdown \\ [],
    days \\ DateTime.current_week(),
    current_day  \\ DateTime.current_working_day(),
    current_state \\ "past")
  def breakdown(breakdown, [], _current_day, _current_state), do: breakdown
  def breakdown(breakdown, [day | rest], current_day, _current_state) when day == current_day do
    grade = day |> get_by |> entry_grade
    breakdown
    |> Enum.concat([%{grade: grade, status: "present"}])
    |> breakdown(rest, current_day, "future")
  end
  def breakdown(breakdown, [day | rest], current_day, current_state) do
    grade = day |> get_by |> entry_grade
    breakdown
    |> Enum.concat([%{grade: grade, status: current_state}])
    |> breakdown(rest, current_day, current_state)
  end


  defp entry_grade(nil), do: "gutter"
  defp entry_grade(%__MODULE__{word_count: 0}), do: "gutter"
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
