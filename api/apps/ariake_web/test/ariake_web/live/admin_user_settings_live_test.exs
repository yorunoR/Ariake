defmodule AriakeWeb.AdminUserSettingsLiveTest do
  use AriakeWeb.ConnCase

  alias Ariake.Admin
  import Phoenix.LiveViewTest
  import Ariake.AdminFixtures

  describe "Settings page" do
    test "renders settings page", %{conn: conn} do
      {:ok, _lv, html} =
        conn
        |> log_in_admin_user(admin_user_fixture())
        |> live(~p"/admin_user/settings")

      assert html =~ "Change Email"
      assert html =~ "Change Password"
    end

    test "redirects if admin_user is not logged in", %{conn: conn} do
      assert {:error, redirect} = live(conn, ~p"/admin_user/settings")

      assert {:redirect, %{to: path, flash: flash}} = redirect
      assert path == ~p"/admin_user/log_in"
      assert %{"error" => "You must log in to access this page."} = flash
    end
  end

  describe "update email form" do
    setup %{conn: conn} do
      password = valid_admin_user_password()
      admin_user = admin_user_fixture(%{password: password})
      %{conn: log_in_admin_user(conn, admin_user), admin_user: admin_user, password: password}
    end

    test "updates the admin_user email", %{conn: conn, password: password, admin_user: admin_user} do
      new_email = unique_admin_user_email()

      {:ok, lv, _html} = live(conn, ~p"/admin_user/settings")

      result =
        lv
        |> form("#email_form", %{
          "current_password" => password,
          "admin_user" => %{"email" => new_email}
        })
        |> render_submit()

      assert result =~ "A link to confirm your email"
      assert Admin.get_admin_user_by_email(admin_user.email)
    end

    test "renders errors with invalid data (phx-change)", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/admin_user/settings")

      result =
        lv
        |> element("#email_form")
        |> render_change(%{
          "action" => "update_email",
          "current_password" => "invalid",
          "admin_user" => %{"email" => "with spaces"}
        })

      assert result =~ "Change Email"
      assert result =~ "must have the @ sign and no spaces"
    end

    test "renders errors with invalid data (phx-submit)", %{conn: conn, admin_user: admin_user} do
      {:ok, lv, _html} = live(conn, ~p"/admin_user/settings")

      result =
        lv
        |> form("#email_form", %{
          "current_password" => "invalid",
          "admin_user" => %{"email" => admin_user.email}
        })
        |> render_submit()

      assert result =~ "Change Email"
      assert result =~ "did not change"
      assert result =~ "is not valid"
    end
  end

  describe "update password form" do
    setup %{conn: conn} do
      password = valid_admin_user_password()
      admin_user = admin_user_fixture(%{password: password})
      %{conn: log_in_admin_user(conn, admin_user), admin_user: admin_user, password: password}
    end

    test "updates the admin_user password", %{
      conn: conn,
      admin_user: admin_user,
      password: password
    } do
      new_password = valid_admin_user_password()

      {:ok, lv, _html} = live(conn, ~p"/admin_user/settings")

      form =
        form(lv, "#password_form", %{
          "current_password" => password,
          "admin_user" => %{
            "email" => admin_user.email,
            "password" => new_password,
            "password_confirmation" => new_password
          }
        })

      render_submit(form)

      new_password_conn = follow_trigger_action(form, conn)

      assert redirected_to(new_password_conn) == ~p"/admin_user/settings"

      assert get_session(new_password_conn, :admin_user_token) !=
               get_session(conn, :admin_user_token)

      assert Phoenix.Flash.get(new_password_conn.assigns.flash, :info) =~
               "Password updated successfully"

      assert Admin.get_admin_user_by_email_and_password(admin_user.email, new_password)
    end

    test "renders errors with invalid data (phx-change)", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/admin_user/settings")

      result =
        lv
        |> element("#password_form")
        |> render_change(%{
          "current_password" => "invalid",
          "admin_user" => %{
            "password" => "too short",
            "password_confirmation" => "does not match"
          }
        })

      assert result =~ "Change Password"
      assert result =~ "should be at least 12 character(s)"
      assert result =~ "does not match password"
    end

    test "renders errors with invalid data (phx-submit)", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/admin_user/settings")

      result =
        lv
        |> form("#password_form", %{
          "current_password" => "invalid",
          "admin_user" => %{
            "password" => "too short",
            "password_confirmation" => "does not match"
          }
        })
        |> render_submit()

      assert result =~ "Change Password"
      assert result =~ "should be at least 12 character(s)"
      assert result =~ "does not match password"
      assert result =~ "is not valid"
    end
  end

  describe "confirm email" do
    setup %{conn: conn} do
      admin_user = admin_user_fixture()
      email = unique_admin_user_email()

      token =
        extract_admin_user_token(fn url ->
          Admin.deliver_admin_user_update_email_instructions(
            %{admin_user | email: email},
            admin_user.email,
            url
          )
        end)

      %{
        conn: log_in_admin_user(conn, admin_user),
        token: token,
        email: email,
        admin_user: admin_user
      }
    end

    test "updates the admin_user email once", %{
      conn: conn,
      admin_user: admin_user,
      token: token,
      email: email
    } do
      {:error, redirect} = live(conn, ~p"/admin_user/settings/confirm_email/#{token}")

      assert {:live_redirect, %{to: path, flash: flash}} = redirect
      assert path == ~p"/admin_user/settings"
      assert %{"info" => message} = flash
      assert message == "Email changed successfully."
      refute Admin.get_admin_user_by_email(admin_user.email)
      assert Admin.get_admin_user_by_email(email)

      # use confirm token again
      {:error, redirect} = live(conn, ~p"/admin_user/settings/confirm_email/#{token}")
      assert {:live_redirect, %{to: path, flash: flash}} = redirect
      assert path == ~p"/admin_user/settings"
      assert %{"error" => message} = flash
      assert message == "Email change link is invalid or it has expired."
    end

    test "does not update email with invalid token", %{conn: conn, admin_user: admin_user} do
      {:error, redirect} = live(conn, ~p"/admin_user/settings/confirm_email/oops")
      assert {:live_redirect, %{to: path, flash: flash}} = redirect
      assert path == ~p"/admin_user/settings"
      assert %{"error" => message} = flash
      assert message == "Email change link is invalid or it has expired."
      assert Admin.get_admin_user_by_email(admin_user.email)
    end

    test "redirects if admin_user is not logged in", %{token: token} do
      conn = build_conn()
      {:error, redirect} = live(conn, ~p"/admin_user/settings/confirm_email/#{token}")
      assert {:redirect, %{to: path, flash: flash}} = redirect
      assert path == ~p"/admin_user/log_in"
      assert %{"error" => message} = flash
      assert message == "You must log in to access this page."
    end
  end
end
