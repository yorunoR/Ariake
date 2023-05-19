defmodule AriakeWeb.AdminUserConfirmationLive do
  use AriakeWeb, :live_view

  alias Ariake.Admin

  def render(%{live_action: :edit} = assigns) do
    ~H"""
    <div class="mx-auto max-w-sm">
      <.header class="text-center">Confirm Account</.header>

      <.simple_form for={@form} id="confirmation_form" phx-submit="confirm_account">
        <.input field={@form[:token]} type="hidden" />
        <:actions>
          <.button phx-disable-with="Confirming..." class="w-full">Confirm my account</.button>
        </:actions>
      </.simple_form>

      <p class="text-center mt-4">
        <.link href={~p"/admin_user/register"}>Register</.link>
        | <.link href={~p"/admin_user/log_in"}>Log in</.link>
      </p>
    </div>
    """
  end

  def mount(%{"token" => token}, _session, socket) do
    form = to_form(%{"token" => token}, as: "admin_user")
    {:ok, assign(socket, form: form), temporary_assigns: [form: nil]}
  end

  # Do not log in the admin_user after confirmation to avoid a
  # leaked token giving the admin_user access to the account.
  def handle_event("confirm_account", %{"admin_user" => %{"token" => token}}, socket) do
    case Admin.confirm_admin_user(token) do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:info, "AdminUser confirmed successfully.")
         |> redirect(to: ~p"/")}

      :error ->
        # If there is a current admin_user and the account was already confirmed,
        # then odds are that the confirmation link was already visited, either
        # by some automation or by the admin_user themselves, so we redirect without
        # a warning message.
        case socket.assigns do
          %{current_admin_user: %{confirmed_at: confirmed_at}} when not is_nil(confirmed_at) ->
            {:noreply, redirect(socket, to: ~p"/")}

          %{} ->
            {:noreply,
             socket
             |> put_flash(:error, "AdminUser confirmation link is invalid or it has expired.")
             |> redirect(to: ~p"/")}
        end
    end
  end
end
