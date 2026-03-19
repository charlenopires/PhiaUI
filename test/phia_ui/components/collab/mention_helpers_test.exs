defmodule PhiaUi.Components.Collab.MentionHelpersTest do
  use ExUnit.Case, async: true

  alias PhiaUi.Components.Collab.MentionHelpers

  # ===========================================================================
  # parse_mentions/1
  # ===========================================================================

  describe "parse_mentions/1" do
    test "parses single mention" do
      text = "Hello @[Alice](user-1)!"
      [mention] = MentionHelpers.parse_mentions(text)
      assert mention.name == "Alice"
      assert mention.user_id == "user-1"
      assert mention.start == 6
    end

    test "parses multiple mentions" do
      text = "@[Alice](u1) and @[Bob](u2)"
      mentions = MentionHelpers.parse_mentions(text)
      assert length(mentions) == 2
      assert Enum.map(mentions, & &1.name) == ["Alice", "Bob"]
      assert Enum.map(mentions, & &1.user_id) == ["u1", "u2"]
    end

    test "returns empty list for no mentions" do
      assert MentionHelpers.parse_mentions("No mentions here") == []
    end

    test "returns empty list for nil" do
      assert MentionHelpers.parse_mentions(nil) == []
    end

    test "handles mentions with spaces in display name" do
      text = "Hey @[Jane Doe](user-42)"
      [mention] = MentionHelpers.parse_mentions(text)
      assert mention.name == "Jane Doe"
      assert mention.user_id == "user-42"
    end
  end

  # ===========================================================================
  # render_mentions/1
  # ===========================================================================

  describe "render_mentions/1" do
    test "replaces mention markup with @name" do
      text = "Hello @[Alice](user-1)!"
      assert MentionHelpers.render_mentions(text) == "Hello @Alice!"
    end

    test "replaces multiple mentions" do
      text = "@[Alice](u1) and @[Bob](u2)"
      assert MentionHelpers.render_mentions(text) == "@Alice and @Bob"
    end

    test "returns text unchanged if no mentions" do
      text = "No mentions"
      assert MentionHelpers.render_mentions(text) == "No mentions"
    end

    test "handles empty string" do
      assert MentionHelpers.render_mentions("") == ""
    end
  end

  # ===========================================================================
  # mentioned_user_ids/1
  # ===========================================================================

  describe "mentioned_user_ids/1" do
    test "extracts unique user IDs" do
      text = "Hey @[Alice](u1) and @[Bob](u2) and @[Alice](u1) again"
      assert MentionHelpers.mentioned_user_ids(text) == ["u1", "u2"]
    end

    test "returns empty list for no mentions" do
      assert MentionHelpers.mentioned_user_ids("No mentions") == []
    end

    test "returns empty list for nil" do
      assert MentionHelpers.mentioned_user_ids(nil) == []
    end

    test "extracts single user ID" do
      text = "Check with @[Alice](user-abc)"
      assert MentionHelpers.mentioned_user_ids(text) == ["user-abc"]
    end
  end
end
