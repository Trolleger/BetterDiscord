defmodule ChatApp.Accounts do
@moduledoc """
The Accounts context.
"""
import Ecto.Query, warn: false
alias ChatApp.Repo

alias ChatApp.Accounts.User

def create_user(attrs) do
  # Passes in the attributes the user gives
  %User{}
  # creats a struct. Insure that %User has the first letter as uppercase you know?
  |> User.registration_changeset(attrs)
  # after processing that in the changeset
  |> Repo.insert()
  # Insert the data inside of the repo, this basically just creates a user for user. now we want to insert it inside of the controller

end
end
