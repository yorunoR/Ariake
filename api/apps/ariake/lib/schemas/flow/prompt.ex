defmodule Schemas.Flow.Prompt do
  use Ariake.Schema
  import Ecto.SoftDelete.Schema

  schema "prompts" do
    field :template, :string
    field :variables, :map

    timestamps()
    soft_delete_schema()
  end
end
