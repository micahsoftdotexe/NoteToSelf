defmodule NoteToSelfWeb.Service.Auth do
  alias NoteToSelf.Repo
  alias NoteToSelf.Auth.{User, Token}

  @doc """
   Checks user's email and password and returns both an access token and refresh token if successful

    ## Examples

        iex> login("foo@example.com", "correct_password")
        {:ok, %{:access_token, :refresh_token}}

        iex> login("foo@example.com", "invalid_password")
        {:error, :invalid_login}

  """
  def login(email, password) do
    with(
      {:ok, user} <- authenticate(email, password),
      {:ok, response} <- fetch_tokens(user)
    ) do
      {:ok, response}
    else
      _any -> {:error, :invalid_login}
    end
  end

  @doc """
   Checks user's username and password and returns both an access token and refresh token if successful

    ## Examples

        iex> login_username("foo", "correct_password")
        {:ok, %{:access_token, :refresh_token}}

        iex> login("foo@example.com", "invalid_password")
        {:error, :invalid_login}

  """
  def login_username(username, password) do
    with(
      {:ok, user} <- authenticate_username(username, password),
      {:ok, response} <- fetch_tokens(user)
    ) do
      {:ok, response}
    else
      _any -> {:error, :invalid_login}
    end
  end

  def refresh(user) do
    with(
      {:ok, response} <- fetch_tokens(user)
    ) do
      {:ok, response}
    else
      _any -> {:error, :invalid_login}
    end
  end

  def get_user(id) do
    Repo.get(User, id)
  end

  def disable(user_id) do
    user = get_user(user_id)
    if user do
      user = User.disabled_changeset(user, %{disabledTS: NaiveDateTime.utc_now()})
      Repo.update(user)
    else
      {:error, :not_found}
    end
  end

  def get_admin_user() do
    Repo.get_by(User, is_admin: true)
  end

  defp authenticate(email, password)
       when is_binary(email) and is_binary(password) do
    user = Repo.get_by(User, email: email)

    if User.valid_password?(user, password) do
      {:ok, user}
    else
      {:error, :invalid_login}
    end
  end

  defp authenticate_username(username, password)
       when is_binary(username) and is_binary(password) do
    user = Repo.get_by(User, username: username)

    if User.valid_password?(user, password) do
      {:ok, user}
    else
      {:error, :invalid_login}
    end
  end

  defp fetch_tokens(user) do
    with(
      {:ok, jwt, _full_claims} <- Token.encode_and_sign(user, %{}, ttl: {30, :minute}),
      {:ok, refresh, _full_claims} <-
        Token.encode_and_sign(user, %{}, ttl: {1, :day}, type: :refresh)
    ) do
      {:ok, %{:access_token => jwt, :refresh_token => refresh}}
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
