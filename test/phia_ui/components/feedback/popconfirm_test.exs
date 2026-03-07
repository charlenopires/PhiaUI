defmodule PhiaUi.Components.PopconfirmTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.Popconfirm

    def render_basic(assigns) do
      ~H"""
      <.popconfirm id="test-confirm" title="Are you sure?">
        <:trigger><button>Delete</button></:trigger>
      </.popconfirm>
      """
    end

    def render_with_description(assigns) do
      ~H"""
      <.popconfirm id="desc-confirm" title="Delete?" description="This cannot be undone.">
        <:trigger><button>Delete</button></:trigger>
      </.popconfirm>
      """
    end

    def render_bottom(assigns) do
      ~H"""
      <.popconfirm id="bottom-confirm" title="Confirm?" placement={:bottom}>
        <:trigger><button>Click</button></:trigger>
      </.popconfirm>
      """
    end

    def render_left(assigns) do
      ~H"""
      <.popconfirm id="left-confirm" title="Confirm?" placement={:left}>
        <:trigger><button>Click</button></:trigger>
      </.popconfirm>
      """
    end

    def render_right(assigns) do
      ~H"""
      <.popconfirm id="right-confirm" title="Confirm?" placement={:right}>
        <:trigger><button>Click</button></:trigger>
      </.popconfirm>
      """
    end

    def render_custom_labels(assigns) do
      ~H"""
      <.popconfirm id="labels-confirm" title="Archive?" confirm_label="Archive" cancel_label="Keep">
        <:trigger><button>Archive</button></:trigger>
      </.popconfirm>
      """
    end

    def render_custom_class(assigns) do
      ~H"""
      <.popconfirm id="class-confirm" title="Sure?" class="my-pop">
        <:trigger><button>Trigger</button></:trigger>
      </.popconfirm>
      """
    end
  end

  describe "popconfirm/1" do
    test "renders a root div" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ "<div"
    end

    test "panel starts hidden" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ ~s(class="hidden)
    end

    test "panel has correct id" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ ~s(id="test-confirm-panel")
    end

    test "trigger slot is rendered" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ "Delete"
    end

    test "title is rendered in panel" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ "Are you sure?"
    end

    test "description is rendered when provided" do
      html = render_component(&H.render_with_description/1, %{})
      assert html =~ "This cannot be undone."
    end

    test ":top placement uses bottom-full class (default)" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ "bottom-full"
    end

    test ":bottom placement uses top-full class" do
      html = render_component(&H.render_bottom/1, %{})
      assert html =~ "top-full"
    end

    test ":left placement uses right-full class" do
      html = render_component(&H.render_left/1, %{})
      assert html =~ "right-full"
    end

    test ":right placement uses left-full class" do
      html = render_component(&H.render_right/1, %{})
      assert html =~ "left-full"
    end

    test "confirm label is rendered" do
      html = render_component(&H.render_custom_labels/1, %{})
      assert html =~ "Archive"
    end

    test "cancel label is rendered" do
      html = render_component(&H.render_custom_labels/1, %{})
      assert html =~ "Keep"
    end

    test "warning icon is rendered in panel" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ "triangle-alert"
    end

    test "custom class applied to root" do
      html = render_component(&H.render_custom_class/1, %{})
      assert html =~ "my-pop"
    end
  end
end
