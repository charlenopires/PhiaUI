defmodule PhiaUi.Components.TeamCardTest do
  use ExUnit.Case, async: true
  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.TeamCard

    attr :name, :string, default: "Alice Smith"
    attr :role, :string, default: nil
    attr :department, :string, default: nil
    attr :src, :string, default: nil
    attr :fallback, :string, default: "AS"
    attr :email, :string, default: nil
    attr :variant, :atom, default: :default
    attr :class, :string, default: nil

    def render_team_card(assigns) do
      ~H"""
      <.team_card
        name={@name}
        role={@role}
        department={@department}
        src={@src}
        fallback={@fallback}
        email={@email}
        variant={@variant}
        class={@class}
      />
      """
    end

    attr :name, :string, default: "Bob"

    def render_with_slots(assigns) do
      ~H"""
      <.team_card name={@name} fallback="B">
        <:badges><span>Lead</span></:badges>
        <:actions><button>Message</button></:actions>
      </.team_card>
      """
    end

    attr :name, :string, default: "Carol"
    attr :src, :string, default: "/avatar.jpg"

    def render_with_src(assigns) do
      ~H"""
      <.team_card name={@name} src={@src} />
      """
    end
  end

  defp render_team_card(attrs \\ %{}) do
    render_component(&H.render_team_card/1, attrs)
  end

  describe "team_card/1 default render" do
    test "renders a card wrapper" do
      html = render_team_card()
      assert html =~ "<div"
    end

    test "renders the name" do
      html = render_team_card(%{name: "David Lee"})
      assert html =~ "David Lee"
    end

    test "default variant uses centered flex-col layout" do
      html = render_team_card(%{variant: :default})
      assert html =~ "flex-col"
      assert html =~ "items-center"
    end
  end

  describe "team_card/1 optional fields" do
    test "renders role when provided" do
      html = render_team_card(%{role: "Staff Engineer"})
      assert html =~ "Staff Engineer"
    end

    test "does not render role when nil" do
      html = render_team_card(%{role: nil})
      refute html =~ "Staff Engineer"
    end

    test "renders department when provided" do
      html = render_team_card(%{department: "Platform"})
      assert html =~ "Platform"
    end

    test "does not render department when nil" do
      html = render_team_card(%{department: nil})
      refute html =~ "Platform"
    end

    test "renders email when provided" do
      html = render_team_card(%{email: "alice@example.com"})
      assert html =~ "alice@example.com"
    end

    test "does not render email when nil" do
      html = render_team_card(%{email: nil})
      refute html =~ "alice@example.com"
    end
  end

  describe "team_card/1 avatar" do
    test "renders fallback initial" do
      html = render_team_card(%{fallback: "D"})
      assert html =~ "D"
    end

    test "renders img when src provided" do
      html = render_component(&H.render_with_src/1, %{})
      assert html =~ "<img"
      assert html =~ ~s(src="/avatar.jpg")
    end

    test "does not render img when src is nil" do
      html = render_team_card(%{src: nil})
      refute html =~ "<img"
    end
  end

  describe "team_card/1 variants" do
    test ":default variant uses flex-col items-center" do
      html = render_team_card(%{variant: :default})
      assert html =~ "flex-col"
      assert html =~ "items-center"
    end

    test ":compact variant uses flex-col items-center" do
      html = render_team_card(%{variant: :compact})
      assert html =~ "flex-col"
      assert html =~ "items-center"
    end

    test ":horizontal variant uses flex-row" do
      html = render_team_card(%{variant: :horizontal})
      assert html =~ "flex-row"
    end
  end

  describe "team_card/1 slots" do
    test "renders badges slot content" do
      html = render_component(&H.render_with_slots/1, %{})
      assert html =~ "Lead"
    end

    test "renders actions slot content" do
      html = render_component(&H.render_with_slots/1, %{})
      assert html =~ "Message"
    end
  end

  describe "team_card/1 class forwarding" do
    test "accepts custom class" do
      html = render_team_card(%{class: "my-team-card"})
      assert html =~ "my-team-card"
    end
  end
end
