defmodule PhiaUi.Components.ErrorDisplayTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.ErrorDisplay

    def render_error_display(assigns) do
      ~H"""
      <.error_display message="Payment failed" />
      """
    end

    def render_with_code(assigns) do
      ~H"""
      <.error_display message="Rate limited" code="RATE_LIMIT_EXCEEDED" />
      """
    end

    def render_with_detail(assigns) do
      ~H"""
      <.error_display message="Invalid input" detail="Field 'email' must be a valid email address." />
      """
    end

    def render_with_trace(assigns) do
      ~H"""
      <.error_display message="Server error" trace="RuntimeError at line 42" />
      """
    end

    def render_warning_variant(assigns) do
      ~H"""
      <.error_display message="Session expiring" variant={:warning} />
      """
    end

    def render_default_variant(assigns) do
      ~H"""
      <.error_display message="Info message" variant={:default} />
      """
    end

    def render_boundary(assigns) do
      ~H"""
      <.error_boundary title="Load failed">
        Could not load dashboard data.
        <:actions>
          <button phx-click="retry">Retry</button>
        </:actions>
      </.error_boundary>
      """
    end

    def render_boundary_with_detail(assigns) do
      ~H"""
      <.error_boundary>
        Something went wrong.
        <:detail>The server returned error 503.</:detail>
      </.error_boundary>
      """
    end

    def render_http_404(assigns) do
      ~H"""
      <.http_error status={404} />
      """
    end

    def render_http_500(assigns) do
      ~H"""
      <.http_error status={500} />
      """
    end

    def render_http_403(assigns) do
      ~H"""
      <.http_error status={403} />
      """
    end

    def render_http_custom(assigns) do
      ~H"""
      <.http_error status={503} title="Under maintenance" message="Back soon." />
      """
    end
  end

  # ---------------------------------------------------------------------------
  # error_display/1
  # ---------------------------------------------------------------------------

  describe "error_display/1" do
    test "renders role=alert" do
      html = render_component(&H.render_error_display/1, %{})
      assert html =~ ~s(role="alert")
    end

    test "renders message" do
      html = render_component(&H.render_error_display/1, %{})
      assert html =~ "Payment failed"
    end

    test "renders code when provided" do
      html = render_component(&H.render_with_code/1, %{})
      assert html =~ "RATE_LIMIT_EXCEEDED"
    end

    test "renders detail when provided" do
      html = render_component(&H.render_with_detail/1, %{})
      assert html =~ "Field &#39;email&#39;"
    end

    test "renders stack trace details when trace provided" do
      html = render_component(&H.render_with_trace/1, %{})
      assert html =~ "Show stack trace"
      assert html =~ "RuntimeError at line 42"
    end

    test "no stack trace when trace not provided" do
      html = render_component(&H.render_error_display/1, %{})
      refute html =~ "Show stack trace"
    end

    test "destructive variant renders destructive border" do
      html = render_component(&H.render_error_display/1, %{})
      assert html =~ "border-destructive"
    end

    test "warning variant renders warning border" do
      html = render_component(&H.render_warning_variant/1, %{})
      assert html =~ "border-warning"
    end

    test "default variant renders border-border" do
      html = render_component(&H.render_default_variant/1, %{})
      assert html =~ "border-border"
    end
  end

  # ---------------------------------------------------------------------------
  # error_boundary/1
  # ---------------------------------------------------------------------------

  describe "error_boundary/1" do
    test "renders role=alert" do
      html = render_component(&H.render_boundary/1, %{})
      assert html =~ ~s(role="alert")
    end

    test "renders custom title" do
      html = render_component(&H.render_boundary/1, %{})
      assert html =~ "Load failed"
    end

    test "renders inner block message" do
      html = render_component(&H.render_boundary/1, %{})
      assert html =~ "Could not load dashboard data."
    end

    test "renders action slot" do
      html = render_component(&H.render_boundary/1, %{})
      assert html =~ "Retry"
    end

    test "renders detail slot when provided" do
      html = render_component(&H.render_boundary_with_detail/1, %{})
      assert html =~ "The server returned error 503."
    end

    test "renders destructive icon bg" do
      html = render_component(&H.render_boundary/1, %{})
      assert html =~ "bg-destructive"
    end
  end

  # ---------------------------------------------------------------------------
  # http_error/1
  # ---------------------------------------------------------------------------

  describe "http_error/1 — 404" do
    test "renders status code 404" do
      html = render_component(&H.render_http_404/1, %{})
      assert html =~ "404"
    end

    test "renders default 404 title" do
      html = render_component(&H.render_http_404/1, %{})
      assert html =~ "Page Not Found"
    end

    test "renders default 404 message" do
      html = render_component(&H.render_http_404/1, %{})
      assert html =~ "doesn&#39;t exist"
    end

    test "renders go home link by default" do
      html = render_component(&H.render_http_404/1, %{})
      assert html =~ "Go home"
    end
  end

  describe "http_error/1 — 500" do
    test "renders status code 500" do
      html = render_component(&H.render_http_500/1, %{})
      assert html =~ "500"
    end

    test "renders default 500 title" do
      html = render_component(&H.render_http_500/1, %{})
      assert html =~ "Internal Server Error"
    end
  end

  describe "http_error/1 — 403" do
    test "renders status code 403" do
      html = render_component(&H.render_http_403/1, %{})
      assert html =~ "403"
    end

    test "renders Access Denied title" do
      html = render_component(&H.render_http_403/1, %{})
      assert html =~ "Access Denied"
    end
  end

  describe "http_error/1 — custom overrides" do
    test "renders custom title" do
      html = render_component(&H.render_http_custom/1, %{})
      assert html =~ "Under maintenance"
    end

    test "renders custom message" do
      html = render_component(&H.render_http_custom/1, %{})
      assert html =~ "Back soon."
    end
  end
end
