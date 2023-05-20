defmodule AriakeWeb.AdminUserRegistrationLive do
  use AriakeWeb, :live_view

  alias Ariake.Admin
  alias Ariake.Admin.AdminUser

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-sm">
      <.header class="text-center">
        Register for an account
        <:subtitle>
          Already registered?
          <.link navigate={~p"/admin_user/log_in"} class="font-semibold text-brand hover:underline">
            Sign in
          </.link>
          to your account now.
        </:subtitle>
      </.header>

      <div class="text-center" style="font-size: 40px; margin-top: 60px">
        <b> Not accepted now. </b>
      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    changeset = Admin.change_admin_user_registration(%AdminUser{})

    socket =
      socket
      |> assign(trigger_submit: false, check_errors: false)
      |> assign_form(changeset)

    {:ok, socket, temporary_assigns: [form: nil]}
  end

  def handle_event("save", %{"admin_user" => admin_user_params}, socket) do
    case Admin.register_admin_user(admin_user_params) do
      {:ok, admin_user} ->
        {:ok, _} =
          Admin.deliver_admin_user_confirmation_instructions(
            admin_user,
            &url(~p"/admin_user/confirm/#{&1}")
          )

        changeset = Admin.change_admin_user_registration(admin_user)
        {:noreply, socket |> assign(trigger_submit: true) |> assign_form(changeset)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, socket |> assign(check_errors: true) |> assign_form(changeset)}
    end
  end

  def handle_event("validate", %{"admin_user" => admin_user_params}, socket) do
    changeset = Admin.change_admin_user_registration(%AdminUser{}, admin_user_params)
    {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    form = to_form(changeset, as: "admin_user")

    if changeset.valid? do
      assign(socket, form: form, check_errors: false)
    else
      assign(socket, form: form)
    end
  end
end
