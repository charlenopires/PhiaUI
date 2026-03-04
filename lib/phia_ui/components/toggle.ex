defmodule PhiaUi.Components.Toggle do
  @moduledoc """
  Pressable toggle button component with `aria-pressed` semantics.

  A two-state button that communicates its on/off state through the `aria-pressed`
  ARIA attribute. Ideal for toolbar actions (Bold, Italic, Underline), filter
  buttons, or any feature that the user activates by clicking.

  ## When to use

  Use `toggle/1` when:
  - The button represents an on/off feature that applies while pressed (e.g. text formatting)
  - The pressed state is visually distinct from the unpressed state
  - You need the `aria-pressed` semantics that `button[aria-pressed]` provides

  Use `switch/1` instead for binary settings (on/off configurations that persist),
  and `toggle_group/1` when multiple toggles need to coordinate as a single or
  multi-select group.

  ## State ownership

  State is owned by the server — pass `:pressed` from your LiveView assigns and
  update it on the server via `phx-click`. For purely client-side toggling without
  a server round-trip, wire `Phoenix.LiveView.JS` push/toggle operations:

      <.toggle pressed={@bold} phx-click="toggle_bold">
        <.icon name="bold" size="sm" />
      </.toggle>

  ## Text editor toolbar example

      <div class="flex items-center gap-1 border rounded-md p-1">
        <.toggle pressed={@bold} phx-click="toggle_format" phx-value-format="bold">
          <.icon name="bold" size="sm" />
        </.toggle>
        <.toggle pressed={@italic} phx-click="toggle_format" phx-value-format="italic">
          <.icon name="italic" size="sm" />
        </.toggle>
        <.toggle pressed={@underline} phx-click="toggle_format" phx-value-format="underline">
          <.icon name="underline" size="sm" />
        </.toggle>
      </div>

  ## Filter tag example

      <div class="flex flex-wrap gap-2">
        <.toggle
          :for={tag <- @available_tags}
          pressed={tag in @active_tags}
          phx-click="toggle_tag"
          phx-value-tag={tag}
          variant="outline"
          size="sm"
        >
          {tag}
        </.toggle>
      </div>

  ## Variants

  - `"default"` — ghost-like, transparent background, switches to `bg-accent` when pressed
  - `"outline"` — shows a `border-input` border, switches to `bg-accent` when pressed

  ## Sizes

  - `"sm"` — `h-9 px-2.5 text-xs`, compact for toolbars
  - `"default"` — `h-10 px-3`, standard size
  - `"lg"` — `h-11 px-5`, larger click target

  ## Accessibility

  - `aria-pressed="true"` / `"false"` reflects the current state to screen readers
  - Focus ring (`focus-visible:ring-2`) ensures keyboard navigability
  - `disabled` attribute prevents interaction and sets `pointer-events-none`
  - Content (slot) should include descriptive text or an icon with `aria-label`
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  attr(:pressed, :boolean,
    required: true,
    doc: """
    Whether the toggle is in the pressed (active) state. Controls the visual
    appearance and the `aria-pressed` attribute. Pass a boolean from your
    LiveView assigns and update it via a `phx-click` event handler.
    """
  )

  attr(:variant, :string,
    default: "default",
    values: ~w(default outline),
    doc: """
    Visual style of the toggle button:
    - `"default"` — ghost-like with transparent background. On press: `bg-accent`
    - `"outline"` — shows a `border-input` border. On press: `bg-accent` with border
    """
  )

  attr(:size, :string,
    default: "default",
    values: ~w(default sm lg),
    doc: """
    Size of the toggle button. Controls height and horizontal padding:
    - `"sm"` — `h-9 px-2.5 text-xs` (compact, ideal for toolbars)
    - `"default"` — `h-10 px-3` (standard)
    - `"lg"` — `h-11 px-5` (larger click target)
    """
  )

  attr(:class, :string,
    default: nil,
    doc: """
    Additional CSS classes applied to the `<button>` element via `cn/1`.
    Last-wins merge means your classes override the size/variant defaults.
    """
  )

  attr(:rest, :global,
    include: ~w(disabled form name value type phx-click phx-value),
    doc: """
    HTML attributes forwarded to the `<button>` element. Commonly used:
    - `phx-click` — LiveView event name to handle the toggle
    - `phx-value-*` — additional context passed with the event (e.g. `phx-value-format="bold"`)
    - `disabled` — disables the button
    """
  )

  slot(:inner_block,
    required: true,
    doc: """
    The content of the toggle button — typically an icon or short text label.
    For icon-only toggles, add `aria-label` via `:rest` to describe the action
    for screen readers.
    """
  )

  @doc """
  Renders a pressable toggle button with `aria-pressed` state.

  The `<button>` receives `type="button"` to prevent accidental form submission.
  Visual state is communicated via background colour change (variant-controlled)
  in addition to the `aria-pressed` attribute for screen readers.

  ## Examples

      <%!-- Icon toggle in a toolbar --%>
      <.toggle pressed={@bold} phx-click="toggle_bold">
        <.icon name="bold" size="sm" />
      </.toggle>

      <%!-- Text toggle --%>
      <.toggle pressed={@active} phx-click="toggle">
        Compact view
      </.toggle>

      <%!-- Outline variant --%>
      <.toggle pressed={@italic} variant="outline" phx-click="toggle_italic">
        <.icon name="italic" size="sm" />
      </.toggle>

      <%!-- Small toolbar toggle with aria-label --%>
      <.toggle pressed={@underline} size="sm" phx-click="toggle_underline" aria-label="Underline">
        <.icon name="underline" size="sm" />
      </.toggle>

      <%!-- Disabled --%>
      <.toggle pressed={false} disabled>
        Unavailable
      </.toggle>

      <%!-- Filter tag pattern --%>
      <.toggle
        pressed={"elixir" in @selected_tags}
        phx-click="toggle_tag"
        phx-value-tag="elixir"
        variant="outline"
        size="sm"
      >
        Elixir
      </.toggle>
  """
  def toggle(assigns) do
    ~H"""
    <button
      type="button"
      aria-pressed={to_string(@pressed)}
      class={cn([base_class(), variant_class(@variant, @pressed), size_class(@size), @class])}
      {@rest}
    >
      {render_slot(@inner_block)}
    </button>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  # Shared structural classes applied to every toggle regardless of variant/size.
  # Defined as a function for consistency with other helpers (avoids module attributes).
  defp base_class do
    "inline-flex items-center justify-center rounded-md text-sm font-medium " <>
      "transition-colors focus-visible:outline-none focus-visible:ring-2 " <>
      "focus-visible:ring-ring focus-visible:ring-offset-2 " <>
      "disabled:pointer-events-none disabled:opacity-50"
  end

  # Four-clause match for the full variant × pressed matrix.
  # Pattern matching on two booleans is more explicit than nested ifs and
  # makes each visual state easy to locate and adjust independently.
  defp variant_class("default", false),
    do: "bg-transparent hover:bg-muted hover:text-muted-foreground"

  defp variant_class("default", true), do: "bg-accent text-accent-foreground"

  defp variant_class("outline", false),
    do: "border border-input bg-transparent hover:bg-accent hover:text-accent-foreground"

  defp variant_class("outline", true), do: "border border-input bg-accent text-accent-foreground"

  # Three size options covering compact toolbar (sm), standard (default), and
  # large click target (lg). Values mirror shadcn/ui sizing conventions.
  defp size_class("default"), do: "h-10 px-3"
  defp size_class("sm"), do: "h-9 px-2.5 text-xs"
  defp size_class("lg"), do: "h-11 px-5"
end
