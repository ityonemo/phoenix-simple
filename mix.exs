defmodule MyApp.MixProject do
  use Mix.Project

  def project do
    [
      app: :my_app,
      version: "0.1.0",
      elixir: "~> 1.15",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      test_pattern: "*_test.exs",
      test_paths: ["lib"],
      listeners: [Phoenix.CodeReloader]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {MyApp.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:protoss, "~> 1.0"},
      {:match_spec, "~> 0.3"},
      {:phoenix, "~> 1.8.0-rc.3", override: true},
      {:phoenix_ecto, "~> 4.5"},
      {:ecto_sql, "~> 3.10"},
      {:ecto_sqlite3, ">= 0.0.0"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 4.1"},
      {:phoenix_live_view, "~> 1.0.9"},
      {:ecto_enum, "~> 1.4"},
      {:phoenix_live_dashboard, "~> 0.8.3"},
      {:heroicons,
       github: "tailwindlabs/heroicons",
       tag: "v2.1.1",
       sparse: "optimized",
       app: false,
       compile: false,
       depth: 1},
      {:req, "~> 0.5"},
      {:telemetry_metrics, "~> 1.0"},
      {:telemetry_poller, "~> 1.0"},
      {:dns_cluster, "~> 0.1.1"},
      {:bandit, "~> 1.5"},
      # Test
      {:bypass, "~> 2.1", only: :test},
      {:faker, "~> 0.18", only: :test},
      {:floki, ">= 0.30.0", only: :test},
      # devtools
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:esbuild, "~> 0.9", runtime: Mix.env() == :dev},
      {:tailwind, "~> 0.3", runtime: Mix.env() == :dev},
      # linters
      {:credo, "~> 1.7", only: :dev, runtime: false},
      {:mox, "~> 1.0", only: :test}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      compile: [&dump_agents/1, "compile"],
      "phx.server": [&dump_agents/1, "phx.server"],
      setup: ["deps.get", "ecto.setup", "assets.setup", "assets.build"],
      "ecto.setup": ["ecto.create", "ecto.migrate" | ecto_seeds(Mix.env())],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test --include lib"],
      "assets.setup": ["tailwind.install --if-missing", "esbuild.install --if-missing"],
      "assets.build": ["tailwind my_app", "esbuild my_app"],
      "assets.deploy": [
        "tailwind my_app --minify",
        "esbuild my_app --minify",
        "phx.digest"
      ]
    ]
  end

  defp ecto_seeds(:dev), do: ["run priv/repo/seeds.exs"]
  defp ecto_seeds(_), do: []

  defp dump_agents(_args) do
    if System.get_env("I_AM_NOT_AN_AI", "false") == "true" do
      "AGENTS.md"
      |> File.read!
      |> IO.puts()
    end
  end
end
