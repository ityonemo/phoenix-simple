defmodule OAuth.Auth0Test do
  use ExUnit.Case, async: true
  alias OAuth.Auth0

  setup do
    # Set up environment variables for testing
    System.put_env("AUTH0_DOMAIN", "test-domain.auth0.com")
    System.put_env("AUTH0_CLIENT_ID", "test_client_id")
    System.put_env("AUTH0_CLIENT_SECRET", "test_client_secret")
    System.put_env("AUTH0_REDIRECT_URI", "http://localhost:4000/auth/callback")
    System.put_env("AUTH0_HOME_URI", "http://localhost:4000")

    auth0 = Auth0.init()
    {:ok, auth0: auth0}
  end

  # Helper function to create bypass server with isolated cache
  defp create_bypass_setup do
    bypass = Bypass.open()

    # Create a new isolated cache for this test
    cache_name = :"test_cache_#{System.unique_integer([:positive])}"
    OAuth.Cache.start_link(name: cache_name)

    # Override domain to point to our bypass server and use isolated cache
    auth0 = %Auth0{
      domain: "localhost:#{bypass.port}",
      client_id: "test_client_id",
      client_secret: "test_client_secret",
      redirect_uri: "http://localhost:4000/auth/callback",
      cache: cache_name
    }

    cache_struct = %OAuth.Cache{id: cache_name}

    {:ok, bypass: bypass, auth0: auth0, cache: cache_struct}
  end

  describe "init/0" do
    test "creates Auth0 struct with environment variables" do
      auth0 = Auth0.init()

      assert %Auth0{
               domain: "test-domain.auth0.com",
               client_id: "test_client_id",
               client_secret: "test_client_secret",
               redirect_uri: "http://localhost:4000/auth/callback",
               home_uri: "http://localhost:4000",
               cache: OAuth.Cache
             } = auth0
    end

    test "raises when required environment variables are missing" do
      System.delete_env("AUTH0_DOMAIN")

      assert_raise System.EnvError, ~r/could not fetch environment variable/, fn ->
        Auth0.init()
      end
    end
  end

  describe "authorize_url/1" do
    test "generates correct authorize URL", %{auth0: auth0} do
      {:ok, url} = Auth0.authorize_url(auth0)

      assert url =~ "https://test-domain.auth0.com/authorize?"
      assert url =~ "response_type=code"
      assert url =~ "client_id=test_client_id"
      assert url =~ "redirect_uri=http%3A%2F%2Flocalhost%3A4000%2Fauth%2Fcallback"
      assert url =~ "scope=openid+profile+email"

      assert url =~ "audience=https%3A%2F%2Ftest-domain.auth0.com%2Fapi%2Fv2%2F"
    end

    test "handles localhost domain with http", %{auth0: auth0} do
      localhost_auth0 = %{auth0 | domain: "localhost:3001"}
      {:ok, url} = Auth0.authorize_url(localhost_auth0)

      assert url =~ "http://localhost:3001/authorize?"
    end
  end

  describe "logout_url/1" do
    test "generates correct logout URL", %{auth0: auth0} do
      {:ok, url} = Auth0.logout_url(auth0)

      assert url =~ "https://test-domain.auth0.com/v2/logout?"
      assert url =~ "returnTo=http%3A%2F%2Flocalhost%3A4000"
      assert url =~ "client_id=test_client_id"
    end

    test "handles localhost domain with http", %{auth0: auth0} do
      localhost_auth0 = %{auth0 | domain: "localhost:3001"}
      {:ok, url} = Auth0.logout_url(localhost_auth0)

      assert url =~ "http://localhost:3001/v2/logout?"
    end
  end

  describe "fetch_token/2" do
    setup do
      create_bypass_setup()
    end

    test "returns access token on successful exchange", %{
      bypass: bypass,
      auth0: auth0,
      cache: cache
    } do
      expected_response = %{
        "access_token" => "mock_access_token_123",
        "expires_in" => 3600,
        "token_type" => "Bearer"
      }

      Bypass.expect_once(bypass, "POST", "/oauth/token", fn conn ->
        # Verify request body
        {:ok, body, conn} = Plug.Conn.read_body(conn)
        request_data = Jason.decode!(body)

        assert request_data["grant_type"] == "authorization_code"
        assert request_data["client_id"] == "test_client_id"
        assert request_data["client_secret"] == "test_client_secret"
        assert request_data["code"] == "test_code"
        assert request_data["redirect_uri"] == "http://localhost:4000/auth/callback"

        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.resp(200, Jason.encode!(expected_response))
      end)

      assert {:ok, "mock_access_token_123"} = Auth0.fetch_token(auth0, "test_code")

      # Verify token was cached in our isolated cache
      assert {:ok, "mock_access_token_123"} = OAuth.Cache.fetch_token(cache, "test_code")
    end

    test "returns error on failed token exchange", %{bypass: bypass, auth0: auth0, cache: cache} do
      error_response = %{
        "error" => "invalid_grant",
        "error_description" => "Invalid authorization code"
      }

      Bypass.expect_once(bypass, "POST", "/oauth/token", fn conn ->
        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.resp(400, Jason.encode!(error_response))
      end)

      assert {:error, "auth0 token exchange failed"} = Auth0.fetch_token(auth0, "invalid_code")

      # Verify nothing was cached on failure
      assert :error = OAuth.Cache.fetch_token(cache, "invalid_code")
    end

    test "handles network errors", %{bypass: bypass, auth0: auth0, cache: cache} do
      Bypass.down(bypass)

      assert {:error, %Req.TransportError{}} = Auth0.fetch_token(auth0, "test_code")

      # Verify nothing was cached on network error
      assert :error = OAuth.Cache.fetch_token(cache, "test_code")
    end
  end

  describe "fetch_user_info/2" do
    setup do
      create_bypass_setup()
    end

    test "returns user info on successful request", %{bypass: bypass, auth0: auth0, cache: cache} do
      expected_user_info = %{
        "sub" => "auth0|123456",
        "email" => "test@example.com",
        "name" => "Test User",
        "picture" => "https://example.com/avatar.jpg"
      }

      Bypass.expect_once(bypass, "GET", "/userinfo", fn conn ->
        # Verify authorization header
        [auth_header] = Plug.Conn.get_req_header(conn, "authorization")
        assert auth_header == "Bearer test_access_token"

        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.resp(200, Jason.encode!(expected_user_info))
      end)

      assert {:ok, ^expected_user_info} = Auth0.fetch_user_info(auth0, "test_access_token")

      # Verify user info was cached in our isolated cache
      assert {:ok, ^expected_user_info} = OAuth.Cache.fetch_user_info(cache, "test_access_token")
    end

    test "returns error on failed user info request", %{
      bypass: bypass,
      auth0: auth0,
      cache: cache
    } do
      Bypass.expect_once(bypass, "GET", "/userinfo", fn conn ->
        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.resp(401, Jason.encode!(%{"error" => "Unauthorized"}))
      end)

      assert {:error, "Auth0 user info failed"} = Auth0.fetch_user_info(auth0, "invalid_token")

      # Verify nothing was cached on failure
      assert :error = OAuth.Cache.fetch_user_info(cache, "invalid_token")
    end

    test "handles network errors", %{bypass: bypass, auth0: auth0, cache: cache} do
      Bypass.down(bypass)

      assert {:error, %Req.TransportError{}} = Auth0.fetch_user_info(auth0, "test_token")

      # Verify nothing was cached on network error
      assert :error = OAuth.Cache.fetch_user_info(cache, "test_token")
    end
  end

  describe "integration with isolated cache" do
    setup do
      create_bypass_setup()
    end

    test "caches access token on successful fetch", %{bypass: bypass, auth0: auth0, cache: cache} do
      token_response = %{
        "access_token" => "cached_token_123",
        "expires_in" => 3600,
        "token_type" => "Bearer"
      }

      Bypass.expect_once(bypass, "POST", "/oauth/token", fn conn ->
        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.resp(200, Jason.encode!(token_response))
      end)

      assert {:ok, "cached_token_123"} = Auth0.fetch_token(auth0, "bearer_code")

      # Verify token was cached in our isolated cache
      assert {:ok, "cached_token_123"} = OAuth.Cache.fetch_token(cache, "bearer_code")
    end

    test "caches user info on successful fetch", %{bypass: bypass, auth0: auth0, cache: cache} do
      user_info = %{
        "sub" => "auth0|cached_user",
        "email" => "cached@example.com",
        "name" => "Cached User"
      }

      Bypass.expect_once(bypass, "GET", "/userinfo", fn conn ->
        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.resp(200, Jason.encode!(user_info))
      end)

      assert {:ok, ^user_info} = Auth0.fetch_user_info(auth0, "access_token_123")

      # Verify user info was cached in our isolated cache
      assert {:ok, ^user_info} = OAuth.Cache.fetch_user_info(cache, "access_token_123")
    end

    test "isolated caches don't interfere with each other", %{
      bypass: bypass,
      auth0: auth0,
      cache: cache
    } do
      # Create another isolated cache
      other_cache_name = :"other_cache_#{System.unique_integer([:positive])}"
      OAuth.Cache.start_link(name: other_cache_name)
      other_cache = %OAuth.Cache{id: other_cache_name}

      user_info = %{
        "sub" => "auth0|isolated_user",
        "email" => "isolated@example.com",
        "name" => "Isolated User"
      }

      Bypass.expect_once(bypass, "GET", "/userinfo", fn conn ->
        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.resp(200, Jason.encode!(user_info))
      end)

      assert {:ok, ^user_info} = Auth0.fetch_user_info(auth0, "isolated_token")

      # Verify it's only in our test cache, not the other cache
      assert {:ok, ^user_info} = OAuth.Cache.fetch_user_info(cache, "isolated_token")
      assert :error = OAuth.Cache.fetch_user_info(other_cache, "isolated_token")
    end
  end
end
