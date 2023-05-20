defmodule Ariake.Admin.AdminUserAdmin do
  def custom_links(_schema) do
    [
      %{
        name: "Log Out",
        url: "http://localhost:3000/admin_user/log_out",
        method: :delete,
        order: 2,
        location: :top,
        icon: "sign-out-alt"
      }
    ]
  end
end
