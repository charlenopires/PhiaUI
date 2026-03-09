defmodule PhiaUi.Components.TagTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.Tag

    attr :label, :string, default: "Elixir"
    attr :variant, :atom, default: :default
    attr :size, :atom, default: :default
    attr :dismissible, :boolean, default: false
    attr :on_dismiss, :string, default: nil
    attr :value, :string, default: nil
    attr :dot, :boolean, default: false
    attr :class, :string, default: nil

    def render_tag(assigns) do
      ~H"""
      <.tag
        label={@label}
        variant={@variant}
        size={@size}
        dismissible={@dismissible}
        on_dismiss={@on_dismiss}
        value={@value}
        dot={@dot}
        class={@class}
      />
      """
    end

    attr :label, :string, default: "Elixir"

    def render_tag_with_icon(assigns) do
      ~H"""
      <.tag label={@label}>
        <:icon>
          <svg data-testid="custom-icon" viewBox="0 0 24 24"><circle cx="12" cy="12" r="10" /></svg>
        </:icon>
      </.tag>
      """
    end

    attr :label, :string, default: "Elixir"

    def render_tag_with_rest(assigns) do
      ~H"""
      <.tag label={@label} data-testid="my-tag" />
      """
    end
  end

  defp render_tag(attrs \\ %{}) do
    render_component(&H.render_tag/1, attrs)
  end

  # ---------------------------------------------------------------------------
  # Base classes (present in every variant)
  # ---------------------------------------------------------------------------

  describe "base classes" do
    test "renders rounded-md shape" do
      assert render_tag() =~ "rounded-md"
    end

    test "renders inline-flex" do
      assert render_tag() =~ "inline-flex"
    end

    test "renders items-center" do
      assert render_tag() =~ "items-center"
    end

    test "renders truncate on label span" do
      assert render_tag() =~ "truncate"
    end

    test "renders border" do
      assert render_tag() =~ "border"
    end

    test "renders font-medium" do
      assert render_tag() =~ "font-medium"
    end

    test "renders transition-colors" do
      assert render_tag() =~ "transition-colors"
    end

    test "renders label text" do
      assert render_tag(%{label: "Phoenix"}) =~ "Phoenix"
    end
  end

  # ---------------------------------------------------------------------------
  # Variants
  # ---------------------------------------------------------------------------

  describe "variant :default" do
    test "renders bg-muted" do
      assert render_tag(%{variant: :default}) =~ "bg-muted"
    end

    test "renders text-muted-foreground" do
      assert render_tag(%{variant: :default}) =~ "text-muted-foreground"
    end

    test "renders border-border" do
      assert render_tag(%{variant: :default}) =~ "border-border"
    end
  end

  describe "variant :primary" do
    test "renders bg-primary/10" do
      assert render_tag(%{variant: :primary}) =~ "bg-primary/10"
    end

    test "renders text-primary" do
      assert render_tag(%{variant: :primary}) =~ "text-primary"
    end
  end

  describe "variant :error" do
    test "renders bg-red-50" do
      assert render_tag(%{variant: :error}) =~ "bg-red-50"
    end

    test "renders text-red-700" do
      assert render_tag(%{variant: :error}) =~ "text-red-700"
    end

    test "renders border-red-200" do
      assert render_tag(%{variant: :error}) =~ "border-red-200"
    end
  end

  describe "variant :success" do
    test "renders bg-green-50" do
      assert render_tag(%{variant: :success}) =~ "bg-green-50"
    end

    test "renders text-green-700" do
      assert render_tag(%{variant: :success}) =~ "text-green-700"
    end
  end

  describe "variant :warning" do
    test "renders bg-yellow-50" do
      assert render_tag(%{variant: :warning}) =~ "bg-yellow-50"
    end

    test "renders text-yellow-700" do
      assert render_tag(%{variant: :warning}) =~ "text-yellow-700"
    end
  end

  describe "variant :outline" do
    test "renders border-border" do
      assert render_tag(%{variant: :outline}) =~ "border-border"
    end

    test "renders bg-transparent" do
      assert render_tag(%{variant: :outline}) =~ "bg-transparent"
    end

    test "renders text-foreground" do
      assert render_tag(%{variant: :outline}) =~ "text-foreground"
    end
  end

  # ---------------------------------------------------------------------------
  # Sizes
  # ---------------------------------------------------------------------------

  describe "size :sm" do
    test "renders h-6" do
      assert render_tag(%{size: :sm}) =~ "h-6"
    end

    test "renders px-2" do
      assert render_tag(%{size: :sm}) =~ "px-2"
    end
  end

  describe "size :default" do
    test "renders h-7" do
      assert render_tag(%{size: :default}) =~ "h-7"
    end
  end

  describe "size :lg" do
    test "renders h-8" do
      assert render_tag(%{size: :lg}) =~ "h-8"
    end

    test "renders text-sm" do
      assert render_tag(%{size: :lg}) =~ "text-sm"
    end
  end

  # ---------------------------------------------------------------------------
  # Dot indicator
  # ---------------------------------------------------------------------------

  describe "dot indicator" do
    test "renders rounded-full dot when dot=true" do
      html = render_tag(%{dot: true})
      assert html =~ "rounded-full"
    end

    test "does not render dot when dot=false" do
      html = render_tag(%{dot: false})
      # The only rounded-full in the component is the dot span
      refute html =~ "rounded-full"
    end

    test "renders dot color matching variant" do
      html = render_tag(%{dot: true, variant: :success})
      assert html =~ "bg-green-500"
    end

    test "renders dot color for error variant" do
      html = render_tag(%{dot: true, variant: :error})
      assert html =~ "bg-red-500"
    end
  end

  # ---------------------------------------------------------------------------
  # Dismissible / close button
  # ---------------------------------------------------------------------------

  describe "dismissible" do
    test "renders close button when dismissible=true" do
      html = render_tag(%{dismissible: true, label: "Draft"})
      assert html =~ "<button"
      assert html =~ ~s(type="button")
    end

    test "renders aria-label with tag label" do
      html = render_tag(%{dismissible: true, label: "Draft"})
      assert html =~ ~s(aria-label="Remove Draft")
    end

    test "does not render close button when dismissible=false" do
      html = render_tag(%{dismissible: false})
      refute html =~ "<button"
    end

    test "renders phx-click with on_dismiss event" do
      html = render_tag(%{dismissible: true, on_dismiss: "remove_tag"})
      assert html =~ ~s(phx-click="remove_tag")
    end

    test "renders phx-value-value with value attr" do
      html = render_tag(%{dismissible: true, on_dismiss: "remove_tag", value: "elixir"})
      assert html =~ ~s(phx-value-value="elixir")
    end

    test "renders X icon svg" do
      html = render_tag(%{dismissible: true})
      assert html =~ "<svg"
      assert html =~ ~s(aria-hidden="true")
    end
  end

  # ---------------------------------------------------------------------------
  # Icon slot
  # ---------------------------------------------------------------------------

  describe "icon slot" do
    test "renders icon content" do
      html = render_component(&H.render_tag_with_icon/1, %{})
      assert html =~ ~s(data-testid="custom-icon")
    end

    test "wraps icon in shrink-0 span" do
      html = render_component(&H.render_tag_with_icon/1, %{})
      assert html =~ "shrink-0"
    end
  end

  # ---------------------------------------------------------------------------
  # Custom class and @rest
  # ---------------------------------------------------------------------------

  describe "class override" do
    test "adds custom class" do
      html = render_tag(%{class: "uppercase tracking-wide"})
      assert html =~ "uppercase"
    end
  end

  describe "@rest passthrough" do
    test "passes data-testid to the element" do
      html = render_component(&H.render_tag_with_rest/1, %{})
      assert html =~ ~s(data-testid="my-tag")
    end
  end
end
