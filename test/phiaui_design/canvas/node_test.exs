defmodule PhiaUiDesign.Canvas.NodeTest do
  use ExUnit.Case, async: true

  alias PhiaUiDesign.Canvas.Node

  # ---------------------------------------------------------------------------
  # Node.new_component/2
  # ---------------------------------------------------------------------------

  describe "new_component/2" do
    test "creates a node with type :phia_component" do
      node = Node.new_component(:button)

      assert node.type == :phia_component
      assert node.component == :button
    end

    test "generates a unique ID when none is provided" do
      node1 = Node.new_component(:button)
      node2 = Node.new_component(:button)

      assert is_binary(node1.id)
      assert is_binary(node2.id)
      assert node1.id != node2.id
    end

    test "uses a custom ID when provided" do
      node = Node.new_component(:button, id: "custom-id")

      assert node.id == "custom-id"
    end

    test "sets default name from component atom" do
      node = Node.new_component(:button)

      assert node.name == "button"
    end

    test "accepts a custom name" do
      node = Node.new_component(:button, name: "Primary Button")

      assert node.name == "Primary Button"
    end

    test "stores attrs map" do
      node = Node.new_component(:button, attrs: %{variant: :destructive, size: :lg})

      assert node.attrs == %{variant: :destructive, size: :lg}
    end

    test "stores slots map" do
      node = Node.new_component(:card, slots: %{inner_block: "Hello"})

      assert node.slots == %{inner_block: "Hello"}
    end

    test "stores module reference" do
      node = Node.new_component(:button, module: PhiaUi.Components.Button)

      assert node.module == PhiaUi.Components.Button
    end

    test "stores parent_id" do
      node = Node.new_component(:button, parent_id: "parent-123")

      assert node.parent_id == "parent-123"
    end

    test "defaults attrs to empty map" do
      node = Node.new_component(:button)

      assert node.attrs == %{}
    end

    test "defaults slots to empty map" do
      node = Node.new_component(:button)

      assert node.slots == %{}
    end

    test "defaults parent_id to nil" do
      node = Node.new_component(:button)

      assert node.parent_id == nil
    end

    test "defaults children to empty list" do
      node = Node.new_component(:button)

      assert node.children == []
    end

    test "defaults locked to false" do
      node = Node.new_component(:button)

      assert node.locked == false
    end

    test "defaults visible to true" do
      node = Node.new_component(:button)

      assert node.visible == true
    end
  end

  # ---------------------------------------------------------------------------
  # Node.new_element/2
  # ---------------------------------------------------------------------------

  describe "new_element/2" do
    test "creates a node with type :html_element" do
      node = Node.new_element("div")

      assert node.type == :html_element
      assert node.tag == "div"
    end

    test "generates a unique ID" do
      node = Node.new_element("div")

      assert is_binary(node.id)
    end

    test "uses a custom ID when provided" do
      node = Node.new_element("div", id: "wrapper")

      assert node.id == "wrapper"
    end

    test "sets default name from tag" do
      node = Node.new_element("section")

      assert node.name == "section"
    end

    test "accepts a custom name" do
      node = Node.new_element("div", name: "Container")

      assert node.name == "Container"
    end

    test "stores classes" do
      node = Node.new_element("div", classes: "flex gap-4 items-center")

      assert node.classes == "flex gap-4 items-center"
    end

    test "stores parent_id" do
      node = Node.new_element("span", parent_id: "parent-1")

      assert node.parent_id == "parent-1"
    end

    test "stores children list" do
      node = Node.new_element("div", children: ["child-1", "child-2"])

      assert node.children == ["child-1", "child-2"]
    end

    test "defaults classes to nil" do
      node = Node.new_element("div")

      assert node.classes == nil
    end

    test "defaults children to empty list" do
      node = Node.new_element("div")

      assert node.children == []
    end

    test "component field is nil for HTML elements" do
      node = Node.new_element("div")

      assert node.component == nil
    end
  end

  # ---------------------------------------------------------------------------
  # Node.new_text/2
  # ---------------------------------------------------------------------------

  describe "new_text/2" do
    test "creates a node with type :text" do
      node = Node.new_text("Hello world")

      assert node.type == :text
      assert node.text_content == "Hello world"
    end

    test "generates a unique ID" do
      node = Node.new_text("content")

      assert is_binary(node.id)
    end

    test "uses a custom ID when provided" do
      node = Node.new_text("content", id: "text-1")

      assert node.id == "text-1"
    end

    test "sets default name to first 21 characters of content" do
      node = Node.new_text("Short text")

      assert node.name == "Short text"
    end

    test "truncates default name for long content" do
      long_text = String.duplicate("a", 50)
      node = Node.new_text(long_text)

      # String.slice(content, 0..20) gives 21 characters
      assert String.length(node.name) == 21
    end

    test "accepts a custom name" do
      node = Node.new_text("Hello", name: "Greeting")

      assert node.name == "Greeting"
    end

    test "stores parent_id" do
      node = Node.new_text("Hello", parent_id: "parent-1")

      assert node.parent_id == "parent-1"
    end

    test "tag is nil for text nodes" do
      node = Node.new_text("Hello")

      assert node.tag == nil
    end

    test "component is nil for text nodes" do
      node = Node.new_text("Hello")

      assert node.component == nil
    end
  end

  # ---------------------------------------------------------------------------
  # Node.new_frame/1
  # ---------------------------------------------------------------------------

  describe "new_frame/1" do
    test "creates a node with type :frame" do
      node = Node.new_frame()

      assert node.type == :frame
    end

    test "generates a unique ID" do
      node = Node.new_frame()

      assert is_binary(node.id)
    end

    test "uses a custom ID when provided" do
      node = Node.new_frame(id: "frame-1")

      assert node.id == "frame-1"
    end

    test "sets default name to Frame" do
      node = Node.new_frame()

      assert node.name == "Frame"
    end

    test "accepts a custom name" do
      node = Node.new_frame(name: "Header Group")

      assert node.name == "Header Group"
    end

    test "stores classes" do
      node = Node.new_frame(classes: "flex flex-col gap-2")

      assert node.classes == "flex flex-col gap-2"
    end

    test "stores parent_id" do
      node = Node.new_frame(parent_id: "root-1")

      assert node.parent_id == "root-1"
    end

    test "stores children list" do
      node = Node.new_frame(children: ["a", "b", "c"])

      assert node.children == ["a", "b", "c"]
    end

    test "defaults classes to nil" do
      node = Node.new_frame()

      assert node.classes == nil
    end

    test "defaults children to empty list" do
      node = Node.new_frame()

      assert node.children == []
    end

    test "defaults parent_id to nil" do
      node = Node.new_frame()

      assert node.parent_id == nil
    end

    test "component is nil for frames" do
      node = Node.new_frame()

      assert node.component == nil
    end

    test "tag is nil for frames" do
      node = Node.new_frame()

      assert node.tag == nil
    end
  end

  # ---------------------------------------------------------------------------
  # Struct enforcement
  # ---------------------------------------------------------------------------

  describe "struct enforcement" do
    test "id and type are enforced keys" do
      assert_raise ArgumentError, fn ->
        struct!(Node, %{})
      end
    end

    test "struct can be pattern matched" do
      node = Node.new_component(:button)

      assert %Node{id: _, type: :phia_component} = node
    end
  end
end
