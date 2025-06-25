defmodule OAuth.Auth0 do
  @moduledoc """
  Auth0 OAuth implementation for handling authentication flows.

  Provides OAuth token exchange, user info retrieval, and URL generation
  for Auth0 integration with caching support.
  """
  use OAuth
  alias OAuth.Cache
  require Logger

  @env_mapping %{
    domain: "AUTH0_DOMAIN",
    client_id: "AUTH0_CLIENT_ID",
    client_secret: "AUTH0_CLIENT_SECRET",
    redirect_uri: "AUTH0_REDIRECT_URI",
    home_uri: "AUTH0_HOME_URI"
  }

  defstruct Map.keys(@env_mapping) ++ [cache: Cache]

  @type t :: %__MODULE__{
          domain: String.t(),
          client_id: String.t(),
          client_secret: String.t(),
          redirect_uri: String.t(),
          home_uri: String.t(),
          cache: atom
        }

  def init do
    @env_mapping
    |> Enum.map(fn {k, v} -> {k, System.fetch_env!(v)} end)
    |> then(&struct!(__MODULE__, &1))
  end

  # Support both HTTP and HTTPS for testing
  defp scheme(auth0) do
    if auth0.domain =~ "localhost", do: "http://", else: "https://"
  end

  defp url(auth0, path) do
    auth0
    |> scheme
    |> then(&Path.join([&1, auth0.domain, path]))
  end

  def fetch_token(auth0, bearer_token) do
    url = url(auth0, "/oauth/token")

    body = %{
      grant_type: :authorization_code,
      client_id: auth0.client_id,
      client_secret: auth0.client_secret,
      code: bearer_token,
      redirect_uri: auth0.redirect_uri
    }

    case Req.post(url, json: body) do
      {:ok, %{status: 200, body: response}} ->
        Cache.insert_access_token(auth0.cache, bearer_token, response)
        {:ok, Map.fetch!(response, "access_token")}

      {:ok, %{status: _status, body: body}} ->
        Logger.error("Auth0 token exchange failure: #{inspect(body)}")
        {:error, "auth0 token exchange failed"}

      {:error, reason} ->
        Logger.error("Auth0 token exchange error: #{inspect(reason)}")
        {:error, reason}
    end
  end

  def fetch_user_info(auth0, access_token) do
    url = url(auth0, "/userinfo")

    headers = [{"authorization", "Bearer #{access_token}"}]

    case Req.get(url, headers: headers) do
      {:ok, %{status: 200, body: user_info}} ->
        Cache.insert_user_info(auth0.cache, access_token, user_info)
        {:ok, user_info}

      {:ok, %{status: _status, body: body}} ->
        Logger.error("Auth0 user info failure: #{inspect(body)}")
        {:error, "Auth0 user info failed"}

      {:error, reason} ->
        Logger.error("Auth0 user info error: #{inspect(reason)}")
        {:error, reason}
    end
  end

  def logout_url(auth0) do
    params = %{returnTo: auth0.home_uri, client_id: auth0.client_id}
    query_string = URI.encode_query(params)
    {:ok, "#{scheme(auth0)}#{auth0.domain}/v2/logout?#{query_string}"}
  end

  def authorize_url(auth0) do
    params = %{
      response_type: "code",
      client_id: auth0.client_id,
      redirect_uri: auth0.redirect_uri,
      scope: "openid profile email",
      audience: "#{scheme(auth0)}#{auth0.domain}/api/v2/"
    }

    query_string = URI.encode_query(params)
    {:ok, "#{scheme(auth0)}#{auth0.domain}/authorize?#{query_string}"}
  end
end
