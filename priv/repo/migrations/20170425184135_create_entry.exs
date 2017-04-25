defmodule FiveHundo.Repo.Migrations.CreateEntry do
  use Ecto.Migration

  def change do
    create table(:entries) do
      add :text, :text
      add :word_count, :integer
      add :year, :integer
      add :month, :integer
      add :day, :integer

      timestamps()
    end

  end
end
