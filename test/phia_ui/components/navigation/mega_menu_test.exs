defmodule PhiaUi.Components.MegaMenuTest do
  use ExUnit.Case, async: true
  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.MegaMenu

    def render_menu(assigns) do
      ~H"""
      <.mega_menu id="nav-mega">
        <.mega_menu_trigger>Products</.mega_menu_trigger>
        <.mega_menu_content>
          <.mega_menu_section title="Tools">
            <.mega_menu_item href="/tools/editor" title="Editor" description="Write content" />
          </.mega_menu_section>
        </.mega_menu_content>
      </.mega_menu>
      """
    end

    def render_menu_cols(assigns) do
      ~H"""
      <.mega_menu id="nav-cols">
        <.mega_menu_trigger>Menu</.mega_menu_trigger>
        <.mega_menu_content cols={:"3"}>
          <.mega_menu_section title="A">
            <.mega_menu_item href="/a" title="Item A" />
          </.mega_menu_section>
        </.mega_menu_content>
      </.mega_menu>
      """
    end

    def render_section_no_title(assigns) do
      ~H"""
      <.mega_menu id="nav-s">
        <.mega_menu_trigger>M</.mega_menu_trigger>
        <.mega_menu_content>
          <.mega_menu_section>
            <.mega_menu_item href="/" title="Home" />
          </.mega_menu_section>
        </.mega_menu_content>
      </.mega_menu>
      """
    end

    def render_item_with_icon(assigns) do
      ~H"""
      <.mega_menu id="nav-icon">
        <.mega_menu_trigger>M</.mega_menu_trigger>
        <.mega_menu_content>
          <.mega_menu_item href="/analytics" title="Analytics">
            <:icon><span>A</span></:icon>
          </.mega_menu_item>
        </.mega_menu_content>
      </.mega_menu>
      """
    end

    def render_featured(assigns) do
      ~H"""
      <.mega_menu id="nav-feat">
        <.mega_menu_trigger>M</.mega_menu_trigger>
        <.mega_menu_content>
          <.mega_menu_featured href="/featured" title="Featured" description="Check this out" />
        </.mega_menu_content>
      </.mega_menu>
      """
    end

    def render_custom_class(assigns) do
      ~H"""
      <.mega_menu id="nav-cc" class="my-mega">
        <.mega_menu_trigger>M</.mega_menu_trigger>
        <.mega_menu_content>
          <.mega_menu_item href="/" title="Home" />
        </.mega_menu_content>
      </.mega_menu>
      """
    end
  end

  describe "mega_menu/1" do
    test "renders div with id" do
      html = render_component(&H.render_menu/1, %{})
      assert html =~ ~s(id="nav-mega")
    end

    test "has phx-hook=PhiaMegaMenu" do
      html = render_component(&H.render_menu/1, %{})
      assert html =~ ~s(phx-hook="PhiaMegaMenu")
    end

    test "custom class applied" do
      html = render_component(&H.render_custom_class/1, %{})
      assert html =~ "my-mega"
    end
  end

  describe "mega_menu_trigger/1" do
    test "renders button" do
      html = render_component(&H.render_menu/1, %{})
      assert html =~ "<button"
    end

    test "has data-mega-trigger" do
      html = render_component(&H.render_menu/1, %{})
      assert html =~ "data-mega-trigger"
    end

    test "renders trigger label" do
      html = render_component(&H.render_menu/1, %{})
      assert html =~ "Products"
    end

    test "has aria-haspopup=true" do
      html = render_component(&H.render_menu/1, %{})
      assert html =~ ~s(aria-haspopup="true")
    end
  end

  describe "mega_menu_content/1" do
    test "has data-mega-content" do
      html = render_component(&H.render_menu/1, %{})
      assert html =~ "data-mega-content"
    end

    test "is hidden by default" do
      html = render_component(&H.render_menu/1, %{})
      assert html =~ "hidden"
    end

    test "cols=3 applies grid-cols-3" do
      html = render_component(&H.render_menu_cols/1, %{})
      assert html =~ "grid-cols-3"
    end
  end

  describe "mega_menu_section/1" do
    test "renders section title" do
      html = render_component(&H.render_menu/1, %{})
      assert html =~ "Tools"
    end

    test "section title has uppercase tracking" do
      html = render_component(&H.render_menu/1, %{})
      assert html =~ "uppercase"
      assert html =~ "tracking-wider"
    end

    test "no title element when title is nil" do
      html = render_component(&H.render_section_no_title/1, %{})
      refute html =~ "uppercase tracking-wider"
    end
  end

  describe "mega_menu_item/1" do
    test "renders item title" do
      html = render_component(&H.render_menu/1, %{})
      assert html =~ "Editor"
    end

    test "renders description" do
      html = render_component(&H.render_menu/1, %{})
      assert html =~ "Write content"
    end

    test "has href" do
      html = render_component(&H.render_menu/1, %{})
      assert html =~ ~s(href="/tools/editor")
    end

    test "icon slot renders" do
      html = render_component(&H.render_item_with_icon/1, %{})
      assert html =~ "A"
    end
  end

  describe "mega_menu_featured/1" do
    test "renders featured title" do
      html = render_component(&H.render_featured/1, %{})
      assert html =~ "Featured"
    end

    test "renders featured description" do
      html = render_component(&H.render_featured/1, %{})
      assert html =~ "Check this out"
    end

    test "has gradient background" do
      html = render_component(&H.render_featured/1, %{})
      assert html =~ "bg-gradient-to-br"
    end
  end
end
