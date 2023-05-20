defmodule AriakeWeb.Context do
  require Logger

  import Plug.Conn

  alias Resolvers.AccountResolver

  @cert_url "https://www.googleapis.com/robot/v1/metadata/x509/securetoken@system.gserviceaccount.com"

  def build_context(conn) do
    with ["Bearer " <> token] <- get_req_header(conn, "authorization"),
         {:ok, verified = %{"user_id" => uid}} <- verify(token),
         {:ok, current_user} = get_user(uid) do
      case verified do
        %{"email" => email, "name" => name} ->
          %{
            current_user: current_user,
            email: email,
            uid: uid,
            name: name,
            anonymous: false
          }

        %{"provider_id" => "anonymous"} ->
          %{
            current_user: current_user,
            uid: uid,
            anonymous: true
          }
      end
    else
      user_err ->
        user_err |> inspect |> Logger.error()
        Logger.error("<~ #{__MODULE__}")
        %{}
    end
  end

  def get_user(nil) do
    {:ok, nil}
  end

  def get_user(uid) do
    AccountResolver.call(
      :user,
      nil,
      %{uid: uid},
      %{context: nil}
    )
  end

  def verify(token) do
    case Joken.peek_header(token) do
      {:ok, header} ->
        cert = get_cert(header["kid"])
        {true, jose_jwt, _} = JOSE.JWT.verify(cert, token)
        fields = JOSE.JWT.to_map(jose_jwt) |> elem(1)
        {:ok, fields}

      _ ->
        {:ok, %{}}
    end
  end

  # TODO: etsにキャッシュする
  def get_cert(kid) do
    %{body: body} = Req.get!(@cert_url)
    jwks = JOSE.JWK.from_firebase(body)
    jwks[kid] |> JOSE.JWK.to_map() |> elem(1)
  end
end
