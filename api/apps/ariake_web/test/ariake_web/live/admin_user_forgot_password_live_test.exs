defmodule AriakeWeb.AdminUserForgotPasswordLiveTest do
  use AriakeWeb.ConnCase

  import Phoenix.LiveViewTest
  import Ariake.AdminFixtures

  alias Ariake.Admin
  alias Ariake.Repo

  describe "Forgot password page" do
    test "renders email page", %{conn: conn} do
      {:ok, lv, html} = live(conn, ~p"/admin_user/reset_password")

      assert html =~ "Forgot your password?"
      assert has_element?(lv, ~s|a[href="#{~p"/admin_user/register"}"]|, "Register")
      assert has_element?(lv, ~s|a[href="#{~p"/admin_user/log_in"}"]|, "Log in")
    end

    test "redirects if already logged in", %{conn: conn} do
      result =
        conn
        |> log_in_admin_user(admin_user_fixture())
        |> live(~p"/admin_user/reset_password")
        |> follow_redirect(conn, ~p"/")

      assert {:ok, _conn} = result
    end
  end

  describe "Reset link" do
    setup do
      %{admin_user: admin_user_fixture()}
    end

    test "sends a new reset password token", %{conn: conn, admin_user: admin_user} do
      {:ok, lv, _html} = live(conn, ~p"/admin_user/reset_password")

      {:ok, conn} =
        lv
        |> form("#reset_password_form", admin_user: %{"email" => admin_user.email})
        |> render_submit()
        |> follow_redirect(conn, "/")

      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "If your email is in our system"

      assert Repo.get_by!(Admin.AdminUserToken, admin_user_id: admin_user.id).context ==
               "reset_password"
    end

    test "does not send reset password token if email is invalid", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/admin_user/reset_password")

      {:ok, conn} =
        lv
        |> form("#reset_password_form", admin_user: %{"email" => "unknown@example.com"})
        |> render_submit()
        |> follow_redirect(conn, "/")

      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "If your email is in our system"
      assert Repo.all(Admin.AdminUserToken) == []
    end
  end
end
