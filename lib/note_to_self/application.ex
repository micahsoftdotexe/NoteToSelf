defmodule NoteToSelf.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      NoteToSelfWeb.Telemetry,
      # Start the Ecto repository
      NoteToSelf.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: NoteToSelf.PubSub},
      # Start Finch
      {Finch, name: NoteToSelf.Finch},
      # Start the Endpoint (http/https)
      NoteToSelfWeb.Endpoint
      # Start a worker by calling: NoteToSelf.Worker.start_link(arg)
      # {NoteToSelf.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: NoteToSelf.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    NoteToSelfWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
