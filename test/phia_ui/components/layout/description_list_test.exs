defmodule PhiaUi.Components.Layout.DescriptionListTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.Layout.DescriptionList

    def render_description_list(assigns) do
      ~H"""
      <.description_list variant={assigns[:variant] || :vertical} class={assigns[:class]}>
        <.dl_item>
          <:term>Status</:term>
          <:description>Active</:description>
        </.dl_item>
      </.description_list>
      """
    end

    def render_dl_item(assigns) do
      ~H"""
      <dl>
        <.dl_item class={assigns[:class]}>
          <:term>Key</:term>
          <:description>Value</:description>
        </.dl_item>
      </dl>
      """
    end

    def render_dl_term(assigns) do
      ~H"<dl><dt><.dl_term class={assigns[:class]}>Label</.dl_term></dt></dl>"
    end

    def render_dl_description(assigns) do
      ~H"<dl><dd><.dl_description class={assigns[:class]}>Value</.dl_description></dd></dl>"
    end
  end

  defp render_description_list(attrs \\ %{}) do
    render_component(&H.render_description_list/1, attrs)
  end

  describe "description_list/1 default (vertical)" do
    test "renders a dl element" do
      assert render_description_list() =~ "<dl"
    end

    test "applies space-y-4 for vertical" do
      assert render_description_list() =~ "space-y-4"
    end

    test "renders term" do
      assert render_description_list() =~ "Status"
    end

    test "renders description" do
      assert render_description_list() =~ "Active"
    end
  end

  describe "description_list/1 variants" do
    test "horizontal applies divide-y" do
      assert render_description_list(%{variant: :horizontal}) =~ "divide-y"
    end

    test "grid applies grid grid-cols-2" do
      html = render_description_list(%{variant: :grid})
      assert html =~ "grid"
      assert html =~ "grid-cols-2"
    end
  end

  describe "description_list/1 class forwarding" do
    test "forwards custom class" do
      assert render_description_list(%{class: "mt-4"}) =~ "mt-4"
    end
  end

  describe "dl_term/1" do
    test "renders dt with muted foreground" do
      html = render_component(&H.render_dl_term/1, %{class: nil})
      assert html =~ "text-muted-foreground"
      assert html =~ "Label"
    end
  end

  describe "dl_description/1" do
    test "renders dd with foreground" do
      html = render_component(&H.render_dl_description/1, %{class: nil})
      assert html =~ "text-foreground"
      assert html =~ "Value"
    end
  end
end
