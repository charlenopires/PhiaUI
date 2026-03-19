defmodule PhiaUi.Components.Editor.TextDirection do
  @moduledoc """
  Text Direction Suite — 2 components for bidirectional (BiDi) text support
  in the PhiaUI rich text editor.

  Provides LTR/RTL/Auto toggling and explicit directional block wrappers,
  enabling proper bidirectional content editing for mixed-language documents.

  ## Components

  - `text_direction_toggle/1` — segmented button group for LTR / RTL / Auto direction
  - `bidi_text_block/1`       — block wrapper with explicit `dir` attribute for directional content

  ## Example

      <.text_direction_toggle id="dir-toggle" value={@text_direction} />

      <.bidi_text_block id="rtl-para" direction={:rtl}>
        <p>Arabic or Hebrew text here</p>
      </.bidi_text_block>
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  # ============================================================================
  # 1. text_direction_toggle/1
  # ============================================================================

  @directions [:ltr, :rtl, :auto]

  attr :id, :string, required: true, doc: "Unique identifier for the toggle group."
  attr :value, :atom, default: :ltr, values: @directions, doc: "Currently active direction."
  attr :class, :string, default: nil, doc: "Additional CSS classes for the container."
  attr :rest, :global

  @doc """
  Renders a segmented button group for switching between LTR, RTL, and Auto
  text directions.

  The active button is highlighted with primary styling. Each button emits a
  `"text-direction:change"` event with a `direction` value.

  Uses `role="radiogroup"` with individual `role="radio"` buttons and proper
  `aria-checked` state for screen reader accessibility.

  ## Example

      <.text_direction_toggle id="dir-toggle" value={:ltr} />
      <.text_direction_toggle id="dir-toggle" value={:rtl} />
  """
  def text_direction_toggle(assigns) do
    ~H"""
    <div
      id={@id}
      role="radiogroup"
      aria-label="Text direction"
      class={cn([
        "inline-flex h-8 items-center rounded-md border border-border bg-muted p-0.5",
        @class
      ])}
      {@rest}
    >
      <%!-- LTR button --%>
      <button
        type="button"
        role="radio"
        aria-checked={to_string(@value == :ltr)}
        aria-label="Left to right"
        title="Left to right (LTR)"
        phx-click="text-direction:change"
        phx-value-direction="ltr"
        class={cn([
          toggle_btn_class(),
          @value == :ltr && "bg-primary text-primary-foreground shadow-sm"
        ])}
      >
        <svg
          class="h-3.5 w-3.5"
          viewBox="0 0 24 24"
          fill="none"
          stroke="currentColor"
          stroke-width="2"
          stroke-linecap="round"
          stroke-linejoin="round"
          aria-hidden="true"
        >
          <line x1="3" y1="6" x2="21" y2="6" />
          <line x1="3" y1="12" x2="18" y2="12" />
          <line x1="3" y1="18" x2="15" y2="18" />
        </svg>
      </button>

      <%!-- RTL button --%>
      <button
        type="button"
        role="radio"
        aria-checked={to_string(@value == :rtl)}
        aria-label="Right to left"
        title="Right to left (RTL)"
        phx-click="text-direction:change"
        phx-value-direction="rtl"
        class={cn([
          toggle_btn_class(),
          @value == :rtl && "bg-primary text-primary-foreground shadow-sm"
        ])}
      >
        <svg
          class="h-3.5 w-3.5"
          viewBox="0 0 24 24"
          fill="none"
          stroke="currentColor"
          stroke-width="2"
          stroke-linecap="round"
          stroke-linejoin="round"
          aria-hidden="true"
        >
          <line x1="3" y1="6" x2="21" y2="6" />
          <line x1="6" y1="12" x2="21" y2="12" />
          <line x1="9" y1="18" x2="21" y2="18" />
        </svg>
      </button>

      <%!-- Auto button --%>
      <button
        type="button"
        role="radio"
        aria-checked={to_string(@value == :auto)}
        aria-label="Auto detect direction"
        title="Auto detect direction"
        phx-click="text-direction:change"
        phx-value-direction="auto"
        class={cn([
          toggle_btn_class(),
          @value == :auto && "bg-primary text-primary-foreground shadow-sm"
        ])}
      >
        <span class="text-xs font-semibold leading-none">A</span>
      </button>
    </div>
    """
  end

  defp toggle_btn_class do
    cn([
      "inline-flex h-7 w-7 items-center justify-center rounded-sm text-xs transition-colors",
      "text-muted-foreground hover:text-foreground",
      "focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring"
    ])
  end

  # ============================================================================
  # 2. bidi_text_block/1
  # ============================================================================

  attr :id, :string, required: true, doc: "Unique identifier for the block."

  attr :direction, :atom,
    default: :auto,
    values: @directions,
    doc: "Explicit text direction for the block content."

  attr :class, :string, default: nil, doc: "Additional CSS classes for the container."
  attr :rest, :global

  slot :inner_block, required: true, doc: "Block content that should follow the specified direction."

  @doc """
  Renders a block-level wrapper with an explicit HTML `dir` attribute for
  bidirectional text support.

  Sets the appropriate `dir` attribute (`"ltr"`, `"rtl"`, or `"auto"`) on the
  container `<div>`. When `:rtl` is active, the block receives `text-right`
  alignment. When `:auto`, the browser uses `unicode-bidi: plaintext` to infer
  direction from content.

  ## Example

      <.bidi_text_block id="arabic-block" direction={:rtl}>
        <p>Some right-to-left content here.</p>
      </.bidi_text_block>

      <.bidi_text_block id="mixed-block" direction={:auto}>
        <p>Content where direction is auto-detected.</p>
      </.bidi_text_block>
  """
  def bidi_text_block(assigns) do
    ~H"""
    <div
      id={@id}
      dir={direction_attr(@direction)}
      data-type="bidiBlock"
      data-direction={to_string(@direction)}
      class={cn([
        "relative min-h-[1.5em]",
        @direction == :rtl && "text-right",
        @class
      ])}
      style={if @direction == :auto, do: "unicode-bidi: plaintext;", else: nil}
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end

  # ── Helpers ──────────────────────────────────────────────────────────────────

  defp direction_attr(:ltr), do: "ltr"
  defp direction_attr(:rtl), do: "rtl"
  defp direction_attr(:auto), do: "auto"
  defp direction_attr(_), do: "auto"
end
