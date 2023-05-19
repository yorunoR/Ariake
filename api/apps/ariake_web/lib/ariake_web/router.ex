defmodule AriakeWeb.Router do
  use AriakeWeb, :router

  import AriakeWeb.AdminUserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {AriakeWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_admin_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", AriakeWeb do
    pipe_through :browser

    get "/", PageController, :home
  end

  # Other scopes may use custom stacks.
  # scope "/api", AriakeWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:ariake_web, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: AriakeWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", AriakeWeb do
    pipe_through [:browser, :redirect_if_admin_user_is_authenticated]

    live_session :redirect_if_admin_user_is_authenticated,
      on_mount: [{AriakeWeb.AdminUserAuth, :redirect_if_admin_user_is_authenticated}] do
      live "/admin_user/register", AdminUserRegistrationLive, :new
      live "/admin_user/log_in", AdminUserLoginLive, :new
      live "/admin_user/reset_password", AdminUserForgotPasswordLive, :new
      live "/admin_user/reset_password/:token", AdminUserResetPasswordLive, :edit
    end

    post "/admin_user/log_in", AdminUserSessionController, :create
  end

  scope "/", AriakeWeb do
    pipe_through [:browser, :require_authenticated_admin_user]

    live_session :require_authenticated_admin_user,
      on_mount: [{AriakeWeb.AdminUserAuth, :ensure_authenticated}] do
      live "/admin_user/settings", AdminUserSettingsLive, :edit
      live "/admin_user/settings/confirm_email/:token", AdminUserSettingsLive, :confirm_email
    end
  end

  scope "/", AriakeWeb do
    pipe_through [:browser]

    delete "/admin_user/log_out", AdminUserSessionController, :delete

    live_session :current_admin_user,
      on_mount: [{AriakeWeb.AdminUserAuth, :mount_current_admin_user}] do
      live "/admin_user/confirm/:token", AdminUserConfirmationLive, :edit
      live "/admin_user/confirm", AdminUserConfirmationInstructionsLive, :new
    end
  end
end
