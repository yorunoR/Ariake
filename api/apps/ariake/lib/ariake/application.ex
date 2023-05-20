defmodule Ariake.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Ariake.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: Ariake.PubSub},
      # Start Finch
      {Finch, name: Ariake.Finch}
      # Start a worker by calling: Ariake.Worker.start_link(arg)
      # {Ariake.Worker, arg}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: Ariake.Supervisor)
  end
end
