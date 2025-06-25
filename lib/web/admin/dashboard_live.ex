defmodule Web.Admin.DashboardLive do
  use Phoenix.LiveView

  alias Web.Layouts

  # Routes generation with the ~p sigil
  use Web.VerifiedRoutes

  import Phoenix.Controller, only: [get_csrf_token: 0]

  alias MyApp.Users

  def mount(_params, session, socket) do
    user_id = Map.get(session, "user_id")
    current_user = if user_id, do: MyApp.Users.get(user_id)

    users = Users.list_users()

    {:ok,
     socket
     |> assign(:current_user, current_user)
     |> assign(:users, users)
     |> assign(:page_title, "Admin Dashboard")}
  end

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_user={assigns[:current_user]}>
      <div class="min-h-screen bg-black dashboard-container">
        <div class="max-w-7xl mx-auto px-6 py-8 dashboard-content">
          <div class="flex items-center justify-between mb-8 dashboard-header">
            <h1 class="text-4xl font-bold text-white dashboard-title">Admin Dashboard</h1>
            <div class="flex items-center space-x-4 dashboard-actions">
              <span class="text-gray-300 welcome-message">
                Welcome, {assigns[:current_user].name}
              </span>
              <form action="/auth/logout" method="post" class="inline logout-form">
                <input type="hidden" name="_csrf_token" value={get_csrf_token()} />
                <button
                  type="submit"
                  class="px-4 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700 transition-colors logout-button"
                >
                  Logout
                </button>
              </form>
            </div>
          </div>

          <div class="bg-white/5 rounded-lg p-6 users-section">
            <h2 class="text-2xl font-bold text-white mb-4 users-title">
              System Users ({length(@users)})
            </h2>
            <div class="space-y-3 users-list">
              <%= for user <- @users do %>
                <div class="bg-white/10 rounded-lg p-4 user-card">
                  <p class="text-white font-semibold user-name">{user.name}</p>
                  <p class="text-gray-300 text-sm user-email">{user.email}</p>
                  <p class="text-gray-400 text-xs user-role">Role: {user.role}</p>
                </div>
              <% end %>
            </div>
          </div>

          <div class="mt-8 bg-white/5 rounded-lg p-6 management-section">
            <h2 class="text-2xl font-bold text-white mb-4 management-title">System Management</h2>
            <p class="text-gray-300 mb-4 management-description">
              Lorem ipsum dolor sit amet, consectetur adipiscing elit. Administrative tools and system management options will appear here.
            </p>
            <div class="space-x-4">
              <button class="px-6 py-3 bg-red-600 text-white rounded-lg hover:bg-red-700 transition-colors manage-users-button">
                Manage Users
              </button>
              <button class="px-6 py-3 bg-white/10 text-white rounded-lg hover:bg-white/20 transition-colors system-settings-button">
                System Settings
              </button>
            </div>
          </div>
        </div>
      </div>
    </Layouts.app>
    """
  end
end
