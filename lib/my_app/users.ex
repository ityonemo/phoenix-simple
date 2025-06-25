defmodule MyApp.Users do
  @moduledoc """
  The Users context for business logic operations.
  """

  import Ecto.Query, warn: false
  alias Data.Repo
  alias Data.User

  @doc """
  Finds or creates a user with the given attributes from OAuth.
  """
  def find_or_create(attrs) do
    if user = get_by_auth0_id(attrs.auth0_id), do: user, else: create(attrs)
  end

  @doc """
  Gets a user by their Auth0 ID.
  """
  def get_by_auth0_id(auth0_id), do: Repo.get_by(User, auth0_id: auth0_id)

  def get_by_email(email), do: Repo.get_by(User, email: email)

  @doc """
  Gets a user by ID.
  """
  def get(id), do: Repo.get(User, id)

  @doc """
  Gets a user by ID, raising if not found.
  """
  def get!(id), do: Repo.get!(User, id)

  @doc """
  Creates a user.
  """
  def create(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user.
  """
  def update(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user.
  """
  def delete(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.
  """
  def change(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end

  @doc """
  Lists all users (formerly clients and trainers).
  """
  def list_users do
    Repo.all(from(u in User, where: u.role == :user))
  end

  @doc """
  Lists all admins.
  """
  def list_admins do
    Repo.all(from(u in User, where: u.role == :admin))
  end
end
