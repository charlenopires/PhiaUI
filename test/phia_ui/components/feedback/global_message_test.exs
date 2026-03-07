defmodule PhiaUi.Components.GlobalMessageTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.GlobalMessage

    def render_global_message(assigns) do
      ~H"""
      <.global_message id="phia-global-message" />
      """
    end

    def render_with_max(assigns) do
      ~H"""
      <.global_message id="msg" max_messages={3} />
      """
    end

    def render_with_class(assigns) do
      ~H"""
      <.global_message id="msg-cls" class="my-message-container" />
      """
    end
  end

  describe "global_message/1" do
    test "renders the container with phx-hook" do
      html = render_component(&H.render_global_message/1, %{})
      assert html =~ ~s(phx-hook="PhiaGlobalMessage")
    end

    test "renders the id" do
      html = render_component(&H.render_global_message/1, %{})
      assert html =~ ~s(id="phia-global-message")
    end

    test "renders role=status" do
      html = render_component(&H.render_global_message/1, %{})
      assert html =~ ~s(role="status")
    end

    test "renders aria-live=polite" do
      html = render_component(&H.render_global_message/1, %{})
      assert html =~ ~s(aria-live="polite")
    end

    test "renders aria-atomic=false" do
      html = render_component(&H.render_global_message/1, %{})
      assert html =~ ~s(aria-atomic="false")
    end

    test "renders fixed top-center positioning" do
      html = render_component(&H.render_global_message/1, %{})
      assert html =~ "fixed top-4"
      assert html =~ "left-1/2"
    end

    test "renders data-max-messages attribute" do
      html = render_component(&H.render_with_max/1, %{})
      assert html =~ ~s(data-max-messages="3")
    end

    test "accepts :class override" do
      html = render_component(&H.render_with_class/1, %{})
      assert html =~ "my-message-container"
    end
  end
end
