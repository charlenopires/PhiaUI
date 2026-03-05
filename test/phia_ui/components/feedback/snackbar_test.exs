defmodule PhiaUi.Components.SnackbarTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.Snackbar

    def render_basic(assigns) do
      ~H"""
      <.snackbar>
        <:label>3 items selected</:label>
        <:actions>
          <button>Delete</button>
        </:actions>
      </.snackbar>
      """
    end

    def render_with_icon(assigns) do
      ~H"""
      <.snackbar>
        <:icon><span>★</span></:icon>
        <:label>1 contact selected</:label>
        <:actions><button>Assign</button></:actions>
      </.snackbar>
      """
    end

    def render_hidden(assigns) do
      ~H"""
      <.snackbar visible={false}>
        <:label>Hidden</:label>
      </.snackbar>
      """
    end

    def render_visible(assigns) do
      ~H"""
      <.snackbar visible={true}>
        <:label>Visible</:label>
      </.snackbar>
      """
    end

    def render_custom_class(assigns) do
      ~H"""
      <.snackbar class="my-snackbar-class">
        <:label>Test</:label>
      </.snackbar>
      """
    end

    def render_label_only(assigns) do
      ~H"""
      <.snackbar>
        <:label>Selection info</:label>
      </.snackbar>
      """
    end

    def render_multiple_actions(assigns) do
      ~H"""
      <.snackbar>
        <:label>5 items</:label>
        <:actions>
          <button>Move</button>
          <button>Delete</button>
          <button>Archive</button>
        </:actions>
      </.snackbar>
      """
    end
  end

  describe "snackbar/1" do
    test "renders a root element" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ "<div"
    end

    test "renders label slot content" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ "3 items selected"
    end

    test "renders actions slot content" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ "Delete"
    end

    test "renders icon slot when provided" do
      html = render_component(&H.render_with_icon/1, %{})
      assert html =~ "★"
    end

    test "does not render when visible=false" do
      html = render_component(&H.render_hidden/1, %{})
      refute html =~ "Hidden"
    end

    test "renders when visible=true" do
      html = render_component(&H.render_visible/1, %{})
      assert html =~ "Visible"
    end

    test "renders by default (visible defaults to true)" do
      html = render_component(&H.render_label_only/1, %{})
      assert html =~ "Selection info"
    end

    test "custom class applied to root element" do
      html = render_component(&H.render_custom_class/1, %{})
      assert html =~ "my-snackbar-class"
    end

    test "fixed positioning applied" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ "fixed"
    end

    test "positioned at bottom of screen" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ "bottom-"
    end

    test "centered horizontally" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ "left-1/2" or html =~ "-translate-x-1/2"
    end

    test "high z-index to float above content" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ "z-"
    end

    test "has shadow styling" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ "shadow"
    end

    test "has rounded corners" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ "rounded"
    end

    test "multiple action buttons render" do
      html = render_component(&H.render_multiple_actions/1, %{})
      assert html =~ "Move"
      assert html =~ "Delete"
      assert html =~ "Archive"
    end

    test "label-only snackbar renders without error" do
      html = render_component(&H.render_label_only/1, %{})
      assert html =~ "Selection info"
    end
  end
end
