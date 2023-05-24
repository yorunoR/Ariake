defmodule Ariake.Repo.Migrations.CreateDerivedCommands do
  use Ecto.Migration
  import Ecto.SoftDelete.Migration

  def up do
    create table(:derived_commands) do
      add :value, :string
      add :category_id, references(:categories, on_delete: :nothing)
      add :command_id, references(:commands, on_delete: :nothing)
      add :embedding, :vector, size: 1536

      timestamps()
      soft_delete_columns()
    end

    create index(:derived_commands, [:category_id])
    create index(:derived_commands, [:command_id])
  end

  def down do
    drop table(:derived_commands)
  end
end
