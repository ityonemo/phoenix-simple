# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     MyApp.Repo.insert!(%MyApp.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Data.Repo
alias Data.User

# Test users with fixed UUIDs for easy AI testing
test_users = [
  %{
    id: "11111111-1111-1111-1111-111111111111",
    name: "Test Admin",
    email: "admin@test.com",
    auth0_id: "auth0|admin123",
    role: :admin
  },
  %{
    id: "33333333-3333-3333-3333-333333333333",
    name: "Test User",
    email: "user@test.com",
    auth0_id: "auth0|user123",
    role: :user
  }
]

# Create test users
Enum.each(test_users, fn user_attrs ->
  case Repo.get_by(User, email: user_attrs.email) do
    nil ->
      Repo.insert!(User.changeset(%User{}, user_attrs))
      IO.puts("Created #{user_attrs.role} user: #{user_attrs.name} (#{user_attrs.email})")

    existing_user ->
      IO.puts("User already exists: #{existing_user.name} (#{existing_user.email})")
  end
end)

