defmodule PhiaUiDesign.Templates.SemanticDefaults do
  @moduledoc """
  Role-based defaults for components used in page templates.

  When a template creates a semantic section (sidebar, stat area, form, etc.),
  these defaults provide the right PhiaUI components with appropriate
  attributes and layout properties for that context.
  """

  @doc """
  Get the default configuration for a semantic role.

  Returns a map with `:component`, `:attrs`, `:slots`, `:layout`, and `:children`
  keys describing how to build that section.
  """
  @spec get(atom()) :: map() | nil
  def get(:sidebar_nav) do
    %{
      component: :nav_list,
      layout: %{layout: :vertical, gap: 4, padding: 16, width: :fill},
      children: [
        %{component: :button, attrs: %{variant: "ghost", class: "w-full justify-start"}}
      ]
    }
  end

  def get(:stat_section) do
    %{
      component: :simple_grid,
      attrs: %{columns: 4},
      layout: %{layout: :horizontal, gap: 16, width: :fill},
      children: [
        %{component: :stat_card}
      ]
    }
  end

  def get(:form_section) do
    %{
      component: :card,
      layout: %{layout: :vertical, gap: 16, padding: 24, width: :fill},
      children: [
        %{component: :card_header},
        %{component: :card_content, children: [
          %{component: :form_grid}
        ]}
      ]
    }
  end

  def get(:page_header) do
    %{
      component: :page_header,
      layout: %{layout: :horizontal, justify_content: :between, align_items: :center, width: :fill}
    }
  end

  def get(:data_section) do
    %{
      component: :card,
      layout: %{layout: :vertical, gap: 0, width: :fill},
      children: [
        %{component: :card_header},
        %{component: :card_content, children: [
          %{component: :data_table}
        ]}
      ]
    }
  end

  def get(:auth_form) do
    %{
      component: :card,
      attrs: %{class: "w-full max-w-md"},
      layout: %{layout: :vertical, gap: 0, width: :fill},
      children: [
        %{component: :card_header},
        %{component: :card_content, children: [
          %{frame: true, layout: %{layout: :vertical, gap: 16}}
        ]},
        %{component: :card_footer}
      ]
    }
  end

  def get(:hero_section) do
    %{
      frame: true,
      layout: %{layout: :vertical, gap: 24, padding: [80, 24, 80, 24], align_items: :center, width: :fill}
    }
  end

  def get(:features_grid) do
    %{
      component: :simple_grid,
      attrs: %{columns: 3},
      layout: %{layout: :horizontal, gap: 32, width: :fill, wrap: true}
    }
  end

  def get(:pricing_grid) do
    %{
      component: :simple_grid,
      attrs: %{columns: 3},
      layout: %{layout: :horizontal, gap: 32, width: :fill, align_items: :stretch}
    }
  end

  def get(:kanban_board) do
    %{
      frame: true,
      layout: %{layout: :horizontal, gap: 16, width: :fill, align_items: :start},
      children: [
        %{component: :card, attrs: %{class: "min-w-[280px] flex-1"},
          layout: %{layout: :vertical, gap: 8, padding: 16}}
      ]
    }
  end

  def get(:inbox_layout) do
    %{
      frame: true,
      layout: %{layout: :horizontal, gap: 0, width: :fill, height: :fill},
      children: [
        %{frame: true, layout: %{layout: :vertical, width: 320, height: :fill}},
        %{frame: true, layout: %{layout: :vertical, width: :fill, height: :fill}}
      ]
    }
  end

  def get(_), do: nil

  @doc """
  List all available semantic role keys.
  """
  @spec keys() :: [atom()]
  def keys do
    [
      :sidebar_nav,
      :stat_section,
      :form_section,
      :page_header,
      :data_section,
      :auth_form,
      :hero_section,
      :features_grid,
      :pricing_grid,
      :kanban_board,
      :inbox_layout
    ]
  end
end
