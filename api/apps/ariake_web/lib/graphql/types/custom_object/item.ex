defmodule Graphql.Types.CustomObject.Item do
  use Absinthe.Schema.Notation

  object :item do
    field(:key, non_null(:string))
    field(:val, non_null(:string))
  end
end
