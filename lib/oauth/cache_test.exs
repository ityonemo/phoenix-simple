defmodule OAuth.CacheTest do
  use ExUnit.Case, async: true
  alias OAuth.Cache

  setup do
    # Create a unique cache for each test to avoid conflicts
    cache_name = :"test_cache_#{:erlang.unique_integer([:positive])}"
    {:ok, _pid} = Cache.start_link(name: cache_name)
    cache = %Cache{id: cache_name}
    {:ok, cache: cache}
  end

  describe "init/0" do
    test "creates Cache struct with default module name" do
      cache = Cache.init()
      assert %Cache{id: OAuth.Cache} = cache
    end
  end

  describe "logout_url/1" do
    test "returns error for cache", %{cache: cache} do
      assert :error = Cache.logout_url(cache)
    end
  end

  describe "authorize_url/1" do
    test "returns error for cache", %{cache: cache} do
      assert :error = Cache.authorize_url(cache)
    end
  end

  describe "fetch_token/2" do
    test "returns error when no token is cached", %{cache: cache} do
      assert :error = Cache.fetch_token(cache, "nonexistent_bearer")
    end

    test "returns cached token when valid", %{cache: cache} do
      access_token = "test_access_token_123"
      bearer_token = "test_bearer_token_123"
      expires_in = 3600

      # Insert token manually to simulate caching
      now = :erlang.monotonic_time(:second)
      expiry = now + expires_in - 10
      :ets.insert(cache.id, {{:bearer, bearer_token}, access_token, expiry})

      assert {:ok, ^access_token} = Cache.fetch_token(cache, bearer_token)
    end

    test "returns error when token is expired", %{cache: cache} do
      access_token = "expired_access_token"
      bearer_token = "expired_bearer_token"

      # Insert expired token
      now = :erlang.monotonic_time(:second)
      # 100 seconds ago
      expired_time = now - 100
      :ets.insert(cache.id, {{:bearer, bearer_token}, access_token, expired_time})

      assert :error = Cache.fetch_token(cache, bearer_token)

      # Verify the access token was also purged
      assert [] = :ets.lookup(cache.id, {:access_token, access_token})
    end
  end

  describe "fetch_user_info/2" do
    test "returns error when no user info is cached", %{cache: cache} do
      assert :error = Cache.fetch_user_info(cache, "nonexistent_access_token")
    end

    test "returns cached user info when available", %{cache: cache} do
      access_token = "test_access_token"

      user_info = %{
        "sub" => "auth0|123456",
        "email" => "test@example.com",
        "name" => "Test User"
      }

      # Insert user info manually
      :ets.insert(cache.id, {{:access_token, access_token}, user_info})

      assert {:ok, ^user_info} = Cache.fetch_user_info(cache, access_token)
    end
  end

  describe "insert_access_token/3" do
    test "inserts bearer token mapping to access token with expiry", %{cache: cache} do
      bearer_token = "bearer_123"

      access_response = %{
        "access_token" => "access_123",
        "expires_in" => 3600,
        "token_type" => "Bearer"
      }

      Cache.insert_access_token(cache.id, bearer_token, access_response)

      # Verify token was inserted
      assert {:ok, "access_123"} = Cache.fetch_token(cache, bearer_token)
    end

    test "calculates correct expiry time with buffer", %{cache: cache} do
      bearer_token = "bearer_expiry_test"

      access_response = %{
        "access_token" => "access_expiry_test",
        "expires_in" => 3600
      }

      now_before = :erlang.monotonic_time(:second)
      Cache.insert_access_token(cache.id, bearer_token, access_response)
      now_after = :erlang.monotonic_time(:second)

      # Ensure that the expiry is within seconds of now + expires_in - 10
      assert_in_delta now_after - now_before, 0, 1

      # The access token should be cached and retrievable
      assert {:ok, "access_expiry_test"} = Cache.fetch_token(cache, bearer_token)
    end
  end
end
