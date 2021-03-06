defmodule Crit.Users.UserHavingToken do
  alias Crit.Users.Schemas.{User, PasswordToken}
  
  defstruct [:user, :token]

  def new(%User{} = user, %PasswordToken{} = token),
    do: %__MODULE__{user: user, token: token}

  def user(tokenized), do: tokenized.user
  def token(tokenized), do: tokenized.token

  def user_id(tokenized), do: user(tokenized).id
  def display_name(tokenized), do: user(tokenized).display_name
  def auth_id(tokenized), do: user(tokenized).auth_id
  def email(tokenized), do: user(tokenized).email

  def token_text(tokenized), do: token(tokenized).text
end
