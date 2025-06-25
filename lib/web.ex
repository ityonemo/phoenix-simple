defmodule Web do
  @moduledoc """
  The Web context.

  Provides static asset paths and verified routes utilities for the Phoenix application.
  """

  def static_paths, do: ~w(assets fonts images favicon.ico robots.txt)

  defmodule VerifiedRoutes do
    @moduledoc """
    Verified routes macro for compile-time route verification.

    Provides the `use Web.VerifiedRoutes` macro that sets up Phoenix.VerifiedRoutes
    with the correct endpoint, router, and static paths configuration.
    """
    defmacro __using__(_opts) do
      quote do
        use Phoenix.VerifiedRoutes,
          endpoint: Web.Endpoint,
          router: Web.Router,
          statics: Web.static_paths()
      end
    end
  end
end
