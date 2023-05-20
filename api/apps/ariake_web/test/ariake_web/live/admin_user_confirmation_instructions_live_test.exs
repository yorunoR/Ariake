defmodule AriakeWeb.AdminUserConfirmationInstructionsLiveTest do
  use AriakeWeb.ConnCase

  import Phoenix.LiveViewTest
  import Ariake.AdminFixtures

  alias Ariake.Admin
  alias Ariake.Repo

  setup do
    %{admin_user: admin_user_fixture()}
  end

  describe "Resend confirmation" do
    test "renders the resend confirmation page", %{conn: conn} do
      {:ok, _lv, html} = live(conn, ~p"/admin_user/confirm")
      assert html =~ "Resend confirmation instructions"
    end

    test "sends a new confirmation token", %{conn: conn, admin_user: admin_user} do
      {:ok, lv, _html} = live(conn, ~p"/admin_user/confirm")

      {:ok, conn} =
        lv
        |> form("#resend_confirmation_form", admin_user: %{email: admin_user.email})
        |> render_submit()
        |> follow_redirect(conn, ~p"/")

      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~
               "If your email is in our system"

      assert Repo.get_by!(Admin.AdminUserToken, admin_user_id: admin_user.id).context == "confirm"
    end

    test "does not send confirmation token if admin_user is confirmed", %{
      conn: conn,
      admin_user: admin_user
    } do
      Repo.update!(Admin.AdminUser.confirm_changeset(admin_user))

      {:ok, lv, _html} = live(conn, ~p"/admin_user/confirm")

      {:ok, conn} =
        lv
        |> form("#resend_confirmation_form", admin_user: %{email: admin_user.email})
        |> render_submit()
        |> follow_redirect(conn, ~p"/")

      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~
               "If your email is in our system"

      refute Repo.get_by(Admin.AdminUserToken, admin_user_id: admin_user.id)
    end

    test "does not send confirmation token if email is invalid", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/admin_user/confirm")

      {:ok, conn} =
        lv
        |> form("#resend_confirmation_form", admin_user: %{email: "unknown@example.com"})
        |> render_submit()
        |> follow_redirect(conn, ~p"/")

      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~
               "If your email is in our system"

      assert Repo.all(Admin.AdminUserToken) == []
    end
  end
end
