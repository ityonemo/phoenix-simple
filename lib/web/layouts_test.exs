defmodule Web.LayoutsTest do
  use Web.ConnCase, async: true
  import Phoenix.LiveViewTest

  describe "flash_group/1" do
    test "renders flash group container" do
      assigns = %{flash: %{}}

      html = render_component(&Web.Layouts.flash_group/1, assigns)

      assert html =~ ~s(id="flash-group")
      assert html =~ ~s(aria-live="polite")
    end

    test "renders with custom id" do
      assigns = %{flash: %{}, id: "custom-flash"}

      html = render_component(&Web.Layouts.flash_group/1, assigns)

      assert html =~ ~s(id="custom-flash")
      assert html =~ ~s(aria-live="polite")
    end

    test "includes client and server error flash components" do
      assigns = %{flash: %{}}

      html = render_component(&Web.Layouts.flash_group/1, assigns)

      assert html =~ ~s(id="client-error")
      assert html =~ ~s(id="server-error")
      assert html =~ "We can&#39;t find the internet"
      assert html =~ "Something went wrong!"
    end
  end
end
