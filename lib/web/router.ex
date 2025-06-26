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

  pipeline :localhost_only do
    plug :require_localhost
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

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:my_app, :dev_routes) do
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: Web.Telemetry
    end
  end

  if Application.compile_env(:my_app, :env) == :dev do
    scope "/dev" do
      pipe_through [:browser, :localhost_only]

      get "/login_as/:id", Web.DevController, :login_as
      get "/logout", Web.DevController, :logout
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

  defp require_localhost(conn, _opts) do
    # Check for proxy headers - if any are present, this is an external request
    x_forwarded_for = Plug.Conn.get_req_header(conn, "x-forwarded-for")
    x_real_ip = Plug.Conn.get_req_header(conn, "x-real-ip")
    forwarded = Plug.Conn.get_req_header(conn, "forwarded")

    proxy_headers_present =
      !Enum.empty?(x_forwarded_for) or
        !Enum.empty?(x_real_ip) or
        !Enum.empty?(forwarded)

    cond do
      # If any proxy headers are present, reject
      proxy_headers_present ->
        conn
        |> Phoenix.Controller.put_flash(
          :error,
          "Access denied. This endpoint is only available from localhost."
        )
        |> Phoenix.Controller.redirect(to: "/")
        |> Conn.halt()
        |> Phoenix.Controller.redirect(to: "/")
        |> Conn.halt()

      # Only allow true localhost IPs with no proxy headers
      conn.remote_ip == {127, 0, 0, 1} or
          conn.remote_ip == {0, 0, 0, 0, 0, 0, 0, 1} ->
        conn

      :else ->
        conn
        |> Phoenix.Controller.put_flash(
          :error,
          "Access denied. This endpoint is only available from localhost."
        )
        |> Phoenix.Controller.redirect(to: "/")
        |> Conn.halt()
    end
  end
end
