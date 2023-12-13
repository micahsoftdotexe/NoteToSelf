defmodule NoteToSelfWeb.Router do
  # alias NoteToSelfWeb.AuthController
  use NoteToSelfWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :auth do
    plug NoteToSelf.Auth.Pipeline
  end

  pipeline :refresh_auth do
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
    pipe_through [:api, :fetch_session, :relax_auth]
    post("/register", AuthController, :register)
  end

  scope "/api", NoteToSelfWeb do
    pipe_through [:fetch_session, :protect_from_forgery, :api, :auth]
    get("/user", AuthController, :show)
    get("/disable/:user_id", AuthController, :disable)
    get("/enable/:user_id", AuthController, :enable)
    get("/user/:identifying_info", AuthController, :find)
  end

  scope "/api", NoteToSelfWeb do
    pipe_through [:api, :refresh_auth, :fetch_session, :protect_from_forgery]
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
