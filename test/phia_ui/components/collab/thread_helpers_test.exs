defmodule PhiaUi.Components.Collab.ThreadHelpersTest do
  use ExUnit.Case, async: true

  alias PhiaUi.Components.Collab.ThreadHelpers

  # ===========================================================================
  # thread_reply_count/1
  # ===========================================================================

  describe "thread_reply_count/1" do
    test "returns 0 for empty comments" do
      assert ThreadHelpers.thread_reply_count(%{comments: []}) == 0
    end

    test "returns 0 for single comment (root only)" do
      assert ThreadHelpers.thread_reply_count(%{comments: [%{id: "c1"}]}) == 0
    end

    test "counts replies excluding root" do
      comments = [%{id: "c1"}, %{id: "c2"}, %{id: "c3"}]
      assert ThreadHelpers.thread_reply_count(%{comments: comments}) == 2
    end

    test "returns 0 for map without comments key" do
      assert ThreadHelpers.thread_reply_count(%{}) == 0
    end

    test "returns 0 for nil" do
      assert ThreadHelpers.thread_reply_count(nil) == 0
    end
  end

  # ===========================================================================
  # thread_participants/1
  # ===========================================================================

  describe "thread_participants/1" do
    test "returns unique user IDs" do
      comments = [
        %{user_id: "u1"},
        %{user_id: "u2"},
        %{user_id: "u1"},
        %{user_id: "u3"}
      ]

      assert ThreadHelpers.thread_participants(%{comments: comments}) == ["u1", "u2", "u3"]
    end

    test "returns empty list for empty comments" do
      assert ThreadHelpers.thread_participants(%{comments: []}) == []
    end

    test "returns empty list for no comments key" do
      assert ThreadHelpers.thread_participants(%{}) == []
    end

    test "returns empty list for nil" do
      assert ThreadHelpers.thread_participants(nil) == []
    end
  end

  # ===========================================================================
  # thread_is_resolved/1
  # ===========================================================================

  describe "thread_is_resolved/1" do
    test "returns true for resolved thread" do
      assert ThreadHelpers.thread_is_resolved(%{resolved: true}) == true
    end

    test "returns false for unresolved thread" do
      assert ThreadHelpers.thread_is_resolved(%{resolved: false}) == false
    end

    test "returns false for thread without resolved key" do
      assert ThreadHelpers.thread_is_resolved(%{}) == false
    end
  end

  # ===========================================================================
  # sort_threads/2
  # ===========================================================================

  describe "sort_threads/2" do
    setup do
      now = DateTime.utc_now()
      old = DateTime.add(now, -3600, :second)
      older = DateTime.add(now, -7200, :second)

      threads = [
        %{
          id: "t1",
          resolved: false,
          created_at: older,
          comments: [%{user_id: "u1", created_at: older}]
        },
        %{
          id: "t2",
          resolved: true,
          created_at: old,
          comments: [%{user_id: "u2", created_at: now}]
        },
        %{
          id: "t3",
          resolved: false,
          created_at: now,
          comments: [%{user_id: "u3", created_at: old}]
        }
      ]

      {:ok, threads: threads}
    end

    test "sorts by date (newest first)", %{threads: threads} do
      sorted = ThreadHelpers.sort_threads(threads, :date)
      ids = Enum.map(sorted, & &1.id)
      assert ids == ["t3", "t2", "t1"]
    end

    test "sorts by activity (most recently active first)", %{threads: threads} do
      sorted = ThreadHelpers.sort_threads(threads, :activity)
      ids = Enum.map(sorted, & &1.id)
      # t2 has newest comment, then t3, then t1
      assert ids == ["t2", "t3", "t1"]
    end

    test "sorts unresolved first", %{threads: threads} do
      sorted = ThreadHelpers.sort_threads(threads, :unresolved_first)
      resolved_flags = Enum.map(sorted, & &1.resolved)
      # Unresolved (false) come before resolved (true)
      assert Enum.take(resolved_flags, 2) == [false, false]
      assert List.last(resolved_flags) == true
    end

    test "returns unchanged for unknown strategy", %{threads: threads} do
      assert ThreadHelpers.sort_threads(threads, :unknown) == threads
    end
  end

  # ===========================================================================
  # filter_threads/2
  # ===========================================================================

  describe "filter_threads/2" do
    setup do
      threads = [
        %{id: "t1", resolved: false, comments: [%{user_id: "u1"}]},
        %{id: "t2", resolved: true, comments: [%{user_id: "u2"}, %{user_id: "u1"}]},
        %{id: "t3", resolved: false, comments: [%{user_id: "u3"}]}
      ]

      {:ok, threads: threads}
    end

    test "filters by user_id", %{threads: threads} do
      filtered = ThreadHelpers.filter_threads(threads, user_id: "u1")
      ids = Enum.map(filtered, & &1.id)
      assert ids == ["t1", "t2"]
    end

    test "filters by resolved status", %{threads: threads} do
      filtered = ThreadHelpers.filter_threads(threads, resolved: false)
      ids = Enum.map(filtered, & &1.id)
      assert ids == ["t1", "t3"]
    end

    test "combines user_id and resolved filters", %{threads: threads} do
      filtered = ThreadHelpers.filter_threads(threads, user_id: "u1", resolved: false)
      ids = Enum.map(filtered, & &1.id)
      assert ids == ["t1"]
    end

    test "returns all threads with no filters", %{threads: threads} do
      filtered = ThreadHelpers.filter_threads(threads, [])
      assert length(filtered) == 3
    end
  end
end
