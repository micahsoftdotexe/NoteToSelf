defmodule NoteToSelf.Auth do
  alias NoteToSelf.Repo
  alias NoteToSelf.Auth.{User, Token}

  def generate_user_token(user) do
    {:ok, jwt, _full_claims} = Token.encode_and_sign(user)
    jwt
  end
  @doc """
  Gets a user by email and password and validates the credentials.

  ## Examples

      iex> get_user_by_email_and_password("foo@example.com", "correct_password")
      {:ok, %User{}}

      iex> get_user_by_email_and_password("foo@example.com", "invalid_password")
      {:error, :invalid_login}

  """
  def authenticate(email, password)
    when is_binary(email) and is_binary(password) do
      user = Repo.get_by(User, [email: email])
      if User.valid_password?(user, password) do
        {:ok, user}
      else
        {:error, :invalid_login}
      end
    end

  @doc """
  Registers a user.

  ## Examples

      iex> register_user(%{field: value})
      {:ok, %User{}}

      iex> register_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def register_user(attrs) do
    %User{}
    |> User.registration_changeset(attrs)
    |> Repo.insert()
  end

  def register_user!(attrs) do
    %User{}
    |> User.registration_changeset(attrs)
    |> Repo.insert!()
  end

end
