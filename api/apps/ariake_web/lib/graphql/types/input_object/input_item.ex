defmodule Graphql.Types.InputObject.InputItem do
  use Absinthe.Schema.Notation

  input_object :input_item do
    field(:key, non_null(:string))
    field(:val, non_null(:string))
  end
end
