use Protoss

defprotocol OAuth do
  @moduledoc """
  OAuth module for Auth0 integration.  This defines a protocol that
  can be substituted to implement different OAuth providers based on a
  configuration struct.

  Generally handles OAuth token exchange, user info retrieval, and user management.

  The two OAuth providers supported are `OAuth.Auth0` and `OAuth.Cache`.  The cache
  module is designed to be depolyed to prevent multiple calls to rate-limited Auth0
  endpoints.

  This protocol can be easily modified to support OAuth providers on a per-user basis,
  depending on the user's configuration.
  """
  require Logger
  alias MyApp.Users

  @spec logout_url(t) :: {:ok, String.t()} | :error
  def logout_url(provider)

  @spec authorize_url(t) :: {:ok, String.t()} | :error
  def authorize_url(provider)

  @spec fetch_token(t, String.t()) :: {:ok, String.t()} | :error | {:error, any}
  def fetch_token(provider, bearer_token)

  @spec fetch_user_info(t, String.t()) :: {:ok, map} | :error | {:error, any}
  def fetch_user_info(provider, oauth_token)
after
  @callback init() :: t
  def init do
    :my_app
    |> Application.fetch_env!(:oauth_modules)
    |> Enum.map(& &1.init())
    |> then(&Application.put_env(:my_app, :oauth_providers, &1))
  end

  defp providers, do: Application.get_env(:my_app, :oauth_providers)

  defp exec(function, args) do
    Enum.reduce_while(providers(), [], fn
      _, {:ok, _} = result -> {:halt, result}
      provider, _ -> {:cont, apply(__MODULE__, function, [provider | args])}
    end)
  end

  defp exec!(function, args) do
    case exec(function, args) do
      {:ok, result} -> result
      {:error, reason} -> raise reason
    end
  end

  def logout_url, do: exec!(:logout_url, [])
  def authorize_url, do: exec!(:authorize_url, [])
  def fetch_token(bearer_token), do: exec(:fetch_token, [bearer_token])
  def fetch_user_info(oauth_token), do: exec(:fetch_user_info, [oauth_token])

  @doc """
  from OAuth user info, find or create a user in the system, this is in the
  OAuth context because it is OAuth-specific logic to interface with the
  existing user database system.
  """
  def fetch!(key) do
    case Application.get_env(:my_app, key) do
      nil -> raise ArgumentError, "Configuration for #{key} not found"
      value -> value
    end
  end

  def find_or_create_user(user_info) do
    email = user_info["email"]
    name = user_info["name"]
    auth0_id = user_info["sub"]

    if user = Users.get_by_email(email) do
      Users.update(user, %{auth0_id: auth0_id})
    else
      attrs = %{
        email: email,
        name: name,
        auth0_id: auth0_id,
        role: :user
      }

      Users.create(attrs)
    end
  end
end
