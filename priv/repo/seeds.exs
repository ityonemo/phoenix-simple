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

# Create a test user for debugging
test_user_attrs = %{
  id: Ecto.UUID.generate(),
  name: "Test User",
  email: "test@user.com",
  auth0_id: "auth0|test123",
  role: :user
}

case Repo.get_by(User, email: test_user_attrs.email) do
  nil ->
    Repo.insert!(User.changeset(%User{}, test_user_attrs))
    IO.puts("Created test user: #{test_user_attrs.email}")

  user ->
    IO.puts("Test user already exists: #{user.email}")
end
