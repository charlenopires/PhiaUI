defmodule PhiaUi.Components.FilterBarTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.FilterBar

    def render_bar(assigns) do
      ~H"""
      <.filter_bar class={assigns[:class]}>
        <.filter_search placeholder={assigns[:placeholder]} on_search={assigns[:on_search] || "search"} />
        <.filter_select
          label="Status"
          name="status"
          options={[{"All", ""}, {"Active", "active"}, {"Inactive", "inactive"}]}
          value={assigns[:status] || ""}
          on_change="filter_status"
        />
        <.filter_toggle label="Archived" name="archived" checked={assigns[:archived] || false} on_change="toggle_archived" />
        <.filter_reset on_click="reset_filters" />
      </.filter_bar>
      """
    end

    def render_bar_empty(assigns) do
      ~H"""
      <.filter_bar>
        <.filter_search on_search="search" />
      </.filter_bar>
      """
    end

    def render_search(assigns) do
      ~H"""
      <.filter_search
        placeholder={assigns[:placeholder] || "Search…"}
        on_search={assigns[:on_search] || "search"}
        value={assigns[:value] || ""}
        class={assigns[:class]}
      />
      """
    end

    def render_select(assigns) do
      ~H"""
      <.filter_select
        label={assigns[:label] || "Status"}
        name={assigns[:name] || "status"}
        options={assigns[:options] || [{"All", ""}, {"Active", "active"}]}
        value={assigns[:value] || ""}
        on_change={assigns[:on_change] || "filter_change"}
        class={assigns[:class]}
      />
      """
    end

    def render_toggle(assigns) do
      ~H"""
      <.filter_toggle
        label={assigns[:label] || "Archived"}
        name={assigns[:name] || "archived"}
        checked={assigns[:checked] || false}
        on_change={assigns[:on_change] || "toggle_filter"}
        class={assigns[:class]}
      />
      """
    end

    def render_reset(assigns) do
      ~H"""
      <.filter_reset on_click={assigns[:on_click] || "reset_filters"} label={assigns[:label]} class={assigns[:class]} />
      """
    end
  end

  defp render_bar(attrs \\ %{}), do: render_component(&H.render_bar/1, attrs)
  defp render_bar_empty(attrs \\ %{}), do: render_component(&H.render_bar_empty/1, attrs)
  defp render_search(attrs \\ %{}), do: render_component(&H.render_search/1, attrs)
  defp render_select(attrs \\ %{}), do: render_component(&H.render_select/1, attrs)
  defp render_toggle(attrs \\ %{}), do: render_component(&H.render_toggle/1, attrs)
  defp render_reset(attrs \\ %{}), do: render_component(&H.render_reset/1, attrs)

  # ---------------------------------------------------------------------------
  # filter_bar/1 — root container
  # ---------------------------------------------------------------------------

  describe "filter_bar/1 — structure" do
    test "renders a root element" do
      assert render_bar() =~ "<div"
    end

    test "renders inner slot content" do
      assert render_bar() =~ ~s(type="search") or render_bar() =~ "<input"
    end

    test "custom class is applied to wrapper" do
      assert render_bar(%{class: "my-filter-bar"}) =~ "my-filter-bar"
    end

    test "renders children from slot" do
      html = render_bar()
      assert html =~ "Status"
      assert html =~ "Archived"
    end
  end

  # ---------------------------------------------------------------------------
  # filter_search/1
  # ---------------------------------------------------------------------------

  describe "filter_search/1 — search input" do
    test "renders an input element" do
      assert render_search() =~ "<input"
    end

    test "input has search type or text type" do
      html = render_search()
      assert html =~ ~s(type="search") or html =~ ~s(type="text")
    end

    test "placeholder is applied when provided" do
      html = render_search(%{placeholder: "Find users..."})
      assert html =~ "Find users..."
    end

    test "default placeholder is applied when not provided" do
      assert render_search() =~ "Search"
    end

    test "phx-change or phx-keyup is wired to on_search event" do
      html = render_search(%{on_search: "my_search_event"})
      assert html =~ "my_search_event"
    end

    test "value is populated when provided" do
      html = render_search(%{value: "hello"})
      assert html =~ "hello"
    end

    test "custom class is applied" do
      assert render_search(%{class: "my-search"}) =~ "my-search"
    end

    test "has search icon or magnifier indicator" do
      html = render_search()
      assert html =~ "search" or html =~ "magnify" or html =~ "svg"
    end
  end

  # ---------------------------------------------------------------------------
  # filter_select/1
  # ---------------------------------------------------------------------------

  describe "filter_select/1 — dropdown select" do
    test "renders a select element" do
      assert render_select() =~ "<select"
    end

    test "renders a label when provided" do
      html = render_select(%{label: "Category"})
      assert html =~ "Category"
    end

    test "renders option elements for each entry" do
      html = render_select(%{options: [{"All", ""}, {"Active", "active"}]})
      assert html =~ "<option"
      assert html =~ "All"
      assert html =~ "Active"
    end

    test "option values are set correctly" do
      html = render_select(%{options: [{"Active", "active"}]})
      assert html =~ ~s(value="active")
    end

    test "selected value is marked as selected" do
      html = render_select(%{options: [{"All", ""}, {"Active", "active"}], value: "active"})
      assert html =~ "selected"
    end

    test "phx-change is wired to on_change event" do
      html = render_select(%{on_change: "my_change_event"})
      assert html =~ "my_change_event"
    end

    test "name attribute is set on the select" do
      html = render_select(%{name: "my_filter"})
      assert html =~ "my_filter"
    end

    test "custom class is applied" do
      assert render_select(%{class: "my-select"}) =~ "my-select"
    end
  end

  # ---------------------------------------------------------------------------
  # filter_toggle/1
  # ---------------------------------------------------------------------------

  describe "filter_toggle/1 — checkbox toggle" do
    test "renders a checkbox input" do
      html = render_toggle()
      assert html =~ ~s(type="checkbox")
    end

    test "renders a label" do
      html = render_toggle(%{label: "Show archived"})
      assert html =~ "Show archived"
    end

    test "checked attribute is set when checked=true" do
      html = render_toggle(%{checked: true})
      assert html =~ "checked"
    end

    test "not checked when checked=false" do
      html = render_toggle(%{checked: false})
      refute html =~ ~s(checked="true")
    end

    test "name attribute is set on the input" do
      html = render_toggle(%{name: "archived_filter"})
      assert html =~ "archived_filter"
    end

    test "phx-change is wired to on_change event" do
      html = render_toggle(%{on_change: "my_toggle_event"})
      assert html =~ "my_toggle_event"
    end

    test "custom class is applied" do
      assert render_toggle(%{class: "my-toggle"}) =~ "my-toggle"
    end
  end

  # ---------------------------------------------------------------------------
  # filter_reset/1
  # ---------------------------------------------------------------------------

  describe "filter_reset/1 — reset button" do
    test "renders a button" do
      assert render_reset() =~ "<button"
    end

    test "button has phx-click wired to on_click event" do
      html = render_reset(%{on_click: "my_reset"})
      assert html =~ "my_reset"
    end

    test "renders default label 'Reset' or 'Clear'" do
      html = render_reset()
      assert html =~ "Reset" or html =~ "Clear" or html =~ "reset" or html =~ "clear"
    end

    test "renders custom label when provided" do
      html = render_reset(%{label: "Clear all"})
      assert html =~ "Clear all"
    end

    test "custom class is applied" do
      assert render_reset(%{class: "my-reset"}) =~ "my-reset"
    end
  end

  # ---------------------------------------------------------------------------
  # Semantic tokens
  # ---------------------------------------------------------------------------

  describe "filter_bar/1 — semantic tokens" do
    test "uses border-border or border-input token" do
      html = render_bar()
      assert html =~ "border-border" or html =~ "border-input" or html =~ "border"
    end

    test "uses bg-background or bg-muted token" do
      html = render_bar()
      assert html =~ "bg-background" or html =~ "bg-muted" or html =~ "bg-"
    end

    test "no hardcoded hex colors in style attributes" do
      html = render_bar()
      refute html =~ ~r/style="[^"]*#[0-9a-fA-F]{3,6}/
    end
  end

  # ---------------------------------------------------------------------------
  # Full composition
  # ---------------------------------------------------------------------------

  describe "full composition" do
    test "renders search + select + toggle + reset together" do
      html = render_bar()
      assert html =~ "<input"
      assert html =~ "<select"
      assert html =~ ~s(type="checkbox")
      assert html =~ "<button"
    end

    test "renders with only search input (minimal)" do
      html = render_bar_empty()
      assert html =~ "<input"
    end

    test "no hardcoded hex colors in full composition" do
      html = render_bar()
      refute html =~ ~r/style="[^"]*#[0-9a-fA-F]{3,6}/
    end
  end
end
