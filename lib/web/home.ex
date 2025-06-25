defmodule Web.Home do
  @moduledoc """
  Home controller for the landing page.
  """
  use Phoenix.Controller,
    formats: [:html],
    layouts: [html: Web.Layouts]

  def index(conn, _params) do
    conn |> put_layout(false) |> render(:index)
  end
end

defmodule Web.HomeHTML do
  @moduledoc """
  This module contains templates rendered by Home controller.
  """
  use Phoenix.Component

  # Routes generation with the ~p sigil
  use Web.VerifiedRoutes

  embed_templates "templates/home/*"
end
