use Mix.Config

# Configure your database
config :crit, Crit.Repo,
  username: "bem",
  password: "postgres",
  database: "crit_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :crit, CritWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

config :phoenix_integration,
  endpoint: CritWeb.Endpoint

## Within-app interfaces

config :pbkdf2_elixir,
  rounds: 1    # make tests faster
