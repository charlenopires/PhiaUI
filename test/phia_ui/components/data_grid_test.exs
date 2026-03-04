defmodule PhiaUi.Components.DataGridTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.DataGrid

    # Full grid with sortable and non-sortable columns
    def render_grid(assigns) do
      ~H"""
      <.data_grid>
        <thead>
          <tr>
            <.data_grid_head sort_key="name" sort_dir={:none} on_sort="sort">Name</.data_grid_head>
            <.data_grid_head sort_key="email" sort_dir={:asc} on_sort="sort">Email</.data_grid_head>
            <.data_grid_head sort_key="age" sort_dir={:desc} on_sort="sort">Age</.data_grid_head>
            <.data_grid_head>Actions</.data_grid_head>
          </tr>
        </thead>
        <.data_grid_body id="users-body">
          <.data_grid_row id="row-1" class="highlighted">
            <.data_grid_cell>Alice</.data_grid_cell>
            <.data_grid_cell>alice@example.com</.data_grid_cell>
            <.data_grid_cell>30</.data_grid_cell>
            <.data_grid_cell>Edit</.data_grid_cell>
          </.data_grid_row>
        </.data_grid_body>
      </.data_grid>
      """
    end

    def render_stream_body(assigns) do
      ~H"""
      <.data_grid>
        <.data_grid_body id="stream-body" phx-update="stream">
          <.data_grid_row id="r1"><.data_grid_cell>Row 1</.data_grid_cell></.data_grid_row>
        </.data_grid_body>
      </.data_grid>
      """
    end

    def render_sort_none(assigns) do
      ~H"""
      <table>
        <thead><tr>
          <.data_grid_head sort_key="col" sort_dir={:none} on_sort="sort">Col</.data_grid_head>
        </tr></thead>
      </table>
      """
    end

    def render_sort_asc(assigns) do
      ~H"""
      <table>
        <thead><tr>
          <.data_grid_head sort_key="col" sort_dir={:asc} on_sort="sort">Col</.data_grid_head>
        </tr></thead>
      </table>
      """
    end

    def render_sort_desc(assigns) do
      ~H"""
      <table>
        <thead><tr>
          <.data_grid_head sort_key="col" sort_dir={:desc} on_sort="sort">Col</.data_grid_head>
        </tr></thead>
      </table>
      """
    end

    def render_no_sort(assigns) do
      ~H"""
      <table>
        <thead><tr>
          <.data_grid_head>Static Column</.data_grid_head>
        </tr></thead>
      </table>
      """
    end

    def render_pagination_basic(assigns) do
      ~H"""
      <.data_grid_pagination current_page={2} total_pages={5} />
      """
    end

    def render_pagination_first_page(assigns) do
      ~H"""
      <.data_grid_pagination current_page={1} total_pages={5} />
      """
    end

    def render_pagination_last_page(assigns) do
      ~H"""
      <.data_grid_pagination current_page={5} total_pages={5} />
      """
    end

    def render_toolbar(assigns) do
      ~H"""
      <.data_grid_toolbar>
        <input type="text" placeholder="Search..." />
      </.data_grid_toolbar>
      """
    end

    def render_column_toggle(assigns) do
      ~H"""
      <.data_grid_column_toggle
        id="toggle-test"
        columns={[
          %{key: "name", label: "Name", visible: true},
          %{key: "email", label: "Email", visible: false}
        ]}
        on_toggle="toggle_col"
      />
      """
    end

    def render_row_checkbox_checked(assigns) do
      ~H"""
      <table>
        <tbody>
          <tr>
            <.data_grid_row_checkbox row_id="user-1" checked={true} on_check="select_row" />
            <.data_grid_cell>Alice</.data_grid_cell>
          </tr>
        </tbody>
      </table>
      """
    end

    def render_row_checkbox_unchecked(assigns) do
      ~H"""
      <table>
        <tbody>
          <tr>
            <.data_grid_row_checkbox row_id="user-2" checked={false} on_check="select_row" />
            <.data_grid_cell>Bob</.data_grid_cell>
          </tr>
        </tbody>
      </table>
      """
    end

    def render_select_all(assigns) do
      ~H"""
      <table>
        <thead>
          <tr>
            <.data_grid_select_all on_check="select_all" />
            <.data_grid_head>Name</.data_grid_head>
          </tr>
        </thead>
      </table>
      """
    end

    def render_select_all_indeterminate(assigns) do
      ~H"""
      <table>
        <thead>
          <tr>
            <.data_grid_select_all checked={false} indeterminate={true} on_check="select_all" />
          </tr>
        </thead>
      </table>
      """
    end

    def render_grid_with_status(assigns) do
      ~H"""
      <.data_grid id="my-grid" status_message="Sorted by Name, ascending">
        <thead><tr><th>Name</th></tr></thead>
        <.data_grid_body id="body">
          <.data_grid_row id="r1"><.data_grid_cell>Alice</.data_grid_cell></.data_grid_row>
        </.data_grid_body>
      </.data_grid>
      """
    end

    def render_grid_with_empty_status(assigns) do
      ~H"""
      <.data_grid id="empty-grid">
        <thead><tr><th>Name</th></tr></thead>
        <.data_grid_body id="body2">
          <.data_grid_row id="r2"><.data_grid_cell>Bob</.data_grid_cell></.data_grid_row>
        </.data_grid_body>
      </.data_grid>
      """
    end
  end

  defp render_grid, do: render_component(&H.render_grid/1, %{})
  defp render_stream_body, do: render_component(&H.render_stream_body/1, %{})
  defp render_sort_none, do: render_component(&H.render_sort_none/1, %{})
  defp render_sort_asc, do: render_component(&H.render_sort_asc/1, %{})
  defp render_sort_desc, do: render_component(&H.render_sort_desc/1, %{})
  defp render_no_sort, do: render_component(&H.render_no_sort/1, %{})
  defp render_pagination_basic, do: render_component(&H.render_pagination_basic/1, %{})
  defp render_pagination_first_page, do: render_component(&H.render_pagination_first_page/1, %{})
  defp render_pagination_last_page, do: render_component(&H.render_pagination_last_page/1, %{})
  defp render_toolbar, do: render_component(&H.render_toolbar/1, %{})
  defp render_column_toggle, do: render_component(&H.render_column_toggle/1, %{})
  defp render_row_checkbox_checked, do: render_component(&H.render_row_checkbox_checked/1, %{})

  defp render_row_checkbox_unchecked,
    do: render_component(&H.render_row_checkbox_unchecked/1, %{})

  defp render_select_all, do: render_component(&H.render_select_all/1, %{})

  defp render_select_all_indeterminate,
    do: render_component(&H.render_select_all_indeterminate/1, %{})

  defp render_grid_with_status,
    do: render_component(&H.render_grid_with_status/1, %{})

  defp render_grid_with_empty_status,
    do: render_component(&H.render_grid_with_empty_status/1, %{})

  # ---------------------------------------------------------------------------
  # data_grid/1
  # ---------------------------------------------------------------------------

  describe "data_grid/1" do
    test "renders <table> element" do
      assert render_grid() =~ "<table"
    end

    test "renders cell content" do
      assert render_grid() =~ "Alice"
    end
  end

  # ---------------------------------------------------------------------------
  # data_grid_head/1 — sortable
  # ---------------------------------------------------------------------------

  describe "data_grid_head/1 — sort_dir :none" do
    test "renders <th> element" do
      assert render_sort_none() =~ "<th"
    end

    test "renders sort button when sort_key provided" do
      assert render_sort_none() =~ "<button"
    end

    test "shows chevrons-up-down icon for :none" do
      assert render_sort_none() =~ "chevrons-up-down"
    end

    test "has aria-sort='none'" do
      assert render_sort_none() =~ ~s(aria-sort="none")
    end

    test "has phx-click with on_sort event" do
      assert render_sort_none() =~ ~s(phx-click="sort")
    end

    test "has phx-value-key with sort_key" do
      assert render_sort_none() =~ ~s(phx-value-key="col")
    end

    test "fires :asc as next direction when currently :none" do
      assert render_sort_none() =~ ~s(phx-value-dir="asc")
    end
  end

  describe "data_grid_head/1 — sort_dir :asc" do
    test "shows chevron-up icon for :asc" do
      assert render_sort_asc() =~ "chevron-up"
    end

    test "has aria-sort='ascending'" do
      assert render_sort_asc() =~ ~s(aria-sort="ascending")
    end

    test "fires :desc as next direction when currently :asc" do
      assert render_sort_asc() =~ ~s(phx-value-dir="desc")
    end
  end

  describe "data_grid_head/1 — sort_dir :desc" do
    test "shows chevron-down icon for :desc" do
      assert render_sort_desc() =~ "chevron-down"
    end

    test "has aria-sort='descending'" do
      assert render_sort_desc() =~ ~s(aria-sort="descending")
    end

    test "fires :none as next direction when currently :desc" do
      assert render_sort_desc() =~ ~s(phx-value-dir="none")
    end
  end

  # ---------------------------------------------------------------------------
  # data_grid_head/1 — non-sortable
  # ---------------------------------------------------------------------------

  describe "data_grid_head/1 — no sort_key" do
    test "renders <th> without sort button" do
      html = render_no_sort()
      assert html =~ "<th"
      refute html =~ "<button"
    end

    test "renders column text" do
      assert render_no_sort() =~ "Static Column"
    end

    test "has no phx-click" do
      refute render_no_sort() =~ "phx-click"
    end
  end

  # ---------------------------------------------------------------------------
  # data_grid_body/1
  # ---------------------------------------------------------------------------

  describe "data_grid_body/1" do
    test "renders <tbody>" do
      assert render_grid() =~ "<tbody"
    end

    test "supports phx-update='stream'" do
      assert render_stream_body() =~ ~s(phx-update="stream")
    end
  end

  # ---------------------------------------------------------------------------
  # data_grid_row/1
  # ---------------------------------------------------------------------------

  describe "data_grid_row/1" do
    test "renders <tr>" do
      assert render_grid() =~ "<tr"
    end

    test "accepts :class for conditional styling" do
      assert render_grid() =~ "highlighted"
    end
  end

  # ---------------------------------------------------------------------------
  # data_grid_cell/1
  # ---------------------------------------------------------------------------

  describe "data_grid_cell/1" do
    test "renders <td>" do
      assert render_grid() =~ "<td"
    end

    test "renders cell content" do
      assert render_grid() =~ "alice@example.com"
    end
  end

  # ---------------------------------------------------------------------------
  # data_grid_toolbar/1
  # ---------------------------------------------------------------------------

  describe "data_grid_toolbar/1" do
    test "renders a div wrapper" do
      assert render_toolbar() =~ "<div"
    end

    test "renders slot content" do
      assert render_toolbar() =~ ~s(placeholder="Search...")
    end

    test "applies flex layout classes" do
      assert render_toolbar() =~ "flex"
    end
  end

  # ---------------------------------------------------------------------------
  # data_grid_pagination/1
  # ---------------------------------------------------------------------------

  describe "data_grid_pagination/1" do
    test "renders nav element with aria-label" do
      html = render_pagination_basic()
      assert html =~ "<nav"
      assert html =~ ~s(aria-label="Table pagination")
    end

    test "shows current page and total pages" do
      assert render_pagination_basic() =~ "Page 2 of 5"
    end

    test "previous and first buttons are disabled on first page" do
      html = render_pagination_first_page()
      assert html =~ "pointer-events-none opacity-50"
    end

    test "next and last buttons are disabled on last page" do
      html = render_pagination_last_page()
      assert html =~ "pointer-events-none opacity-50"
    end

    test "previous button has correct phx-value-page" do
      assert render_pagination_basic() =~ ~s(phx-value-page="1")
    end

    test "next button has correct phx-value-page" do
      assert render_pagination_basic() =~ ~s(phx-value-page="3")
    end

    test "fires paginate event by default" do
      assert render_pagination_basic() =~ ~s(phx-click="paginate")
    end

    test "renders rows-per-page selector" do
      html = render_pagination_basic()
      assert html =~ "Rows per page"
      assert html =~ "<select"
    end

    test "default page size options are present" do
      html = render_pagination_basic()
      assert html =~ ~s(value="10")
      assert html =~ ~s(value="20")
      assert html =~ ~s(value="50")
      assert html =~ ~s(value="100")
    end
  end

  # ---------------------------------------------------------------------------
  # data_grid_column_toggle/1
  # ---------------------------------------------------------------------------

  describe "data_grid_column_toggle/1" do
    test "renders toggle button with label" do
      html = render_column_toggle()
      assert html =~ "<button"
      assert html =~ "Columns"
    end

    test "renders column names in dropdown" do
      html = render_column_toggle()
      assert html =~ "Name"
      assert html =~ "Email"
    end

    test "visible column has checked attribute" do
      assert render_column_toggle() =~ "checked"
    end

    test "fires on_toggle event on each column checkbox" do
      assert render_column_toggle() =~ ~s(phx-click="toggle_col")
    end

    test "phx-value-column matches column keys" do
      html = render_column_toggle()
      assert html =~ ~s(phx-value-column="name")
      assert html =~ ~s(phx-value-column="email")
    end

    test "has id for JS toggle targeting" do
      assert render_column_toggle() =~ ~s(id="toggle-test")
    end
  end

  # ---------------------------------------------------------------------------
  # data_grid_row_checkbox/1
  # ---------------------------------------------------------------------------

  describe "data_grid_row_checkbox/1" do
    test "renders checkbox input inside td" do
      html = render_row_checkbox_checked()
      assert html =~ "<td"
      assert html =~ ~s(type="checkbox")
    end

    test "checked=true sets aria-checked='true'" do
      assert render_row_checkbox_checked() =~ ~s(aria-checked="true")
    end

    test "checked=false sets aria-checked='false'" do
      assert render_row_checkbox_unchecked() =~ ~s(aria-checked="false")
    end

    test "phx-value-id matches row_id" do
      assert render_row_checkbox_checked() =~ ~s(phx-value-id="user-1")
    end

    test "fires on_check event" do
      assert render_row_checkbox_checked() =~ ~s(phx-click="select_row")
    end
  end

  # ---------------------------------------------------------------------------
  # data_grid_select_all/1
  # ---------------------------------------------------------------------------

  describe "data_grid_select_all/1" do
    test "renders checkbox inside th" do
      html = render_select_all()
      assert html =~ "<th"
      assert html =~ ~s(type="checkbox")
    end

    test "has aria-label 'Select all rows'" do
      assert render_select_all() =~ ~s(aria-label="Select all rows")
    end

    test "indeterminate=true sets aria-checked='mixed'" do
      assert render_select_all_indeterminate() =~ ~s(aria-checked="mixed")
    end

    test "indeterminate=false sets aria-checked='false' by default" do
      assert render_select_all() =~ ~s(aria-checked="false")
    end

    test "fires on_check event" do
      assert render_select_all() =~ ~s(phx-click="select_all")
    end
  end

  # ---------------------------------------------------------------------------
  # data_grid/1 — aria-live status region
  # ---------------------------------------------------------------------------

  describe "data_grid/1 — aria-live status region" do
    test "renders a visually hidden aria-live region with role=status" do
      html = render_grid_with_status()
      assert html =~ ~s(role="status")
      assert html =~ ~s(aria-live="polite")
      assert html =~ ~s(aria-atomic="true")
      assert html =~ ~s(class="sr-only")
    end

    test "aria-live region contains the status_message text" do
      assert render_grid_with_status() =~ "Sorted by Name, ascending"
    end

    test "aria-live region id is derived from component id" do
      assert render_grid_with_status() =~ ~s(id="my-grid-status")
    end

    test "status_message defaults to empty string when not provided" do
      html = render_grid_with_empty_status()
      assert html =~ ~s(role="status")
      assert html =~ ~s(aria-live="polite")
    end

    test "outer wrapper div receives the id attribute" do
      assert render_grid_with_status() =~ ~s(id="my-grid")
    end
  end

  # ---------------------------------------------------------------------------
  # data_grid_pagination/1 — touch target size
  # ---------------------------------------------------------------------------

  describe "data_grid_pagination/1 — touch target size" do
    test "pagination buttons use h-9 w-9 for 36px touch targets" do
      html = render_pagination_basic()
      assert html =~ "h-9 w-9"
    end

    test "pagination buttons do not use the old h-8 w-8 size" do
      refute render_pagination_basic() =~ "h-8 w-8"
    end
  end

  # ---------------------------------------------------------------------------
  # data_grid_row_checkbox/1 — aria-label
  # ---------------------------------------------------------------------------

  describe "data_grid_row_checkbox/1 — aria-label" do
    test "row checkbox has aria-label identifying the row" do
      assert render_row_checkbox_checked() =~ ~s(aria-label="Select row")
    end
  end
end
