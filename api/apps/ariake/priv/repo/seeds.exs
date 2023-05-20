# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Ariake.Repo.insert!(%Ariake.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Ariake.Admin

email = System.get_env("ADMIN_USER_EMAIL")
Admin.register_admin_user(%{email: email, password: "123456123456"})
