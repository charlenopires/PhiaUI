defmodule PhiaUiDesign.Codegen.LiveviewEmitterTest do
  use ExUnit.Case, async: true

  alias PhiaUiDesign.Canvas.Scene
  alias PhiaUiDesign.Codegen.LiveviewEmitter

  # ---------------------------------------------------------------------------
  # Helper: create a scene and ensure cleanup
  # ---------------------------------------------------------------------------

  defp new_scene do
    scene = Scene.new()
    on_exit(fn -> try do Scene.destroy(scene) rescue _ -> :ok end end)
    scene
  end

  # ---------------------------------------------------------------------------
  # Basic module structure
  # ---------------------------------------------------------------------------

  describe "emit/3 module structure" do
    test "emits a defmodule with the given module name" do
      scene = new_scene()

      result = LiveviewEmitter.emit(scene, "MyAppWeb.DashboardLive")

      assert result =~ "defmodule MyAppWeb.DashboardLive do"
      assert result =~ "end\n"
    end

    test "includes use with default web module" do
      scene = new_scene()

      result = LiveviewEmitter.emit(scene, "MyAppWeb.PageLive")

      assert result =~ "use MyAppWeb, :live_view"
    end

    test "includes use with custom web module" do
      scene = new_scene()

      result = LiveviewEmitter.emit(scene, "MyAppWeb.PageLive", web_module: "CustomWeb")

      assert result =~ "use CustomWeb, :live_view"
    end

    test "includes mount/3 callback" do
      scene = new_scene()

      result = LiveviewEmitter.emit(scene, "MyAppWeb.PageLive")

      assert result =~ "@impl true"
      assert result =~ "def mount(_params, _session, socket) do"
      assert result =~ "{:ok, assign(socket)}"
      assert result =~ "end"
    end

    test "includes render/1 callback with HEEx sigil" do
      scene = new_scene()

      result = LiveviewEmitter.emit(scene, "MyAppWeb.PageLive")

      assert result =~ "@impl true"
      assert result =~ "def render(assigns) do"
      assert result =~ ~s(~H\"\"\")
      assert result =~ ~s(    \"\"\")
      assert result =~ "end"
    end

    test "ends with a newline" do
      scene = new_scene()

      result = LiveviewEmitter.emit(scene, "MyAppWeb.PageLive")

      assert String.ends_with?(result, "\n")
    end
  end

  # ---------------------------------------------------------------------------
  # Imports based on components
  # ---------------------------------------------------------------------------

  describe "emit/3 with imports" do
    test "includes import for button component module" do
      scene = new_scene()
      Scene.insert_component(scene, :button)

      result = LiveviewEmitter.emit(scene, "MyAppWeb.PageLive")

      assert result =~ "import PhiaUi.Components.Button"
    end

    test "includes imports for multiple component modules" do
      scene = new_scene()
      Scene.insert_component(scene, :button)
      Scene.insert_component(scene, :badge)

      result = LiveviewEmitter.emit(scene, "MyAppWeb.PageLive")

      assert result =~ "import PhiaUi.Components.Button"
      assert result =~ "import PhiaUi.Components.Badge"
    end

    test "deduplicates imports for same module" do
      scene = new_scene()
      Scene.insert_component(scene, :button)
      Scene.insert_component(scene, :button)

      result = LiveviewEmitter.emit(scene, "MyAppWeb.PageLive")

      # Count occurrences of the import line
      count =
        result
        |> String.split("\n")
        |> Enum.count(&(&1 =~ "import PhiaUi.Components.Button"))

      assert count == 1
    end

    test "does not include imports when no components are used" do
      scene = new_scene()
      Scene.insert_element(scene, "div")

      result = LiveviewEmitter.emit(scene, "MyAppWeb.PageLive")

      refute result =~ "import Phia"
    end
  end

  # ---------------------------------------------------------------------------
  # HEEx template content
  # ---------------------------------------------------------------------------

  describe "emit/3 template content" do
    test "embeds the HEEx output from the scene" do
      scene = new_scene()
      Scene.insert_component(scene, :button, slots: %{inner_block: "Click"})

      result = LiveviewEmitter.emit(scene, "MyAppWeb.PageLive")

      assert result =~ ".button"
      assert result =~ "Click"
    end

    test "indents HEEx content within render/1" do
      scene = new_scene()
      Scene.insert_component(scene, :button, attrs: %{variant: :default})

      result = LiveviewEmitter.emit(scene, "MyAppWeb.PageLive")

      # HeexEmitter is called with indent: 4, so content should be indented
      lines = String.split(result, "\n")
      button_line = Enum.find(lines, &(&1 =~ ".button"))

      assert button_line != nil
      assert String.starts_with?(button_line, "    ")
    end
  end

  # ---------------------------------------------------------------------------
  # Mount assigns
  # ---------------------------------------------------------------------------

  describe "emit/3 with assigns" do
    test "adds assigns to mount callback" do
      scene = new_scene()

      result =
        LiveviewEmitter.emit(scene, "MyAppWeb.PageLive",
          assigns: %{title: "Dashboard", count: 0}
        )

      assert result =~ "assign(socket, count: 0, title: \"Dashboard\")"
    end

    test "sorts assigns alphabetically" do
      scene = new_scene()

      result =
        LiveviewEmitter.emit(scene, "MyAppWeb.PageLive",
          assigns: %{zebra: true, alpha: 1}
        )

      alpha_pos = :binary.match(result, "alpha:") |> elem(0)
      zebra_pos = :binary.match(result, "zebra:") |> elem(0)
      assert alpha_pos < zebra_pos
    end

    test "does not add assigns when empty map provided" do
      scene = new_scene()

      result = LiveviewEmitter.emit(scene, "MyAppWeb.PageLive", assigns: %{})

      assert result =~ "{:ok, assign(socket)}"
    end
  end

  # ---------------------------------------------------------------------------
  # Event handlers
  # ---------------------------------------------------------------------------

  describe "emit/3 with events" do
    test "adds handle_event callbacks" do
      scene = new_scene()

      result =
        LiveviewEmitter.emit(scene, "MyAppWeb.PageLive",
          events: [{"save", "{:noreply, socket}"}]
        )

      assert result =~ ~s[def handle_event("save", params, socket) do]
      assert result =~ "{:noreply, socket}"
    end

    test "adds multiple event handlers" do
      scene = new_scene()

      result =
        LiveviewEmitter.emit(scene, "MyAppWeb.PageLive",
          events: [
            {"save", "{:noreply, socket}"},
            {"delete", "{:noreply, socket}"}
          ]
        )

      assert result =~ ~s[def handle_event("save", params, socket)]
      assert result =~ ~s[def handle_event("delete", params, socket)]
    end

    test "does not add event section when no events given" do
      scene = new_scene()

      result = LiveviewEmitter.emit(scene, "MyAppWeb.PageLive")

      refute result =~ "handle_event"
    end
  end

  # ---------------------------------------------------------------------------
  # generate_imports/1
  # ---------------------------------------------------------------------------

  describe "generate_imports/1" do
    test "returns import lines for component keys" do
      result = LiveviewEmitter.generate_imports([:button])

      assert result =~ "import PhiaUi.Components.Button"
    end

    test "returns empty string for empty list" do
      result = LiveviewEmitter.generate_imports([])

      assert result == ""
    end

    test "returns empty string for unknown components" do
      result = LiveviewEmitter.generate_imports([:nonexistent_component_xyz])

      assert result == ""
    end
  end

  # ---------------------------------------------------------------------------
  # required_hooks/1
  # ---------------------------------------------------------------------------

  describe "required_hooks/1" do
    test "returns JS hook names for components that need them" do
      hooks = LiveviewEmitter.required_hooks([:dialog])

      assert "PhiaFocusTrap" in hooks
      assert "PhiaDialog" in hooks
    end

    test "returns empty list for components without hooks" do
      hooks = LiveviewEmitter.required_hooks([:button])

      assert hooks == []
    end

    test "deduplicates and sorts hooks" do
      hooks = LiveviewEmitter.required_hooks([:dialog, :sheet])

      # Both have PhiaFocusTrap — should only appear once
      assert length(Enum.filter(hooks, &(&1 == "PhiaFocusTrap"))) == 1
      # Should be sorted
      assert hooks == Enum.sort(hooks)
    end

    test "returns empty list for empty input" do
      assert LiveviewEmitter.required_hooks([]) == []
    end
  end

  # ---------------------------------------------------------------------------
  # required_add_commands/1
  # ---------------------------------------------------------------------------

  describe "required_add_commands/1" do
    test "returns mix phia.add commands for each component" do
      commands = LiveviewEmitter.required_add_commands([:button, :badge])

      assert "mix phia.add badge" in commands
      assert "mix phia.add button" in commands
    end

    test "sorts commands alphabetically" do
      commands = LiveviewEmitter.required_add_commands([:card, :badge, :button])

      assert commands == [
               "mix phia.add badge",
               "mix phia.add button",
               "mix phia.add card"
             ]
    end

    test "returns empty list for empty input" do
      assert LiveviewEmitter.required_add_commands([]) == []
    end
  end
end
