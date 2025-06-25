defmodule Web.Router do
  use Phoenix.Router, helpers: false

  # Import common connection and controller functions to use in pipelines
  import Phoenix.LiveView.Router

  alias Plug.Conn
  alias MyApp.Users

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {Web.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :assign_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :authenticate_admin do
    plug :authenticate, :admin
  end

  pipeline :authenticate_user do
    plug :authenticate, :user
  end

  scope "/", Web do
    pipe_through :browser
    get "/", Home, :index
  end

  scope "/auth", Web.Auth do
    pipe_through :browser

    get "/auth0", Controller, :request
    get "/callback", Controller, :callback
    post "/logout", Controller, :logout
  end

  scope "/admin", Web.Admin do
    pipe_through :browser
    pipe_through :authenticate_admin

    live "/dashboard", DashboardLive, :index
  end

  scope "/user", Web.User do
    pipe_through :browser
    pipe_through :authenticate_user

    live "/dashboard", DashboardLive, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", Web do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:my_app, :dev_routes) do
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: Web.Telemetry
    end
  end

  defp authenticate(conn, what) do
    alias Phoenix.Controller

    case conn.assigns do
      %{current_user: %{role: ^what}} ->
        conn

      _ ->
        conn
        |> Controller.put_flash(:error, "You must be logged in to access this page.")
        |> Controller.redirect(to: "/")
        |> Conn.halt()
    end
  end

  defp assign_current_user(conn, _opts) do
    user_id = get_session(conn, :user_id)

    cond do
      !user_id ->
        assign(conn, :current_user, nil)

      user = Users.get(user_id) ->
        assign(conn, :current_user, user)

      :else ->
        assign(conn, :current_user, nil)
    end
  end
end
