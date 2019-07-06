defmodule Crit.Users.Workflow.NewUserTest do
  use Crit.DataCase

  alias Crit.Users
  alias Crit.Users.User
  import Crit.Test.Util

  def creation_and_first_save(params) do
    assert {:ok, user} = Users.user_needing_activation(params)

    assert_same_values(user, params, User.creation_attrs)
    assert is_binary(user.password_token.text)

    user
  end

  def show_password_token(token_text) do
    assert {:ok, user_id} = Users.user_id_from_token(token_text)
    user_id
  end

  def supply_new_password(user_id, new_password) do
    params = %{"new_password" => new_password,
               "new_password_confirmation" => new_password}
    assert :ok = Users.set_password(user_id, params)
  end

  test "successful creation through activation" do
    user = creation_and_first_save(user_creation_params())

    user_id = show_password_token(user.password_token.text)
    assert user.id == user_id

    new_password = "something horse something something"
    assert :error = Users.check_password(user.auth_id, new_password)
    supply_new_password(user_id, new_password)
    assert :ok = Users.check_password(user.auth_id, new_password)
  end

end