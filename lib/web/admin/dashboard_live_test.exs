defmodule Web.Admin.DashboardLiveTest do
  use Web.ConnCase, async: false
  import Phoenix.LiveViewTest

  alias Data.Factory
  alias Data.User

  setup do
    admin =
      Factory.insert(User,
        name: "Admin User",
        email: "admin@example.com",
        auth0_id: "auth0|admin123",
        role: :admin
      )

    user1 =
      Factory.insert(User,
        name: "Test User 1",
        email: "user1@example.com",
        auth0_id: "auth0|user123",
        role: :user
      )

    user2 =
      Factory.insert(User,
        name: "Test User 2",
        email: "user2@example.com",
        auth0_id: "auth0|user456",
        role: :user
      )

    %{admin: admin, user1: user1, user2: user2}
  end

  describe "Admin Dashboard LiveView" do
    test "admin can mount and view dashboard", %{conn: conn, admin: admin} do
      conn = init_test_session(conn, %{user_id: admin.id})

      {:ok, _view, html} = live(conn, ~p"/admin/dashboard")

      {:ok, document} = Floki.parse_document(html)

      # Verify page title using semantic class
      assert [_] = Floki.find(document, ".dashboard-title")
      dashboard_title_text = Floki.text(Floki.find(document, ".dashboard-title"))
      assert dashboard_title_text =~ "Admin Dashboard"

      # Verify welcome message with user name using semantic class
      assert [_] = Floki.find(document, ".welcome-message")
      welcome_text = Floki.text(Floki.find(document, ".welcome-message"))
      assert welcome_text =~ "Welcome, Admin User"

      # Verify logout button using semantic class
      assert [_] = Floki.find(document, ".logout-button")
      logout_text = Floki.text(Floki.find(document, ".logout-button"))
      assert logout_text =~ "Logout"

      # Verify CSRF token is present
      assert [_] = Floki.find(document, "input[name='_csrf_token']")
    end

    test "displays system users section", %{conn: conn, admin: admin} do
      conn = init_test_session(conn, %{user_id: admin.id})

      {:ok, _view, html} = live(conn, ~p"/admin/dashboard")
      {:ok, document} = Floki.parse_document(html)

      # Check for users section using semantic class
      assert [_] = Floki.find(document, ".users-title")
      users_title_text = Floki.text(Floki.find(document, ".users-title"))
      assert users_title_text =~ "System Users"

      # Check for users list using semantic class
      assert [_] = Floki.find(document, ".users-list")
    end

    test "displays user cards correctly", %{conn: conn, admin: admin} do
      conn = init_test_session(conn, %{user_id: admin.id})

      {:ok, _view, html} = live(conn, ~p"/admin/dashboard")
      {:ok, document} = Floki.parse_document(html)

      # Check for user cards using semantic class
      user_cards = Floki.find(document, ".user-card")
      assert length(user_cards) >= 2

      # Verify user name appears using semantic class
      assert user_name_elements = Floki.find(document, ".user-name")
      assert length(user_name_elements) >= 1
      user_name_elements = Floki.find(document, ".user-name")
      user_names_text = Enum.map(user_name_elements, &Floki.text/1) |> Enum.join(" ")
      assert user_names_text =~ "Test User"

      # Verify user email appears using semantic class
      assert user_email_elements = Floki.find(document, ".user-email")
      assert length(user_email_elements) >= 1
      user_email_elements = Floki.find(document, ".user-email")
      user_emails_text = Enum.map(user_email_elements, &Floki.text/1) |> Enum.join(" ")
      assert user_emails_text =~ "@example.com"

      # Verify user role appears using semantic class
      assert user_role_elements = Floki.find(document, ".user-role")
      assert length(user_role_elements) >= 1
      user_role_elements = Floki.find(document, ".user-role")
      user_roles_text = Enum.map(user_role_elements, &Floki.text/1) |> Enum.join(" ")
      assert user_roles_text =~ "user"
    end

    test "displays system management section", %{conn: conn, admin: admin} do
      conn = init_test_session(conn, %{user_id: admin.id})

      {:ok, _view, html} = live(conn, ~p"/admin/dashboard")
      {:ok, document} = Floki.parse_document(html)

      # Check for management section using semantic class
      assert [_] = Floki.find(document, ".management-title")
      management_title_text = Floki.text(Floki.find(document, ".management-title"))
      assert management_title_text =~ "System Management"

      # Check for management buttons using semantic class
      assert [_] = Floki.find(document, ".manage-users-button")
      manage_users_text = Floki.text(Floki.find(document, ".manage-users-button"))
      assert manage_users_text =~ "Manage Users"

      assert [_] = Floki.find(document, ".system-settings-button")
      system_settings_text = Floki.text(Floki.find(document, ".system-settings-button"))
      assert system_settings_text =~ "System Settings"
    end

    test "has correct styling and layout classes", %{conn: conn, admin: admin} do
      conn = init_test_session(conn, %{user_id: admin.id})

      {:ok, _view, html} = live(conn, ~p"/admin/dashboard")
      {:ok, document} = Floki.parse_document(html)

      # Check for dashboard container using semantic class
      assert [_] = Floki.find(document, ".dashboard-container")

      # Check for dashboard content using semantic class
      assert [_] = Floki.find(document, ".dashboard-content")

      # Check for dashboard header using semantic class
      assert [_] = Floki.find(document, ".dashboard-header")

      # Check for users section using semantic class
      assert [_] = Floki.find(document, ".users-section")

      # Check for management section using semantic class
      assert [_] = Floki.find(document, ".management-section")

      # Check for responsive layout
      assert [_] = Floki.find(document, ".max-w-7xl.mx-auto")
    end

    test "non-admin users cannot access admin dashboard", %{conn: conn, user1: user1} do
      conn = init_test_session(conn, %{user_id: user1.id})

      assert {:error, {:redirect, %{to: "/"}}} =
               live(conn, ~p"/admin/dashboard")
    end

    test "unauthenticated users are redirected", %{conn: conn} do
      assert {:error, {:redirect, %{to: "/"}}} =
               live(conn, ~p"/admin/dashboard")
    end
  end
end
