import Config

# Configure your database
config :ariake, Ariake.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "ariake_dev",
  stacktrace: true,
  show_sensitive_data_on_connection_error: true,
  pool_size: 10
