import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.

database =
  case read_config(:my_app)[:database_adapter] do
    Ecto.Adapters.SQLite3 ->
      Path.expand("../my_app_test.db", __DIR__)

    Ecto.Adapters.Postgres ->
      "my_app_test"
  end

config :my_app, Data.Repo,
  database: database,
  hostname: System.get_env("PGHOST", "localhost"),
  username: System.get_env("PGUSER", "postgres"),
  password: System.get_env("PGPASSWORD", "postgres"),
  port: String.to_integer(System.get_env("PGPORT", "5432")),
  pool_size: System.schedulers_online() * 2,
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :my_app, Web.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "3llPHt6U2+TNCy49GHnTdXKLotfbmCOFvcbh/mJMtxn+EbquaZMB4rwrzwJDxuxX",
  server: false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Enable helpful, but potentially expensive runtime checks
config :phoenix_live_view,
  enable_expensive_runtime_checks: true

config :my_app, :oauth_modules, [OAuth.Test]
