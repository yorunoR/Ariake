defmodule Actions.Account.Mutation.SigninUser do
  import Ecto.Changeset

  alias Schemas.Account.User
  alias Ariake.Repo

  def run(_parent, _args, context) do
    %{email: email, uid: uid, name: name} = context

    user = Repo.get_by(User, uid: uid)

    case user do
      %User{} ->
        {:ok, user}

      _ ->
        %User{}
        |> create_user_changeset(%{email: email, uid: uid, name: name})
        |> Repo.insert()
    end
  end

  def create_user_changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:uid, :name, :email])
    |> validate_required([:uid])
    |> unique_constraint(:email)
  end
end
