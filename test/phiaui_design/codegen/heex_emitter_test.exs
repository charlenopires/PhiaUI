defmodule PhiaUiDesign.Codegen.HeexEmitterTest do
  use ExUnit.Case, async: true

  alias PhiaUiDesign.Canvas.{Scene, Node}
  alias PhiaUiDesign.Codegen.HeexEmitter

  # ---------------------------------------------------------------------------
  # Helper: create a scene and ensure cleanup
  # ---------------------------------------------------------------------------

  defp new_scene do
    scene = Scene.new()
    on_exit(fn -> try do Scene.destroy(scene) rescue _ -> :ok end end)
    scene
  end

  # ---------------------------------------------------------------------------
  # Empty scene
  # ---------------------------------------------------------------------------

  describe "emit/2 with empty scene" do
    test "returns empty string" do
      scene = new_scene()

      assert HeexEmitter.emit(scene) == ""
    end
  end

  # ---------------------------------------------------------------------------
  # Single component
  # ---------------------------------------------------------------------------

  describe "emit/2 with a single component" do
    test "emits self-closing tag when no slots or children" do
      scene = new_scene()
      Scene.insert_component(scene, :button, attrs: %{variant: :default, size: :default})

      result = HeexEmitter.emit(scene)

      assert result =~ "<.button"
      assert result =~ "variant={:default}"
      assert result =~ "size={:default}"
      assert result =~ "/>"
    end

    test "emits component with inner_block slot as content" do
      scene = new_scene()
      Scene.insert_component(scene, :button, slots: %{inner_block: "Click me"})

      result = HeexEmitter.emit(scene)

      assert result =~ "<.button>"
      assert result =~ "Click me"
      assert result =~ "</.button>"
    end

    test "emits component with attrs and inner_block" do
      scene = new_scene()

      Scene.insert_component(scene, :button,
        attrs: %{variant: :default, size: :default},
        slots: %{inner_block: "Button"}
      )

      result = HeexEmitter.emit(scene)

      assert result =~ "<.button"
      assert result =~ "variant={:default}"
      assert result =~ "size={:default}"
      assert result =~ "Button"
      assert result =~ "</.button>"
    end

    test "emits attrs in sorted order" do
      scene = new_scene()
      Scene.insert_component(scene, :button, attrs: %{variant: :default, disabled: true})

      result = HeexEmitter.emit(scene)

      # "disabled" sorts before "variant"
      disabled_pos = :binary.match(result, "disabled") |> elem(0)
      variant_pos = :binary.match(result, "variant") |> elem(0)
      assert disabled_pos < variant_pos
    end

    test "omits nil and false attr values" do
      scene = new_scene()
      Scene.insert_component(scene, :button, attrs: %{variant: :default, tooltip: nil, hidden: false})

      result = HeexEmitter.emit(scene)

      assert result =~ "variant={:default}"
      refute result =~ "tooltip"
      refute result =~ "hidden"
    end

    test "emits boolean true attrs as bare names" do
      scene = new_scene()
      Scene.insert_component(scene, :button, attrs: %{disabled: true})

      result = HeexEmitter.emit(scene)

      assert result =~ "disabled"
      refute result =~ "disabled="
    end
  end

  # ---------------------------------------------------------------------------
  # Named slots
  # ---------------------------------------------------------------------------

  describe "emit/2 with named slots" do
    test "emits named slots as <:slot_name> tags" do
      scene = new_scene()

      Scene.insert_component(scene, :card,
        slots: %{header: "Card Title", inner_block: "Card body"}
      )

      result = HeexEmitter.emit(scene)

      assert result =~ "<:header>Card Title</:header>"
      assert result =~ "Card body"
    end

    test "inner_block is rendered as text, not as a slot tag" do
      scene = new_scene()
      Scene.insert_component(scene, :button, slots: %{inner_block: "Submit"})

      result = HeexEmitter.emit(scene)

      refute result =~ "<:inner_block>"
      assert result =~ "Submit"
    end

    test "named slots are sorted alphabetically" do
      scene = new_scene()

      Scene.insert_component(scene, :card,
        slots: %{footer: "Footer text", header: "Header text"}
      )

      result = HeexEmitter.emit(scene)

      footer_pos = :binary.match(result, "<:footer>") |> elem(0)
      header_pos = :binary.match(result, "<:header>") |> elem(0)
      assert footer_pos < header_pos
    end
  end

  # ---------------------------------------------------------------------------
  # Nested components
  # ---------------------------------------------------------------------------

  describe "emit/2 with nested components" do
    test "renders child components inside parent" do
      scene = new_scene()
      {:ok, card} = Scene.insert_component(scene, :card)
      Scene.insert_component(scene, :button, parent_id: card.id, slots: %{inner_block: "Save"})

      result = HeexEmitter.emit(scene)

      assert result =~ "<.card>"
      assert result =~ "<.button>"
      assert result =~ "Save"
      assert result =~ "</.button>"
      assert result =~ "</.card>"
    end

    test "indents nested children on multi-line output" do
      scene = new_scene()
      {:ok, card} = Scene.insert_component(scene, :card)

      # Insert enough children to force multi-line output
      Scene.insert_component(scene, :button, parent_id: card.id, slots: %{inner_block: "Save"})
      Scene.insert_component(scene, :badge, parent_id: card.id, slots: %{inner_block: "New"})

      result = HeexEmitter.emit(scene, indent_size: 2)

      lines = String.split(result, "\n")
      button_line = Enum.find(lines, &String.contains?(&1, ".button"))
      assert button_line != nil
      # Button should be indented (starts with spaces)
      assert String.starts_with?(button_line, "  ")
    end

    test "renders single short child inline" do
      scene = new_scene()
      {:ok, card} = Scene.insert_component(scene, :card)
      Scene.insert_component(scene, :button, parent_id: card.id)

      result = HeexEmitter.emit(scene, indent_size: 2)

      # Short content is kept on a single line
      assert result =~ "<.card><.button /></.card>"
    end
  end

  # ---------------------------------------------------------------------------
  # HTML elements
  # ---------------------------------------------------------------------------

  describe "emit/2 with HTML elements" do
    test "emits HTML element with class" do
      scene = new_scene()
      Scene.insert_element(scene, "div", classes: "flex gap-4")

      result = HeexEmitter.emit(scene)

      assert result =~ "<div"
      assert result =~ ~s(class="flex gap-4")
      assert result =~ "</div>"
    end

    test "emits self-closing void element" do
      scene = new_scene()
      Scene.insert_element(scene, "hr")

      result = HeexEmitter.emit(scene)

      assert result =~ "<hr />"
    end

    test "emits empty non-void element with open/close tags" do
      scene = new_scene()
      Scene.insert_element(scene, "div")

      result = HeexEmitter.emit(scene)

      assert result =~ "<div></div>"
    end

    test "emits nested HTML elements" do
      scene = new_scene()
      {:ok, outer} = Scene.insert_element(scene, "div", classes: "flex")
      Scene.insert_element(scene, "span", parent_id: outer.id)

      result = HeexEmitter.emit(scene)

      assert result =~ "<div"
      assert result =~ "<span>"
      assert result =~ "</span>"
      assert result =~ "</div>"
    end
  end

  # ---------------------------------------------------------------------------
  # Mixed content
  # ---------------------------------------------------------------------------

  describe "emit/2 with mixed content" do
    test "emits components and HTML elements together" do
      scene = new_scene()
      {:ok, wrapper} = Scene.insert_element(scene, "div", classes: "p-4")
      Scene.insert_component(scene, :button, parent_id: wrapper.id, slots: %{inner_block: "Go"})

      result = HeexEmitter.emit(scene)

      assert result =~ "<div"
      assert result =~ ~s(class="p-4")
      assert result =~ "<.button>"
      assert result =~ "Go"
      assert result =~ "</.button>"
      assert result =~ "</div>"
    end

    test "emits text nodes as plain text" do
      scene = new_scene()
      {:ok, wrapper} = Scene.insert_element(scene, "p")

      text_node = Node.new_text("Hello world", parent_id: wrapper.id)
      Scene.insert(scene, text_node)

      result = HeexEmitter.emit(scene)

      assert result =~ "Hello world"
    end

    test "emits multiple root nodes on separate lines" do
      scene = new_scene()
      Scene.insert_component(scene, :button, slots: %{inner_block: "First"})
      Scene.insert_component(scene, :badge, slots: %{inner_block: "Second"})

      result = HeexEmitter.emit(scene)
      lines = String.split(result, "\n")

      assert length(lines) >= 2
    end
  end

  # ---------------------------------------------------------------------------
  # Frame nodes
  # ---------------------------------------------------------------------------

  describe "emit/2 with frame nodes" do
    test "emits frames as div elements" do
      scene = new_scene()

      frame = Node.new_frame(classes: "flex flex-col")
      Scene.insert(scene, frame)

      result = HeexEmitter.emit(scene)

      assert result =~ "<div"
      assert result =~ ~s(class="flex flex-col")
    end
  end

  # ---------------------------------------------------------------------------
  # Indentation options
  # ---------------------------------------------------------------------------

  describe "emit/2 indentation options" do
    test "respects initial indent level" do
      scene = new_scene()
      Scene.insert_component(scene, :button)

      result = HeexEmitter.emit(scene, indent: 4)

      assert String.starts_with?(result, "    ")
    end

    test "respects custom indent_size on multi-line output" do
      scene = new_scene()
      {:ok, parent} = Scene.insert_element(scene, "div")
      # Insert enough children to force multi-line output
      Scene.insert_component(scene, :button, parent_id: parent.id, slots: %{inner_block: "Save"})
      Scene.insert_component(scene, :badge, parent_id: parent.id, slots: %{inner_block: "New"})

      result = HeexEmitter.emit(scene, indent_size: 4)

      lines = String.split(result, "\n")
      button_line = Enum.find(lines, &String.contains?(&1, ".button"))

      assert button_line != nil
      assert String.starts_with?(button_line, "    ")
    end
  end

  # ---------------------------------------------------------------------------
  # emit_node/3
  # ---------------------------------------------------------------------------

  describe "emit_node/3" do
    test "emits a single node and its descendants" do
      scene = new_scene()
      {:ok, parent} = Scene.insert_element(scene, "div")
      {:ok, child} = Scene.insert_component(scene, :button, parent_id: parent.id)

      # Emit just the button node
      result = HeexEmitter.emit_node(scene, child.id)

      assert result =~ "<.button"
      refute result =~ "<div"
    end

    test "returns empty string for missing node" do
      scene = new_scene()

      assert HeexEmitter.emit_node(scene, "nonexistent") == ""
    end
  end

  # ---------------------------------------------------------------------------
  # String attr formatting
  # ---------------------------------------------------------------------------

  describe "emit/2 attr formatting" do
    test "emits string attrs with double quotes" do
      scene = new_scene()
      Scene.insert_component(scene, :button, attrs: %{label: "Save"})

      result = HeexEmitter.emit(scene)

      assert result =~ ~s(label="Save")
    end

    test "emits atom attrs with curly braces" do
      scene = new_scene()
      Scene.insert_component(scene, :button, attrs: %{variant: :destructive})

      result = HeexEmitter.emit(scene)

      assert result =~ "variant={:destructive}"
    end

    test "emits integer attrs with curly braces" do
      scene = new_scene()
      Scene.insert_component(scene, :button, attrs: %{count: 5})

      result = HeexEmitter.emit(scene)

      assert result =~ "count={5}"
    end

    test "emits list attrs with inspect inside curly braces" do
      scene = new_scene()
      Scene.insert_component(scene, :button, attrs: %{items: [1, 2, 3]})

      result = HeexEmitter.emit(scene)

      assert result =~ "items={[1, 2, 3]}"
    end
  end
end
