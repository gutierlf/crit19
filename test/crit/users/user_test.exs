defmodule Crit.Users.UserTest do
  use Crit.DataCase
  alias Crit.Users
  alias Pile.Changeset
  alias Crit.Users.PermissionList


  test "the fresh/default user changeset contains permissions" do
    changeset = Users.fresh_user_changeset()
    assert %PermissionList{} = changeset.data.permission_list

    assert changeset.valid?
    refute Changeset.represents_form_errors?(changeset)
    refute Changeset.has_changes_for?(changeset, :permission_list)
    
    # for further tests, see `/internal`.
  end

  # See password_token_tests for other tests of initial user creation.
  test "trying to reuse an auth id" do
    first_params = string_params_for_new_user()
    assert {:ok, _} = Users.user_needing_activation(first_params)

    second_params = string_params_for_new_user(auth_id: first_params["auth_id"])
    assert {:error, changeset} = Users.user_needing_activation(second_params)

    assert errors_on(changeset) == %{auth_id: ["has already been taken"]}
  end
  
    

  describe "fetching a user by the auth id" do
    test "success" do
      user = Factory.insert(:user)
      assert {:ok, fetched} = Users.user_from_auth_id(user.auth_id)
      assert fetched.auth_id == user.auth_id
    end

    test "failure" do
      assert {:error, message} = Users.user_from_auth_id("missing")
      assert message =~ "no such user 'missing'"
    end
  end

  
end
