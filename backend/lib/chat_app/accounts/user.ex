defmodule AuthTutorialPhoenix.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :email, :string
    field :first_name, :string
    field :last_name, :string
    field :password, :string

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:first_name, :last_name, :email, :password])
    |> validate_required([:first_name, :last_name, :email, :password])
    |> unique_constraint(:email)
  end
  # Registration changeset is specfically the shit you want to do when registering, the normal changeset is for later other stuff
  def registration_changeset(user, attrs) do
    user
    |> cast(attrs, [:first_name, :last_name, :email, :password])
    |> validate_required([:first_name, :last_name, :email, :password])
    |> unique_constraint(:email)
    |> encrypt_and_put_password()
  end

  defp encrypt_and_put_password(user) do
    with password <- fetch_field!(user,:password) do
      # Bascially says with the password, fetch the field and do something in there
      encrypted_password=Bcrypt.base.hash_password(password,Bcrypt.gen_salt(12,true))
      put_change(user, :password, encrypted_password)
      # Okay it's a bit complicated but according to the tutorial what we have done within the function is:
      # We store inside of the encrypted password the bcrypt.hash password function, and we pass in the password the user sends us and we will salt it with a 12 round
      # and pass true for legacy, the rounds basically are the exponent of 2 algorithim for how many times the internal hashing loop runs, too many times and it's laggy
      # because you have to verify and stuff each time, but at the same time harder for the attacker to get the password. Increase security decrease speed basically so don't
      # set it up to 1000 or whatever

      # Then we put this actual change to update the users password with the encrypted password, and we have to actually set up and use this function within the
      # registration change_set
    end
  end
end
