defmodule Data.Factory do
  alias Data.Repo
  alias Data.User

  def new(table, attrs \\ [])

  def new(User, attrs) do
    attrs
    |> Enum.into(%{
      name: Faker.Person.name(),
      email: Faker.Internet.email(),
      auth0_id: "auth0|" <> Faker.UUID.v4(),
      role: :user
    })
    |> User.changeset()
  end

  def insert(table, attrs) do
    table
    |> new(attrs)
    |> Repo.insert!()
  end
end
