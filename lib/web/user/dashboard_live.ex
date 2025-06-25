defmodule Web.User.DashboardLive do
  use Phoenix.LiveView

  alias Web.Layouts

  # Routes generation with the ~p sigil
  use Web.VerifiedRoutes

  import Phoenix.Controller, only: [get_csrf_token: 0]

  def mount(_params, session, socket) do
    user_id = Map.get(session, "user_id")
    current_user = if user_id, do: MyApp.Users.get(user_id)

    {:ok,
     socket
     |> assign(:current_user, current_user)
     |> assign(:page_title, "User Dashboard")}
  end

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_user={assigns[:current_user]}>
      <div class="min-h-screen bg-black dashboard-container">
        <div class="max-w-7xl mx-auto px-6 py-8 dashboard-content">
          <div class="flex items-center justify-between mb-8 dashboard-header">
            <h1 class="text-4xl font-bold text-white dashboard-title">User Dashboard</h1>
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

          <div class="bg-white/5 rounded-lg p-6 items-section">
            <h2 class="text-2xl font-bold text-white mb-4 items-title">Your Items</h2>
            <p class="text-gray-300 items-description">
              Lorem ipsum dolor sit amet, consectetur adipiscing elit. Your personalized items will appear here.
            </p>
            <div class="mt-4 items-actions">
              <button class="px-6 py-3 bg-red-600 text-white rounded-lg hover:bg-red-700 transition-colors view-items-button">
                View Items
              </button>
            </div>
          </div>

          <div class="mt-8 bg-white/5 rounded-lg p-6 activity-section">
            <h2 class="text-2xl font-bold text-white mb-4 activity-title">Recent Activity</h2>
            <p class="text-gray-400 activity-placeholder">
              Sed do eiusmod tempor incididunt ut labore. Activity feed will appear here.
            </p>
          </div>
        </div>
      </div>
    </Layouts.app>
    """
  end
end
