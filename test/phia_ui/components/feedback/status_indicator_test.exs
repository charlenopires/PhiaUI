defmodule PhiaUi.Components.StatusIndicatorTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.StatusIndicator

    def render_indicator(assigns) do
      ~H"""
      <.status_indicator status={:online} />
      """
    end

    def render_with_label(assigns) do
      ~H"""
      <.status_indicator status={:online} label="Online" />
      """
    end

    def render_offline(assigns) do
      ~H"""
      <.status_indicator status={:offline} />
      """
    end

    def render_away(assigns) do
      ~H"""
      <.status_indicator status={:away} />
      """
    end

    def render_busy(assigns) do
      ~H"""
      <.status_indicator status={:busy} />
      """
    end

    def render_with_pulse(assigns) do
      ~H"""
      <.status_indicator status={:online} show_pulse />
      """
    end

    def render_with_class(assigns) do
      ~H"""
      <.status_indicator status={:online} class="my-status" />
      """
    end

    def render_connection_online(assigns) do
      ~H"""
      <.connection_status status={:online} />
      """
    end

    def render_connection_offline(assigns) do
      ~H"""
      <.connection_status status={:offline} />
      """
    end

    def render_connection_reconnecting(assigns) do
      ~H"""
      <.connection_status status={:reconnecting} />
      """
    end

    def render_live(assigns) do
      ~H"""
      <.live_indicator />
      """
    end

    def render_live_custom(assigns) do
      ~H"""
      <.live_indicator label="ON AIR" />
      """
    end

    def render_service_row(assigns) do
      ~H"""
      <.service_status_row name="API" status={:operational} />
      """
    end

    def render_service_degraded(assigns) do
      ~H"""
      <.service_status_row name="DB" status={:degraded} description="Elevated latency" />
      """
    end

    def render_service_outage(assigns) do
      ~H"""
      <.service_status_row name="CDN" status={:outage} />
      """
    end
  end

  # ---------------------------------------------------------------------------
  # status_indicator/1
  # ---------------------------------------------------------------------------

  describe "status_indicator/1" do
    test "renders online dot color" do
      html = render_component(&H.render_indicator/1, %{})
      assert html =~ "bg-success"
    end

    test "renders offline dot color" do
      html = render_component(&H.render_offline/1, %{})
      assert html =~ "bg-muted-foreground"
    end

    test "renders away dot color" do
      html = render_component(&H.render_away/1, %{})
      assert html =~ "bg-warning"
    end

    test "renders busy dot color" do
      html = render_component(&H.render_busy/1, %{})
      assert html =~ "bg-destructive"
    end

    test "renders label text when provided" do
      html = render_component(&H.render_with_label/1, %{})
      assert html =~ "Online"
    end

    test "no visible label span when label not provided" do
      html = render_component(&H.render_indicator/1, %{})
      # aria-label contains "Online" but no visible <span> with that text
      refute html =~ ~s(class="text-sm text-muted-foreground")
    end

    test "renders pulse animation when show_pulse=true" do
      html = render_component(&H.render_with_pulse/1, %{})
      assert html =~ "animate-ping"
    end

    test "no pulse by default" do
      html = render_component(&H.render_indicator/1, %{})
      refute html =~ "animate-ping"
    end

    test "accepts :class override" do
      html = render_component(&H.render_with_class/1, %{})
      assert html =~ "my-status"
    end
  end

  # ---------------------------------------------------------------------------
  # connection_status/1
  # ---------------------------------------------------------------------------

  describe "connection_status/1" do
    test "online shows Connected" do
      html = render_component(&H.render_connection_online/1, %{})
      assert html =~ "Connected"
    end

    test "offline shows Disconnected" do
      html = render_component(&H.render_connection_offline/1, %{})
      assert html =~ "Disconnected"
    end

    test "reconnecting shows Reconnecting text" do
      html = render_component(&H.render_connection_reconnecting/1, %{})
      assert html =~ "Reconnecting"
    end

    test "reconnecting renders pulse animation" do
      html = render_component(&H.render_connection_reconnecting/1, %{})
      assert html =~ "animate-ping"
    end

    test "renders role=status" do
      html = render_component(&H.render_connection_online/1, %{})
      assert html =~ ~s(role="status")
    end

    test "renders aria-live=polite" do
      html = render_component(&H.render_connection_online/1, %{})
      assert html =~ ~s(aria-live="polite")
    end
  end

  # ---------------------------------------------------------------------------
  # live_indicator/1
  # ---------------------------------------------------------------------------

  describe "live_indicator/1" do
    test "renders LIVE label by default" do
      html = render_component(&H.render_live/1, %{})
      assert html =~ "LIVE"
    end

    test "renders custom label" do
      html = render_component(&H.render_live_custom/1, %{})
      assert html =~ "ON AIR"
    end

    test "renders bg-destructive" do
      html = render_component(&H.render_live/1, %{})
      assert html =~ "bg-destructive"
    end

    test "renders pulse animation" do
      html = render_component(&H.render_live/1, %{})
      assert html =~ "animate-ping"
    end

    test "renders role=status" do
      html = render_component(&H.render_live/1, %{})
      assert html =~ ~s(role="status")
    end
  end

  # ---------------------------------------------------------------------------
  # service_status_row/1
  # ---------------------------------------------------------------------------

  describe "service_status_row/1" do
    test "renders service name" do
      html = render_component(&H.render_service_row/1, %{})
      assert html =~ "API"
    end

    test "operational renders Operational label" do
      html = render_component(&H.render_service_row/1, %{})
      assert html =~ "Operational"
    end

    test "degraded renders Degraded label" do
      html = render_component(&H.render_service_degraded/1, %{})
      assert html =~ "Degraded"
    end

    test "outage renders Outage label" do
      html = render_component(&H.render_service_outage/1, %{})
      assert html =~ "Outage"
    end

    test "renders description when provided" do
      html = render_component(&H.render_service_degraded/1, %{})
      assert html =~ "Elevated latency"
    end

    test "operational renders success color" do
      html = render_component(&H.render_service_row/1, %{})
      assert html =~ "text-success"
    end

    test "outage renders destructive color" do
      html = render_component(&H.render_service_outage/1, %{})
      assert html =~ "text-destructive"
    end
  end
end
