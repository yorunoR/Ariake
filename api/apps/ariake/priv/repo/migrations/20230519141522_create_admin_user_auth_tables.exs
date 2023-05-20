defmodule Ariake.Repo.Migrations.CreateAdminUserAuthTables do
  use Ecto.Migration

  def change do
    execute "CREATE EXTENSION IF NOT EXISTS citext", ""

    create table(:admin_user) do
      add :email, :citext, null: false
      add :hashed_password, :string, null: false
      add :confirmed_at, :naive_datetime
      timestamps()
    end

    create unique_index(:admin_user, [:email])

    create table(:admin_user_tokens) do
      add :admin_user_id, references(:admin_user, on_delete: :delete_all), null: false
      add :token, :binary, null: false
      add :context, :string, null: false
      add :sent_to, :string
      timestamps(updated_at: false)
    end

    create index(:admin_user_tokens, [:admin_user_id])
    create unique_index(:admin_user_tokens, [:context, :token])
  end
end
