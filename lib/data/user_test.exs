defmodule Data.UserTest do
  use MyApp.DataCase, async: true

  alias Data.User

  describe "changeset/2" do
    test "valid changeset with all required fields" do
      attrs = %{
        name: "John Doe",
        email: "john@example.com",
        auth0_id: "auth0|123456789",
        role: :user
      }

      changeset = User.changeset(%User{}, attrs)
      assert changeset.valid?
    end

    test "requires name" do
      attrs = %{
        email: "john@example.com",
        auth0_id: "auth0|123456789",
        role: :user
      }

      changeset = User.changeset(%User{}, attrs)
      refute changeset.valid?
      assert %{name: ["can't be blank"]} = errors_on(changeset)
    end

    test "requires email" do
      attrs = %{
        name: "John Doe",
        auth0_id: "auth0|123456789",
        role: :user
      }

      changeset = User.changeset(%User{}, attrs)
      refute changeset.valid?
      assert %{email: ["can't be blank"]} = errors_on(changeset)
    end

    test "requires auth0_id" do
      attrs = %{
        name: "John Doe",
        email: "john@example.com",
        role: :user
      }

      changeset = User.changeset(%User{}, attrs)
      refute changeset.valid?
      assert %{auth0_id: ["can't be blank"]} = errors_on(changeset)
    end

    test "requires role" do
      attrs = %{
        name: "John Doe",
        email: "john@example.com",
        auth0_id: "auth0|123456789"
      }

      changeset = User.changeset(%User{}, attrs)
      refute changeset.valid?
      assert %{role: ["can't be blank"]} = errors_on(changeset)
    end

    test "validates email format" do
      attrs = %{
        name: "John Doe",
        email: "invalid-email",
        auth0_id: "auth0|123456789",
        role: :user
      }

      changeset = User.changeset(%User{}, attrs)
      refute changeset.valid?
      assert %{email: ["has invalid format"]} = errors_on(changeset)
    end

    test "validates role inclusion" do
      attrs = %{
        name: "John Doe",
        email: "john@example.com",
        auth0_id: "auth0|123456789",
        role: :invalid_role
      }

      changeset = User.changeset(%User{}, attrs)
      refute changeset.valid?
      assert %{role: ["is invalid"]} = errors_on(changeset)
    end

    test "accepts valid roles" do
      valid_roles = [:admin, :user]

      for role <- valid_roles do
        attrs = %{
          name: "John Doe",
          email: "john#{role}@example.com",
          auth0_id: "auth0|123456789#{role}",
          role: role
        }

        changeset = User.changeset(%User{}, attrs)
        assert changeset.valid?, "Role #{role} should be valid"
      end
    end
  end
end
