defmodule PhiaUi.Components.Collab.CollabHelpersTest do
  use ExUnit.Case, async: true

  alias PhiaUi.Components.Collab.CollabHelpers

  # ===========================================================================
  # format_relative_time/1
  # ===========================================================================

  describe "format_relative_time/1" do
    test "returns empty string for nil" do
      assert CollabHelpers.format_relative_time(nil) == ""
    end

    test "returns 'just now' for recent timestamps" do
      now = DateTime.utc_now()
      assert CollabHelpers.format_relative_time(now) == "just now"
    end

    test "returns seconds ago" do
      time = DateTime.utc_now() |> DateTime.add(-30, :second)
      assert CollabHelpers.format_relative_time(time) == "30 seconds ago"
    end

    test "returns 1 minute ago" do
      time = DateTime.utc_now() |> DateTime.add(-90, :second)
      assert CollabHelpers.format_relative_time(time) == "1 minute ago"
    end

    test "returns minutes ago" do
      time = DateTime.utc_now() |> DateTime.add(-600, :second)
      assert CollabHelpers.format_relative_time(time) == "10 minutes ago"
    end

    test "returns 1 hour ago" do
      time = DateTime.utc_now() |> DateTime.add(-5400, :second)
      assert CollabHelpers.format_relative_time(time) == "1 hour ago"
    end

    test "returns hours ago" do
      time = DateTime.utc_now() |> DateTime.add(-18000, :second)
      assert CollabHelpers.format_relative_time(time) == "5 hours ago"
    end

    test "returns Yesterday" do
      time = DateTime.utc_now() |> DateTime.add(-100_000, :second)
      assert CollabHelpers.format_relative_time(time) == "Yesterday"
    end

    test "returns days ago" do
      time = DateTime.utc_now() |> DateTime.add(-345_600, :second)
      assert CollabHelpers.format_relative_time(time) == "4 days ago"
    end

    test "returns formatted date for old timestamps" do
      time = ~U[2024-01-15 10:00:00Z]
      result = CollabHelpers.format_relative_time(time)
      assert result == "Jan 15, 2024"
    end

    test "handles future timestamps gracefully" do
      time = DateTime.utc_now() |> DateTime.add(3600, :second)
      assert CollabHelpers.format_relative_time(time) == "just now"
    end
  end

  # ===========================================================================
  # user_initials/1
  # ===========================================================================

  describe "user_initials/1" do
    test "returns ? for nil" do
      assert CollabHelpers.user_initials(nil) == "?"
    end

    test "returns ? for empty string" do
      assert CollabHelpers.user_initials("") == "?"
    end

    test "returns single initial for single name" do
      assert CollabHelpers.user_initials("Alice") == "A"
    end

    test "returns two initials for full name" do
      assert CollabHelpers.user_initials("Jane Doe") == "JD"
    end

    test "handles multiple names (takes first two)" do
      assert CollabHelpers.user_initials("John Michael Smith") == "JM"
    end

    test "uppercases initials" do
      assert CollabHelpers.user_initials("alice bob") == "AB"
    end

    test "handles extra whitespace" do
      assert CollabHelpers.user_initials("  Jane   Doe  ") == "JD"
    end
  end

  # ===========================================================================
  # collab_color/1
  # ===========================================================================

  describe "collab_color/1" do
    test "returns deterministic oklch color for string user_id" do
      color = CollabHelpers.collab_color("user-1")
      assert color =~ "oklch(0.7 0.15"
    end

    test "returns same color for same user_id" do
      color1 = CollabHelpers.collab_color("user-1")
      color2 = CollabHelpers.collab_color("user-1")
      assert color1 == color2
    end

    test "returns different colors for different user_ids" do
      color1 = CollabHelpers.collab_color("user-1")
      color2 = CollabHelpers.collab_color("user-2")
      assert color1 != color2
    end

    test "returns fallback for non-string" do
      assert CollabHelpers.collab_color(123) == "oklch(0.7 0.15 260)"
    end

    test "returns fallback for nil" do
      assert CollabHelpers.collab_color(nil) == "oklch(0.7 0.15 260)"
    end
  end

  # ===========================================================================
  # format_mention/1
  # ===========================================================================

  describe "format_mention/1" do
    test "prefixes name with @" do
      assert CollabHelpers.format_mention("Alice") == "@Alice"
    end

    test "handles names with spaces" do
      assert CollabHelpers.format_mention("Jane Doe") == "@Jane Doe"
    end
  end

  # ===========================================================================
  # truncate_preview/2
  # ===========================================================================

  describe "truncate_preview/2" do
    test "returns empty string for nil" do
      assert CollabHelpers.truncate_preview(nil, 10) == ""
    end

    test "returns text unchanged if shorter than max" do
      assert CollabHelpers.truncate_preview("Hello", 10) == "Hello"
    end

    test "returns text unchanged if equal to max" do
      assert CollabHelpers.truncate_preview("Hello", 5) == "Hello"
    end

    test "truncates with ellipsis if longer than max" do
      assert CollabHelpers.truncate_preview("Hello World!", 5) == "Hello..."
    end

    test "handles single character max" do
      assert CollabHelpers.truncate_preview("Hello", 1) == "H..."
    end
  end
end
