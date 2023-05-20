defmodule Graphql.Schema do
  use Absinthe.Schema

  alias Graphql.Middlewares.ErrorHandler
  alias Graphql.Middlewares.SafeResolution
  alias Graphql.Sources.Db
  alias Graphql.Types.CommonType
  alias Graphql.Types.AccountType
  alias Graphql.Types.InputObject
  alias Graphql.Types.CustomObject
  alias Graphql.Types.ResourceObject

  import_types(Absinthe.Type.Custom)

  import_types(CommonType)
  import_types(AccountType)

  import_types(InputObject.InputItem)
  import_types(CustomObject.Item)
  import_types(CustomObject.Status)
  import_types(ResourceObject.User)

  query do
    import_fields(:common_queries)
    import_fields(:account_queries)
  end

  mutation do
    import_fields(:account_mutations)
  end

  subscription do
    import_fields(:account_subscriptions)
  end

  def context(ctx) do
    loader = Dataloader.new() |> Dataloader.add_source(:db, Db.data())

    Map.put(ctx, :loader, loader)
  end

  def plugins do
    [Absinthe.Middleware.Dataloader] ++ Absinthe.Plugin.defaults()
  end

  def middleware(middlewares, _field, %{identifier: type}) when type in [:query, :mutation] do
    SafeResolution.apply(middlewares) ++ [ErrorHandler]
  end

  def middleware(middlewares, _field, _object) do
    middlewares
  end
end
