defmodule PhiaUi.ClassMerger.GroupsTest do
  use ExUnit.Case, async: true

  alias PhiaUi.ClassMerger.Groups

  describe "group_for/1 — background" do
    test "bg-primary and bg-secondary share the same group" do
      assert Groups.group_for("bg-primary") == Groups.group_for("bg-secondary")
    end

    test "bg-red-500 is in bg group" do
      assert Groups.group_for("bg-red-500") != nil
    end
  end

  describe "group_for/1 — text color vs text size" do
    test "text-red-500 and text-blue-500 share text-color group" do
      assert Groups.group_for("text-red-500") == Groups.group_for("text-blue-500")
    end

    test "text-sm and text-lg share text-size group" do
      assert Groups.group_for("text-sm") == Groups.group_for("text-lg")
    end

    test "text-sm (size) and text-red-500 (color) are in different groups" do
      refute Groups.group_for("text-sm") == Groups.group_for("text-red-500")
    end
  end

  describe "group_for/1 — font" do
    test "font-bold and font-semibold share font-weight group" do
      assert Groups.group_for("font-bold") == Groups.group_for("font-semibold")
    end

    test "font-sans and font-mono share font-family group" do
      assert Groups.group_for("font-sans") == Groups.group_for("font-mono")
    end

    test "font-bold (weight) and font-sans (family) are different groups" do
      refute Groups.group_for("font-bold") == Groups.group_for("font-sans")
    end
  end

  describe "group_for/1 — spacing" do
    test "p-4 and p-8 share padding group" do
      assert Groups.group_for("p-4") == Groups.group_for("p-8")
    end

    test "px-4 and px-8 share padding-x group" do
      assert Groups.group_for("px-4") == Groups.group_for("px-8")
    end

    test "p-4 and px-4 are in different groups" do
      refute Groups.group_for("p-4") == Groups.group_for("px-4")
    end
  end

  describe "group_for/1 — display" do
    test "flex and grid share display group" do
      assert Groups.group_for("flex") == Groups.group_for("grid")
    end

    test "hidden is in display group" do
      assert Groups.group_for("hidden") == Groups.group_for("flex")
    end
  end

  describe "group_for/1 — position" do
    test "relative and absolute share position group" do
      assert Groups.group_for("relative") == Groups.group_for("absolute")
    end

    test "fixed and sticky share position group" do
      assert Groups.group_for("fixed") == Groups.group_for("sticky")
    end
  end

  describe "group_for/1 — unknown classes" do
    test "returns nil for unknown/arbitrary class" do
      assert Groups.group_for("phia-custom") == nil
    end

    test "my-* is correctly classified as margin-y group (not unknown)" do
      assert Groups.group_for("my-custom") == {nil, :my}
    end
  end

  describe "group_for/1 — responsive prefix awareness" do
    test "sm:bg-primary returns {sm:, :bg}" do
      assert Groups.group_for("sm:bg-primary") == {"sm:", :bg}
    end

    test "md:bg-red-500 returns {md:, :bg}" do
      assert Groups.group_for("md:bg-red-500") == {"md:", :bg}
    end

    test "sm:flex-col and sm:flex-row share the same group" do
      assert Groups.group_for("sm:flex-col") == Groups.group_for("sm:flex-row")
    end

    test "sm:flex-col and md:flex-row are in different groups" do
      refute Groups.group_for("sm:flex-col") == Groups.group_for("md:flex-row")
    end

    test "unprefixed and sm: prefixed are in different groups" do
      refute Groups.group_for("flex-col") == Groups.group_for("sm:flex-col")
    end

    test "hover:bg-red-500 returns {hover:, :bg}" do
      assert Groups.group_for("hover:bg-red-500") == {"hover:", :bg}
    end

    test "hover:sm:bg-red-500 returns {hover:sm:, :bg}" do
      assert Groups.group_for("hover:sm:bg-red-500") == {"hover:sm:", :bg}
    end

    test "@sm: container query prefix is handled" do
      assert Groups.group_for("@sm:flex-col") == {"@sm:", :flex_direction}
    end

    test "unknown class with variant prefix returns nil" do
      assert Groups.group_for("sm:phia-custom") == nil
    end
  end
end
