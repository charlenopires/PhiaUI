defmodule PhiaUi.Components.Typography.LeaderTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.Typography.Leader

    def render_leader(assigns) do
      ~H"""
      <.leader fill={assigns[:fill] || :dot} class={assigns[:class]}>
        <:leading>{assigns[:start_text] || "Chapter 1"}</:leading>
        <:trailing>{assigns[:end_text] || "42"}</:trailing>
      </.leader>
      """
    end
  end

  defp render_leader(attrs \\ %{}), do: render_component(&H.render_leader/1, attrs)

  describe "leader/1" do
    test "renders leading and trailing content" do
      html = render_leader(%{start_text: "Introduction", end_text: "1"})
      assert html =~ "Introduction"
      assert html =~ ">1<"
    end

    test "renders flex container" do
      assert render_leader() =~ "flex"
      assert render_leader() =~ "items-baseline"
    end

    test "default fill is dotted border" do
      assert render_leader() =~ "border-dotted"
    end

    test "dash fill renders dashed border" do
      assert render_leader(%{fill: :dash}) =~ "border-dashed"
    end

    test "line fill renders solid border" do
      assert render_leader(%{fill: :line}) =~ "border-solid"
    end

    test "space fill renders transparent border" do
      assert render_leader(%{fill: :space}) =~ "border-transparent"
    end

    test "leader line has aria-hidden" do
      assert render_leader() =~ "aria-hidden"
    end

    test "custom class is applied" do
      assert render_leader(%{class: "my-leader"}) =~ "my-leader"
    end
  end
end
