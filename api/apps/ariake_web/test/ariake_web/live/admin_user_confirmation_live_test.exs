defmodule AriakeWeb.AdminUserConfirmationLiveTest do
  use AriakeWeb.ConnCase

  import Phoenix.LiveViewTest
  import Ariake.AdminFixtures

  alias Ariake.Admin
  alias Ariake.Repo

  setup do
    %{admin_user: admin_user_fixture()}
  end

  describe "Confirm admin_user" do
    test "renders confirmation page", %{conn: conn} do
      {:ok, _lv, html} = live(conn, ~p"/admin_user/confirm/some-token")
      assert html =~ "Confirm Account"
    end

    test "confirms the given token once", %{conn: conn, admin_user: admin_user} do
      token =
        extract_admin_user_token(fn url ->
          Admin.deliver_admin_user_confirmation_instructions(admin_user, url)
        end)

      {:ok, lv, _html} = live(conn, ~p"/admin_user/confirm/#{token}")

      result =
        lv
        |> form("#confirmation_form")
        |> render_submit()
        |> follow_redirect(conn, "/")

      assert {:ok, conn} = result

      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~
               "AdminUser confirmed successfully"

      assert Admin.get_admin_user!(admin_user.id).confirmed_at
      refute get_session(conn, :admin_user_token)
      assert Repo.all(Admin.AdminUserToken) == []

      # when not logged in
      {:ok, lv, _html} = live(conn, ~p"/admin_user/confirm/#{token}")

      result =
        lv
        |> form("#confirmation_form")
        |> render_submit()
        |> follow_redirect(conn, "/")

      assert {:ok, conn} = result

      assert Phoenix.Flash.get(conn.assigns.flash, :error) =~
               "AdminUser confirmation link is invalid or it has expired"

      # when logged in
      {:ok, lv, _html} =
        build_conn()
        |> log_in_admin_user(admin_user)
        |> live(~p"/admin_user/confirm/#{token}")

      result =
        lv
        |> form("#confirmation_form")
        |> render_submit()
        |> follow_redirect(conn, "/")

      assert {:ok, conn} = result
      refute Phoenix.Flash.get(conn.assigns.flash, :error)
    end

    test "does not confirm email with invalid token", %{conn: conn, admin_user: admin_user} do
      {:ok, lv, _html} = live(conn, ~p"/admin_user/confirm/invalid-token")

      {:ok, conn} =
        lv
        |> form("#confirmation_form")
        |> render_submit()
        |> follow_redirect(conn, ~p"/")

      assert Phoenix.Flash.get(conn.assigns.flash, :error) =~
               "AdminUser confirmation link is invalid or it has expired"

      refute Admin.get_admin_user!(admin_user.id).confirmed_at
    end
  end
end
