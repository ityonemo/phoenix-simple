alias Data.Repo
import Ecto.Query

# Show all tables
{:ok, result} = Repo.query("SELECT name FROM sqlite_master WHERE type='table';")
IO.puts("=== Database Tables ===")
Enum.each(result.rows, fn [table] -> IO.puts("- #{table}") end)

# Show users table if it exists
try do
  users = Repo.all(from u in "users", select: [u.id, u.email, u.name, u.role])
  IO.puts("\n=== Users Table ===")

  Enum.each(users, fn [id, email, name, role] ->
    IO.puts("ID: #{id}, Email: #{email}, Name: #{name}, Role: #{role}")
  end)
rescue
  _ -> IO.puts("\n=== Users table does not exist ===")
end

# Show schema_migrations
try do
  migrations = Repo.all(from m in "schema_migrations", select: m.version)
  IO.puts("\n=== Schema Migrations ===")
  Enum.each(migrations, fn version -> IO.puts("- #{version}") end)
rescue
  _ -> IO.puts("\n=== Schema migrations table does not exist ===")
end
