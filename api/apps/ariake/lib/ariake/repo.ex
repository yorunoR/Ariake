defmodule Ariake.Repo do
  use Ecto.Repo,
    otp_app: :ariake,
    adapter: Ecto.Adapters.Postgres
end
