defmodule AriakeWeb.AdminUserSessionController do
  use AriakeWeb, :controller

  alias Ariake.Admin
  alias AriakeWeb.AdminUserAuth

  def create(conn, %{"_action" => "registered"} = params) do
    create(conn, params, "Account created successfully!")
  end

  def create(conn, %{"_action" => "password_updated"} = params) do
    conn
    |> put_session(:admin_user_return_to, ~p"/admin_user/settings")
    |> create(params, "Password updated successfully!")
  end

  def create(conn, params) do
    create(conn, params, "Welcome back!")
  end

  defp create(conn, %{"admin_user" => admin_user_params}, info) do
    %{"email" => email, "password" => password} = admin_user_params

    if admin_user = Admin.get_admin_user_by_email_and_password(email, password) do
      conn
      |> put_flash(:info, info)
      |> AdminUserAuth.log_in_admin_user(admin_user, admin_user_params)
    else
      # In order to prevent user enumeration attacks, don't disclose whether the email is registered.
      conn
      |> put_flash(:error, "Invalid email or password")
      |> put_flash(:email, String.slice(email, 0, 160))
      |> redirect(to: ~p"/admin_user/log_in")
    end
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "Logged out successfully.")
    |> AdminUserAuth.log_out_admin_user()
  end
end
