defmodule PhiaUi.Components.AlertTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.Alert

    attr :variant, :atom, default: :default
    attr :class, :string, default: nil

    def render_alert(assigns) do
      ~H"""
      <.alert variant={@variant} class={@class}>
        <.alert_title>Alert Title</.alert_title>
        <.alert_description>Alert description text.</.alert_description>
      </.alert>
      """
    end

    def render_with_icon(assigns) do
      ~H"""
      <.alert>
        <:icon>
          <svg data-testid="icon"><use href="#icon-circle-alert" /></svg>
        </:icon>
        <.alert_title>With Icon</.alert_title>
      </.alert>
      """
    end

    def render_without_icon(assigns) do
      ~H"""
      <.alert>
        <.alert_title>No Icon</.alert_title>
      </.alert>
      """
    end

    def render_with_class(assigns) do
      ~H"""
      <.alert class="custom-class">Content</.alert>
      """
    end

    def render_with_rest(assigns) do
      ~H"""
      <.alert data-testid="my-alert">Content</.alert>
      """
    end
  end

  defp render_alert(attrs \\ %{}) do
    render_component(&H.render_alert/1, attrs)
  end

  # ---------------------------------------------------------------------------
  # Base structure
  # ---------------------------------------------------------------------------

  describe "base structure" do
    test "renders with role=alert" do
      assert render_alert() =~ ~s(role="alert")
    end

    test "renders rounded-lg" do
      assert render_alert() =~ "rounded-lg"
    end

    test "renders border" do
      assert render_alert() =~ "border"
    end

    test "renders p-4" do
      assert render_alert() =~ "p-4"
    end

    test "renders inner content" do
      html = render_alert()
      assert html =~ "Alert Title"
      assert html =~ "Alert description text."
    end
  end

  # ---------------------------------------------------------------------------
  # Variants
  # ---------------------------------------------------------------------------

  describe "variant :default" do
    test "renders bg-background" do
      assert render_alert(%{variant: :default}) =~ "bg-background"
    end

    test "renders text-foreground" do
      assert render_alert(%{variant: :default}) =~ "text-foreground"
    end
  end

  describe "variant :destructive" do
    test "renders border-destructive" do
      assert render_alert(%{variant: :destructive}) =~ "border-destructive"
    end

    test "renders text-destructive" do
      assert render_alert(%{variant: :destructive}) =~ "text-destructive"
    end
  end

  describe "variant :warning" do
    test "renders yellow background token" do
      assert render_alert(%{variant: :warning}) =~ "bg-yellow"
    end

    test "renders yellow text token" do
      assert render_alert(%{variant: :warning}) =~ "text-yellow"
    end

    test "renders yellow border token" do
      assert render_alert(%{variant: :warning}) =~ "border-yellow"
    end
  end

  describe "variant :success" do
    test "renders green background token" do
      assert render_alert(%{variant: :success}) =~ "bg-green"
    end

    test "renders green text token" do
      assert render_alert(%{variant: :success}) =~ "text-green"
    end

    test "renders green border token" do
      assert render_alert(%{variant: :success}) =~ "border-green"
    end
  end

  # ---------------------------------------------------------------------------
  # Sub-components
  # ---------------------------------------------------------------------------

  describe "alert_title/1" do
    test "renders title text" do
      assert render_alert() =~ "Alert Title"
    end

    test "renders font-medium class" do
      assert render_alert() =~ "font-medium"
    end

    test "renders leading-none" do
      assert render_alert() =~ "leading-none"
    end
  end

  describe "alert_description/1" do
    test "renders description text" do
      assert render_alert() =~ "Alert description text."
    end

    test "renders text-sm class" do
      assert render_alert() =~ "text-sm"
    end

    test "renders muted-foreground class" do
      assert render_alert() =~ "muted-foreground"
    end
  end

  # ---------------------------------------------------------------------------
  # :icon slot
  # ---------------------------------------------------------------------------

  describe ":icon slot" do
    test "renders icon content when provided" do
      html = render_component(&H.render_with_icon/1, %{})
      assert html =~ ~s(data-testid="icon")
    end

    test "renders without icon when slot is empty" do
      html = render_component(&H.render_without_icon/1, %{})
      refute html =~ ~s(data-testid="icon")
    end
  end

  # ---------------------------------------------------------------------------
  # :class merge and @rest
  # ---------------------------------------------------------------------------

  describe ":class merge" do
    test "adds custom class to root element" do
      html = render_component(&H.render_with_class/1, %{})
      assert html =~ "custom-class"
    end

    test "preserves base border class alongside custom class" do
      html = render_component(&H.render_with_class/1, %{})
      assert html =~ "border"
    end
  end

  describe "@rest passthrough" do
    test "passes data-testid to root element" do
      html = render_component(&H.render_with_rest/1, %{})
      assert html =~ ~s(data-testid="my-alert")
    end
  end
end
