import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :ariake_web, AriakeWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "PW5XWOyVeYV5/HeviMH7q3cWyWKa1Gh66zjyJepnktxjA8egKNXP9wAK0mHcgj7T",
  server: false

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :ariake, Ariake.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "ariake_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10
