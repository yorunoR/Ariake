defmodule AriakeWeb.AdminUserAuthTest do
  use AriakeWeb.ConnCase, async: true

  alias Phoenix.LiveView
  alias Ariake.Admin
  alias AriakeWeb.AdminUserAuth
  import Ariake.AdminFixtures

  @remember_me_cookie "_ariake_web_admin_user_remember_me"

  setup %{conn: conn} do
    conn =
      conn
      |> Map.replace!(:secret_key_base, AriakeWeb.Endpoint.config(:secret_key_base))
      |> init_test_session(%{})

    %{admin_user: admin_user_fixture(), conn: conn}
  end

  describe "log_in_admin_user/3" do
    test "stores the admin_user token in the session", %{conn: conn, admin_user: admin_user} do
      conn = AdminUserAuth.log_in_admin_user(conn, admin_user)
      assert token = get_session(conn, :admin_user_token)

      assert get_session(conn, :live_socket_id) ==
               "admin_user_sessions:#{Base.url_encode64(token)}"

      assert redirected_to(conn) == ~p"/"
      assert Admin.get_admin_user_by_session_token(token)
    end

    test "clears everything previously stored in the session", %{
      conn: conn,
      admin_user: admin_user
    } do
      conn =
        conn
        |> put_session(:to_be_removed, "value")
        |> AdminUserAuth.log_in_admin_user(admin_user)

      refute get_session(conn, :to_be_removed)
    end

    test "redirects to the configured path", %{conn: conn, admin_user: admin_user} do
      conn =
        conn
        |> put_session(:admin_user_return_to, "/hello")
        |> AdminUserAuth.log_in_admin_user(admin_user)

      assert redirected_to(conn) == "/hello"
    end

    test "writes a cookie if remember_me is configured", %{conn: conn, admin_user: admin_user} do
      conn =
        conn
        |> fetch_cookies()
        |> AdminUserAuth.log_in_admin_user(admin_user, %{"remember_me" => "true"})

      assert get_session(conn, :admin_user_token) == conn.cookies[@remember_me_cookie]

      assert %{value: signed_token, max_age: max_age} = conn.resp_cookies[@remember_me_cookie]
      assert signed_token != get_session(conn, :admin_user_token)
      assert max_age == 5_184_000
    end
  end

  describe "logout_admin_user/1" do
    test "erases session and cookies", %{conn: conn, admin_user: admin_user} do
      admin_user_token = Admin.generate_admin_user_session_token(admin_user)

      conn =
        conn
        |> put_session(:admin_user_token, admin_user_token)
        |> put_req_cookie(@remember_me_cookie, admin_user_token)
        |> fetch_cookies()
        |> AdminUserAuth.log_out_admin_user()

      refute get_session(conn, :admin_user_token)
      refute conn.cookies[@remember_me_cookie]
      assert %{max_age: 0} = conn.resp_cookies[@remember_me_cookie]
      assert redirected_to(conn) == ~p"/"
      refute Admin.get_admin_user_by_session_token(admin_user_token)
    end

    test "broadcasts to the given live_socket_id", %{conn: conn} do
      live_socket_id = "admin_user_sessions:abcdef-token"
      AriakeWeb.Endpoint.subscribe(live_socket_id)

      conn
      |> put_session(:live_socket_id, live_socket_id)
      |> AdminUserAuth.log_out_admin_user()

      assert_receive %Phoenix.Socket.Broadcast{event: "disconnect", topic: ^live_socket_id}
    end

    test "works even if admin_user is already logged out", %{conn: conn} do
      conn = conn |> fetch_cookies() |> AdminUserAuth.log_out_admin_user()
      refute get_session(conn, :admin_user_token)
      assert %{max_age: 0} = conn.resp_cookies[@remember_me_cookie]
      assert redirected_to(conn) == ~p"/"
    end
  end

  describe "fetch_current_admin_user/2" do
    test "authenticates admin_user from session", %{conn: conn, admin_user: admin_user} do
      admin_user_token = Admin.generate_admin_user_session_token(admin_user)

      conn =
        conn
        |> put_session(:admin_user_token, admin_user_token)
        |> AdminUserAuth.fetch_current_admin_user([])

      assert conn.assigns.current_admin_user.id == admin_user.id
    end

    test "authenticates admin_user from cookies", %{conn: conn, admin_user: admin_user} do
      logged_in_conn =
        conn
        |> fetch_cookies()
        |> AdminUserAuth.log_in_admin_user(admin_user, %{"remember_me" => "true"})

      admin_user_token = logged_in_conn.cookies[@remember_me_cookie]
      %{value: signed_token} = logged_in_conn.resp_cookies[@remember_me_cookie]

      conn =
        conn
        |> put_req_cookie(@remember_me_cookie, signed_token)
        |> AdminUserAuth.fetch_current_admin_user([])

      assert conn.assigns.current_admin_user.id == admin_user.id
      assert get_session(conn, :admin_user_token) == admin_user_token

      assert get_session(conn, :live_socket_id) ==
               "admin_user_sessions:#{Base.url_encode64(admin_user_token)}"
    end

    test "does not authenticate if data is missing", %{conn: conn, admin_user: admin_user} do
      _ = Admin.generate_admin_user_session_token(admin_user)
      conn = AdminUserAuth.fetch_current_admin_user(conn, [])
      refute get_session(conn, :admin_user_token)
      refute conn.assigns.current_admin_user
    end
  end

  describe "on_mount: mount_current_admin_user" do
    test "assigns current_admin_user based on a valid admin_user_token ", %{
      conn: conn,
      admin_user: admin_user
    } do
      admin_user_token = Admin.generate_admin_user_session_token(admin_user)
      session = conn |> put_session(:admin_user_token, admin_user_token) |> get_session()

      {:cont, updated_socket} =
        AdminUserAuth.on_mount(:mount_current_admin_user, %{}, session, %LiveView.Socket{})

      assert updated_socket.assigns.current_admin_user.id == admin_user.id
    end

    test "assigns nil to current_admin_user assign if there isn't a valid admin_user_token ", %{
      conn: conn
    } do
      admin_user_token = "invalid_token"
      session = conn |> put_session(:admin_user_token, admin_user_token) |> get_session()

      {:cont, updated_socket} =
        AdminUserAuth.on_mount(:mount_current_admin_user, %{}, session, %LiveView.Socket{})

      assert updated_socket.assigns.current_admin_user == nil
    end

    test "assigns nil to current_admin_user assign if there isn't a admin_user_token", %{
      conn: conn
    } do
      session = conn |> get_session()

      {:cont, updated_socket} =
        AdminUserAuth.on_mount(:mount_current_admin_user, %{}, session, %LiveView.Socket{})

      assert updated_socket.assigns.current_admin_user == nil
    end
  end

  describe "on_mount: ensure_authenticated" do
    test "authenticates current_admin_user based on a valid admin_user_token ", %{
      conn: conn,
      admin_user: admin_user
    } do
      admin_user_token = Admin.generate_admin_user_session_token(admin_user)
      session = conn |> put_session(:admin_user_token, admin_user_token) |> get_session()

      {:cont, updated_socket} =
        AdminUserAuth.on_mount(:ensure_authenticated, %{}, session, %LiveView.Socket{})

      assert updated_socket.assigns.current_admin_user.id == admin_user.id
    end

    test "redirects to login page if there isn't a valid admin_user_token ", %{conn: conn} do
      admin_user_token = "invalid_token"
      session = conn |> put_session(:admin_user_token, admin_user_token) |> get_session()

      socket = %LiveView.Socket{
        endpoint: AriakeWeb.Endpoint,
        assigns: %{__changed__: %{}, flash: %{}}
      }

      {:halt, updated_socket} =
        AdminUserAuth.on_mount(:ensure_authenticated, %{}, session, socket)

      assert updated_socket.assigns.current_admin_user == nil
    end

    test "redirects to login page if there isn't a admin_user_token ", %{conn: conn} do
      session = conn |> get_session()

      socket = %LiveView.Socket{
        endpoint: AriakeWeb.Endpoint,
        assigns: %{__changed__: %{}, flash: %{}}
      }

      {:halt, updated_socket} =
        AdminUserAuth.on_mount(:ensure_authenticated, %{}, session, socket)

      assert updated_socket.assigns.current_admin_user == nil
    end
  end

  describe "on_mount: :redirect_if_admin_user_is_authenticated" do
    test "redirects if there is an authenticated  admin_user ", %{
      conn: conn,
      admin_user: admin_user
    } do
      admin_user_token = Admin.generate_admin_user_session_token(admin_user)
      session = conn |> put_session(:admin_user_token, admin_user_token) |> get_session()

      assert {:halt, _updated_socket} =
               AdminUserAuth.on_mount(
                 :redirect_if_admin_user_is_authenticated,
                 %{},
                 session,
                 %LiveView.Socket{}
               )
    end

    test "Don't redirect is there is no authenticated admin_user", %{conn: conn} do
      session = conn |> get_session()

      assert {:cont, _updated_socket} =
               AdminUserAuth.on_mount(
                 :redirect_if_admin_user_is_authenticated,
                 %{},
                 session,
                 %LiveView.Socket{}
               )
    end
  end

  describe "redirect_if_admin_user_is_authenticated/2" do
    test "redirects if admin_user is authenticated", %{conn: conn, admin_user: admin_user} do
      conn =
        conn
        |> assign(:current_admin_user, admin_user)
        |> AdminUserAuth.redirect_if_admin_user_is_authenticated([])

      assert conn.halted
      assert redirected_to(conn) == ~p"/"
    end

    test "does not redirect if admin_user is not authenticated", %{conn: conn} do
      conn = AdminUserAuth.redirect_if_admin_user_is_authenticated(conn, [])
      refute conn.halted
      refute conn.status
    end
  end

  describe "require_authenticated_admin_user/2" do
    test "redirects if admin_user is not authenticated", %{conn: conn} do
      conn = conn |> fetch_flash() |> AdminUserAuth.require_authenticated_admin_user([])
      assert conn.halted

      assert redirected_to(conn) == ~p"/admin_user/log_in"

      assert Phoenix.Flash.get(conn.assigns.flash, :error) ==
               "You must log in to access this page."
    end

    test "stores the path to redirect to on GET", %{conn: conn} do
      halted_conn =
        %{conn | path_info: ["foo"], query_string: ""}
        |> fetch_flash()
        |> AdminUserAuth.require_authenticated_admin_user([])

      assert halted_conn.halted
      assert get_session(halted_conn, :admin_user_return_to) == "/foo"

      halted_conn =
        %{conn | path_info: ["foo"], query_string: "bar=baz"}
        |> fetch_flash()
        |> AdminUserAuth.require_authenticated_admin_user([])

      assert halted_conn.halted
      assert get_session(halted_conn, :admin_user_return_to) == "/foo?bar=baz"

      halted_conn =
        %{conn | path_info: ["foo"], query_string: "bar", method: "POST"}
        |> fetch_flash()
        |> AdminUserAuth.require_authenticated_admin_user([])

      assert halted_conn.halted
      refute get_session(halted_conn, :admin_user_return_to)
    end

    test "does not redirect if admin_user is authenticated", %{conn: conn, admin_user: admin_user} do
      conn =
        conn
        |> assign(:current_admin_user, admin_user)
        |> AdminUserAuth.require_authenticated_admin_user([])

      refute conn.halted
      refute conn.status
    end
  end
end
