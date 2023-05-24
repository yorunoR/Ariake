defmodule Ariake.Repo.Migrations.CreateCommands do
  use Ecto.Migration
  import Ecto.SoftDelete.Migration

  def up do
    create table(:commands) do
      add :name, :string, null: false
      add :arity, :integer, null: false
      add :description, :text
      add :active, :boolean, null: false, default: true
      add :category_id, references(:categories, on_delete: :nothing)

      timestamps()
      soft_delete_columns()
    end

    create index(:commands, [:category_id])
  end

  def down do
    drop table(:commands)
  end
end
