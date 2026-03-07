defmodule PhiaUi.Components.ProfileCardTest do
  use ExUnit.Case, async: true
  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.ProfileCard

    attr :name, :string, default: "Alice"
    attr :role, :string, default: nil
    attr :src, :string, default: nil
    attr :fallback, :string, default: "A"
    attr :status, :atom, default: nil
    attr :variant, :atom, default: :vertical
    attr :class, :string, default: nil

    def render_profile_card(assigns) do
      ~H"""
      <.profile_card
        name={@name}
        role={@role}
        src={@src}
        fallback={@fallback}
        status={@status}
        variant={@variant}
        class={@class}
      />
      """
    end

    attr :name, :string, default: "Alice"

    def render_with_slots(assigns) do
      ~H"""
      <.profile_card name={@name} fallback="A">
        <:bio>Bio text here</:bio>
        <:tags><span>Elixir</span></:tags>
        <:actions><button>Follow</button></:actions>
      </.profile_card>
      """
    end

    attr :name, :string, default: "Alice"
    attr :src, :string, default: "/avatar.jpg"

    def render_with_src(assigns) do
      ~H"""
      <.profile_card name={@name} src={@src} />
      """
    end
  end

  defp render_profile_card(attrs \\ %{}) do
    render_component(&H.render_profile_card/1, attrs)
  end

  describe "profile_card/1 default render" do
    test "renders a card wrapper" do
      html = render_profile_card()
      assert html =~ "<div"
    end

    test "renders the name" do
      html = render_profile_card(%{name: "Jane Smith"})
      assert html =~ "Jane Smith"
    end

    test "renders with default vertical layout" do
      html = render_profile_card()
      assert html =~ "flex-col"
    end

    test "renders avatar fallback initial" do
      html = render_profile_card(%{fallback: "A"})
      assert html =~ "A"
    end
  end

  describe "profile_card/1 role" do
    test "renders role when provided" do
      html = render_profile_card(%{role: "Senior Engineer"})
      assert html =~ "Senior Engineer"
    end

    test "does not render role element when nil" do
      html = render_profile_card(%{role: nil})
      refute html =~ "Senior Engineer"
    end
  end

  describe "profile_card/1 status dot" do
    test "renders online status as bg-emerald-500" do
      html = render_profile_card(%{status: :online})
      assert html =~ "bg-emerald-500"
    end

    test "renders offline status as bg-gray-400" do
      html = render_profile_card(%{status: :offline})
      assert html =~ "bg-gray-400"
    end

    test "renders busy status as bg-red-500" do
      html = render_profile_card(%{status: :busy})
      assert html =~ "bg-red-500"
    end

    test "renders away status as bg-amber-500" do
      html = render_profile_card(%{status: :away})
      assert html =~ "bg-amber-500"
    end

    test "no status dot when status is nil" do
      html = render_profile_card(%{status: nil})
      refute html =~ "bg-emerald-500"
      refute html =~ "bg-gray-400"
      refute html =~ "bg-red-500"
      refute html =~ "bg-amber-500"
    end
  end

  describe "profile_card/1 variants" do
    test ":vertical variant applies flex-col" do
      html = render_profile_card(%{variant: :vertical})
      assert html =~ "flex-col"
    end

    test ":horizontal variant applies flex-row" do
      html = render_profile_card(%{variant: :horizontal})
      assert html =~ "flex-row"
    end
  end

  describe "profile_card/1 class forwarding" do
    test "accepts custom class" do
      html = render_profile_card(%{class: "my-custom-class"})
      assert html =~ "my-custom-class"
    end
  end

  describe "profile_card/1 avatar src" do
    test "renders img tag when src provided" do
      html = render_component(&H.render_with_src/1, %{})
      assert html =~ "<img"
      assert html =~ ~s(src="/avatar.jpg")
    end

    test "does not render img when src is nil" do
      html = render_profile_card(%{src: nil})
      refute html =~ "<img"
    end
  end

  describe "profile_card/1 slots" do
    test "renders bio slot" do
      html = render_component(&H.render_with_slots/1, %{})
      assert html =~ "Bio text here"
    end

    test "renders tags slot" do
      html = render_component(&H.render_with_slots/1, %{})
      assert html =~ "Elixir"
    end

    test "renders actions slot" do
      html = render_component(&H.render_with_slots/1, %{})
      assert html =~ "Follow"
    end
  end
end
