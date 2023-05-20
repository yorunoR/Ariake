defmodule Graphql.Types.CustomObject.Status do
  use Absinthe.Schema.Notation

  object :status do
    field(:status, :boolean)
  end
end
