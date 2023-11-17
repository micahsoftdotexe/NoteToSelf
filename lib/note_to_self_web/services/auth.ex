defmodule NoteToSelfWeb.Service.Auth do
  alias NoteToSelf.Repo
  alias NoteToSelf.Auth.{User, Token}

  @doc """
   Checks user credentials and returns both an access token and refresh token if successful

    ## Examples

        iex> login("foo@example.com", "correct_password")
        {:ok, %{:access_token, :refresh_token}}

        iex> login("foo@example.com", "invalid_password")
        {:error, :invalid_login}

  """
  def login(email, password) do
    with(
      {:ok, user} <- authenticate(email, password),
      {:ok, jwt, _full_claims} <- Token.encode_and_sign(user, %{}, ttl: {30, :minute}),
      {:ok, cookieJWT, _full_claims} <- Token.encode_and_sign(user, %{}, [ttl: {1, :day}, type: :refresh])
    ) do
      {:ok, %{:access_token => jwt, :refresh_token => cookieJWT}}
    else
      _any -> {:error, :invalid_login}
    end
  end

  def get_admin_user() do
    Repo.get_by(User, [is_admin: true])
  end

  defp authenticate(email, password)
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
