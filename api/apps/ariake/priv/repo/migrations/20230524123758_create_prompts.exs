defmodule Ariake.Repo.Migrations.CreatePrompts do
  use Ecto.Migration
  import Ecto.SoftDelete.Migration

  def up do
    create table(:prompts) do
      add :template, :text
      add :variables, :map

      timestamps()
      soft_delete_columns()
    end
  end

  def down do
    drop table(:prompts)
  end
end
