defmodule PhiaUi.Components.BannerTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.Banner

    def render_banner(assigns) do
      ~H"""
      <.banner id="test-banner">Important message</.banner>
      """
    end

    def render_banner_warning(assigns) do
      ~H"""
      <.banner id="warn-banner" variant={:warning}>Warning</.banner>
      """
    end

    def render_banner_destructive(assigns) do
      ~H"""
      <.banner id="err-banner" variant={:destructive}>Error</.banner>
      """
    end

    def render_banner_success(assigns) do
      ~H"""
      <.banner id="ok-banner" variant={:success}>Success</.banner>
      """
    end

    def render_banner_info(assigns) do
      ~H"""
      <.banner id="info-banner" variant={:info}>Info</.banner>
      """
    end

    def render_banner_no_close(assigns) do
      ~H"""
      <.banner id="nc-banner" closeable={false}>No close</.banner>
      """
    end

    def render_banner_with_class(assigns) do
      ~H"""
      <.banner id="cls-banner" class="custom-banner">Text</.banner>
      """
    end

    def render_banner_with_rest(assigns) do
      ~H"""
      <.banner id="rest-banner" data-testid="my-banner">Text</.banner>
      """
    end

    def render_announcement(assigns) do
      ~H"""
      <.announcement_bar id="ann-bar">New release!</.announcement_bar>
      """
    end

    def render_cookie(assigns) do
      ~H"""
      <.cookie_consent id="cookie-bar" title="Cookie preferences">
        We use cookies.
        <:action>Accept</:action>
      </.cookie_consent>
      """
    end
  end

  # ---------------------------------------------------------------------------
  # banner/1
  # ---------------------------------------------------------------------------

  describe "banner/1 base" do
    test "renders role=alert" do
      html = render_component(&H.render_banner/1, %{})
      assert html =~ ~s(role="alert")
    end

    test "renders message content" do
      html = render_component(&H.render_banner/1, %{})
      assert html =~ "Important message"
    end

    test "renders dismiss button when id provided" do
      html = render_component(&H.render_banner/1, %{})
      assert html =~ "Dismiss"
    end

    test "no dismiss button when closeable=false" do
      html = render_component(&H.render_banner_no_close/1, %{})
      refute html =~ "Dismiss"
    end

    test "accepts custom class" do
      html = render_component(&H.render_banner_with_class/1, %{})
      assert html =~ "custom-banner"
    end

    test "passes :rest attrs" do
      html = render_component(&H.render_banner_with_rest/1, %{})
      assert html =~ ~s(data-testid="my-banner")
    end
  end

  describe "banner/1 variants" do
    test ":default renders bg-muted" do
      html = render_component(&H.render_banner/1, %{})
      assert html =~ "bg-muted"
    end

    test ":warning renders bg-warning" do
      html = render_component(&H.render_banner_warning/1, %{})
      assert html =~ "bg-warning"
    end

    test ":destructive renders bg-destructive" do
      html = render_component(&H.render_banner_destructive/1, %{})
      assert html =~ "bg-destructive"
    end

    test ":success renders bg-success" do
      html = render_component(&H.render_banner_success/1, %{})
      assert html =~ "bg-success"
    end

    test ":info renders bg-blue" do
      html = render_component(&H.render_banner_info/1, %{})
      assert html =~ "bg-blue"
    end
  end

  # ---------------------------------------------------------------------------
  # announcement_bar/1
  # ---------------------------------------------------------------------------

  describe "announcement_bar/1" do
    test "renders content" do
      html = render_component(&H.render_announcement/1, %{})
      assert html =~ "New release!"
    end

    test "renders bg-primary" do
      html = render_component(&H.render_announcement/1, %{})
      assert html =~ "bg-primary"
    end

    test "renders dismiss button when id provided" do
      html = render_component(&H.render_announcement/1, %{})
      assert html =~ "Dismiss announcement"
    end
  end

  # ---------------------------------------------------------------------------
  # cookie_consent/1
  # ---------------------------------------------------------------------------

  describe "cookie_consent/1" do
    test "renders title" do
      html = render_component(&H.render_cookie/1, %{})
      assert html =~ "Cookie preferences"
    end

    test "renders description" do
      html = render_component(&H.render_cookie/1, %{})
      assert html =~ "We use cookies."
    end

    test "renders action slot" do
      html = render_component(&H.render_cookie/1, %{})
      assert html =~ "Accept"
    end

    test "renders dialog role" do
      html = render_component(&H.render_cookie/1, %{})
      assert html =~ ~s(role="dialog")
    end

    test "is fixed bottom" do
      html = render_component(&H.render_cookie/1, %{})
      assert html =~ "fixed bottom-0"
    end
  end
end
