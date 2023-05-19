defmodule Ariake.Repo.Migrations.CreateUsers do
  use Ecto.Migration
  import Ecto.SoftDelete.Migration

  def up do
    create table(:users) do
      add :activated, :boolean, null: false, default: false
      add :email, :string
      add :name, :string, null: false
      add :profile_image, :string
      add :role, :integer, null: false, default: 0
      add :uid, :string
      add :anonymous, :boolean, null: false, default: false

      timestamps()
      soft_delete_columns()
    end

    create index(:users, [:email], unique: true, where: "deleted_at IS NULL")
    create index(:users, [:uid], unique: true, where: "deleted_at IS NULL")
  end

  def down do
    drop table(:users)
  end
end
