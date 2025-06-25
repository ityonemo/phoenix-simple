defmodule Web.Auth.ControllerTest do
  use Web.ConnCase, async: true
  import Mox

  # Make sure mocks are verified when the test exits
  setup :verify_on_exit!

  describe "request/2" do
    test "redirects to Auth0 authorize URL", %{conn: conn} do
      # Mock the OAuth.authorize_url call
      expect(OAuth.Mock, :authorize_url, fn %OAuth.Test{} ->
        {:ok,
         "https://test-domain.auth0.com/authorize?response_type=code&client_id=test_client&redirect_uri=http%3A%2F%2Flocalhost%3A4000%2Fauth%2Fcallback&scope=openid+profile+email&audience=https%3A%2F%2Ftest-domain.auth0.com%2Fapi%2Fv2%2F"}
      end)

      conn = get(conn, ~p"/auth/auth0")

      assert redirected_to(conn, 302)
      location = List.first(get_resp_header(conn, "location"))

      # Verify it redirects to Auth0 domain
      assert location =~ "https://"
      assert location =~ "/authorize"
      assert location =~ "response_type=code"
      assert location =~ "client_id="
      assert location =~ "redirect_uri="
      assert location =~ "scope=openid+profile+email"
    end
  end

  describe "callback/2" do
    test "handles missing authorization code", %{conn: conn} do
      conn = get(conn, ~p"/auth/callback")

      assert redirected_to(conn) == ~p"/"

      assert Phoenix.Flash.get(conn.assigns.flash, :error) ==
               "Authentication failed. Missing authorization code."
    end

    test "handles callback with code but fails OAuth", %{conn: conn} do
      # Mock the OAuth.fetch_token call to return an error
      expect(OAuth.Mock, :fetch_token, fn %OAuth.Test{}, "invalid_test_code" ->
        {:error, "invalid authorization code"}
      end)

      # Test with a real code that will fail OAuth validation
      conn = get(conn, ~p"/auth/callback?code=invalid_test_code")

      # Should redirect to home on OAuth failure
      assert redirected_to(conn) == ~p"/"
      assert Phoenix.Flash.get(conn.assigns.flash, :error) == "Authentication failed."
    end
  end

  describe "logout/2" do
    test "clears session and redirects to Auth0 logout", %{conn: conn} do
      # Mock the OAuth.logout_url call
      expect(OAuth.Mock, :logout_url, fn %OAuth.Test{} ->
        {:ok,
         "https://test-domain.auth0.com/v2/logout?returnTo=http%3A%2F%2Flocalhost%3A4000&client_id=test_client"}
      end)

      # Use a valid UUID instead of integer
      test_user_id = Ecto.UUID.generate()

      conn =
        conn
        |> init_test_session(%{user_id: test_user_id})
        |> post(~p"/auth/logout")

      assert get_session(conn, :user_id) == nil
      assert Phoenix.Flash.get(conn.assigns.flash, :info) == "You have been logged out."

      location = List.first(get_resp_header(conn, "location"))
      assert location =~ "https://"
      assert location =~ "/v2/logout"
      assert location =~ "returnTo="
      assert location =~ "client_id="
    end
  end
end
