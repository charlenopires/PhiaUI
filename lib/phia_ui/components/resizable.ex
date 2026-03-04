defmodule PhiaUi.Components.Resizable do
  @moduledoc """
  Drag-to-resize split panel component.

  Provides `resizable/1`, `resizable_panel/1`, and `resizable_handle/1`
  sub-components that together create a resizable split-pane layout. The
  `PhiaResizable` JavaScript hook handles mouse drag, touch drag, and
  keyboard arrow-key resizing with configurable min/max size clamping.

  ## Sub-components

  | Component           | Element | Purpose                                               |
  |---------------------|---------|-------------------------------------------------------|
  | `resizable/1`       | `<div>` | Flex container with the `PhiaResizable` hook attached |
  | `resizable_panel/1` | `<div>` | Individual panel sized via CSS `flex`                 |
  | `resizable_handle/1`| `<div>` | Drag handle between panels (keyboard focusable)       |

  ## Hook setup

  Register the `PhiaResizable` hook in your LiveSocket before using this
  component:

      // assets/js/app.js
      import PhiaResizable from "./hooks/resizable"

      let liveSocket = new LiveSocket("/live", Socket, {
        hooks: { PhiaResizable }
      })

  ## Horizontal split (default)

  Side-by-side panels, the most common layout for code editors, detail/list
  splits, and side-by-side comparisons:

      <.resizable class="h-[400px]">
        <.resizable_panel default_size={50} min_size={20}>
          <div class="h-full p-4">Left panel</div>
        </.resizable_panel>
        <.resizable_handle />
        <.resizable_panel default_size={50} min_size={20}>
          <div class="h-full p-4">Right panel</div>
        </.resizable_panel>
      </.resizable>

  ## Vertical split

  Top-and-bottom panels, useful for query editors, terminal splits, or
  primary + detail layouts:

      <.resizable direction="vertical" class="h-[600px]">
        <.resizable_panel default_size={60} min_size={30}>
          <div class="h-full overflow-auto p-4">Top panel (query editor)</div>
        </.resizable_panel>
        <.resizable_handle />
        <.resizable_panel default_size={40} min_size={20}>
          <div class="h-full overflow-auto p-4">Bottom panel (results)</div>
        </.resizable_panel>
      </.resizable>

  ## Three-column layout (master-detail-info)

      <.resizable class="h-screen">
        <.resizable_panel default_size={20} min_size={15} max_size={30}>
          <%!-- Sidebar navigation --%>
          <nav class="h-full overflow-y-auto p-4">...</nav>
        </.resizable_panel>
        <.resizable_handle />
        <.resizable_panel default_size={50} min_size={30}>
          <%!-- Main content --%>
          <main class="h-full overflow-y-auto p-4">...</main>
        </.resizable_panel>
        <.resizable_handle />
        <.resizable_panel default_size={30} min_size={20} max_size={40}>
          <%!-- Detail/properties panel --%>
          <aside class="h-full overflow-y-auto p-4">...</aside>
        </.resizable_panel>
      </.resizable>

  ## IDE-style layout (file tree + editor + terminal)

      <.resizable direction="vertical" class="h-screen">
        <.resizable_panel default_size={70}>
          <.resizable class="h-full">
            <.resizable_panel default_size={20} min_size={15}>
              <div class="h-full p-2">File tree</div>
            </.resizable_panel>
            <.resizable_handle />
            <.resizable_panel default_size={80}>
              <div class="h-full p-4">Editor</div>
            </.resizable_panel>
          </.resizable>
        </.resizable_panel>
        <.resizable_handle />
        <.resizable_panel default_size={30} min_size={10}>
          <div class="h-full p-2 font-mono text-sm">Terminal</div>
        </.resizable_panel>
      </.resizable>

  ## Panel size model

  Panel sizes are percentages (0–100). The CSS `flex` property is set to
  `flex: N 1 0%` where `N` is the `default_size`. The `PhiaResizable` hook
  reads `data-min-size` and `data-max-size` from each panel to clamp dragging.

  ## Accessibility

  - The `resizable_handle/1` carries `role="separator"` and `tabindex="0"`
    so keyboard users can focus it and adjust the split with arrow keys.
  - `aria-valuenow`, `aria-valuemin`, and `aria-valuemax` communicate the
    current split position to assistive technologies.
  """

  use Phoenix.Component
  import PhiaUi.ClassMerger, only: [cn: 1]

  # ---------------------------------------------------------------------------
  # resizable/1 — container with hook
  # ---------------------------------------------------------------------------

  attr(:direction, :string,
    default: "horizontal",
    values: ~w(horizontal vertical),
    doc: "Split direction: `\"horizontal\"` (panels side-by-side) or `\"vertical\"` (panels top-and-bottom)."
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes applied to the container `<div>`. Always set an explicit height (e.g. `class=\"h-[400px]\"`) so panels have space to fill.")
  attr(:rest, :global, doc: "HTML attributes forwarded to the container `<div>` element.")
  slot(:inner_block, required: true, doc: "Alternating `resizable_panel/1` and `resizable_handle/1` children.")

  @doc """
  Renders the resizable container.

  Attaches the `PhiaResizable` JavaScript hook via `phx-hook`. The hook
  reads the `data-direction` attribute to determine drag axis. Requires the
  `PhiaResizable` hook to be registered in your `LiveSocket` hooks.

  Always set an explicit height on the container so the panels have space
  to fill — the container uses `h-full w-full` internally:

      <.resizable class="h-[500px]">
        ...
      </.resizable>
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

  # ---------------------------------------------------------------------------
  # resizable_panel/1 — individual panel
  # ---------------------------------------------------------------------------

  attr(:default_size, :integer,
    default: 50,
    doc: "Initial panel size as a percentage of the container (0–100). The sum of all panel `default_size` values should equal 100."
  )

  attr(:min_size, :integer,
    default: 10,
    doc: "Minimum panel size as a percentage. The hook clamps dragging so this panel cannot shrink below this value."
  )

  attr(:max_size, :integer,
    default: 90,
    doc: "Maximum panel size as a percentage. The hook clamps dragging so this panel cannot grow beyond this value."
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes applied to the panel `<div>`. Typically `overflow-auto` or `overflow-hidden`.")
  attr(:rest, :global, doc: "HTML attributes forwarded to the panel `<div>` element.")
  slot(:inner_block, required: true, doc: "Panel content.")

  @doc """
  Renders a resizable panel inside a `resizable/1` container.

  The panel's initial size is set via CSS `flex: N 1 0%` where `N` is the
  `default_size`. The hook stores `data-default-size`, `data-min-size`, and
  `data-max-size` for runtime clamping during drag operations.

  Panels use `overflow-hidden` by default to prevent content from breaking
  the layout. Override with `class="overflow-auto"` when the panel content
  should scroll independently.

  ## Example

      <.resizable_panel default_size={40} min_size={20} max_size={70}>
        <div class="h-full overflow-auto p-4">
          Panel content
        </div>
      </.resizable_panel>
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

  # ---------------------------------------------------------------------------
  # resizable_handle/1 — drag handle
  # ---------------------------------------------------------------------------

  attr(:class, :string, default: nil, doc: "Additional CSS classes applied to the handle `<div>`.")
  attr(:rest, :global, doc: "HTML attributes forwarded to the handle `<div>` element.")

  @doc """
  Renders the drag handle between two resizable panels.

  The handle is a thin `<div>` with a 1px `bg-border` line and an expanded
  interactive hit area via an `::after` pseudo-element. It is keyboard
  focusable (`tabindex="0"`) and carries ARIA separator attributes.

  Place one handle between each pair of adjacent panels:

      <.resizable_panel ...>...</.resizable_panel>
      <.resizable_handle />                         <%!-- between panels --%>
      <.resizable_panel ...>...</.resizable_panel>

  Keyboard interaction (managed by the `PhiaResizable` hook):
  - `ArrowLeft` / `ArrowRight` — adjust horizontal split.
  - `ArrowUp` / `ArrowDown` — adjust vertical split.
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

  # Horizontal: panels flow left-to-right in a flex row
  defp container_class("horizontal"),
    do: "flex h-full w-full"

  # Vertical: panels stack top-to-bottom in a flex column
  defp container_class("vertical"),
    do: "flex flex-col h-full w-full"

  # Handle styling: thin visible line + wide invisible click/drag target via ::after.
  # `after:w-1` extends the interactive area 4px either side of the 1px line,
  # making it easier to grab on touch devices.
  defp handle_class do
    "relative flex w-px items-center justify-center bg-border " <>
      "after:absolute after:inset-y-0 after:left-1/2 after:w-1 " <>
      "after:-translate-x-1/2 focus-visible:outline-none " <>
      "focus-visible:ring-1 focus-visible:ring-ring " <>
      "cursor-col-resize select-none hover:bg-accent transition-colors"
  end
end
