defmodule Web.HomeTest do
  use Web.ConnCase, async: true

  describe "GET /" do
    test "renders homepage with correct structure and content", %{conn: conn} do
      conn = get(conn, ~p"/")
      assert html_response(conn, 200)

      {:ok, document} = Floki.parse_document(html_response(conn, 200))

      spans = Floki.find(document, "span")
      span_text = Floki.text(spans)
      assert span_text =~ "MyApp"

      # Check for main hero heading
      headings = Floki.find(document, "h1")
      heading_text = Floki.text(headings)
      assert heading_text =~ "Welcome to MyApp"

      # Check for value proposition subtitle
      paragraphs = Floki.find(document, "p")
      paragraph_text = Floki.text(paragraphs)
      assert paragraph_text =~ "Lorem ipsum dolor sit amet"

      # Check for Sign In button
      sign_in_links = Floki.find(document, "a")

      sign_in_found =
        Enum.any?(sign_in_links, fn link ->
          Floki.text(link) =~ "Sign In"
        end)

      assert sign_in_found

      # Verify sign in link href
      sign_in_link =
        Enum.find(sign_in_links, fn link ->
          Floki.text(link) =~ "Sign In"
        end)

      href = Floki.attribute(sign_in_link, "href")
      assert "/auth/auth0" in href
    end

    test "has correct navigation structure", %{conn: conn} do
      conn = get(conn, ~p"/")
      {:ok, document} = Floki.parse_document(html_response(conn, 200))

      # Check for navigation element
      assert [_] = Floki.find(document, "nav")

      # Check for logo container with red background
      logo_containers = Floki.find(document, "div.bg-red-600")
      assert length(logo_containers) >= 1

      # Check for "M" logo text (MyApp instead of V for Vibe)
      spans = Floki.find(document, "span")
      span_text = Floki.text(spans)
      assert span_text =~ "M"
    end

    test "displays admin features section correctly", %{conn: conn} do
      conn = get(conn, ~p"/")
      {:ok, document} = Floki.parse_document(html_response(conn, 200))

      # Check for admin section heading
      h2_elements = Floki.find(document, "h2")
      h2_text = Floki.text(h2_elements)
      assert h2_text =~ "For Administrators"

      # Check for specific admin features
      h3_elements = Floki.find(document, "h3")
      h3_text = Floki.text(h3_elements)
      assert h3_text =~ "Manage System"
      assert h3_text =~ "User Management"

      # Check for feature descriptions
      paragraphs = Floki.find(document, "p")
      paragraph_text = Floki.text(paragraphs)
      assert paragraph_text =~ "Ut enim ad minim veniam"
      assert paragraph_text =~ "Duis aute irure dolor"

      # Check for red checkmark indicators
      checkmarks = Floki.find(document, "div.bg-red-600 span")
      checkmark_text = Floki.text(checkmarks)
      assert checkmark_text =~ "✓"
    end

    test "displays user features section correctly", %{conn: conn} do
      conn = get(conn, ~p"/")
      {:ok, document} = Floki.parse_document(html_response(conn, 200))

      # Check for user section heading
      h2_elements = Floki.find(document, "h2")
      h2_text = Floki.text(h2_elements)
      assert h2_text =~ "For Users"

      # Check for specific user features
      h3_elements = Floki.find(document, "h3")
      h3_text = Floki.text(h3_elements)
      assert h3_text =~ "Access Your Items"
      assert h3_text =~ "Real-time Updates"

      # Check for feature descriptions
      paragraphs = Floki.find(document, "p")
      paragraph_text = Floki.text(paragraphs)
      assert paragraph_text =~ "Excepteur sint occaecat"
      assert paragraph_text =~ "Lorem ipsum dolor sit amet"
    end

    test "has correct styling and theme", %{conn: conn} do
      conn = get(conn, ~p"/")
      {:ok, document} = Floki.parse_document(html_response(conn, 200))

      # Check for black background theme
      assert [_] = Floki.find(document, "div.bg-black")

      # Check for red accent elements
      red_elements = Floki.find(document, ".bg-red-600")
      # Logo, checkmarks, and sign-in button
      assert length(red_elements) >= 3

      # Check for white text elements
      white_text = Floki.find(document, ".text-white")
      # Various headings and text
      assert length(white_text) >= 5
    end

    test "homepage layout is not wrapped with LiveView", %{conn: conn} do
      conn = get(conn, ~p"/")
      response = html_response(conn, 200)

      # Verify no LiveView socket (static page)
      refute response =~ "phx-socket"

      # Verify direct HTML structure without layout wrapper
      assert response =~ "bg-black"
      assert response =~ "bg-red-600"
    end

    test "responsive design elements are present", %{conn: conn} do
      conn = get(conn, ~p"/")
      {:ok, document} = Floki.parse_document(html_response(conn, 200))

      # Check for responsive text sizing
      assert [_] = Floki.find(document, ".text-5xl.md\\:text-7xl")

      # Check for responsive grid layout
      assert [_] = Floki.find(document, ".grid.md\\:grid-cols-2")

      # Check for responsive container - expect multiple matches
      max_w_containers = Floki.find(document, ".max-w-7xl.mx-auto")
      assert length(max_w_containers) >= 1
    end
  end
end
