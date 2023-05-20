defmodule AriakeWeb.AdminUserSessionControllerTest do
  use AriakeWeb.ConnCase, async: true

  import Ariake.AdminFixtures

  setup do
    %{admin_user: admin_user_fixture()}
  end

  describe "POST /admin_user/log_in" do
    test "logs the admin_user in", %{conn: conn, admin_user: admin_user} do
      conn =
        post(conn, ~p"/admin_user/log_in", %{
          "admin_user" => %{
            "email" => admin_user.email,
            "password" => valid_admin_user_password()
          }
        })

      assert get_session(conn, :admin_user_token)
      assert redirected_to(conn) == ~p"/"

      # Now do a logged in request and assert on the menu
      conn = get(conn, ~p"/")
      response = html_response(conn, 200)
      assert response =~ admin_user.email
      assert response =~ ~p"/admin_user/settings"
      assert response =~ ~p"/admin_user/log_out"
    end

    test "logs the admin_user in with remember me", %{conn: conn, admin_user: admin_user} do
      conn =
        post(conn, ~p"/admin_user/log_in", %{
          "admin_user" => %{
            "email" => admin_user.email,
            "password" => valid_admin_user_password(),
            "remember_me" => "true"
          }
        })

      assert conn.resp_cookies["_ariake_web_admin_user_remember_me"]
      assert redirected_to(conn) == ~p"/"
    end

    test "logs the admin_user in with return to", %{conn: conn, admin_user: admin_user} do
      conn =
        conn
        |> init_test_session(admin_user_return_to: "/foo/bar")
        |> post(~p"/admin_user/log_in", %{
          "admin_user" => %{
            "email" => admin_user.email,
            "password" => valid_admin_user_password()
          }
        })

      assert redirected_to(conn) == "/foo/bar"
      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "Welcome back!"
    end

    test "login following registration", %{conn: conn, admin_user: admin_user} do
      conn =
        conn
        |> post(~p"/admin_user/log_in", %{
          "_action" => "registered",
          "admin_user" => %{
            "email" => admin_user.email,
            "password" => valid_admin_user_password()
          }
        })

      assert redirected_to(conn) == ~p"/"
      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "Account created successfully"
    end

    test "login following password update", %{conn: conn, admin_user: admin_user} do
      conn =
        conn
        |> post(~p"/admin_user/log_in", %{
          "_action" => "password_updated",
          "admin_user" => %{
            "email" => admin_user.email,
            "password" => valid_admin_user_password()
          }
        })

      assert redirected_to(conn) == ~p"/admin_user/settings"
      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "Password updated successfully"
    end

    test "redirects to login page with invalid credentials", %{conn: conn} do
      conn =
        post(conn, ~p"/admin_user/log_in", %{
          "admin_user" => %{"email" => "invalid@email.com", "password" => "invalid_password"}
        })

      assert Phoenix.Flash.get(conn.assigns.flash, :error) == "Invalid email or password"
      assert redirected_to(conn) == ~p"/admin_user/log_in"
    end
  end

  describe "DELETE /admin_user/log_out" do
    test "logs the admin_user out", %{conn: conn, admin_user: admin_user} do
      conn = conn |> log_in_admin_user(admin_user) |> delete(~p"/admin_user/log_out")
      assert redirected_to(conn) == ~p"/"
      refute get_session(conn, :admin_user_token)
      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "Logged out successfully"
    end

    test "succeeds even if the admin_user is not logged in", %{conn: conn} do
      conn = delete(conn, ~p"/admin_user/log_out")
      assert redirected_to(conn) == ~p"/"
      refute get_session(conn, :admin_user_token)
      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "Logged out successfully"
    end
  end
end
