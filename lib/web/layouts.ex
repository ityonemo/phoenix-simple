defmodule Web.Layouts do
  @moduledoc """
  This module holds different layouts used by your application.

  See the `layouts` directory for all templates available.
  The "root" layout is a skeleton rendered as part of the
  application router. The "app" layout is rendered as component
  in regular views and live views.
  """
  use Phoenix.Component

  # Import convenience functions from controllers
  import Phoenix.Controller, only: [get_csrf_token: 0]

  # Core UI components and translation
  alias Web.Components.Core

  # Shortcut for generating JS commands
  alias Phoenix.LiveView.JS

  # Helper functions for JS commands
  defp show(selector), do: JS.show(to: selector)
  defp hide(selector), do: JS.hide(to: selector)

  # Routes generation with the ~p sigil
  use Web.VerifiedRoutes

  embed_templates "layouts/*"

  @doc """
  Renders the app layout

  ## Examples

      <Layouts.app flash={@flash}>
        <h1>Content</h1>
      </Layout.app>
      
  """
  attr :flash, :map, required: true, doc: "the map of flash messages"

  attr :current_user, :map,
    default: nil,
    doc: "the current user"

  slot :inner_block, required: true

  def app(assigns) do
    ~H"""
    <div class="min-h-screen bg-black">
      <.flash_group flash={@flash} />
      {render_slot(@inner_block)}
    </div>
    """
  end

  @doc """
  Shows the flash group with standard titles and content.

  ## Examples

      <.flash_group flash={@flash} />
  """
  attr :flash, :map, required: true, doc: "the map of flash messages"
  attr :id, :string, default: "flash-group", doc: "the optional id of flash container"

  def flash_group(assigns) do
    ~H"""
    <div id={@id} aria-live="polite">
      <Core.flash kind={:info} flash={@flash} />
      <Core.flash kind={:error} flash={@flash} />

      <Core.flash
        id="client-error"
        kind={:error}
        title="We can't find the internet"
        phx-disconnected={show(".phx-client-error #client-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#client-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        Attempting to reconnect
        <Core.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </Core.flash>

      <Core.flash
        id="server-error"
        kind={:error}
        title="Something went wrong!"
        phx-disconnected={show(".phx-server-error #server-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#server-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        Attempting to reconnect
        <Core.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </Core.flash>
    </div>
    """
  end
end
