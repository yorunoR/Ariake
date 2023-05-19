IO.puts("====-====-====-====-====")
IO.puts(".iex.exs")

IO.puts("* Import Modules")
import Ecto.Query
import Ariake

IO.puts("* Alias Modules")
alias Ariake.Repo
alias Schemas.Account.User
# alias Queries.AccountQuery

IO.puts("====-====-====-====-====")
