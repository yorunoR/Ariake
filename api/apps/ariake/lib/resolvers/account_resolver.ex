defmodule Resolvers.AccountResolver do
  alias Actions.Account.Mutation
  alias Actions.Account.Query

  def call(action, parent, args, %{context: context}) do
    case action do
      action when action in [:signin_user, :user] ->
        run(action, parent, args, context)
    end
  end

  def run(action, parent, args, context) do
    case action do
      :user ->
        Query.User.run(parent, args, context)

      :signin_user ->
        Mutation.SigninUser.run(parent, args, context)

      _ ->
        {:error, "Not defined in Account context"}
    end
  end
end
