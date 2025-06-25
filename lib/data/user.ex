defmodule Data.User do
  @moduledoc """
  User schema with role-based authentication.
  """
  use Ecto.Schema
  import EctoEnum
  alias Ecto.Changeset

  defenum(Role, admin: 0, user: 1)

  @valid_roles [:admin, :user]

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "users" do
    field :name, :string
    field :email, :string
    field :auth0_id, :string
    field :role, Role

    timestamps(type: :utc_datetime)
  end

  @doc """
  Creates a changeset for user creation and updates.
  """
  def changeset(user \\ %__MODULE__{}, attrs) do
    user
    |> Changeset.cast(attrs, [:id, :name, :email, :auth0_id, :role])
    |> Changeset.validate_required([:name, :email, :auth0_id, :role])
    |> Changeset.validate_format(:email, ~r/^[^\s]+@[^\s]+\.[^\s]+$/)
    |> Changeset.validate_inclusion(:role, @valid_roles)
  end

  @doc """
  Creates a changeset for user updates only (no ID changes).
  """
  def update_changeset(user, attrs) do
    user
    |> Changeset.cast(attrs, [:name, :email, :role])
    |> Changeset.validate_required([:name, :email, :role])
    |> Changeset.validate_format(:email, ~r/^[^\s]+@[^\s]+\.[^\s]+$/)
    |> Changeset.validate_inclusion(:role, @valid_roles)
  end
end
