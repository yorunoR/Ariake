defmodule Schemas.Flow.Command do
  use Ariake.Schema
  import Ecto.SoftDelete.Schema

  alias Schemas.Flow.Category
  alias Schemas.Flow.DerivedCommand

  schema "commands" do
    belongs_to :category, Category

    field :name, :string
    field :arity, :integer
    field :description, :string
    field :active, :boolean, default: false

    timestamps()
    soft_delete_schema()

    has_many :derived_commands, DerivedCommand, on_delete: :delete_all
  end
end
