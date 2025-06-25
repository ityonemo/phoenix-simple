defmodule Web.Auth.Controller do
  @moduledoc """
  Authentication controller for handling Auth0 OAuth flows.

  Manages login, logout, and callback handling for Auth0 integration.
  """
  use Phoenix.Controller,
    formats: [:html, :json],
    layouts: [html: Web.Layouts]

  alias Plug.Conn

  use Web.VerifiedRoutes

  alias Phoenix.Controller

  def request(conn, _params) do
    Controller.redirect(conn, external: OAuth.authorize_url())
  end

  def callback(conn, %{"code" => code}) do
    with {:ok, token} <- OAuth.fetch_token(code),
         {:ok, user_info} <- OAuth.fetch_user_info(token),
         {:ok, user} <- OAuth.find_or_create_user(user_info) do
      conn
      |> Conn.put_session(:user_id, user.id)
      |> Controller.put_flash(:info, "Welcome, #{user.name}!")
      |> Controller.redirect(to: dashboard_path_for_role(user.role))
    else
      _ ->
        # TODO: better logging here.
        conn
        |> Controller.put_flash(:error, "Authentication failed.")
        |> Controller.redirect(to: "/")
    end
  end

  def callback(conn, _no_code) do
    conn
    |> Controller.put_flash(:error, "Authentication failed. Missing authorization code.")
    |> Controller.redirect(to: "/")
  end

  def logout(conn, _params) do
    conn
    |> Conn.clear_session()
    |> Controller.put_flash(:info, "You have been logged out.")
    |> Controller.redirect(external: OAuth.logout_url())
  end

  defp dashboard_path_for_role(:admin), do: ~p"/admin/dashboard"
  defp dashboard_path_for_role(:user), do: ~p"/user/dashboard"
end
