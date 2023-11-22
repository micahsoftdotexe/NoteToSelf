defmodule NoteToSelfWeb.Router do
  # alias NoteToSelfWeb.AuthController
  use NoteToSelfWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :auth do
    plug NoteToSelf.Auth.Pipeline
  end

  pipeline :cookie_auth do
    plug NoteToSelf.Auth.RefreshPipeline
  end

  pipeline :relax_auth do
    plug NoteToSelf.Auth.RelaxAuthPipeline
  end

  scope "/api", NoteToSelfWeb do
    pipe_through :api
    post("/login", AuthController, :login)
    # post("/register", AuthController, :register)
  end

  scope "/api", NoteToSelfWeb do
    pipe_through [:api, :relax_auth]
    post("/register", AuthController, :register)
  end

  scope "/api", NoteToSelfWeb do
    pipe_through [:fetch_session, :protect_from_forgery, :api, :auth]
    get("/user", AuthController, :show)
    post("/notes/create", NotesController, :create)
  end

  scope "/api", NoteToSelfWeb do
    pipe_through [:api, :cookie_auth, :fetch_session, :protect_from_forgery]
    get("/refresh", AuthController, :refresh)
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:note_to_self, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through [:fetch_session, :protect_from_forgery]

      live_dashboard "/dashboard", metrics: NoteToSelfWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
