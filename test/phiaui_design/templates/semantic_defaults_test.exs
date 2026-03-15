defmodule PhiaUiDesign.Templates.SemanticDefaultsTest do
  use ExUnit.Case, async: true

  alias PhiaUiDesign.Templates.SemanticDefaults

  # ---------------------------------------------------------------------------
  # Known roles
  # ---------------------------------------------------------------------------

  describe "get/1" do
    test "returns config for sidebar_nav" do
      config = SemanticDefaults.get(:sidebar_nav)

      assert config.component == :nav_list
      assert config.layout.layout == :vertical
      assert config.layout.gap == 4
    end

    test "returns config for stat_section" do
      config = SemanticDefaults.get(:stat_section)

      assert config.component == :simple_grid
      assert config.attrs.columns == 4
      assert config.layout.layout == :horizontal
    end

    test "returns config for form_section" do
      config = SemanticDefaults.get(:form_section)

      assert config.component == :card
      assert config.layout.layout == :vertical
      assert is_list(config.children)
    end

    test "returns config for page_header" do
      config = SemanticDefaults.get(:page_header)

      assert config.component == :page_header
      assert config.layout.justify_content == :between
    end

    test "returns config for data_section" do
      config = SemanticDefaults.get(:data_section)

      assert config.component == :card
      assert is_list(config.children)
    end

    test "returns config for auth_form" do
      config = SemanticDefaults.get(:auth_form)

      assert config.component == :card
      assert config.attrs.class =~ "max-w"
    end

    test "returns config for hero_section" do
      config = SemanticDefaults.get(:hero_section)

      assert config.frame == true
      assert config.layout.align_items == :center
    end

    test "returns config for features_grid" do
      config = SemanticDefaults.get(:features_grid)

      assert config.layout.wrap == true
    end

    test "returns config for pricing_grid" do
      config = SemanticDefaults.get(:pricing_grid)

      assert config.layout.align_items == :stretch
    end

    test "returns config for kanban_board" do
      config = SemanticDefaults.get(:kanban_board)

      assert config.frame == true
      assert config.layout.layout == :horizontal
    end

    test "returns config for inbox_layout" do
      config = SemanticDefaults.get(:inbox_layout)

      assert config.frame == true
      assert length(config.children) == 2
    end

    test "returns nil for unknown role" do
      assert SemanticDefaults.get(:nonexistent) == nil
    end
  end

  # ---------------------------------------------------------------------------
  # keys/0
  # ---------------------------------------------------------------------------

  describe "keys/0" do
    test "returns all known role keys" do
      keys = SemanticDefaults.keys()

      assert :sidebar_nav in keys
      assert :stat_section in keys
      assert :form_section in keys
      assert :kanban_board in keys
      assert :inbox_layout in keys
      assert length(keys) == 11
    end
  end
end
