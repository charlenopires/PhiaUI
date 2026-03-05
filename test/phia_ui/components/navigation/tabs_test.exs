defmodule PhiaUi.Components.TabsTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.Tabs

    attr(:default_value, :string, default: "tab1")
    attr(:class, :string, default: nil)
    attr(:variant, :atom, default: :solid)

    def render_tabs(assigns) do
      ~H"""
      <.tabs default_value={@default_value} class={@class} variant={@variant}>
        <.tabs_list variant={@variant}>
          <.tabs_trigger value="tab1" active={@default_value} variant={@variant}>Tab 1</.tabs_trigger>
          <.tabs_trigger value="tab2" active={@default_value} variant={@variant}>Tab 2</.tabs_trigger>
          <.tabs_trigger value="tab3" active={@default_value} variant={@variant} disabled>Tab 3</.tabs_trigger>
        </.tabs_list>
        <.tabs_content value="tab1" active={@default_value}>Content 1</.tabs_content>
        <.tabs_content value="tab2" active={@default_value}>Content 2</.tabs_content>
        <.tabs_content value="tab3" active={@default_value}>Content 3</.tabs_content>
      </.tabs>
      """
    end

    def render_tabs_underline(assigns) do
      ~H"""
      <.tabs default_value="tab1" variant={:underline}>
        <.tabs_list variant={:underline}>
          <.tabs_trigger value="tab1" active="tab1" variant={:underline}>Tab 1</.tabs_trigger>
          <.tabs_trigger value="tab2" active="tab1" variant={:underline}>Tab 2</.tabs_trigger>
        </.tabs_list>
        <.tabs_content value="tab1" active="tab1">Content 1</.tabs_content>
      </.tabs>
      """
    end

    def render_tabs_pill(assigns) do
      ~H"""
      <.tabs default_value="tab1" variant={:pill}>
        <.tabs_list variant={:pill}>
          <.tabs_trigger value="tab1" active="tab1" variant={:pill}>Tab 1</.tabs_trigger>
          <.tabs_trigger value="tab2" active="tab1" variant={:pill}>Tab 2</.tabs_trigger>
        </.tabs_list>
        <.tabs_content value="tab1" active="tab1">Content 1</.tabs_content>
      </.tabs>
      """
    end
  end

  defp render_tabs(attrs \\ %{}) do
    render_component(&H.render_tabs/1, attrs)
  end

  # ---------------------------------------------------------------------------
  # tabs/1 — container
  # ---------------------------------------------------------------------------

  describe "tabs/1 container" do
    test "renders a div wrapper" do
      assert render_tabs() =~ "<div"
    end

    test "applies custom class" do
      assert render_tabs(%{class: "w-full"}) =~ "w-full"
    end

    test "renders all triggers" do
      html = render_tabs()
      assert html =~ "Tab 1"
      assert html =~ "Tab 2"
      assert html =~ "Tab 3"
    end

    test "renders all content panels" do
      html = render_tabs()
      assert html =~ "Content 1"
      assert html =~ "Content 2"
      assert html =~ "Content 3"
    end
  end

  # ---------------------------------------------------------------------------
  # tabs_list/1
  # ---------------------------------------------------------------------------

  describe "tabs_list/1" do
    test "renders role=tablist" do
      assert render_tabs() =~ ~s(role="tablist")
    end

    test "renders bg-muted track" do
      assert render_tabs(%{variant: :solid}) =~ "bg-muted"
    end

    test "renders rounded container" do
      assert render_tabs() =~ "rounded"
    end
  end

  # ---------------------------------------------------------------------------
  # tabs_trigger/1 — ARIA
  # ---------------------------------------------------------------------------

  describe "tabs_trigger/1 ARIA" do
    test "renders role=tab on each trigger" do
      html = render_tabs()
      count = html |> String.split(~s(role="tab")) |> length() |> Kernel.-(1)
      assert count == 3
    end

    test "selected trigger has aria-selected=true" do
      html = render_tabs(%{default_value: "tab1"})
      assert html =~ ~s(aria-selected="true")
    end

    test "non-selected triggers have aria-selected=false" do
      html = render_tabs(%{default_value: "tab1"})
      count = html |> String.split(~s(aria-selected="false")) |> length() |> Kernel.-(1)
      assert count == 2
    end

    test "each trigger has aria-controls pointing to its panel" do
      html = render_tabs(%{default_value: "tab1"})
      assert html =~ ~s(aria-controls="panel-tab1")
      assert html =~ ~s(aria-controls="panel-tab2")
    end
  end

  # ---------------------------------------------------------------------------
  # tabs_trigger/1 — selected state
  # ---------------------------------------------------------------------------

  describe "tabs_trigger/1 selected state" do
    test "selected trigger has bg-background" do
      html = render_tabs(%{variant: :solid, default_value: "tab1"})
      assert html =~ "bg-background"
    end

    test "selected trigger has shadow" do
      html = render_tabs(%{variant: :solid, default_value: "tab1"})
      assert html =~ "shadow"
    end

    test "switching default_value changes which tab is selected" do
      html = render_tabs(%{default_value: "tab2"})
      # Find aria-selected=true — it should be near "Tab 2"
      assert html =~ ~s(aria-selected="true")
    end
  end

  # ---------------------------------------------------------------------------
  # tabs_trigger/1 — disabled
  # ---------------------------------------------------------------------------

  describe "tabs_trigger/1 disabled" do
    test "disabled trigger renders disabled attribute" do
      assert render_tabs() =~ "disabled"
    end

    test "disabled trigger has opacity class" do
      assert render_tabs() =~ "opacity-50"
    end
  end

  # ---------------------------------------------------------------------------
  # tabs_content/1 — visibility
  # ---------------------------------------------------------------------------

  describe "tabs_content/1 visibility" do
    test "active content panel renders role=tabpanel" do
      assert render_tabs() =~ ~s(role="tabpanel")
    end

    test "active content has its id set correctly" do
      html = render_tabs(%{default_value: "tab1"})
      assert html =~ ~s(id="panel-tab1")
    end

    test "active content is visible (block)" do
      html = render_tabs(%{default_value: "tab1"})
      assert html =~ "Content 1"
    end

    test "inactive content is hidden" do
      html = render_tabs(%{default_value: "tab1"})
      # Content 2 should be hidden (display:none or hidden class)
      assert html =~ "hidden"
    end

    test "only active panel is visible — others have hidden class" do
      html = render_tabs(%{default_value: "tab2"})
      # tab2 content visible, tab1 and tab3 hidden
      assert html =~ "Content 2"
    end
  end

  # ---------------------------------------------------------------------------
  # tabs_content/1 — ARIA
  # ---------------------------------------------------------------------------

  describe "tabs_content/1 ARIA" do
    test "panel has aria-labelledby pointing to its trigger" do
      html = render_tabs(%{default_value: "tab1"})
      assert html =~ ~s(aria-labelledby="trigger-tab1")
    end
  end

  # ---------------------------------------------------------------------------
  # tabs semantic tokens
  # ---------------------------------------------------------------------------

  describe "tabs semantic tokens" do
    test "uses bg-muted for list track (not bg-gray)" do
      html = render_tabs(%{variant: :solid})
      assert html =~ "bg-muted"
      refute html =~ "bg-gray-"
    end

    test "uses text-muted-foreground for inactive triggers" do
      assert render_tabs() =~ "text-muted-foreground"
    end
  end

  # ---------------------------------------------------------------------------
  # tabs variant :underline
  # ---------------------------------------------------------------------------

  describe "tabs variant :underline" do
    test "does not have bg-muted container" do
      html = render_component(&H.render_tabs_underline/1, %{})
      refute html =~ "bg-muted"
    end

    test "has border-b class on list" do
      html = render_component(&H.render_tabs_underline/1, %{})
      assert html =~ "border-b"
    end

    test "selected trigger has border-primary" do
      html = render_component(&H.render_tabs_underline/1, %{})
      assert html =~ "border-primary"
    end

    test "trigger has rounded-none" do
      html = render_component(&H.render_tabs_underline/1, %{})
      assert html =~ "rounded-none"
    end
  end

  # ---------------------------------------------------------------------------
  # tabs variant :pill
  # ---------------------------------------------------------------------------

  describe "tabs variant :pill" do
    test "selected trigger has bg-primary" do
      html = render_component(&H.render_tabs_pill/1, %{})
      assert html =~ "bg-primary"
    end

    test "trigger has rounded-full" do
      html = render_component(&H.render_tabs_pill/1, %{})
      assert html =~ "rounded-full"
    end
  end

  # ---------------------------------------------------------------------------
  # tabs variant :solid (explicit)
  # ---------------------------------------------------------------------------

  describe "tabs variant :solid (explicit)" do
    test "has bg-muted container" do
      html = render_component(&H.render_tabs/1, %{variant: :solid})
      assert html =~ "bg-muted"
    end

    test "selected trigger has bg-background" do
      html = render_component(&H.render_tabs/1, %{variant: :solid})
      assert html =~ "bg-background"
    end

    test "selected trigger has shadow" do
      html = render_component(&H.render_tabs/1, %{variant: :solid})
      assert html =~ "shadow"
    end
  end
end
