defmodule PhiaUi.Components.TableStateTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.TableState

    def render_skeleton(assigns) do
      ~H"""
      <.table_skeleton />
      """
    end

    attr(:rows, :integer, default: 3)
    attr(:cols, :integer, default: 2)
    attr(:show_header, :boolean, default: true)

    def render_skeleton_opts(assigns) do
      ~H"""
      <.table_skeleton rows={@rows} cols={@cols} show_header={@show_header} />
      """
    end

    def render_empty(assigns) do
      ~H"""
      <table><tbody><.table_empty /></tbody></table>
      """
    end

    attr(:title, :string, default: "No results")
    attr(:description, :string, default: nil)
    attr(:icon, :string, default: "inbox")

    def render_empty_opts(assigns) do
      ~H"""
      <table><tbody>
        <.table_empty title={@title} description={@description} icon={@icon} />
      </tbody></table>
      """
    end

    def render_empty_with_action(assigns) do
      ~H"""
      <table><tbody>
        <.table_empty title="Empty">
          <:action><button>Add item</button></:action>
        </.table_empty>
      </tbody></table>
      """
    end

    def render_error(assigns) do
      ~H"""
      <table><tbody><.table_error /></tbody></table>
      """
    end

    attr(:message, :string, default: "Failed to load data")

    def render_error_opts(assigns) do
      ~H"""
      <table><tbody><.table_error message={@message} /></tbody></table>
      """
    end

    def render_error_with_action(assigns) do
      ~H"""
      <table><tbody>
        <.table_error message="Error">
          <:action><button>Retry</button></:action>
        </.table_error>
      </tbody></table>
      """
    end
  end

  # ---------------------------------------------------------------------------
  # table_skeleton/1
  # ---------------------------------------------------------------------------

  describe "table_skeleton/1" do
    test "renders table element" do
      html = render_component(&H.render_skeleton/1, %{})
      assert html =~ "<table"
    end

    test "renders thead by default" do
      html = render_component(&H.render_skeleton/1, %{})
      assert html =~ "<thead"
    end

    test "renders 5 tbody rows by default" do
      html = render_component(&H.render_skeleton/1, %{})
      # Count tr elements in tbody (the thead also has one tr)
      assert html =~ "<tbody"
      assert length(String.split(html, "<tr")) - 1 >= 6
    end

    test "respects rows option" do
      html = render_component(&H.render_skeleton_opts/1, %{rows: 2, cols: 3, show_header: true})
      # Should have 2 body rows + 1 header row
      assert length(String.split(html, "<tr")) - 1 == 3
    end

    test "respects cols option" do
      html = render_component(&H.render_skeleton_opts/1, %{rows: 1, cols: 3, show_header: false})
      assert length(String.split(html, "<td")) - 1 == 3
    end

    test "show_header=false hides thead" do
      html = render_component(&H.render_skeleton_opts/1, %{rows: 2, cols: 2, show_header: false})
      refute html =~ "<thead"
    end

    test "has motion-safe:animate-pulse on skeleton cells" do
      html = render_component(&H.render_skeleton/1, %{})
      assert html =~ "motion-safe:animate-pulse"
    end

    test "has bg-muted on shimmer blocks" do
      html = render_component(&H.render_skeleton/1, %{})
      assert html =~ "bg-muted"
    end
  end

  # ---------------------------------------------------------------------------
  # table_empty/1
  # ---------------------------------------------------------------------------

  describe "table_empty/1" do
    test "renders tr and td" do
      html = render_component(&H.render_empty/1, %{})
      assert html =~ "<tr"
      assert html =~ "<td"
    end

    test "td has colspan=100" do
      html = render_component(&H.render_empty/1, %{})
      assert html =~ ~s(colspan="100")
    end

    test "renders default title" do
      html = render_component(&H.render_empty/1, %{})
      assert html =~ "No results"
    end

    test "renders custom title" do
      html = render_component(&H.render_empty_opts/1, %{title: "Nothing here", description: nil, icon: "inbox"})
      assert html =~ "Nothing here"
    end

    test "renders description when provided" do
      html = render_component(&H.render_empty_opts/1, %{title: "Empty", description: "Try again", icon: "inbox"})
      assert html =~ "Try again"
    end

    test "does not render description when nil" do
      html = render_component(&H.render_empty_opts/1, %{title: "Empty", description: nil, icon: "inbox"})
      refute html =~ "Try again"
    end

    test "renders action slot" do
      html = render_component(&H.render_empty_with_action/1, %{})
      assert html =~ "Add item"
    end

    test "has centered layout classes" do
      html = render_component(&H.render_empty/1, %{})
      assert html =~ "text-center"
      assert html =~ "flex-col"
      assert html =~ "items-center"
    end
  end

  # ---------------------------------------------------------------------------
  # table_error/1
  # ---------------------------------------------------------------------------

  describe "table_error/1" do
    test "renders tr and td" do
      html = render_component(&H.render_error/1, %{})
      assert html =~ "<tr"
      assert html =~ "<td"
    end

    test "td has colspan=100" do
      html = render_component(&H.render_error/1, %{})
      assert html =~ ~s(colspan="100")
    end

    test "renders default error message" do
      html = render_component(&H.render_error/1, %{})
      assert html =~ "Failed to load data"
    end

    test "renders custom message" do
      html = render_component(&H.render_error_opts/1, %{message: "Custom error"})
      assert html =~ "Custom error"
    end

    test "uses destructive color" do
      html = render_component(&H.render_error/1, %{})
      assert html =~ "text-destructive"
    end

    test "renders action slot" do
      html = render_component(&H.render_error_with_action/1, %{})
      assert html =~ "Retry"
    end
  end
end
