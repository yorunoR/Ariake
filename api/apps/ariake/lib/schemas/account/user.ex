defmodule Schemas.Account.User do
  use Ariake.Schema
  import Ecto.SoftDelete.Schema

  schema "users" do
    field :activated, :boolean
    field :email, :string
    field :name, :string
    field :profile_image, :string
    field :role, :integer
    field :uid, :string
    field :anonymous, :boolean

    timestamps()
    soft_delete_schema()
  end
end
