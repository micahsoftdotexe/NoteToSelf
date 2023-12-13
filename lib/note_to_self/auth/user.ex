defmodule NoteToSelf.Auth.User do
  use Ecto.Schema
  alias NoteToSelf.Repo
  import Ecto.Changeset

  @derive {Inspect, except: [:password]}
  @primary_key {:id, :binary_id, autogenerate: true}
  schema "users" do
    # field :is_staff, :boolean
    field :email, :string
    field :password, :string, virtual: true, redact: true
    field :hashed_password, :string, redact: true
    field :username, :string
    field :is_admin, :boolean
    field :disabledTS, :naive_datetime
    has_many :user_note_roles, NoteToSelf.Notes.UserNoteRole

    timestamps()
  end

  @doc """
  A user changeset for registration.

  It is important to validate the length of both email and password.
  Otherwise databases may truncate the email without warnings, which
  could lead to unpredictable or insecure behaviour. Long passwords may
  also be very expensive to hash for certain algorithms.

  ## Options

    * `:hash_password` - Hashes the password so it can be stored securely
      in the database and ensures the password field is cleared to prevent
      leaks in the logs. If password hashing is not needed and clearing the
      password field is not desired (like when using this changeset for
      validations on a LiveView form), this option can be set to `false`.
      Defaults to `true`.
  """
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :username, :is_admin])
  end
  def registration_changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :username, :password, :is_admin])
    |> validate_email
    |> validate_username
    |> validate_password
    |> maybe_hash_password
  end

  defp validate_email(changeset) do
    changeset
    |> validate_required([:email])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "must have the @ sign and no spaces")
    |> validate_length(:email, max: 160)
    |> unsafe_validate_unique(:email, NoteToSelf.Repo)
    |> unique_constraint(:email)
  end

  defp validate_username(changeset) do
    changeset
    |> validate_required([:username])
    |> validate_format(:username, ~r/^[A-Za-z0-9]+(?:[ _-][A-Za-z0-9]+)*$/,
      message: "must be a valid username"
    )
    |> validate_length(:username, max: 25)
    |> unsafe_validate_unique(:username, NoteToSelf.Repo)
    |> unique_constraint(:username)
  end

  defp validate_password(changeset) do
    changeset
    |> validate_required([:password])
    |> validate_length(:password, min: 8, max: 80)
    |> validate_format(:password, ~r/[a-z]/, message: "at least one lower case character")
    |> validate_format(:password, ~r/[A-Z]/, message: "at least one upper case character")
    |> validate_format(:password, ~r/[!?@#$%^&*_0-9]/,
      message: "at least one digit or punctuation character"
    )
    |> validate_confirmation(:password, message: "passwords do not match")
  end

  defp maybe_hash_password(changeset) do
    password = get_change(changeset, :password)

    if password && changeset.valid? do
      changeset
      |> put_change(:hashed_password, Argon2.hash_pwd_salt(password))
      |> delete_change(:password)
    else
      changeset
    end
  end

  @doc """
  A user changeset for changing the email.

  It requires the email to change otherwise an error is added.
  """
  def email_changeset(user, attrs) do
    user
    |> cast(attrs, [:email])
    |> validate_email()
    |> case do
      %{changes: %{email: _}} = changeset -> changeset
      %{} = changeset -> add_error(changeset, :email, "did not change")
    end
  end

  @doc """
  A user changeset for changing the password.

  ## Options

    * `:hash_password` - Hashes the password so it can be stored securely
      in the database and ensures the password field is cleared to prevent
      leaks in the logs. If password hashing is not needed and clearing the
      password field is not desired (like when using this changeset for
      validations on a LiveView form), this option can be set to `false`.
      Defaults to `true`.
  """
  def password_changeset(user, attrs) do
    user
    |> cast(attrs, [:password])
    |> validate_confirmation(:password, message: "does not match password")
    |> validate_password
  end


  def disabled_changeset(user, attrs \\ %{}) do
    user
    |> cast(attrs, [:disabledTS])
  end

  @doc """
  Verifies the password.

  If there is no user or the user doesn't have a password, we call
  `Bcrypt.no_user_verify/0` to avoid timing attacks.
  """
  def valid_password?(%NoteToSelf.Auth.User{hashed_password: hashed_password}, password)
      when is_binary(hashed_password) and byte_size(password) > 0 do
    Argon2.verify_pass(password, hashed_password)
  end

  def valid_password?(_, _) do
    Argon2.no_user_verify()
    false
  end
  def get_user(id) do
    Repo.get(__MODULE__, id)
  end
  def get_admin_user() do
    Repo.get_by(__MODULE__, is_admin: true)
  end

  def get_user_by_username(username) do
    Repo.get_by(__MODULE__, username: username)
  end

  def get_user_by_email(email) do
    Repo.get_by(__MODULE__, email: email)
  end



end
