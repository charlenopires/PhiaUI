defmodule PhiaUi.Components.EventCardTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.EventCard

    attr(:title, :string, default: "Team Standup")
    attr(:month, :string, default: nil)
    attr(:day, :string, default: nil)
    attr(:time, :string, default: nil)
    attr(:location, :string, default: nil)
    attr(:virtual, :boolean, default: false)
    attr(:attendees, :list, default: [])
    attr(:max_attendees, :integer, default: 3)
    attr(:category_color, :atom, default: :primary)
    attr(:class, :string, default: nil)

    def render_event_card(assigns) do
      ~H"""
      <.event_card
        title={@title}
        month={@month}
        day={@day}
        time={@time}
        location={@location}
        virtual={@virtual}
        attendees={@attendees}
        max_attendees={@max_attendees}
        category_color={@category_color}
        class={@class}
      />
      """
    end

    attr(:title, :string, default: "Team Standup")

    def render_with_actions(assigns) do
      ~H"""
      <.event_card title={@title}>
        <:actions>
          <button type="button">RSVP</button>
        </:actions>
      </.event_card>
      """
    end
  end

  defp render_event_card(attrs \\ %{}) do
    render_component(&H.render_event_card/1, attrs)
  end

  # ---------------------------------------------------------------------------
  # Basic rendering
  # ---------------------------------------------------------------------------

  describe "event_card/1 basic rendering" do
    test "renders a wrapper element" do
      html = render_event_card()
      assert html =~ "<div"
    end

    test "renders the title" do
      html = render_event_card(%{title: "Product Launch"})
      assert html =~ "Product Launch"
    end

    test "title has font-semibold styling" do
      html = render_event_card(%{title: "My Event"})
      assert html =~ "font-semibold"
    end
  end

  # ---------------------------------------------------------------------------
  # Date badge (month / day)
  # ---------------------------------------------------------------------------

  describe "event_card/1 date badge" do
    test "renders month label" do
      html = render_event_card(%{month: "JAN"})
      assert html =~ "JAN"
    end

    test "renders day label" do
      html = render_event_card(%{day: "15"})
      assert html =~ "15"
    end

    test "day has text-3xl font-bold styling" do
      html = render_event_card(%{day: "22"})
      assert html =~ "text-3xl"
      assert html =~ "font-bold"
    end

    test "month and day not rendered when nil" do
      html = render_event_card(%{month: nil, day: nil})
      refute html =~ "JAN"
    end
  end

  # ---------------------------------------------------------------------------
  # Time row
  # ---------------------------------------------------------------------------

  describe "event_card/1 time" do
    test "renders time when provided" do
      html = render_event_card(%{time: "3:00 PM"})
      assert html =~ "3:00 PM"
    end

    test "renders clock icon when time is provided" do
      html = render_event_card(%{time: "9:00 AM"})
      assert html =~ ~s(href="/icons/lucide-sprite.svg#icon-clock")
    end

    test "time not rendered when nil" do
      html = render_event_card(%{time: nil})
      refute html =~ ~s(#icon-clock)
    end
  end

  # ---------------------------------------------------------------------------
  # Location row
  # ---------------------------------------------------------------------------

  describe "event_card/1 location" do
    test "renders location when provided" do
      html = render_event_card(%{location: "Room 42"})
      assert html =~ "Room 42"
    end

    test "renders map-pin icon for in-person event" do
      html = render_event_card(%{location: "HQ", virtual: false})
      assert html =~ ~s(href="/icons/lucide-sprite.svg#icon-map-pin")
    end

    test "renders video icon for virtual event" do
      html = render_event_card(%{location: "Zoom", virtual: true})
      assert html =~ ~s(href="/icons/lucide-sprite.svg#icon-video")
    end

    test "virtual event does not show map-pin icon" do
      html = render_event_card(%{location: "Zoom", virtual: true})
      refute html =~ ~s(href="/icons/lucide-sprite.svg#icon-map-pin")
    end

    test "location not rendered when nil" do
      html = render_event_card(%{location: nil})
      refute html =~ "map-pin"
    end
  end

  # ---------------------------------------------------------------------------
  # Category colors
  # ---------------------------------------------------------------------------

  describe "event_card/1 category_color" do
    test "primary uses bg-primary" do
      html = render_event_card(%{category_color: :primary})
      assert html =~ "bg-primary"
    end

    test "blue uses bg-blue-500" do
      html = render_event_card(%{category_color: :blue})
      assert html =~ "bg-blue-500"
    end

    test "emerald uses bg-emerald-500" do
      html = render_event_card(%{category_color: :emerald})
      assert html =~ "bg-emerald-500"
    end

    test "amber uses bg-amber-500" do
      html = render_event_card(%{category_color: :amber})
      assert html =~ "bg-amber-500"
    end

    test "rose uses bg-rose-500" do
      html = render_event_card(%{category_color: :rose})
      assert html =~ "bg-rose-500"
    end

    test "violet uses bg-violet-500" do
      html = render_event_card(%{category_color: :violet})
      assert html =~ "bg-violet-500"
    end
  end

  # ---------------------------------------------------------------------------
  # Attendees
  # ---------------------------------------------------------------------------

  describe "event_card/1 attendees" do
    test "renders attendee avatars" do
      attendees = [%{src: "/a.jpg", name: "Alice"}, %{src: "/b.jpg", name: "Bob"}]
      html = render_event_card(%{attendees: attendees})
      assert html =~ "Alice"
      assert html =~ "Bob"
    end

    test "respects max_attendees limit" do
      attendees = [
        %{src: nil, name: "A"},
        %{src: nil, name: "B"},
        %{src: nil, name: "C"},
        %{src: nil, name: "D"}
      ]

      html = render_event_card(%{attendees: attendees, max_attendees: 2})
      # Shows overflow count
      assert html =~ "+2"
    end

    test "no overflow badge when attendees fit within max" do
      attendees = [%{src: nil, name: "Alice"}, %{src: nil, name: "Bob"}]
      html = render_event_card(%{attendees: attendees, max_attendees: 3})
      refute html =~ "+"
    end

    test "no attendees section when list is empty" do
      html = render_event_card(%{attendees: []})
      refute html =~ "-space-x-2"
    end
  end

  # ---------------------------------------------------------------------------
  # Actions slot
  # ---------------------------------------------------------------------------

  describe "event_card/1 :actions slot" do
    test "renders actions slot content" do
      html = render_component(&H.render_with_actions/1, %{})
      assert html =~ "RSVP"
    end

    test "actions not rendered when slot is empty" do
      html = render_event_card()
      refute html =~ "RSVP"
    end
  end

  # ---------------------------------------------------------------------------
  # Custom class
  # ---------------------------------------------------------------------------

  describe "event_card/1 class" do
    test "accepts custom class" do
      html = render_event_card(%{class: "my-event-class"})
      assert html =~ "my-event-class"
    end
  end
end
