defmodule PhiaUi.ComponentRegistryTest do
  use ExUnit.Case, async: true

  alias PhiaUi.ComponentRegistry

  @required_fields [:name, :module, :template_file, :js_hooks, :dependencies, :tier, :shadcn_equivalent, :status]
  @valid_tiers [:primitive, :interactive, :form, :navigation, :shell, :widget]
  @valid_statuses [:planned, :implemented]

  describe "all/0" do
    test "returns a map" do
      assert is_map(ComponentRegistry.all())
    end

    test "contains exactly 59 components" do
      assert map_size(ComponentRegistry.all()) == 59
    end

    test "all keys are atom component names" do
      ComponentRegistry.all()
      |> Map.keys()
      |> Enum.each(fn key -> assert is_atom(key) end)
    end

    test "every entry has all required fields" do
      ComponentRegistry.all()
      |> Enum.each(fn {_key, meta} ->
        Enum.each(@required_fields, fn field ->
          assert Map.has_key?(meta, field),
                 "Component #{meta[:name]} missing field :#{field}"
        end)
      end)
    end

    test "every entry has a non-empty string name" do
      ComponentRegistry.all()
      |> Enum.each(fn {key, meta} ->
        assert is_binary(meta.name) and meta.name != "",
               "Component key #{inspect(key)} has invalid :name"
      end)
    end

    test "every entry has a valid tier" do
      ComponentRegistry.all()
      |> Enum.each(fn {_key, meta} ->
        assert meta.tier in @valid_tiers,
               "Component #{meta.name} has invalid tier: #{inspect(meta.tier)}"
      end)
    end

    test "every entry has a valid status" do
      ComponentRegistry.all()
      |> Enum.each(fn {_key, meta} ->
        assert meta.status in @valid_statuses,
               "Component #{meta.name} has invalid status: #{inspect(meta.status)}"
      end)
    end

    test "every entry has a list for js_hooks" do
      ComponentRegistry.all()
      |> Enum.each(fn {_key, meta} ->
        assert is_list(meta.js_hooks),
               "Component #{meta.name} :js_hooks must be a list"
      end)
    end

    test "every entry has a list for dependencies" do
      ComponentRegistry.all()
      |> Enum.each(fn {_key, meta} ->
        assert is_list(meta.dependencies),
               "Component #{meta.name} :dependencies must be a list"
      end)
    end
  end

  describe "get/1" do
    test "returns metadata for a known component" do
      assert %{name: "button"} = ComponentRegistry.get(:button)
    end

    test "returns nil for unknown component" do
      assert ComponentRegistry.get(:unknown_component) == nil
    end
  end

  describe "by_tier/1" do
    test "returns only primitive components" do
      primitives = ComponentRegistry.by_tier(:primitive)
      assert primitives != []
      Enum.each(primitives, fn meta -> assert meta.tier == :primitive end)
    end

    test "returns only interactive components" do
      interactive = ComponentRegistry.by_tier(:interactive)
      assert interactive != []
      Enum.each(interactive, fn meta -> assert meta.tier == :interactive end)
    end
  end

  describe "known components present" do
    test "button is registered" do
      assert ComponentRegistry.get(:button) != nil
    end

    test "card is registered" do
      assert ComponentRegistry.get(:card) != nil
    end

    test "dialog is registered as interactive" do
      meta = ComponentRegistry.get(:dialog)
      assert meta != nil
      assert meta.tier == :interactive
    end

    test "stat_card depends on card and badge" do
      meta = ComponentRegistry.get(:stat_card)
      assert :card in meta.dependencies
      assert :badge in meta.dependencies
    end

    test "dialog has js_hooks" do
      meta = ComponentRegistry.get(:dialog)
      assert meta.js_hooks != []
    end
  end
end
