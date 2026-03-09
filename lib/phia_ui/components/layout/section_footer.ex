defmodule PhiaUi.Components.Layout.SectionFooter do
  @moduledoc """
  Section-ending divider with action row.

  Typically placed at the bottom of a content section to provide
  pagination, save buttons, or navigation actions.

  ## Examples

      <.section_footer>
        <.button variant={:outline}>Cancel</.button>
        <.button>Save</.button>
      </.section_footer>

      <.section_footer align={:between}>
        <span class="text-sm text-muted-foreground">Showing 1-10 of 50</span>
        <.pagination ... />
      </.section_footer>

      <.section_footer divider={false} align={:end}>
        <.button>Next</.button>
      </.section_footer>
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  attr :divider, :boolean, default: true, doc: "Show top border"
  attr :align, :atom, values: [:start, :center, :end, :between], default: :end
  attr :class, :string, default: nil
  attr :rest, :global

  slot :inner_block, required: true

  def section_footer(assigns) do
    ~H"""
    <div
      class={cn([
        "flex items-center gap-3",
        @divider && "border-t border-border pt-4",
        align_class(@align),
        @class
      ])}
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end

  defp align_class(:start), do: "justify-start"
  defp align_class(:center), do: "justify-center"
  defp align_class(:end), do: "justify-end"
  defp align_class(:between), do: "justify-between"
end
