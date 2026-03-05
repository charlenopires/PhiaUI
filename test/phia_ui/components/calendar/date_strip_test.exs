defmodule PhiaUi.Components.DateStripTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.DateStrip

    @dates [~D[2026-03-23], ~D[2026-03-24], ~D[2026-03-25], ~D[2026-03-31]]

    def render_default(assigns) do
      assigns = assign(assigns, :dates, @dates)
      ~H"<.date_strip dates={@dates} />"
    end

    def render_with_selected(assigns) do
      assigns = assign(assigns, :dates, @dates)
      ~H"<.date_strip dates={@dates} selected_date={~D[2026-03-23]} />"
    end

    def render_with_today(assigns) do
      assigns = assign(assigns, :dates, @dates)
      ~H"<.date_strip dates={@dates} today={~D[2026-03-24]} />"
    end

    def render_with_click(assigns) do
      assigns = assign(assigns, :dates, @dates)
      ~H[<.date_strip dates={@dates} on_select="pick_date" />]
    end

    def render_sm(assigns) do
      assigns = assign(assigns, :dates, @dates)
      ~H"<.date_strip dates={@dates} size={:sm} />"
    end

    def render_lg(assigns) do
      assigns = assign(assigns, :dates, @dates)
      ~H"<.date_strip dates={@dates} size={:lg} />"
    end

    def render_not_scrollable(assigns) do
      assigns = assign(assigns, :dates, @dates)
      ~H"<.date_strip dates={@dates} scrollable={false} />"
    end

    def render_with_class(assigns) do
      assigns = assign(assigns, :dates, @dates)
      ~H[<.date_strip dates={@dates} class="my-strip" />]
    end
  end

  describe "date_strip/1" do
    test "renders all 4 dates" do
      html = render_component(&H.render_default/1, %{})
      # 4 cards rendered — check for the flex-shrink-0 wrapper per card
      cards = Regex.scan(~r/flex-shrink-0/, html)
      assert length(cards) == 4
    end

    test "renders day numbers 23, 24, 25, 31" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "23"
      assert html =~ "24"
      assert html =~ "25"
      assert html =~ "31"
    end

    test "renders day abbreviations" do
      html = render_component(&H.render_default/1, %{})
      # 2026-03-23 is Monday
      assert html =~ "Mon"
      # 2026-03-24 is Tuesday
      assert html =~ "Tue"
      # 2026-03-25 is Wednesday
      assert html =~ "Wed"
      # 2026-03-31 is Tuesday
      assert html =~ "Tue"
    end

    test "default state includes bg-background" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "bg-background"
    end

    test "default state includes shadow-sm" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "shadow-sm"
    end

    test "selected date includes bg-primary" do
      html = render_component(&H.render_with_selected/1, %{})
      assert html =~ "bg-primary"
    end

    test "selected date includes text-primary-foreground" do
      html = render_component(&H.render_with_selected/1, %{})
      assert html =~ "text-primary-foreground"
    end

    test "today date includes bg-primary/10" do
      html = render_component(&H.render_with_today/1, %{})
      assert html =~ "bg-primary/10"
    end

    test "today date includes text-primary" do
      html = render_component(&H.render_with_today/1, %{})
      assert html =~ "text-primary"
    end

    test "non-selected non-today dates do not have bg-primary as a direct class" do
      html = render_component(&H.render_default/1, %{})
      # No selected_date and no today set — bg-primary should not appear
      refute html =~ "bg-primary"
    end

    test "on_select adds phx-click attribute" do
      html = render_component(&H.render_with_click/1, %{})
      assert html =~ ~s(phx-click="pick_date")
    end

    test "on_select adds phx-value-date attribute" do
      html = render_component(&H.render_with_click/1, %{})
      assert html =~ "phx-value-date"
    end

    test "phx-value-date contains iso8601 formatted date" do
      html = render_component(&H.render_with_click/1, %{})
      assert html =~ ~s(phx-value-date="2026-03-23")
      assert html =~ ~s(phx-value-date="2026-03-31")
    end

    test "scrollable (default) has overflow-x-auto" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "overflow-x-auto"
    end

    test "not scrollable removes overflow-x-auto" do
      html = render_component(&H.render_not_scrollable/1, %{})
      refute html =~ "overflow-x-auto"
    end

    test "sm size renders w-12" do
      html = render_component(&H.render_sm/1, %{})
      assert html =~ "w-12"
    end

    test "lg size renders w-20" do
      html = render_component(&H.render_lg/1, %{})
      assert html =~ "w-20"
    end

    test "default size renders w-16" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "w-16"
    end

    test "custom class applied to wrapper" do
      html = render_component(&H.render_with_class/1, %{})
      assert html =~ "my-strip"
    end

    test "renders flex gap-2" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "flex"
      assert html =~ "gap-2"
    end
  end
end
