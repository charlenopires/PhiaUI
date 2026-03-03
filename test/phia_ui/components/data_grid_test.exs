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
  end

  defp render_grid, do: render_component(&H.render_grid/1, %{})
  defp render_stream_body, do: render_component(&H.render_stream_body/1, %{})
  defp render_sort_none, do: render_component(&H.render_sort_none/1, %{})
  defp render_sort_asc, do: render_component(&H.render_sort_asc/1, %{})
  defp render_sort_desc, do: render_component(&H.render_sort_desc/1, %{})
  defp render_no_sort, do: render_component(&H.render_no_sort/1, %{})

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
end
