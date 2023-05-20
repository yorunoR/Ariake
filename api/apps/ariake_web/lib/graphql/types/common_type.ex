defmodule Graphql.Types.CommonType do
  use Absinthe.Schema.Notation

  object :common_queries do
    field(:ping, non_null(:status)) do
      resolve(fn _parent, _args, %{context: _context} ->
        {:ok, %{status: true}}
      end)
    end
  end
end
