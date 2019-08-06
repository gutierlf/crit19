defmodule Crit.Users.UserTest do
  use Crit.DataCase
  alias Crit.Users
  alias Pile.Changeset
  alias Crit.Users.PermissionList
  alias Crit.Sql

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
    first_params = Factory.string_params_for(:user)
    assert {:ok, _} = Users.user_needing_activation(first_params, @default_institution)

    second_params = Factory.string_params_for(:user, auth_id: first_params["auth_id"])
    assert {:error, changeset} = Users.user_needing_activation(second_params, @default_institution)

    assert errors_on(changeset) == %{auth_id: ["has already been taken"]}
  end
  
    

  describe "fetching a user by the auth id" do
    test "success" do
      user = Factory.build(:user) |> Sql.insert!(@default_institution)
      assert {:ok, fetched} = Users.user_from_auth_id(user.auth_id, @default_institution)
      assert fetched.auth_id == user.auth_id
      assert_without_permissions(fetched)
    end

    test "failure" do
      assert {:error, message} = Users.user_from_auth_id("missing", @default_institution)
      assert message =~ "no such user 'missing'"
    end
  end

  describe "getting a fully permissioned user" do
    test "does not exist" do
      refute Users.permissioned_user_from_id(3838, @default_institution)
    end

    test "does exist" do
      original = Factory.build(:user) |> Sql.insert!(@default_institution)
      assert fetched = Users.permissioned_user_from_id(original.id, @default_institution)
      assert fetched.permission_list == original.permission_list
    end
  end

  test "fetching all *active* users" do
    visible = Factory.build(:user) |> Sql.insert!(@default_institution)
    _invisible = Factory.build(:user, active: false) |> Sql.insert!(@default_institution)

    assert [retrieved] = Users.active_users(@default_institution)
    assert retrieved.auth_id == visible.auth_id
  end
end

