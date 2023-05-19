defmodule Graphql.Sources.Db do
  import Ecto.Query

  alias Jehuty.Repo

  def data() do
    Dataloader.Ecto.new(Repo, query: &custom_query/2)
  end

  def custom_query(query, args) do
    query = query |> order_by(desc: :id)

    Enum.reduce(args, query, fn
      {:limit, limit_to}, query ->
        query |> limit(^limit_to)

      {:offset, offset_from}, query ->
        query |> offset(^offset_from)
    end)
  end
end
