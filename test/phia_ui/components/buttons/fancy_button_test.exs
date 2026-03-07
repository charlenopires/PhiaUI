defmodule PhiaUi.Components.FancyButtonTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.FancyButton

    def render_gradient_default(assigns) do
      ~H"""
      <.gradient_button gradient={:sunset}>Click me</.gradient_button>
      """
    end

    def render_gradient(assigns) do
      ~H"""
      <.gradient_button gradient={@gradient}>Click me</.gradient_button>
      """
    end

    def render_gradient_with_icons(assigns) do
      ~H"""
      <.gradient_button gradient={:ocean}>
        <:left_icon><span>←</span></:left_icon>
        Go
        <:right_icon><span>→</span></:right_icon>
      </.gradient_button>
      """
    end

    def render_gradient_loading(assigns) do
      ~H"""
      <.gradient_button gradient={:aurora} loading={true}>Saving</.gradient_button>
      """
    end

    def render_gradient_disabled(assigns) do
      ~H"""
      <.gradient_button gradient={:sunset} disabled={true}>Disabled</.gradient_button>
      """
    end

    def render_shimmer_dark(assigns) do
      ~H"""
      <.shimmer_button variant={:dark}>Get started</.shimmer_button>
      """
    end

    def render_shimmer_light(assigns) do
      ~H"""
      <.shimmer_button variant={:light}>Get started</.shimmer_button>
      """
    end

    def render_shimmer_primary(assigns) do
      ~H"""
      <.shimmer_button variant={:primary}>Get started</.shimmer_button>
      """
    end

    def render_glow_default(assigns) do
      ~H"""
      <.glow_button color={:blue}>Glow</.glow_button>
      """
    end

    def render_glow(assigns) do
      ~H"""
      <.glow_button color={@color} glow_intensity={@intensity}>Glow</.glow_button>
      """
    end

    def render_pulse_default(assigns) do
      ~H"""
      <.pulse_button color={:primary}>Pulse</.pulse_button>
      """
    end

    def render_pulse(assigns) do
      ~H"""
      <.pulse_button color={@color} pulse={@pulse}>Action</.pulse_button>
      """
    end

    def render_pulse_no_pulse(assigns) do
      ~H"""
      <.pulse_button color={:primary} pulse={false}>No pulse</.pulse_button>
      """
    end
  end

  defp render_gradient_default, do: render_component(&H.render_gradient_default/1, %{})
  defp render_gradient(g), do: render_component(&H.render_gradient/1, %{gradient: g})
  defp render_gradient_with_icons, do: render_component(&H.render_gradient_with_icons/1, %{})
  defp render_gradient_loading, do: render_component(&H.render_gradient_loading/1, %{})
  defp render_gradient_disabled, do: render_component(&H.render_gradient_disabled/1, %{})
  defp render_shimmer(v), do: render_component(
    case v do
      :dark -> &H.render_shimmer_dark/1
      :light -> &H.render_shimmer_light/1
      :primary -> &H.render_shimmer_primary/1
    end, %{})
  defp render_glow_default, do: render_component(&H.render_glow_default/1, %{})
  defp render_glow(color, intensity), do: render_component(&H.render_glow/1, %{color: color, intensity: intensity})
  defp render_pulse_default, do: render_component(&H.render_pulse_default/1, %{})
  defp render_pulse(color, pulse), do: render_component(&H.render_pulse/1, %{color: color, pulse: pulse})
  defp render_pulse_no_pulse, do: render_component(&H.render_pulse_no_pulse/1, %{})

  # ---------------------------------------------------------------------------
  # gradient_button/1
  # ---------------------------------------------------------------------------

  describe "gradient_button/1" do
    test "renders button element" do
      assert render_gradient_default() =~ "<button"
    end

    test "renders inner content" do
      assert render_gradient_default() =~ "Click me"
    end

    test "always has text-white" do
      assert render_gradient_default() =~ "text-white"
    end

    test "sunset gradient applies from-orange-500" do
      assert render_gradient(:sunset) =~ "from-orange-500"
    end

    test "ocean gradient applies from-blue-500" do
      assert render_gradient(:ocean) =~ "from-blue-500"
    end

    test "forest gradient applies from-green-600" do
      assert render_gradient(:forest) =~ "from-green-600"
    end

    test "aurora gradient applies from-violet-500" do
      assert render_gradient(:aurora) =~ "from-violet-500"
    end

    test "monochrome gradient applies from-gray-900" do
      assert render_gradient(:monochrome) =~ "from-gray-900"
    end

    test "primary gradient uses from-primary" do
      assert render_gradient(:primary) =~ "from-primary"
    end

    test "with icons adds gap-2" do
      assert render_gradient_with_icons() =~ "gap-2"
    end

    test "loading shows spinner" do
      assert render_gradient_loading() =~ "animate-spin"
    end

    test "disabled adds opacity-50" do
      assert render_gradient_disabled() =~ "opacity-50"
    end

    test "function is exported" do
      assert function_exported?(PhiaUi.Components.FancyButton, :gradient_button, 1)
    end
  end

  # ---------------------------------------------------------------------------
  # shimmer_button/1
  # ---------------------------------------------------------------------------

  describe "shimmer_button/1" do
    test "renders button element" do
      assert render_shimmer(:dark) =~ "<button"
    end

    test "renders inner content" do
      assert render_shimmer(:dark) =~ "Get started"
    end

    test "has overflow-hidden for shimmer clip" do
      assert render_shimmer(:dark) =~ "overflow-hidden"
    end

    test "has relative for shimmer positioning" do
      assert render_shimmer(:dark) =~ "relative"
    end

    test "shimmer span has inline style with animation" do
      assert render_shimmer(:dark) =~ "phia-shimmer-pass"
    end

    test "dark variant applies zinc-900 bg" do
      assert render_shimmer(:dark) =~ "bg-zinc-900"
    end

    test "light variant applies white bg" do
      assert render_shimmer(:light) =~ "bg-white"
    end

    test "primary variant applies primary bg" do
      assert render_shimmer(:primary) =~ "bg-primary"
    end

    test "shimmer span is pointer-events-none" do
      assert render_shimmer(:dark) =~ "pointer-events-none"
    end

    test "function is exported" do
      assert function_exported?(PhiaUi.Components.FancyButton, :shimmer_button, 1)
    end
  end

  # ---------------------------------------------------------------------------
  # glow_button/1
  # ---------------------------------------------------------------------------

  describe "glow_button/1" do
    test "renders button element" do
      assert render_glow_default() =~ "<button"
    end

    test "has bg-background" do
      assert render_glow_default() =~ "bg-background"
    end

    test "has inline box-shadow style" do
      assert render_glow_default() =~ "box-shadow"
    end

    test "blue glow includes hex color" do
      assert render_glow(:blue, :normal) =~ "#3b82f6"
    end

    test "purple glow includes hex color" do
      assert render_glow(:purple, :normal) =~ "#8b5cf6"
    end

    test "primary glow uses CSS variable" do
      assert render_glow(:primary, :normal) =~ "--color-primary"
    end

    test "intense glow has three shadow layers" do
      html = render_glow(:blue, :intense)
      # Intense has 3 shadow values separated by commas
      assert html =~ "0 0 20px"
      assert html =~ "0 0 40px"
      assert html =~ "0 0 60px"
    end

    test "border matches glow color" do
      assert render_glow(:blue, :normal) =~ "border-blue-500"
    end

    test "function is exported" do
      assert function_exported?(PhiaUi.Components.FancyButton, :glow_button, 1)
    end
  end

  # ---------------------------------------------------------------------------
  # pulse_button/1
  # ---------------------------------------------------------------------------

  describe "pulse_button/1" do
    test "renders wrapper div" do
      assert render_pulse_default() =~ "<div"
    end

    test "renders button element" do
      assert render_pulse_default() =~ "<button"
    end

    test "renders animate-ping span when pulse=true" do
      assert render_pulse_default() =~ "animate-ping"
    end

    test "no animate-ping when pulse=false" do
      refute render_pulse_no_pulse() =~ "animate-ping"
    end

    test "ping span has opacity-75" do
      assert render_pulse_default() =~ "opacity-75"
    end

    test "primary color applies bg-primary to button" do
      assert render_pulse_default() =~ "bg-primary"
    end

    test "destructive color applies bg-destructive" do
      assert render_pulse(:destructive, true) =~ "bg-destructive"
    end

    test "success color applies bg-green-500" do
      assert render_pulse(:success, true) =~ "bg-green-500"
    end

    test "warning color applies bg-yellow-500" do
      assert render_pulse(:warning, true) =~ "bg-yellow-500"
    end

    test "renders inner content" do
      assert render_pulse_default() =~ "Pulse"
    end

    test "ping span has absolute positioning" do
      assert render_pulse_default() =~ "absolute"
    end

    test "function is exported" do
      assert function_exported?(PhiaUi.Components.FancyButton, :pulse_button, 1)
    end
  end
end
