defmodule PhiaUi.ClassMergerTest do
  use ExUnit.Case, async: true

  alias PhiaUi.ClassMerger

  describe "cn/1 basic merging" do
    test "joins a list of class strings" do
      assert ClassMerger.cn(["foo", "bar"]) == "foo bar"
    end

    test "returns empty string for empty list" do
      assert ClassMerger.cn([]) == ""
    end

    test "returns single class unchanged" do
      assert ClassMerger.cn(["btn"]) == "btn"
    end

    test "splits space-separated strings in the list" do
      assert ClassMerger.cn(["foo bar", "baz"]) == "foo bar baz"
    end

    test "handles multiple spaces in a class string" do
      assert ClassMerger.cn(["foo  bar"]) == "foo bar"
    end
  end

  describe "cn/1 falsy filtering" do
    test "filters out nil values" do
      assert ClassMerger.cn(["foo", nil, "bar"]) == "foo bar"
    end

    test "filters out false values" do
      assert ClassMerger.cn(["foo", false, "bar"]) == "foo bar"
    end

    test "handles list of only nil/false" do
      assert ClassMerger.cn([nil, false]) == ""
    end
  end

  describe "cn/1 deduplication (last wins)" do
    test "removes exact duplicate classes, keeping last occurrence" do
      assert ClassMerger.cn(["foo", "bar", "foo"]) == "bar foo"
    end

    test "deduplicates across space-separated tokens" do
      assert ClassMerger.cn(["foo bar", "foo"]) == "bar foo"
    end
  end

  describe "cn/1 caching" do
    test "returns the same result on repeated calls" do
      first = ClassMerger.cn(["px-4", "py-2"])
      second = ClassMerger.cn(["px-4", "py-2"])
      assert first == second
    end
  end
end
