defmodule PhiaUi.Components.Collab.VersionHelpersTest do
  use ExUnit.Case, async: true

  alias PhiaUi.Components.Collab.VersionHelpers

  # ---------------------------------------------------------------------------
  # diff_documents/2
  # ---------------------------------------------------------------------------

  describe "diff_documents/2" do
    test "returns empty list for identical documents" do
      doc = %{"content" => [%{"type" => "paragraph", "text" => "Hello"}]}
      assert VersionHelpers.diff_documents(doc, doc) == []
    end

    test "detects added nodes" do
      old = %{"content" => [%{"type" => "paragraph", "text" => "Hello"}]}

      new = %{
        "content" => [
          %{"type" => "paragraph", "text" => "Hello"},
          %{"type" => "paragraph", "text" => "World"}
        ]
      }

      changes = VersionHelpers.diff_documents(old, new)
      assert length(changes) == 1
      assert hd(changes).type == :added
      assert hd(changes).content == %{"type" => "paragraph", "text" => "World"}
    end

    test "detects removed nodes" do
      old = %{
        "content" => [
          %{"type" => "paragraph", "text" => "Hello"},
          %{"type" => "paragraph", "text" => "World"}
        ]
      }

      new = %{"content" => [%{"type" => "paragraph", "text" => "Hello"}]}

      changes = VersionHelpers.diff_documents(old, new)
      assert length(changes) == 1
      assert hd(changes).type == :removed
    end

    test "detects modified nodes" do
      old = %{"content" => [%{"type" => "paragraph", "text" => "Hello"}]}
      new = %{"content" => [%{"type" => "paragraph", "text" => "World"}]}

      changes = VersionHelpers.diff_documents(old, new)
      assert length(changes) == 1
      assert hd(changes).type == :modified
      assert hd(changes).old == %{"type" => "paragraph", "text" => "Hello"}
      assert hd(changes).new == %{"type" => "paragraph", "text" => "World"}
    end

    test "handles empty content arrays" do
      old = %{"content" => []}
      new = %{"content" => []}
      assert VersionHelpers.diff_documents(old, new) == []
    end

    test "handles missing content key" do
      assert VersionHelpers.diff_documents(%{}, %{}) == []
    end

    test "returns empty list for non-map inputs" do
      assert VersionHelpers.diff_documents(nil, nil) == []
      assert VersionHelpers.diff_documents("string", 42) == []
    end

    test "detects multiple changes" do
      old = %{"content" => [%{"type" => "p", "text" => "A"}, %{"type" => "p", "text" => "B"}]}
      new = %{"content" => [%{"type" => "p", "text" => "X"}, %{"type" => "p", "text" => "B"}, %{"type" => "p", "text" => "C"}]}

      changes = VersionHelpers.diff_documents(old, new)
      types = Enum.map(changes, & &1.type)
      assert :modified in types
      assert :added in types
    end
  end

  # ---------------------------------------------------------------------------
  # diff_summary/1
  # ---------------------------------------------------------------------------

  describe "diff_summary/1" do
    test "returns 'No changes' for empty list" do
      assert VersionHelpers.diff_summary([]) == "No changes"
    end

    test "summarizes added changes" do
      changes = [%{type: :added}, %{type: :added}]
      assert VersionHelpers.diff_summary(changes) == "2 added"
    end

    test "summarizes removed changes" do
      changes = [%{type: :removed}]
      assert VersionHelpers.diff_summary(changes) == "1 removed"
    end

    test "summarizes modified changes" do
      changes = [%{type: :modified}, %{type: :modified}, %{type: :modified}]
      assert VersionHelpers.diff_summary(changes) == "3 modified"
    end

    test "summarizes mixed changes" do
      changes = [%{type: :added}, %{type: :removed}, %{type: :modified}]
      assert VersionHelpers.diff_summary(changes) == "1 added, 1 removed, 1 modified"
    end

    test "returns 'No changes' for non-list input" do
      assert VersionHelpers.diff_summary(nil) == "No changes"
      assert VersionHelpers.diff_summary("not a list") == "No changes"
    end
  end

  # ---------------------------------------------------------------------------
  # format_version_date/1
  # ---------------------------------------------------------------------------

  describe "format_version_date/1" do
    test "returns empty string for nil" do
      assert VersionHelpers.format_version_date(nil) == ""
    end

    test "formats a DateTime" do
      datetime = ~U[2026-03-19 14:30:00Z]
      result = VersionHelpers.format_version_date(datetime)
      assert result =~ "March"
      assert result =~ "19"
      assert result =~ "2026"
    end

    test "formats a NaiveDateTime" do
      naive = ~N[2026-01-15 09:15:00]
      result = VersionHelpers.format_version_date(naive)
      assert result =~ "January"
      assert result =~ "15"
      assert result =~ "2026"
    end
  end

  # ---------------------------------------------------------------------------
  # group_versions_by_day/1
  # ---------------------------------------------------------------------------

  describe "group_versions_by_day/1" do
    test "groups versions by date descending" do
      versions = [
        %{id: "v1", created_at: ~U[2026-03-19 10:00:00Z]},
        %{id: "v2", created_at: ~U[2026-03-19 12:00:00Z]},
        %{id: "v3", created_at: ~U[2026-03-18 09:00:00Z]}
      ]

      result = VersionHelpers.group_versions_by_day(versions)
      assert length(result) == 2
      {first_date, first_versions} = hd(result)
      assert first_date == ~D[2026-03-19]
      assert length(first_versions) == 2
    end

    test "returns empty list for empty input" do
      assert VersionHelpers.group_versions_by_day([]) == []
    end

    test "returns empty list for non-list input" do
      assert VersionHelpers.group_versions_by_day(nil) == []
    end

    test "handles string key created_at" do
      versions = [%{"created_at" => ~U[2026-03-19 10:00:00Z]}]
      result = VersionHelpers.group_versions_by_day(versions)
      assert length(result) == 1
    end
  end

  # ---------------------------------------------------------------------------
  # word_count_delta/2
  # ---------------------------------------------------------------------------

  describe "word_count_delta/2" do
    test "returns positive delta with plus sign" do
      assert VersionHelpers.word_count_delta(100, 120) == "+20"
    end

    test "returns negative delta with minus sign" do
      assert VersionHelpers.word_count_delta(100, 80) == "-20"
    end

    test "returns zero for no change" do
      assert VersionHelpers.word_count_delta(100, 100) == "0"
    end

    test "returns zero for non-integer inputs" do
      assert VersionHelpers.word_count_delta(nil, nil) == "0"
      assert VersionHelpers.word_count_delta("a", "b") == "0"
    end
  end
end
