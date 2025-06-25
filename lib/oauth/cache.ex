defmodule OAuth.Cache do
  @moduledoc """
  ETS-based caching implementation for OAuth tokens and user info.

  Provides caching for bearer tokens, access tokens, and user information
  to reduce API calls to Auth0 and improve performance.
  """
  use OAuth
  use MatchSpec

  defstruct id: __MODULE__

  @type t :: %__MODULE__{id: atom}

  # protocol implementations
  # NOTE: this is distinct from the `init/1` function which is a GenServer
  # callback.
  def init, do: %__MODULE__{}

  def logout_url(_), do: :error
  def authorize_url(_), do: :error

  def fetch_token(%{id: table_id}, bearer_token) do
    now = :erlang.monotonic_time(:second)

    case :ets.lookup(table_id, {:bearer, bearer_token}) do
      [{_, access_token, expiry}] when expiry > now ->
        {:ok, access_token}

      [{_, access_token, _}] ->
        purge_by_access_token(table_id, access_token)
        :error

      _ ->
        :error
    end
  end

  def fetch_user_info(%{id: table_id}, access_token) do
    case :ets.lookup(table_id, {:access_token, access_token}) do
      [{_, user_info}] -> {:ok, user_info}
      [] -> :error
    end
  end

  ## Implementation.  Note functions below this line do NOT take
  ## the `Oauth.Cache` struct as a first argument.

  use GenServer

  def start_link(opts) do
    opts = Keyword.put_new(opts, :name, __MODULE__)
    GenServer.start_link(__MODULE__, opts, opts)
  end

  def init(opts) do
    opts
    |> Keyword.fetch!(:name)
    |> :ets.new(~w[set named_table public]a)

    {:ok, []}
  end

  defmatchspec access_token_by_email(email) do
    {{:access_token, access_token}, %{"email" => ^email}} -> access_token
  end

  defmatchspec bearer_token_by_access_token(access_token) do
    {_, ^access_token, _} -> true
  end

  def purge(table_id, email) do
    table_id
    |> :ets.select(access_token_by_email(email))
    |> Enum.each(fn access_token ->
      :ets.delete(table_id, {:access_token, access_token})
      :ets.select_delete(table_id, bearer_token_by_access_token(access_token))
    end)
  end

  defp purge_by_access_token(table_id, access_token) do
    :ets.delete(table_id, {:access_token, access_token})
    :ets.select_delete(table_id, bearer_token_by_access_token(access_token))
  end

  def insert_access_token(table_id, bearer_token, access_response) when is_atom(table_id) do
    %{"access_token" => access_token, "expires_in" => expires_in} = access_response
    expiry = :erlang.monotonic_time(:second) + expires_in - 10
    :ets.insert(table_id, {{:bearer, bearer_token}, access_token, expiry})
  end

  def insert_user_info(table_id, access_token, user_info) when is_atom(table_id) do
    :ets.insert(table_id, {{:access_token, access_token}, user_info})
  end
end
