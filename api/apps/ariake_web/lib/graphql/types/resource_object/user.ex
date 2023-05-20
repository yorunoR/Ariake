defmodule Graphql.Types.ResourceObject.User do
  use Absinthe.Schema.Notation
  import Absinthe.Resolution.Helpers

  object :user do
    field(:id, non_null(:id))
    field(:activated, non_null(:boolean))
    field(:email, non_null(:string))
    field(:name, non_null(:string))
    field(:profile_image, :string)
    field(:role, non_null(:integer))
    field(:uid, :string)
    field(:inserted_at, non_null(:datetime))
    field(:updated_at, non_null(:datetime))
  end
end
