defmodule PhiaUiDesign.Canvas.VariablesTest do
  use ExUnit.Case, async: true

  alias PhiaUiDesign.Canvas.{Scene, Variables}

  defp new_scene do
    scene = Scene.new()
    on_exit(fn -> try do Scene.destroy(scene) rescue _ -> :ok end end)
    scene
  end

  # ---------------------------------------------------------------------------
  # Storage
  # ---------------------------------------------------------------------------

  describe "get_all/1" do
    test "returns empty map for new scene" do
      scene = new_scene()
      assert Variables.get_all(scene) == %{}
    end
  end

  describe "put/3" do
    test "stores a variable" do
      scene = new_scene()

      :ok = Variables.put(scene, "primary", %{value: "#3b82f6", type: :color, theme_overrides: %{}})

      vars = Variables.get_all(scene)
      assert Map.has_key?(vars, "primary")
      assert vars["primary"].value == "#3b82f6"
      assert vars["primary"].type == :color
    end

    test "overwrites existing variable" do
      scene = new_scene()

      Variables.put(scene, "spacing", %{value: 16, type: :spacing, theme_overrides: %{}})
      Variables.put(scene, "spacing", %{value: 24, type: :spacing, theme_overrides: %{}})

      vars = Variables.get_all(scene)
      assert vars["spacing"].value == 24
    end
  end

  describe "delete/2" do
    test "removes a variable" do
      scene = new_scene()

      Variables.put(scene, "temp", %{value: "x", type: :string, theme_overrides: %{}})
      Variables.delete(scene, "temp")

      assert Variables.get_all(scene) == %{}
    end

    test "no-op for non-existent variable" do
      scene = new_scene()

      assert :ok = Variables.delete(scene, "nonexistent")
    end
  end

  describe "put_all/2" do
    test "merges multiple variables" do
      scene = new_scene()

      Variables.put(scene, "existing", %{value: "keep", type: :string, theme_overrides: %{}})

      Variables.put_all(scene, %{
        "primary" => %{value: "#3b82f6", type: :color, theme_overrides: %{}},
        "spacing" => %{value: 16, type: :spacing, theme_overrides: %{}}
      })

      vars = Variables.get_all(scene)
      assert map_size(vars) == 3
      assert vars["existing"].value == "keep"
      assert vars["primary"].value == "#3b82f6"
      assert vars["spacing"].value == 16
    end
  end

  # ---------------------------------------------------------------------------
  # Resolution
  # ---------------------------------------------------------------------------

  describe "resolve/3" do
    test "resolves a variable reference" do
      scene = new_scene()
      Variables.put(scene, "primary", %{value: "#3b82f6", type: :color, theme_overrides: %{}})

      assert Variables.resolve("$primary", scene, :zinc) == "#3b82f6"
    end

    test "returns theme override when theme matches" do
      scene = new_scene()

      Variables.put(scene, "bg", %{
        value: "#ffffff",
        type: :color,
        theme_overrides: %{dark: "#1a1a2e"}
      })

      assert Variables.resolve("$bg", scene, :dark) == "#1a1a2e"
    end

    test "returns default value when theme has no override" do
      scene = new_scene()

      Variables.put(scene, "bg", %{
        value: "#ffffff",
        type: :color,
        theme_overrides: %{dark: "#1a1a2e"}
      })

      assert Variables.resolve("$bg", scene, :zinc) == "#ffffff"
    end

    test "returns original string for undefined variable" do
      scene = new_scene()

      assert Variables.resolve("$undefined", scene, :zinc) == "$undefined"
    end

    test "passes through non-variable values" do
      scene = new_scene()

      assert Variables.resolve("hello", scene, :zinc) == "hello"
      assert Variables.resolve(42, scene, :zinc) == 42
      assert Variables.resolve(nil, scene, :zinc) == nil
    end
  end

  describe "resolve_attrs/3" do
    test "resolves all variable references in a map" do
      scene = new_scene()
      Variables.put(scene, "primary", %{value: "#3b82f6", type: :color, theme_overrides: %{}})
      Variables.put(scene, "radius", %{value: 8, type: :number, theme_overrides: %{}})

      attrs = %{color: "$primary", radius: "$radius", label: "Hello"}
      resolved = Variables.resolve_attrs(attrs, scene, :zinc)

      assert resolved.color == "#3b82f6"
      assert resolved.radius == 8
      assert resolved.label == "Hello"
    end
  end

  # ---------------------------------------------------------------------------
  # is_variable_ref?
  # ---------------------------------------------------------------------------

  describe "is_variable_ref?/1" do
    test "returns true for $-prefixed strings" do
      assert Variables.is_variable_ref?("$primary")
      assert Variables.is_variable_ref?("$spacing_lg")
    end

    test "returns false for non-variable values" do
      refute Variables.is_variable_ref?("hello")
      refute Variables.is_variable_ref?(42)
      refute Variables.is_variable_ref?(nil)
    end
  end

  # ---------------------------------------------------------------------------
  # Normalization
  # ---------------------------------------------------------------------------

  describe "normalization" do
    test "accepts string keys in definition" do
      scene = new_scene()

      Variables.put(scene, "test", %{
        "value" => "#fff",
        "type" => "color",
        "theme_overrides" => %{"dark" => "#000"}
      })

      vars = Variables.get_all(scene)
      assert vars["test"].value == "#fff"
      assert vars["test"].type == :color
      assert vars["test"].theme_overrides == %{dark: "#000"}
    end
  end
end
