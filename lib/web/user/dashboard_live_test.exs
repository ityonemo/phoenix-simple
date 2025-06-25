defmodule Web.User.DashboardLiveTest do
  use Web.ConnCase, async: true
  import Phoenix.LiveViewTest

  alias Data.Factory
  alias Data.User

  setup do
    # Create test users with different roles

    admin =
      Factory.insert(User, role: :admin)

    user =
      Factory.insert(User, role: :user)

    %{admin: admin, user: user}
  end

  describe "Client Dashboard LiveView" do
    test "user can mount and view dashboard", %{conn: conn, user: user} do
      conn = init_test_session(conn, %{user_id: user.id})

      {:ok, _view, html} = live(conn, ~p"/user/dashboard")

      {:ok, document} = Floki.parse_document(html)

      # Verify page title using semantic class
      assert [_] = Floki.find(document, ".dashboard-title")
      dashboard_title_text = Floki.text(Floki.find(document, ".dashboard-title"))
      assert dashboard_title_text =~ "User Dashboard"

      # Verify welcome message with user name using semantic class
      assert [_] = Floki.find(document, ".welcome-message")
      welcome_text = Floki.text(Floki.find(document, ".welcome-message"))
      assert welcome_text =~ "Welcome, #{user.name}"

      # Verify logout button using semantic class
      assert [_] = Floki.find(document, ".logout-button")
      logout_text = Floki.text(Floki.find(document, ".logout-button"))
      assert logout_text =~ "Logout"

      # Verify CSRF token is present
      assert [_] = Floki.find(document, "input[name='_csrf_token']")
    end

    test "displays workout section with placeholder content", %{conn: conn, user: user} do
      conn = init_test_session(conn, %{user_id: user.id})

      {:ok, _view, html} = live(conn, ~p"/user/dashboard")
      {:ok, document} = Floki.parse_document(html)

      # Check for workout section heading using semantic class
      assert [_] = Floki.find(document, ".items-title")
      workouts_title_text = Floki.text(Floki.find(document, ".items-title"))
      assert workouts_title_text =~ "Your Items"

      # Check for placeholder message using semantic class
      assert [_] = Floki.find(document, ".items-description")
      workouts_desc_text = Floki.text(Floki.find(document, ".items-description"))

      assert workouts_desc_text =~ "Your personalized items will appear here"

      # Check for View Workouts button using semantic class
      assert [_] = Floki.find(document, ".view-items-button")
      button_text = Floki.text(Floki.find(document, ".view-items-button"))
      assert button_text =~ "View Items"
    end

    test "has correct styling and layout classes", %{conn: conn, user: user} do
      conn = init_test_session(conn, %{user_id: user.id})

      {:ok, _view, html} = live(conn, ~p"/user/dashboard")
      {:ok, document} = Floki.parse_document(html)

      # Check for dashboard container using semantic class
      assert [_] = Floki.find(document, ".dashboard-container")

      # Check for dashboard content using semantic class
      assert [_] = Floki.find(document, ".dashboard-content")

      # Check for dashboard header using semantic class
      assert [_] = Floki.find(document, ".dashboard-header")

      # Check for workouts section using semantic class
      assert [_] = Floki.find(document, ".items-section")

      # Check for workouts actions using semantic class
      assert [_] = Floki.find(document, ".items-actions")

      # Check for responsive layout
      assert [_] = Floki.find(document, ".max-w-7xl.mx-auto")
    end

    test "non-user users cannot access user dashboard", %{conn: conn, admin: admin} do
      conn = init_test_session(conn, %{user_id: admin.id})

      assert {:error, {:redirect, %{to: "/"}}} = live(conn, ~p"/user/dashboard")
    end

    test "unauthenticated users are redirected", %{conn: conn} do
      assert {:error, {:redirect, %{to: "/"}}} = live(conn, ~p"/user/dashboard")
    end
  end
end
