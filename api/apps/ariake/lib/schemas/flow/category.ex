defmodule Schemas.Flow.Category do
  use Ariake.Schema
  import Ecto.SoftDelete.Schema

  alias Schemas.Flow.Command
  alias Schemas.Flow.DerivedCommand

  schema "categories" do
    field :name, :string
    field :description, :string

    timestamps()
    soft_delete_schema()

    has_many :commands, Command, on_delete: :delete_all
    has_many :derived_commands, DerivedCommand, on_delete: :delete_all
  end
end
