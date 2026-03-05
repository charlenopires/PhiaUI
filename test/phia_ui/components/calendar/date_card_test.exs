defmodule PhiaUi.Components.DateCardTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.DateCard

    def render_default(assigns), do: ~H"<.date_card date={~D[2026-03-23]} />"
    def render_selected(assigns), do: ~H"<.date_card date={~D[2026-03-23]} selected />"
    def render_today(assigns), do: ~H"<.date_card date={~D[2026-03-23]} today />"
    def render_disabled(assigns), do: ~H"<.date_card date={~D[2026-03-23]} disabled />"
    def render_sm(assigns), do: ~H"<.date_card date={~D[2026-03-23]} size={:sm} />"
    def render_lg(assigns), do: ~H"<.date_card date={~D[2026-03-23]} size={:lg} />"
    def render_with_class(assigns) do
      ~H'<.date_card date={~D[2026-03-23]} class="my-card" />'
    end

    def render_with_click(assigns) do
      ~H'<.date_card date={~D[2026-03-23]} on_click="select_date" />'
    end

    def render_disabled_with_click(assigns) do
      ~H'<.date_card date={~D[2026-03-23]} disabled on_click="select_date" />'
    end
    def render_31_mon(assigns), do: ~H"<.date_card date={~D[2026-03-31]} />"
  end

  describe "date_card/1 — day number and abbreviation" do
    test "renders day number 23" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "23"
    end

    test "renders weekday abbreviation for 2026-03-23 (Mon)" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "Mon"
    end

    test "renders day number 31 for date 2026-03-31" do
      html = render_component(&H.render_31_mon/1, %{})
      assert html =~ "31"
    end

    test "renders weekday abbreviation Tue for 2026-03-31" do
      html = render_component(&H.render_31_mon/1, %{})
      assert html =~ "Tue"
    end
  end

  describe "date_card/1 — default state" do
    test "default has bg-background" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "bg-background"
    end

    test "default has border class" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "border"
    end

    test "default has shadow-sm" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "shadow-sm"
    end

    test "default has rounded-2xl" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "rounded-2xl"
    end
  end

  describe "date_card/1 — selected state" do
    test "selected has bg-primary" do
      html = render_component(&H.render_selected/1, %{})
      assert html =~ "bg-primary"
    end

    test "selected has text-primary-foreground" do
      html = render_component(&H.render_selected/1, %{})
      assert html =~ "text-primary-foreground"
    end

    test "selected does not have shadow-sm" do
      html = render_component(&H.render_selected/1, %{})
      refute html =~ "shadow-sm"
    end
  end

  describe "date_card/1 — today state" do
    test "today has bg-primary/10" do
      html = render_component(&H.render_today/1, %{})
      assert html =~ "bg-primary/10"
    end

    test "today has text-primary" do
      html = render_component(&H.render_today/1, %{})
      assert html =~ "text-primary"
    end

    test "today has border-primary/20" do
      html = render_component(&H.render_today/1, %{})
      assert html =~ "border-primary/20"
    end
  end

  describe "date_card/1 — disabled state" do
    test "disabled has opacity-50" do
      html = render_component(&H.render_disabled/1, %{})
      assert html =~ "opacity-50"
    end

    test "disabled has pointer-events-none" do
      html = render_component(&H.render_disabled/1, %{})
      assert html =~ "pointer-events-none"
    end

    test "disabled has cursor-not-allowed" do
      html = render_component(&H.render_disabled/1, %{})
      assert html =~ "cursor-not-allowed"
    end
  end

  describe "date_card/1 — size variants" do
    test "size :sm renders w-12" do
      html = render_component(&H.render_sm/1, %{})
      assert html =~ "w-12"
    end

    test "size :default renders w-16" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "w-16"
    end

    test "size :lg renders w-20" do
      html = render_component(&H.render_lg/1, %{})
      assert html =~ "w-20"
    end
  end

  describe "date_card/1 — custom class" do
    test "custom class is applied" do
      html = render_component(&H.render_with_class/1, %{})
      assert html =~ "my-card"
    end
  end

  describe "date_card/1 — on_click" do
    test "on_click renders phx-click attribute" do
      html = render_component(&H.render_with_click/1, %{})
      assert html =~ ~s(phx-click="select_date")
    end

    test "on_click renders phx-value-date with ISO 8601 date" do
      html = render_component(&H.render_with_click/1, %{})
      assert html =~ ~s(phx-value-date="2026-03-23")
    end

    test "disabled ignores on_click — no phx-click rendered" do
      html = render_component(&H.render_disabled_with_click/1, %{})
      refute html =~ "phx-click"
    end

    test "disabled ignores on_click — no phx-value-date rendered" do
      html = render_component(&H.render_disabled_with_click/1, %{})
      refute html =~ "phx-value-date"
    end
  end
end
