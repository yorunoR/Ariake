defmodule Ariake.Repo.Migrations.CreateCategories do
  use Ecto.Migration
  import Ecto.SoftDelete.Migration

  def up do
    create table(:categories) do
      add :name, :string, null: false
      add :description, :text

      timestamps()
      soft_delete_columns()
    end
  end

  def down do
    drop table(:categories)
  end
end
