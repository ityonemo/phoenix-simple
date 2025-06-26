# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :my_app,
  ecto_repos: [Data.Repo],
  generators: [timestamp_type: :utc_datetime]

config :my_app, Data.Repo,
  migration_timestamps: [type: :utc_datetime_usec],
  migration_primary_key: [type: :binary_id],
  migration_foreign_key: [type: :binary_id]

database_adapter =
  case System.get_env("DATABASE_ADAPTER", "sqlite") do
    "sqlite" ->
      Ecto.Adapters.SQLite3

    "postgres" ->
      Ecto.Adapters.Postgres
  end

config :my_app, :database_adapter, database_adapter

# Configures the endpoint
config :my_app, Web.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: Web.Error.HTML],
    layout: false
  ],
  pubsub_server: MyApp.PubSub,
  live_view: [signing_salt: "4Ast8RGC"]

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  my_app: [
    args:
      ~w(js/app.js --bundle --target=es2022 --outdir=../priv/static/assets/js --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "4.0.9",
  my_app: [
    args: ~w(
      --input=assets/css/app.css
      --output=priv/static/assets/css/app.css
    ),
    cd: Path.expand("..", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :default_formatter, format: "$time $metadata[$level] $message\n"

# change this to Jason if you are using elixir < 1.18
config :phoenix, :json_library, JSON

config :my_app, :oauth_modules, [OAuth.Cache, OAuth.Auth0]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
