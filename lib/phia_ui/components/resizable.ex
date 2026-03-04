defmodule PhiaUi.Components.Resizable do
  @moduledoc """
  Resizable split panel component for PhiaUI.

  Provides `resizable/1`, `resizable_panel/1`, and `resizable_handle/1`
  sub-components that together create a drag-to-resize layout. The
  `PhiaResizable` JS hook handles mouse/touch drag with min/max clamping.

  ## Examples

      <%!-- Horizontal split (default) --%>
      <.resizable>
        <.resizable_panel default_size={50}>
          Left content
        </.resizable_panel>
        <.resizable_handle />
        <.resizable_panel default_size={50}>
          Right content
        </.resizable_panel>
      </.resizable>

      <%!-- Vertical split --%>
      <.resizable direction="vertical">
        <.resizable_panel default_size={30} min_size={20}>
          Top
        </.resizable_panel>
        <.resizable_handle />
        <.resizable_panel default_size={70}>
          Bottom
        </.resizable_panel>
      </.resizable>

  ## Hook setup

      import PhiaResizable from "./hooks/resizable"
      let liveSocket = new LiveSocket("/live", Socket, {
        hooks: { PhiaResizable }
      })

  """

  use Phoenix.Component
  import PhiaUi.ClassMerger, only: [cn: 1]

  attr(:direction, :string,
    default: "horizontal",
    values: ~w(horizontal vertical),
    doc: "Split direction: \"horizontal\" (side-by-side) or \"vertical\" (top-bottom)"
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:rest, :global, doc: "HTML attributes forwarded to the wrapper element")
  slot(:inner_block, required: true, doc: "resizable_panel and resizable_handle children")

  @doc """
  Renders the resizable container. Attach the `PhiaResizable` hook for drag
  functionality via `phx-hook="PhiaResizable"`.
  """
  def resizable(assigns) do
    ~H"""
    <div
      phx-hook="PhiaResizable"
      data-direction={@direction}
      class={cn([container_class(@direction), @class])}
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end

  attr(:default_size, :integer,
    default: 50,
    doc: "Initial panel size as a percentage (0-100)"
  )

  attr(:min_size, :integer,
    default: 10,
    doc: "Minimum panel size as a percentage"
  )

  attr(:max_size, :integer,
    default: 90,
    doc: "Maximum panel size as a percentage"
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:rest, :global, doc: "HTML attributes forwarded to the panel element")
  slot(:inner_block, required: true, doc: "Panel content")

  @doc """
  Renders a resizable panel within a `resizable/1` container.
  """
  def resizable_panel(assigns) do
    ~H"""
    <div
      data-panel
      data-default-size={@default_size}
      data-min-size={@min_size}
      data-max-size={@max_size}
      style={"flex: #{@default_size} 1 0%"}
      class={cn(["overflow-hidden", @class])}
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end

  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:rest, :global, doc: "HTML attributes forwarded to the handle element")

  @doc """
  Renders the drag handle between two resizable panels.
  """
  def resizable_handle(assigns) do
    ~H"""
    <div
      data-panel-handle
      role="separator"
      aria-orientation="horizontal"
      aria-valuenow={50}
      aria-valuemin={0}
      aria-valuemax={100}
      tabindex={0}
      class={cn([handle_class(), @class])}
      {@rest}
    />
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  defp container_class("horizontal"),
    do: "flex h-full w-full"

  defp container_class("vertical"),
    do: "flex flex-col h-full w-full"

  defp handle_class do
    "relative flex w-px items-center justify-center bg-border " <>
      "after:absolute after:inset-y-0 after:left-1/2 after:w-1 " <>
      "after:-translate-x-1/2 focus-visible:outline-none " <>
      "focus-visible:ring-1 focus-visible:ring-ring " <>
      "cursor-col-resize select-none hover:bg-accent transition-colors"
  end
end
