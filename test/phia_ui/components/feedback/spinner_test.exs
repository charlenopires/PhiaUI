defmodule PhiaUi.Components.SpinnerTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest
  import PhiaUi.Components.Spinner

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.Spinner

    def render_spinner(assigns) do
      ~H"""
      <.spinner />
      """
    end

    def render_spinner_with_label(assigns) do
      ~H"""
      <.spinner label={@label} />
      """
    end

    def render_spinner_with_size(assigns) do
      ~H"""
      <.spinner size={@size} />
      """
    end

    def render_spinner_with_class(assigns) do
      ~H"""
      <.spinner class={@class} />
      """
    end
  end

  defp render_spinner(attrs \\ %{}) do
    render_component(&H.render_spinner/1, attrs)
  end

  defp render_spinner_with_label(attrs) do
    render_component(&H.render_spinner_with_label/1, attrs)
  end

  defp render_spinner_with_size(attrs) do
    render_component(&H.render_spinner_with_size/1, attrs)
  end

  defp render_spinner_with_class(attrs) do
    render_component(&H.render_spinner_with_class/1, attrs)
  end

  # ---------------------------------------------------------------------------
  # Accessibility structure
  # ---------------------------------------------------------------------------

  describe "accessibility" do
    test "renders role=status on outer div" do
      assert render_spinner() =~ ~s(role="status")
    end

    test "renders default aria-label of Loading" do
      assert render_spinner() =~ ~s(aria-label="Loading")
    end

    test "renders custom label in aria-label" do
      html = render_spinner_with_label(%{label: "Loading data..."})
      assert html =~ ~s(aria-label="Loading data...")
    end

    test "renders aria-live=polite" do
      assert render_spinner() =~ ~s(aria-live="polite")
    end

    test "renders sr-only span with default label text" do
      html = render_spinner()
      assert html =~ ~s(class="sr-only")
      assert html =~ "Loading"
    end
  end

  # ---------------------------------------------------------------------------
  # SVG structure
  # ---------------------------------------------------------------------------

  describe "SVG" do
    test "renders SVG with animate-spin class" do
      assert render_spinner() =~ "animate-spin"
    end

    test "SVG uses currentColor" do
      assert render_spinner() =~ "currentColor"
    end

    test "renders circle element" do
      assert render_spinner() =~ "<circle"
    end

    test "renders path element" do
      assert render_spinner() =~ "<path"
    end
  end

  # ---------------------------------------------------------------------------
  # Size variants
  # ---------------------------------------------------------------------------

  describe "size variants" do
    test "size :xs renders h-3 w-3" do
      html = render_spinner_with_size(%{size: :xs})
      assert html =~ "h-3"
      assert html =~ "w-3"
    end

    test "size :sm renders h-4 w-4" do
      html = render_spinner_with_size(%{size: :sm})
      assert html =~ "h-4"
      assert html =~ "w-4"
    end

    test "size :default renders h-6 w-6" do
      html = render_spinner()
      assert html =~ "h-6"
      assert html =~ "w-6"
    end

    test "size :lg renders h-8 w-8" do
      html = render_spinner_with_size(%{size: :lg})
      assert html =~ "h-8"
      assert html =~ "w-8"
    end

    test "size :xl renders h-12 w-12" do
      html = render_spinner_with_size(%{size: :xl})
      assert html =~ "h-12"
      assert html =~ "w-12"
    end
  end

  # ---------------------------------------------------------------------------
  # Class override
  # ---------------------------------------------------------------------------

  describe "class override" do
    test "applies custom class to SVG element" do
      html = render_spinner_with_class(%{class: "text-primary"})
      assert html =~ "text-primary"
    end
  end
end
