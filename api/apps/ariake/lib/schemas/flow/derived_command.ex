defmodule Schemas.Flow.DerivedCommand do
  use Ariake.Schema
  import Ecto.SoftDelete.Schema

  alias Schemas.Flow.Category
  alias Schemas.Flow.Command

  schema "derived_commands" do
    belongs_to :category, Category
    belongs_to :command, Command

    field :value, :string
    field :embedding, Pgvector.Ecto.Vector

    timestamps()
    soft_delete_schema()
  end
end
