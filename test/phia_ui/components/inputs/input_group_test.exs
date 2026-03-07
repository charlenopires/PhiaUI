defmodule PhiaUi.Components.InputGroupTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.InputGroup

    def render_basic(assigns) do
      ~H"""
      <.input_group>
        <:item>
          <input type="text" name="first_name" placeholder="First" class="h-10 w-full border-0 bg-transparent px-3 text-sm focus:outline-none" />
        </:item>
        <:item>
          <input type="text" name="last_name" placeholder="Last" class="h-10 w-full border-0 bg-transparent px-3 text-sm focus:outline-none" />
        </:item>
      </.input_group>
      """
    end

    def render_with_label(assigns) do
      ~H"""
      <.input_group label="Full name" description="Your legal name">
        <:item>
          <input type="text" name="first" placeholder="First" class="h-10 w-full border-0 bg-transparent px-3 text-sm focus:outline-none" />
        </:item>
        <:item>
          <input type="text" name="last" placeholder="Last" class="h-10 w-full border-0 bg-transparent px-3 text-sm focus:outline-none" />
        </:item>
      </.input_group>
      """
    end

    def render_with_item_labels(assigns) do
      ~H"""
      <.input_group>
        <:item label="Min">
          <input type="number" name="min" class="h-10 w-full border-0 bg-transparent px-3 text-sm focus:outline-none" />
        </:item>
        <:item label="Max">
          <input type="number" name="max" class="h-10 w-full border-0 bg-transparent px-3 text-sm focus:outline-none" />
        </:item>
      </.input_group>
      """
    end

    def render_disabled(assigns) do
      ~H"""
      <.input_group disabled={true}>
        <:item>
          <input type="text" name="a" class="h-10 w-full border-0 bg-transparent px-3 text-sm focus:outline-none" />
        </:item>
      </.input_group>
      """
    end
  end

  describe "input_group/1 rendering" do
    test "renders outer wrapper div" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ "<div"
    end

    test "renders both slot items" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ ~s(name="first_name")
      assert html =~ ~s(name="last_name")
    end

    test "adds border-l on second item" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ "border-l"
    end

    test "renders group label" do
      html = render_component(&H.render_with_label/1, %{})
      assert html =~ "Full name"
    end

    test "renders group description" do
      html = render_component(&H.render_with_label/1, %{})
      assert html =~ "Your legal name"
    end

    test "renders item-level labels" do
      html = render_component(&H.render_with_item_labels/1, %{})
      assert html =~ "Min"
      assert html =~ "Max"
    end

    test "applies disabled classes when disabled" do
      html = render_component(&H.render_disabled/1, %{})
      assert html =~ "opacity-50"
    end

    test "has rounded-md border class" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ "rounded-md"
      assert html =~ "border-input"
    end

    test "has focus-within ring class" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ "focus-within:ring-2"
    end
  end
end
