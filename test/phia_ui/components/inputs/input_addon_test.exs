defmodule PhiaUi.Components.InputAddonTest do
  use ExUnit.Case, async: true
  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.InputAddon

    def render_basic(assigns) do
      ~H"""
      <.input_addon><input type="text" placeholder="Amount" /></.input_addon>
      """
    end

    def render_with_prefix(assigns) do
      ~H"""
      <.input_addon><:prefix>$</:prefix><input type="number" /></.input_addon>
      """
    end

    def render_with_suffix(assigns) do
      ~H"""
      <.input_addon><input type="text" /><:suffix>.00</:suffix></.input_addon>
      """
    end

    def render_with_both(assigns) do
      ~H"""
      <.input_addon>
        <:prefix>https://</:prefix>
        <input type="text" />
        <:suffix>.com</:suffix>
      </.input_addon>
      """
    end

    def render_disabled(assigns) do
      ~H"""
      <.input_addon disabled={true}><input type="text" /></.input_addon>
      """
    end

    def render_custom_class(assigns) do
      ~H"""
      <.input_addon class="my-addon-class"><input type="text" /></.input_addon>
      """
    end
  end

  describe "input_addon/1" do
    test "renders a wrapper div" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ "<div"
    end

    test "has border class" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ "border"
    end

    test "has rounded-md class" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ "rounded-md"
    end

    test "has focus-within:ring-2 class" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ "focus-within:ring-2"
    end

    test "with prefix renders prefix content" do
      html = render_component(&H.render_with_prefix/1, %{})
      assert html =~ "$"
    end

    test "with prefix has border-r separator" do
      html = render_component(&H.render_with_prefix/1, %{})
      assert html =~ "border-r"
    end

    test "with suffix renders suffix content" do
      html = render_component(&H.render_with_suffix/1, %{})
      assert html =~ ".00"
    end

    test "with suffix has border-l separator" do
      html = render_component(&H.render_with_suffix/1, %{})
      assert html =~ "border-l"
    end

    test "with both prefix and suffix renders both" do
      html = render_component(&H.render_with_both/1, %{})
      assert html =~ "https://"
      assert html =~ ".com"
    end

    test "without prefix: no prefix div rendered" do
      html = render_component(&H.render_basic/1, %{})
      refute html =~ "border-r"
    end

    test "without suffix: no suffix div rendered" do
      html = render_component(&H.render_basic/1, %{})
      refute html =~ "border-l"
    end

    test "renders inner_block content" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ "<input"
      assert html =~ ~s(placeholder="Amount")
    end

    test "disabled=true has opacity-50" do
      html = render_component(&H.render_disabled/1, %{})
      assert html =~ "opacity-50"
    end

    test "custom class applied" do
      html = render_component(&H.render_custom_class/1, %{})
      assert html =~ "my-addon-class"
    end
  end
end
