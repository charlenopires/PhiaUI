defmodule PhiaUi.Components.Editor.Blocks do
  @moduledoc """
  Editor Block Components — 9 structural block primitives for rich text editors.

  These components provide the building blocks for content structuring inside an
  editor: task lists, callouts, collapsible sections, column layouts, breaks,
  styled blockquotes, and decorative horizontal rules.

  All components render meaningful HTML without JavaScript (progressive enhancement)
  and support dark mode via Tailwind v4 design tokens.

  ## Components

  ### Content Blocks
  - `task_list/1`            — checklist with interactive checkboxes
  - `callout_block/1`        — colored callout box with icon (info/warning/tip/error/note)
  - `collapsible_section/1`  — HTML `<details>/<summary>` disclosure widget
  - `columns_layout/1`       — CSS grid multi-column layout
  - `details_block/1`        — lightweight `<details>/<summary>` block

  ### Separators & Breaks
  - `page_break/1`           — dashed print-oriented page break indicator
  - `section_break/1`        — themed HR variants (line/space/ornament/dashed/dotted)

  ### Styled Text Blocks
  - `block_quote_styled/1`   — blockquote with variant styles (default/border/modern/pull)
  - `horizontal_rule_styled/1` — decorative HR (solid/dashed/dotted/ornament/gradient/fade)
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  # ============================================================================
  # 1. task_list/1
  # ============================================================================

  attr :id, :string, required: true
  attr :items, :list, default: []
  attr :class, :string, default: nil

  @doc """
  Renders a task list with interactive checkboxes.

  Each item in the `:items` list should be a map with `:text` (string) and
  `:checked` (boolean) keys.

  ## Example

      <.task_list id="tasks" items={[
        %{text: "Write tests", checked: true},
        %{text: "Update docs", checked: false}
      ]} />
  """
  def task_list(assigns) do
    ~H"""
    <ul
      id={@id}
      data-type="taskList"
      role="list"
      aria-label="Task list"
      class={cn(["space-y-1", @class])}
    >
      <li
        :for={{item, idx} <- Enum.with_index(@items)}
        data-type="taskItem"
        data-checked={to_string(Map.get(item, :checked, false))}
        class="flex items-start gap-2 rounded-md px-1 py-0.5"
      >
        <label class="flex items-start gap-2 cursor-pointer select-none w-full group/task">
          <input
            type="checkbox"
            checked={Map.get(item, :checked, false)}
            name={"#{@id}-task-#{idx}"}
            aria-label={Map.get(item, :text, "")}
            class={cn([
              "mt-1 h-4 w-4 shrink-0 rounded border border-input bg-background",
              "checked:bg-primary checked:border-primary",
              "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2",
              "accent-primary"
            ])}
          />
          <span class={cn([
            "text-sm leading-relaxed text-foreground",
            Map.get(item, :checked, false) && "line-through text-muted-foreground"
          ])}>
            {Map.get(item, :text, "")}
          </span>
        </label>
      </li>
    </ul>
    """
  end

  # ============================================================================
  # 2. callout_block/1
  # ============================================================================

  attr :id, :string, required: true

  attr :variant, :atom,
    default: :info,
    values: [:info, :warning, :tip, :error, :note]

  attr :icon, :string, default: nil
  attr :class, :string, default: nil
  attr :rest, :global

  slot :inner_block, required: true

  @doc """
  Renders a colored callout block with an optional icon.

  Variants map to semantic color schemes:
  - `:info`    — blue tones
  - `:warning` — amber tones
  - `:tip`     — green tones
  - `:error`   — red tones
  - `:note`    — muted/neutral tones

  ## Example

      <.callout_block id="note-1" variant={:warning} icon="alert-triangle">
        This action cannot be undone.
      </.callout_block>
  """
  def callout_block(assigns) do
    ~H"""
    <div
      id={@id}
      role="note"
      aria-label={callout_aria_label(@variant)}
      class={cn([
        "flex gap-3 rounded-lg border p-4",
        callout_colors(@variant),
        @class
      ])}
      {@rest}
    >
      <div :if={@icon} class={cn(["mt-0.5 shrink-0", callout_icon_color(@variant)])}>
        <span class="text-base" aria-hidden="true">{@icon}</span>
      </div>
      <div :if={!@icon} class={cn(["mt-0.5 shrink-0", callout_icon_color(@variant)])}>
        {callout_default_icon(assigns)}
      </div>
      <div class="min-w-0 flex-1 text-sm leading-relaxed">
        {render_slot(@inner_block)}
      </div>
    </div>
    """
  end

  defp callout_colors(:info), do: "bg-blue-50 border-blue-200 text-blue-900 dark:bg-blue-950/50 dark:border-blue-800 dark:text-blue-100"
  defp callout_colors(:warning), do: "bg-amber-50 border-amber-200 text-amber-900 dark:bg-amber-950/50 dark:border-amber-800 dark:text-amber-100"
  defp callout_colors(:tip), do: "bg-green-50 border-green-200 text-green-900 dark:bg-green-950/50 dark:border-green-800 dark:text-green-100"
  defp callout_colors(:error), do: "bg-red-50 border-red-200 text-red-900 dark:bg-red-950/50 dark:border-red-800 dark:text-red-100"
  defp callout_colors(:note), do: "bg-muted border-border text-foreground"

  defp callout_icon_color(:info), do: "text-blue-600 dark:text-blue-400"
  defp callout_icon_color(:warning), do: "text-amber-600 dark:text-amber-400"
  defp callout_icon_color(:tip), do: "text-green-600 dark:text-green-400"
  defp callout_icon_color(:error), do: "text-red-600 dark:text-red-400"
  defp callout_icon_color(:note), do: "text-muted-foreground"

  defp callout_aria_label(:info), do: "Information"
  defp callout_aria_label(:warning), do: "Warning"
  defp callout_aria_label(:tip), do: "Tip"
  defp callout_aria_label(:error), do: "Error"
  defp callout_aria_label(:note), do: "Note"

  defp callout_default_icon(%{variant: :info} = assigns) do
    ~H"""
    <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
      <circle cx="12" cy="12" r="10" /><path d="M12 16v-4" /><path d="M12 8h.01" />
    </svg>
    """
  end

  defp callout_default_icon(%{variant: :warning} = assigns) do
    ~H"""
    <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
      <path d="m21.73 18-8-14a2 2 0 0 0-3.48 0l-8 14A2 2 0 0 0 4 21h16a2 2 0 0 0 1.73-3Z" /><path d="M12 9v4" /><path d="M12 17h.01" />
    </svg>
    """
  end

  defp callout_default_icon(%{variant: :tip} = assigns) do
    ~H"""
    <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
      <path d="M15 14c.2-1 .7-1.7 1.5-2.5 1-.9 1.5-2.2 1.5-3.5A6 6 0 0 0 6 8c0 1 .2 2.2 1.5 3.5.7.7 1.3 1.5 1.5 2.5" /><path d="M9 18h6" /><path d="M10 22h4" />
    </svg>
    """
  end

  defp callout_default_icon(%{variant: :error} = assigns) do
    ~H"""
    <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
      <circle cx="12" cy="12" r="10" /><path d="m15 9-6 6" /><path d="m9 9 6 6" />
    </svg>
    """
  end

  defp callout_default_icon(%{variant: :note} = assigns) do
    ~H"""
    <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
      <path d="M12 20h9" /><path d="M16.376 3.622a1 1 0 0 1 3.002 3.002L7.368 18.635a2 2 0 0 1-.855.506l-2.872.838a.5.5 0 0 1-.62-.62l.838-2.872a2 2 0 0 1 .506-.855z" />
    </svg>
    """
  end

  # ============================================================================
  # 3. collapsible_section/1
  # ============================================================================

  attr :id, :string, required: true
  attr :summary, :string, default: "Details"
  attr :open, :boolean, default: false
  attr :class, :string, default: nil

  slot :inner_block, required: true

  @doc """
  Renders a collapsible disclosure section using native HTML `<details>/<summary>`.

  The browser handles open/close without JavaScript.

  ## Example

      <.collapsible_section id="faq-1" summary="What is PhiaUI?" open={true}>
        PhiaUI is an Elixir component library for Phoenix LiveView.
      </.collapsible_section>
  """
  def collapsible_section(assigns) do
    ~H"""
    <details
      id={@id}
      open={@open}
      class={cn([
        "group rounded-lg border border-border bg-background",
        @class
      ])}
    >
      <summary class={cn([
        "flex cursor-pointer select-none items-center gap-2 px-4 py-3",
        "text-sm font-medium text-foreground",
        "hover:bg-accent/50 transition-colors",
        "[&::-webkit-details-marker]:hidden list-none"
      ])}>
        <svg
          xmlns="http://www.w3.org/2000/svg"
          width="16"
          height="16"
          viewBox="0 0 24 24"
          fill="none"
          stroke="currentColor"
          stroke-width="2"
          stroke-linecap="round"
          stroke-linejoin="round"
          aria-hidden="true"
          class="shrink-0 text-muted-foreground transition-transform duration-200 group-open:rotate-90"
        >
          <path d="m9 18 6-6-6-6" />
        </svg>
        <span>{@summary}</span>
      </summary>
      <div class="px-4 pb-4 pt-2 text-sm leading-relaxed text-foreground">
        {render_slot(@inner_block)}
      </div>
    </details>
    """
  end

  # ============================================================================
  # 4. columns_layout/1
  # ============================================================================

  attr :id, :string, required: true
  attr :columns, :integer, default: 2
  attr :gap, :string, default: "1rem"
  attr :class, :string, default: nil

  slot :column

  @doc """
  Renders a CSS grid multi-column layout for side-by-side content blocks.

  Use the `:column` slot (repeatable) to provide individual column content.
  The number of visual columns is controlled by the `:columns` attribute.

  ## Example

      <.columns_layout id="two-cols" columns={2}>
        <:column>Left content</:column>
        <:column>Right content</:column>
      </.columns_layout>
  """
  def columns_layout(assigns) do
    ~H"""
    <div
      id={@id}
      role="presentation"
      class={cn(["grid w-full", @class])}
      style={"grid-template-columns: repeat(#{@columns}, 1fr); gap: #{@gap};"}
    >
      <div
        :for={col <- @column}
        class="min-w-0"
      >
        {render_slot(col)}
      </div>
    </div>
    """
  end

  # ============================================================================
  # 5. page_break/1
  # ============================================================================

  attr :class, :string, default: nil

  @doc """
  Renders a visual page break indicator with a dashed line and centered label.

  Intended for print-oriented documents. In `@media print`, this element triggers
  a CSS page break.

  ## Example

      <.page_break />
  """
  def page_break(assigns) do
    ~H"""
    <div
      role="separator"
      aria-label="Page break"
      class={cn([
        "relative my-8 flex items-center justify-center",
        "before:absolute before:inset-x-0 before:top-1/2 before:h-px before:border-t before:border-dashed before:border-muted-foreground/40",
        "print:break-after-page",
        @class
      ])}
    >
      <span class="relative z-10 bg-background px-3 py-1 text-xs font-medium uppercase tracking-widest text-muted-foreground">
        Page Break
      </span>
    </div>
    """
  end

  # ============================================================================
  # 6. section_break/1
  # ============================================================================

  attr :variant, :atom,
    default: :line,
    values: [:line, :space, :ornament, :dashed, :dotted]

  attr :class, :string, default: nil

  @doc """
  Renders a section break/divider with different visual styles.

  Variants:
  - `:line`     — solid thin rule
  - `:space`    — blank vertical space (no visible element)
  - `:ornament` — centered decorative ornament (three dots)
  - `:dashed`   — dashed horizontal rule
  - `:dotted`   — dotted horizontal rule

  ## Example

      <.section_break variant={:ornament} />
      <.section_break variant={:dashed} />
  """
  def section_break(assigns) do
    ~H"""
    <div
      :if={@variant == :space}
      role="separator"
      aria-hidden="true"
      class={cn(["my-8", @class])}
    />
    <hr
      :if={@variant == :line}
      role="separator"
      class={cn(["my-8 border-t border-border", @class])}
    />
    <hr
      :if={@variant == :dashed}
      role="separator"
      class={cn(["my-8 border-t border-dashed border-muted-foreground/40", @class])}
    />
    <hr
      :if={@variant == :dotted}
      role="separator"
      class={cn(["my-8 border-t border-dotted border-muted-foreground/40", @class])}
    />
    <div
      :if={@variant == :ornament}
      role="separator"
      aria-hidden="true"
      class={cn(["my-8 flex items-center justify-center gap-2 text-muted-foreground", @class])}
    >
      <span class="h-1 w-1 rounded-full bg-current" />
      <span class="h-1.5 w-1.5 rounded-full bg-current" />
      <span class="h-1 w-1 rounded-full bg-current" />
    </div>
    """
  end

  # ============================================================================
  # 7. details_block/1
  # ============================================================================

  attr :id, :string, required: true
  attr :summary, :string, required: true
  attr :open, :boolean, default: false
  attr :class, :string, default: nil

  slot :inner_block, required: true

  @doc """
  Renders a lightweight `<details>/<summary>` block for inline disclosures.

  Similar to `collapsible_section/1` but with a simpler, borderless style suitable
  for embedding within prose or editor content.

  ## Example

      <.details_block id="note-1" summary="Click to expand">
        Hidden content revealed on click.
      </.details_block>
  """
  def details_block(assigns) do
    ~H"""
    <details
      id={@id}
      open={@open}
      class={cn(["group", @class])}
    >
      <summary class={cn([
        "flex cursor-pointer select-none items-center gap-1.5",
        "text-sm font-medium text-foreground",
        "hover:text-primary transition-colors",
        "[&::-webkit-details-marker]:hidden list-none"
      ])}>
        <svg
          xmlns="http://www.w3.org/2000/svg"
          width="14"
          height="14"
          viewBox="0 0 24 24"
          fill="none"
          stroke="currentColor"
          stroke-width="2"
          stroke-linecap="round"
          stroke-linejoin="round"
          aria-hidden="true"
          class="shrink-0 text-muted-foreground transition-transform duration-200 group-open:rotate-90"
        >
          <path d="m9 18 6-6-6-6" />
        </svg>
        <span>{@summary}</span>
      </summary>
      <div class="ml-5 mt-1.5 text-sm leading-relaxed text-muted-foreground">
        {render_slot(@inner_block)}
      </div>
    </details>
    """
  end

  # ============================================================================
  # 8. block_quote_styled/1
  # ============================================================================

  attr :variant, :atom,
    default: :default,
    values: [:default, :border, :modern, :pull]

  attr :citation, :string, default: nil
  attr :class, :string, default: nil

  slot :inner_block, required: true

  @doc """
  Renders a styled blockquote with variant visual treatments.

  Variants:
  - `:default` — left border accent with subtle background
  - `:border`  — thick left border, no background
  - `:modern`  — large decorative quotation mark
  - `:pull`    — centered pull-quote with large italic text

  ## Example

      <.block_quote_styled variant={:modern} citation="Alan Kay">
        The best way to predict the future is to invent it.
      </.block_quote_styled>
  """
  def block_quote_styled(assigns) do
    ~H"""
    <figure class={cn(["my-6", @class])}>
      <blockquote
        :if={@variant == :default}
        class="rounded-r-lg border-l-4 border-primary bg-muted/50 py-3 pl-4 pr-4 text-sm italic leading-relaxed text-foreground"
      >
        {render_slot(@inner_block)}
      </blockquote>

      <blockquote
        :if={@variant == :border}
        class="border-l-4 border-muted-foreground/30 py-2 pl-4 text-sm italic leading-relaxed text-foreground"
      >
        {render_slot(@inner_block)}
      </blockquote>

      <blockquote
        :if={@variant == :modern}
        class="relative py-4 pl-10 text-sm leading-relaxed text-foreground"
      >
        <svg
          xmlns="http://www.w3.org/2000/svg"
          width="32"
          height="32"
          viewBox="0 0 24 24"
          fill="currentColor"
          aria-hidden="true"
          class="absolute left-0 top-2 text-primary/20"
        >
          <path d="M14.017 21v-7.391c0-5.704 3.731-9.57 8.983-10.609l.995 2.151c-2.432.917-3.995 3.638-3.995 5.849h4v10h-9.983zm-14.017 0v-7.391c0-5.704 3.748-9.57 9-10.609l.996 2.151c-2.433.917-3.996 3.638-3.996 5.849h3.983v10h-9.983z" />
        </svg>
        <div class="relative">
          {render_slot(@inner_block)}
        </div>
      </blockquote>

      <blockquote
        :if={@variant == :pull}
        class="border-y border-border py-6 text-center text-lg font-medium italic leading-relaxed text-foreground"
      >
        {render_slot(@inner_block)}
      </blockquote>

      <figcaption
        :if={@citation}
        class={cn([
          "mt-2 text-xs text-muted-foreground",
          @variant == :pull && "text-center",
          @variant == :modern && "pl-10"
        ])}
      >
        &mdash; {@citation}
      </figcaption>
    </figure>
    """
  end

  # ============================================================================
  # 9. horizontal_rule_styled/1
  # ============================================================================

  attr :variant, :atom,
    default: :solid,
    values: [:solid, :dashed, :dotted, :ornament, :gradient, :fade]

  attr :class, :string, default: nil

  @doc """
  Renders a decorative horizontal rule with variant visual styles.

  Variants:
  - `:solid`    — standard solid line
  - `:dashed`   — dashed line
  - `:dotted`   — dotted line
  - `:ornament` — centered diamond ornament
  - `:gradient` — gradient line fading from edges
  - `:fade`     — line that fades from center to transparent

  ## Example

      <.horizontal_rule_styled variant={:gradient} />
      <.horizontal_rule_styled variant={:ornament} />
  """
  def horizontal_rule_styled(assigns) do
    ~H"""
    <hr
      :if={@variant == :solid}
      role="separator"
      class={cn(["my-6 border-t border-border", @class])}
    />
    <hr
      :if={@variant == :dashed}
      role="separator"
      class={cn(["my-6 border-t border-dashed border-border", @class])}
    />
    <hr
      :if={@variant == :dotted}
      role="separator"
      class={cn(["my-6 border-t border-dotted border-border", @class])}
    />
    <div
      :if={@variant == :ornament}
      role="separator"
      aria-hidden="true"
      class={cn([
        "my-6 flex items-center justify-center",
        @class
      ])}
    >
      <span class="h-px flex-1 bg-border" />
      <svg
        xmlns="http://www.w3.org/2000/svg"
        width="12"
        height="12"
        viewBox="0 0 24 24"
        fill="currentColor"
        aria-hidden="true"
        class="mx-3 text-muted-foreground"
      >
        <path d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z" />
      </svg>
      <span class="h-px flex-1 bg-border" />
    </div>
    <div
      :if={@variant == :gradient}
      role="separator"
      aria-hidden="true"
      class={cn(["my-6", @class])}
    >
      <div
        class="h-px w-full"
        style="background: linear-gradient(to right, transparent, var(--color-border) 20%, var(--color-border) 80%, transparent);"
      />
    </div>
    <div
      :if={@variant == :fade}
      role="separator"
      aria-hidden="true"
      class={cn(["my-6", @class])}
    >
      <div
        class="mx-auto h-px w-3/4"
        style="background: radial-gradient(ellipse at center, var(--color-border) 0%, transparent 70%);"
      />
    </div>
    """
  end
end
