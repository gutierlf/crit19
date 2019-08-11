defmodule CritWeb.CurrentUser.SettingsControllerTest do
  use CritWeb.ConnCase
  alias CritWeb.CurrentUser.SettingsController, as: UnderTest
  use CritWeb.ConnMacros, controller: UnderTest
  alias Crit.Examples.PasswordFocused
  alias Crit.Users
  alias Crit.Repo
  alias Crit.Users.PasswordToken

  describe "displaying a token to get a form" do
    setup do
      {:ok, %{user: user, token: token}} = Factory.string_params_for(:user) |> Users.create_unactivated_user(@default_institution)
      [token_text: token.text, user: user]
    end

    test "getting the form: there is no matching token", %{conn: conn} do
      conn = get_via_action(conn, :fresh_password_form, "bogus token")
      assert redirected_to(conn) == Routes.public_path(conn, :index)
      assert flash_error(conn) =~ "does not exist"
      assert flash_error(conn) =~ "has probably expired"
    end

    test "getting the form: there is a matching token",
      %{conn: conn, token_text: token_text} do
      conn = get_via_action(conn, :fresh_password_form, token_text)

      assert_purpose conn, create_a_password_without_needing_an_existing_one()
      assert_will_post_to(conn, :set_fresh_password)
      assert {:ok, original_token} = Users.one_token(token_text)
      assert token(conn) == original_token

      # The token is not deleted.
      assert Repo.get_by(PasswordToken, text: token_text)
    end
  end

  describe "setting the password for the first time" do
    setup %{conn: conn} do
      {:ok, %{user: user, token: token}} = Factory.string_params_for(:user) |> Users.create_unactivated_user(@default_institution)

      conn = Plug.Test.init_test_session(conn, token: token)

      run = fn conn, new_password, confirmation ->
        post_to_action(conn, :set_fresh_password,
          under(:password, PasswordFocused.params(new_password, confirmation)))
      end
      
      [conn: conn, valid_password: "something horse something something",
       user: user, run: run]
    end

    test "the password is acceptable",
      %{conn: conn, valid_password: valid_password, user: user, run: run} do

      conn = run.(conn, valid_password, valid_password)
      assert {:ok, user.id} == Users.check_password(user.auth_id, valid_password, @default_institution)
      assert user_id(conn) == user.id
      assert institution(conn) == @default_institution
      refute token(conn)

      assert redirected_to(conn) == Routes.public_path(conn, :index)
      assert flash_info(conn) =~ "You have been logged in"

      # Token has been deleted
      refute Repo.get_by(PasswordToken, user_id: user.id)
    end

    test "something is wrong with the password", 
      %{conn: conn, user: user, valid_password: valid_password, run: run} do

      conn = run.(conn, valid_password, "WRONG")
      refute :ok == Users.check_password(user.auth_id, valid_password, @default_institution)
      assert_purpose conn, create_a_password_without_needing_an_existing_one()
      assert_will_post_to(conn, :set_fresh_password)
      refute user_id(conn)
      refute institution(conn) == @default_institution
      assert token(conn)

      assert_user_sees(conn, 
        [ Common.form_error_message(),
          "should be the same as the new password",
        ])
        
      # The token is not deleted.
      assert Users.one_token(token(conn).text)
    end
  end

end
