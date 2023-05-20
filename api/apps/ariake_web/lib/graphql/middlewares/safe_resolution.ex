defmodule Graphql.Middlewares.SafeResolution do
  require Logger

  alias Absinthe.Resolution

  @behaviour Absinthe.Middleware
  @default_error {:error, %{message: "Raise exception", code: :unknown}}

  @doc """
  Call this on existing middleware to replace instances of
  `Resolution` middleware with `SafeResolution`
  """
  def apply(middlewares) when is_list(middlewares) do
    Enum.map(middlewares, fn
      {{Resolution, :call}, resolver} -> {__MODULE__, resolver}
      other -> other
    end)
  end

  @impl true
  def call(resolution, resolver) do
    Resolution.call(resolution, resolver)
  rescue
    exception ->
      error = Exception.format(:error, exception, __STACKTRACE__)
      Logger.error(error)
      Logger.error("<~ #{__MODULE__}")
      Resolution.put_result(resolution, @default_error)
  end
end
