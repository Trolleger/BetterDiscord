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

  def get_by_email(email) do
    # Build a query to find a user where the email field matches the given email
    query = from(u in User, where: u.email == ^email)

    # Run the query with Repo.one, which returns:
    # - nil if no user is found
    # - the user struct if a match is found
    case Repo.one(query) do
      # Return an error tuple if no user was found
      nil -> {:error, :not_found}
      # Return a success tuple with the user struct
      user -> {:ok, user}
    end
  end

  def get_by_id!(id) do
    User |> Repo.get!(id)
    # we pass the ID and look inside the repo for a user that has that exact id
  end

  # Now we want to create a function that AUTHENTICATES the user
  def authenticate_user(email, password) do
    with {:ok, user} <- get_by_email(email) do
      case validate_password(password, user.password) do
        false -> {:error, :unauthorized}
        true -> {:ok, user}
        # As you can see: we are going to basically get the user by email, (which is the get_by_email function we made earlier)
        # and we want to valdiate the password which basically compares the password that someone who tries to login gives us and compare it to their user.password
        # That is stored within our database. To do this first we have to actually create our validate password function which is below as of writing

      end
    end
  end
  defp validate_password(password, encrypted_password) do
    Bcrypt.verify_pass(password, encrypted_password)
    # This is basically all we need to authenticate a user within the accounts context file
  end
end
