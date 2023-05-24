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
alias Ariake.Repo
alias Schemas.Flow.Prompt

email = System.get_env("ADMIN_USER_EMAIL")
Admin.register_admin_user(%{email: email, password: "123456123456"})

# Summarize
summarize = """
  Summarize the text delimited by triple backticks into a single {__summarize__lang} sentence.

  ```{__summarize__text}```
"""

Repo.insert!(%Prompt{
  template: summarize,
  variables: %{
    text_key: "__summarize__text",
    lang_key: "__summarize__lang"
  }
})

# ToJson
to_json = """
  Provide the text delimited by triple backticks into JSON format with the following keys:
  {__to_json__keys}.


  ```{__to_json__data}```
"""

Repo.insert!(%Prompt{
  template: to_json,
  variables: %{
    data_key: "__to_json__data",
    keys_key: "__to_json__keys"
  }
})
