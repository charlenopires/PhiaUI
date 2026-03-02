defmodule PhiaUi.Components.TableTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.Table

    attr :class, :string, default: nil
    def render_table(assigns) do
      ~H"""
      <.table class={@class}>
        <.table_body>
          <.table_row><.table_cell>Cell</.table_cell></.table_row>
        </.table_body>
      </.table>
      """
    end

    attr :class, :string, default: nil
    def render_table_header(assigns) do
      ~H"""
      <table><.table_header class={@class}><tr><th>H</th></tr></.table_header></table>
      """
    end

    attr :class, :string, default: nil
    def render_table_body(assigns) do
      ~H"""
      <table><.table_body class={@class}><tr><td>B</td></tr></.table_body></table>
      """
    end

    attr :class, :string, default: nil
    def render_table_footer(assigns) do
      ~H"""
      <table><.table_footer class={@class}>Total</.table_footer></table>
      """
    end

    attr :class, :string, default: nil
    attr :selected, :boolean, default: false
    def render_table_row(assigns) do
      ~H"""
      <table><tbody><.table_row selected={@selected} class={@class}>Row</.table_row></tbody></table>
      """
    end

    attr :class, :string, default: nil
    def render_table_head(assigns) do
      ~H"""
      <table><thead><tr><.table_head class={@class}>Name</.table_head></tr></thead></table>
      """
    end

    attr :class, :string, default: nil
    def render_table_cell(assigns) do
      ~H"""
      <table><tbody><tr><.table_cell class={@class}>Value</.table_cell></tr></tbody></table>
      """
    end

    attr :class, :string, default: nil
    def render_table_caption(assigns) do
      ~H"""
      <table><.table_caption class={@class}>Caption</.table_caption></table>
      """
    end

    def render_with_rest(assigns) do
      ~H"""
      <.table data-testid="my-table">
        <.table_body><.table_row><.table_cell>Cell</.table_cell></.table_row></.table_body>
      </.table>
      """
    end

    def render_full(assigns) do
      ~H"""
      <.table>
        <.table_caption>Users</.table_caption>
        <.table_header>
          <.table_row>
            <.table_head>Name</.table_head>
            <.table_head>Email</.table_head>
          </.table_row>
        </.table_header>
        <.table_body>
          <.table_row>
            <.table_cell>Alice</.table_cell>
            <.table_cell>alice@example.com</.table_cell>
          </.table_row>
        </.table_body>
        <.table_footer>
          <.table_row>
            <.table_cell>1 user</.table_cell>
          </.table_row>
        </.table_footer>
      </.table>
      """
    end
  end

  # ---------------------------------------------------------------------------
  # table/1
  # ---------------------------------------------------------------------------

  describe "table/1" do
    test "renders outer wrapper div" do
      html = render_component(&H.render_table/1, %{})
      assert html =~ "<div"
    end

    test "wrapper div has relative w-full overflow-auto" do
      html = render_component(&H.render_table/1, %{})
      assert html =~ "relative"
      assert html =~ "w-full"
      assert html =~ "overflow-auto"
    end

    test "inner table element has w-full caption-bottom text-sm" do
      html = render_component(&H.render_table/1, %{})
      assert html =~ "<table"
      assert html =~ "caption-bottom"
      assert html =~ "text-sm"
    end

    test "accepts custom class on outer wrapper" do
      html = render_component(&H.render_table/1, %{class: "my-custom"})
      assert html =~ "my-custom"
    end

    test "passes @rest to outer wrapper" do
      html = render_component(&H.render_with_rest/1, %{})
      assert html =~ ~s(data-testid="my-table")
    end
  end

  # ---------------------------------------------------------------------------
  # table_header/1
  # ---------------------------------------------------------------------------

  describe "table_header/1" do
    test "renders thead element" do
      html = render_component(&H.render_table_header/1, %{})
      assert html =~ "<thead"
    end

    test "has [&_tr]:border-b class" do
      html = render_component(&H.render_table_header/1, %{})
      # Phoenix HTML-escapes & to &amp; in attribute values
      assert html =~ "[&amp;_tr]:border-b"
    end

    test "accepts custom class" do
      html = render_component(&H.render_table_header/1, %{class: "extra"})
      assert html =~ "extra"
    end
  end

  # ---------------------------------------------------------------------------
  # table_body/1
  # ---------------------------------------------------------------------------

  describe "table_body/1" do
    test "renders tbody element" do
      html = render_component(&H.render_table_body/1, %{})
      assert html =~ "<tbody"
    end

    test "has [&_tr:last-child]:border-0 class" do
      html = render_component(&H.render_table_body/1, %{})
      # Phoenix HTML-escapes & to &amp; in attribute values
      assert html =~ "[&amp;_tr:last-child]:border-0"
    end

    test "accepts custom class" do
      html = render_component(&H.render_table_body/1, %{class: "extra"})
      assert html =~ "extra"
    end
  end

  # ---------------------------------------------------------------------------
  # table_footer/1
  # ---------------------------------------------------------------------------

  describe "table_footer/1" do
    test "renders tfoot element" do
      html = render_component(&H.render_table_footer/1, %{})
      assert html =~ "<tfoot"
    end

    test "has border-t bg-muted/50 font-medium" do
      html = render_component(&H.render_table_footer/1, %{})
      assert html =~ "border-t"
      assert html =~ "bg-muted/50"
      assert html =~ "font-medium"
    end

    test "accepts custom class" do
      html = render_component(&H.render_table_footer/1, %{class: "extra"})
      assert html =~ "extra"
    end
  end

  # ---------------------------------------------------------------------------
  # table_row/1
  # ---------------------------------------------------------------------------

  describe "table_row/1" do
    test "renders tr element" do
      html = render_component(&H.render_table_row/1, %{})
      assert html =~ "<tr"
    end

    test "has border-b transition-colors hover:bg-muted/50" do
      html = render_component(&H.render_table_row/1, %{})
      assert html =~ "border-b"
      assert html =~ "transition-colors"
      assert html =~ "hover:bg-muted/50"
    end

    test "selected=true adds data-state=selected" do
      html = render_component(&H.render_table_row/1, %{selected: true})
      assert html =~ ~s(data-state="selected")
    end

    test "selected=false does not add data-state" do
      html = render_component(&H.render_table_row/1, %{selected: false})
      refute html =~ "data-state"
    end

    test "accepts custom class" do
      html = render_component(&H.render_table_row/1, %{class: "extra"})
      assert html =~ "extra"
    end
  end

  # ---------------------------------------------------------------------------
  # table_head/1
  # ---------------------------------------------------------------------------

  describe "table_head/1" do
    test "renders th element" do
      html = render_component(&H.render_table_head/1, %{})
      assert html =~ "<th"
    end

    test "has h-10 px-2 text-left align-middle font-medium text-muted-foreground" do
      html = render_component(&H.render_table_head/1, %{})
      assert html =~ "h-10"
      assert html =~ "px-2"
      assert html =~ "text-left"
      assert html =~ "align-middle"
      assert html =~ "font-medium"
      assert html =~ "text-muted-foreground"
    end

    test "accepts custom class" do
      html = render_component(&H.render_table_head/1, %{class: "w-32"})
      assert html =~ "w-32"
    end
  end

  # ---------------------------------------------------------------------------
  # table_cell/1
  # ---------------------------------------------------------------------------

  describe "table_cell/1" do
    test "renders td element" do
      html = render_component(&H.render_table_cell/1, %{})
      assert html =~ "<td"
    end

    test "has p-2 align-middle" do
      html = render_component(&H.render_table_cell/1, %{})
      assert html =~ "p-2"
      assert html =~ "align-middle"
    end

    test "accepts custom class" do
      html = render_component(&H.render_table_cell/1, %{class: "font-bold"})
      assert html =~ "font-bold"
    end
  end

  # ---------------------------------------------------------------------------
  # table_caption/1
  # ---------------------------------------------------------------------------

  describe "table_caption/1" do
    test "renders caption element" do
      html = render_component(&H.render_table_caption/1, %{})
      assert html =~ "<caption"
    end

    test "has mt-4 text-sm text-muted-foreground" do
      html = render_component(&H.render_table_caption/1, %{})
      assert html =~ "mt-4"
      assert html =~ "text-sm"
      assert html =~ "text-muted-foreground"
    end

    test "accepts custom class" do
      html = render_component(&H.render_table_caption/1, %{class: "italic"})
      assert html =~ "italic"
    end
  end

  # ---------------------------------------------------------------------------
  # Full composition
  # ---------------------------------------------------------------------------

  describe "full table composition" do
    test "all sub-components render correctly together" do
      html = render_component(&H.render_full/1, %{})
      assert html =~ "Users"
      assert html =~ "Name"
      assert html =~ "Email"
      assert html =~ "Alice"
      assert html =~ "alice@example.com"
      assert html =~ "1 user"
      assert html =~ "<thead"
      assert html =~ "<tbody"
      assert html =~ "<tfoot"
      assert html =~ "<caption"
    end
  end
end
