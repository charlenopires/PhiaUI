defmodule PhiaUiDesign.Catalog.IntrospectorTest do
  use ExUnit.Case, async: true

  alias PhiaUiDesign.Catalog.Introspector

  # ---------------------------------------------------------------------------
  # introspect_module/1
  # ---------------------------------------------------------------------------

  describe "introspect_module/1" do
    test "returns a list of component definitions for a valid Phoenix component module" do
      result = Introspector.introspect_module(PhiaUi.Components.Button)

      assert is_list(result)
      assert length(result) > 0
    end

    test "includes the button component for PhiaUi.Components.Button" do
      result = Introspector.introspect_module(PhiaUi.Components.Button)

      button = Enum.find(result, &(&1.name == :button))
      assert button != nil
      assert button.module == PhiaUi.Components.Button
    end

    test "returns attrs for the button component" do
      result = Introspector.introspect_module(PhiaUi.Components.Button)
      button = Enum.find(result, &(&1.name == :button))

      assert is_list(button.attrs)
      assert length(button.attrs) > 0

      attr_names = Enum.map(button.attrs, & &1.name)
      assert :variant in attr_names
      assert :size in attr_names
      assert :class in attr_names
    end

    test "returns slots for the button component" do
      result = Introspector.introspect_module(PhiaUi.Components.Button)
      button = Enum.find(result, &(&1.name == :button))

      assert is_list(button.slots)
      slot_names = Enum.map(button.slots, & &1.name)
      assert :inner_block in slot_names
    end

    test "attr info contains expected fields" do
      result = Introspector.introspect_module(PhiaUi.Components.Button)
      button = Enum.find(result, &(&1.name == :button))
      variant_attr = Enum.find(button.attrs, &(&1.name == :variant))

      assert Map.has_key?(variant_attr, :name)
      assert Map.has_key?(variant_attr, :type)
      assert Map.has_key?(variant_attr, :required)
      assert Map.has_key?(variant_attr, :default)
      assert Map.has_key?(variant_attr, :values)
      assert Map.has_key?(variant_attr, :doc)
    end

    test "slot info contains expected fields" do
      result = Introspector.introspect_module(PhiaUi.Components.Button)
      button = Enum.find(result, &(&1.name == :button))
      inner_block = Enum.find(button.slots, &(&1.name == :inner_block))

      assert Map.has_key?(inner_block, :name)
      assert Map.has_key?(inner_block, :required)
      assert Map.has_key?(inner_block, :doc)
    end

    test "excludes :rest attr from the attr list" do
      result = Introspector.introspect_module(PhiaUi.Components.Button)
      button = Enum.find(result, &(&1.name == :button))
      attr_names = Enum.map(button.attrs, & &1.name)

      refute :rest in attr_names
    end

    test "attrs are sorted alphabetically by name" do
      result = Introspector.introspect_module(PhiaUi.Components.Button)
      button = Enum.find(result, &(&1.name == :button))
      attr_names = Enum.map(button.attrs, & &1.name)

      assert attr_names == Enum.sort(attr_names)
    end

    test "slots are sorted alphabetically by name" do
      result = Introspector.introspect_module(PhiaUi.Components.Button)
      button = Enum.find(result, &(&1.name == :button))
      slot_names = Enum.map(button.slots, & &1.name)

      assert slot_names == Enum.sort(slot_names)
    end

    test "returns empty list for a module without __components__" do
      result = Introspector.introspect_module(Enum)

      assert result == []
    end

    test "returns empty list for a non-existent module" do
      result = Introspector.introspect_module(NonExistent.Module.That.Does.Not.Exist)

      assert result == []
    end
  end

  # ---------------------------------------------------------------------------
  # introspect_component/2
  # ---------------------------------------------------------------------------

  describe "introspect_component/2" do
    test "returns info for a specific component function" do
      result = Introspector.introspect_component(PhiaUi.Components.Button, :button)

      assert result != nil
      assert result.name == :button
      assert result.module == PhiaUi.Components.Button
    end

    test "returns nil for a non-existent component function" do
      result = Introspector.introspect_component(PhiaUi.Components.Button, :nonexistent)

      assert result == nil
    end

    test "returns nil for a non-component module" do
      result = Introspector.introspect_component(Enum, :map)

      assert result == nil
    end
  end

  # ---------------------------------------------------------------------------
  # get_component_info/1
  # ---------------------------------------------------------------------------

  describe "get_component_info/1" do
    test "returns full component info for a registered key" do
      info = Introspector.get_component_info(:button)

      assert info != nil
      assert info.key == :button
      assert info.name == "button"
      assert info.module == PhiaUi.Components.Button
    end

    test "includes tier from registry" do
      info = Introspector.get_component_info(:button)

      assert info.tier == :primitive
    end

    test "includes js_hooks from registry" do
      info = Introspector.get_component_info(:dialog)

      assert is_list(info.js_hooks)
      assert "FocusTrap" in info.js_hooks
      assert "Dialog" in info.js_hooks
    end

    test "includes dependencies from registry" do
      info = Introspector.get_component_info(:button)

      assert is_list(info.dependencies)
    end

    test "includes attrs from runtime introspection" do
      info = Introspector.get_component_info(:button)

      assert is_list(info.attrs)
      attr_names = Enum.map(info.attrs, & &1.name)
      assert :variant in attr_names
      assert :size in attr_names
    end

    test "includes slots from runtime introspection" do
      info = Introspector.get_component_info(:button)

      assert is_list(info.slots)
      slot_names = Enum.map(info.slots, & &1.name)
      assert :inner_block in slot_names
    end

    test "includes doc string" do
      info = Introspector.get_component_info(:button)

      # doc may be nil or a string depending on whether docs are compiled
      assert info.doc == nil or is_binary(info.doc)
    end

    test "returns nil for an unregistered component key" do
      result = Introspector.get_component_info(:completely_unknown_component_xyz)

      assert result == nil
    end
  end

  # ---------------------------------------------------------------------------
  # introspect_all/0
  # ---------------------------------------------------------------------------

  describe "introspect_all/0" do
    test "returns a list of maps for all implemented components" do
      result = Introspector.introspect_all()

      assert is_list(result)
      assert length(result) > 0
    end

    test "each entry has required keys" do
      result = Introspector.introspect_all()
      entry = hd(result)

      assert Map.has_key?(entry, :key)
      assert Map.has_key?(entry, :name)
      assert Map.has_key?(entry, :module)
      assert Map.has_key?(entry, :tier)
      assert Map.has_key?(entry, :js_hooks)
      assert Map.has_key?(entry, :dependencies)
      assert Map.has_key?(entry, :attrs)
      assert Map.has_key?(entry, :slots)
      assert Map.has_key?(entry, :doc)
    end

    test "includes button in the results" do
      result = Introspector.introspect_all()
      button = Enum.find(result, &(&1.key == :button))

      assert button != nil
      assert button.name == "button"
      assert button.module == PhiaUi.Components.Button
    end

    test "only includes implemented components" do
      result = Introspector.introspect_all()

      # All entries should have corresponding registry entries with status: :implemented
      for entry <- result do
        registry_entry = PhiaUi.ComponentRegistry.get(entry.key)
        assert registry_entry != nil
        assert registry_entry.status == :implemented
      end
    end
  end
end
