defmodule PhiaUi.ClassMerger.ConflictTest do
  use ExUnit.Case, async: true

  alias PhiaUi.ClassMerger

  describe "cn/1 — Tailwind group conflict resolution" do
    test "last bg-* wins" do
      assert ClassMerger.cn(["bg-primary", "bg-secondary"]) == "bg-secondary"
    end

    test "last text color wins" do
      assert ClassMerger.cn(["text-red-500", "text-blue-500"]) == "text-blue-500"
    end

    test "last text size wins" do
      assert ClassMerger.cn(["text-sm", "text-lg"]) == "text-lg"
    end

    test "text size and text color coexist (different groups)" do
      result = ClassMerger.cn(["text-sm", "text-primary"])
      assert result =~ "text-sm"
      assert result =~ "text-primary"
    end

    test "last font-weight wins" do
      assert ClassMerger.cn(["font-bold", "font-semibold"]) == "font-semibold"
    end

    test "last p-* wins" do
      assert ClassMerger.cn(["p-4", "p-8"]) == "p-8"
    end

    test "p-4 and px-4 coexist (different groups)" do
      result = ClassMerger.cn(["p-4", "px-4"])
      assert result =~ "p-4"
      assert result =~ "px-4"
    end

    test "last display utility wins" do
      assert ClassMerger.cn(["flex", "grid"]) == "grid"
    end

    test "last position utility wins" do
      assert ClassMerger.cn(["relative", "absolute"]) == "absolute"
    end

    test "non-conflicting classes are all preserved" do
      result = ClassMerger.cn(["flex", "bg-primary", "text-sm", "p-4", "font-bold"])
      assert result == "flex bg-primary text-sm p-4 font-bold"
    end

    test "override in the middle: last group win applies to full list" do
      # bg-primary then other stuff then bg-secondary: bg-secondary wins
      result = ClassMerger.cn(["bg-primary", "text-sm", "bg-secondary"])
      assert result =~ "bg-secondary"
      refute result =~ "bg-primary"
      assert result =~ "text-sm"
    end
  end
end
