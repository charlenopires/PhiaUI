defmodule PhiaUi.Components.LinkGroup do
  @moduledoc """
  Organized footer / help-column navigation links.

  Three components:

  - `link_group/1` — flex column wrapper
  - `link_group_heading/1` — section heading label
  - `link_group_item/1` — individual link (supports external and disabled states)
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  # ---------------------------------------------------------------------------
  # link_group/1
  # ---------------------------------------------------------------------------

  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:rest, :global)
  slot(:inner_block, required: true)

  @doc "Renders a vertical flex column link group container."
  def link_group(assigns) do
    ~H"""
    <div class={cn(["flex flex-col gap-2", @class])} {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # link_group_heading/1
  # ---------------------------------------------------------------------------

  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  @doc "Renders a section heading for a link group."
  def link_group_heading(assigns) do
    ~H"""
    <h3 class={cn(["text-sm font-semibold text-foreground", @class])} {@rest}>
      {render_slot(@inner_block)}
    </h3>
    """
  end

  # ---------------------------------------------------------------------------
  # link_group_item/1
  # ---------------------------------------------------------------------------

  attr(:href, :string, default: "#")
  attr(:external, :boolean, default: false, doc: "Adds target='_blank' and rel='noopener noreferrer'")
  attr(:disabled, :boolean, default: false)
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  @doc "Renders an individual link inside a link group."
  def link_group_item(assigns) do
    ~H"""
    <a
      href={if @disabled, do: nil, else: @href}
      target={if @external, do: "_blank"}
      rel={if @external, do: "noopener noreferrer"}
      class={cn([
        "text-sm text-muted-foreground hover:text-foreground transition-colors",
        @disabled && "pointer-events-none opacity-50",
        @class
      ])}
      {@rest}
    >
      {render_slot(@inner_block)}
    </a>
    """
  end
end
