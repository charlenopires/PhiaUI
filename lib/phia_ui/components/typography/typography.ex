defmodule PhiaUi.Components.Typography do
  @moduledoc """
  Typography primitives for PhiaUI — 18 components covering headings, text,
  code, lists, and prose containers.

  All components use system fonts (`font-sans` / `font-mono`) — no Google Fonts.
  Max weight is `font-semibold`; max line-height is `leading-relaxed`.

  ## Components

  - `heading/1` — h1–h6 with semantic level prop
  - `display/1` — large hero text (5xl–7xl)
  - `text/1` — polymorphic inline/block text atom (span/p/div/label)
  - `paragraph/1` — body paragraph with typographic rhythm
  - `lead/1` — introductory lead paragraph
  - `blockquote/1` — styled blockquote with optional cite
  - `inline_code/1` — inline monospace code span
  - `code_block/1` — multi-line code block with optional language label
  - `mark/1` — highlighted mark element
  - `text_link/1` — semantic anchor with hover styles
  - `overline/1` — uppercase tracking-widest label
  - `caption/1` — figure caption or muted annotation
  - `abbr/1` — abbreviation with browser tooltip
  - `prose_list/1` — unordered list with variant styles
  - `ordered_list/1` — ordered list with variant styles
  - `gradient_text/1` — gradient-clipped text span
  - `truncated_text/1` — line-clamped paragraph
  - `prose/1` — article container with child element rhythm
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  # ---------------------------------------------------------------------------
  # 1. heading/1
  # ---------------------------------------------------------------------------

  attr :level, :integer, values: [1, 2, 3, 4, 5, 6], default: 2,
    doc: "Semantic heading level (1–6). Determines both the HTML element and default size."

  attr :size, :atom, values: [:auto, :xs, :sm, :base, :lg, :xl, :"2xl", :"3xl", :"4xl"],
    default: :auto,
    doc: "Override the text size. `:auto` uses level-specific defaults."

  attr :align, :atom, values: [:start, :center, :end], default: :start,
    doc: "Text alignment."

  attr :tracking, :atom, values: [:tight, :normal, :wide], default: :tight,
    doc: "Letter spacing."

  attr :fluid, :boolean, default: false,
    doc: "When true, uses CSS custom property fluid font sizes that scale with viewport."

  attr :class, :string, default: nil
  attr :rest, :global

  slot :inner_block, required: true

  @doc """
  Renders a semantic heading (`<h1>`–`<h6>`) with automatic sizing per level.

  ## Examples

      <.heading level={1}>Page Title</.heading>
      <.heading level={2} align={:center}>Section</.heading>
      <.heading level={3} size={:"2xl"}>Custom Size</.heading>
      <.heading level={1} fluid={true}>Fluid Title</.heading>
  """
  def heading(assigns) do
    render_heading(assigns)
  end

  # ---------------------------------------------------------------------------
  # 2. display/1
  # ---------------------------------------------------------------------------

  attr :size, :atom, values: [:"5xl", :"6xl", :"7xl"], default: :"5xl",
    doc: "Hero text size. 5xl=3rem, 6xl=3.75rem, 7xl=4.5rem."

  attr :align, :atom, values: [:start, :center, :end], default: :start
  attr :weight, :atom, values: [:normal, :medium, :semibold], default: :semibold

  attr :fluid, :boolean, default: false,
    doc: "When true, uses CSS custom property fluid font sizes that scale with viewport."

  attr :class, :string, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  @doc """
  Renders large hero/display text beyond the standard heading scale.

  ## Examples

      <.display size={:"6xl"} align={:center}>Welcome</.display>
      <.display fluid={true}>Fluid Hero</.display>
  """
  def display(assigns) do
    size_class = if assigns.fluid, do: fluid_display_size_class(assigns.size), else: display_size_class(assigns.size)
    assigns = assign(assigns, :resolved_size_class, size_class)

    ~H"""
    <p class={cn(["leading-none tracking-tight", @resolved_size_class, align_class(@align), weight_class(@weight), @class])} {@rest}>
      {render_slot(@inner_block)}
    </p>
    """
  end

  # ---------------------------------------------------------------------------
  # 3. text/1
  # ---------------------------------------------------------------------------

  attr :as, :atom, values: [:span, :p, :div, :label], default: :span,
    doc: "HTML element to render."

  attr :size, :atom, values: [:xs, :sm, :base, :lg, :xl], default: :sm
  attr :weight, :atom, values: [:normal, :medium, :semibold], default: :normal
  attr :color, :atom, values: [:default, :muted, :primary, :destructive], default: :default
  attr :align, :atom, values: [:start, :center, :end], default: :start
  attr :truncate, :boolean, default: false
  attr :italic, :boolean, default: false
  attr :underline, :boolean, default: false
  attr :strikethrough, :boolean, default: false
  attr :class, :string, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  @doc """
  Polymorphic text atom. Renders as `span`, `p`, `div`, or `label`.

  ## Examples

      <.text>Default span</.text>
      <.text as={:p} size={:base} color={:muted}>Muted paragraph</.text>
      <.text as={:label} weight={:semibold}>Form Label</.text>
      <.text truncate={true} class="max-w-xs">Long truncated text</.text>
  """
  def text(assigns) do
    render_text(assigns)
  end

  # ---------------------------------------------------------------------------
  # 4. paragraph/1
  # ---------------------------------------------------------------------------

  attr :size, :atom, values: [:sm, :base, :lg], default: :base

  attr :fluid, :boolean, default: false,
    doc: "When true, uses CSS custom property fluid font sizes that scale with viewport."

  attr :class, :string, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  @doc """
  Renders a body paragraph with typographic rhythm.

  ## Examples

      <.paragraph>First paragraph.</.paragraph>
      <.paragraph size={:lg}>Large paragraph.</.paragraph>
      <.paragraph fluid={true}>Fluid paragraph.</.paragraph>
  """
  def paragraph(assigns) do
    size_class = if assigns.fluid, do: fluid_paragraph_size_class(assigns.size), else: paragraph_size_class(assigns.size)
    assigns = assign(assigns, :resolved_size_class, size_class)

    ~H"""
    <p class={cn(["leading-7 [&:not(:first-child)]:mt-6", @resolved_size_class, @class])} {@rest}>
      {render_slot(@inner_block)}
    </p>
    """
  end

  # ---------------------------------------------------------------------------
  # 5. lead/1
  # ---------------------------------------------------------------------------

  attr :class, :string, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  @doc """
  Renders a lead paragraph — larger introductory text above main content.

  ## Examples

      <.lead>An introductory sentence that summarizes the section.</.lead>
  """
  def lead(assigns) do
    ~H"""
    <p class={cn(["text-xl text-muted-foreground leading-relaxed", @class])} {@rest}>
      {render_slot(@inner_block)}
    </p>
    """
  end

  # ---------------------------------------------------------------------------
  # 6. blockquote/1
  # ---------------------------------------------------------------------------

  attr :cite, :string, default: nil,
    doc: "Citation source shown in a <cite> footer below the quote."

  attr :class, :string, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  @doc """
  Renders a styled blockquote with an optional citation footer.

  ## Examples

      <.blockquote>To be or not to be.</.blockquote>
      <.blockquote cite="William Shakespeare">To be or not to be.</.blockquote>
  """
  def blockquote(assigns) do
    ~H"""
    <blockquote class={cn(["mt-6 border-l-4 border-border pl-6 italic text-muted-foreground", @class])} {@rest}>
      {render_slot(@inner_block)}
      <footer :if={@cite} class="mt-2 text-sm not-italic">
        <cite>{@cite}</cite>
      </footer>
    </blockquote>
    """
  end

  # ---------------------------------------------------------------------------
  # 7. inline_code/1
  # ---------------------------------------------------------------------------

  attr :class, :string, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  @doc """
  Renders an inline monospace code span.

  ## Examples

      Use <.inline_code>mix phia.install</.inline_code> to set up.
  """
  def inline_code(assigns) do
    ~H"""
    <code class={cn(["relative rounded-sm bg-muted px-[0.3rem] py-[0.2rem] font-mono text-sm font-semibold", @class])} {@rest}>
      {render_slot(@inner_block)}
    </code>
    """
  end

  # ---------------------------------------------------------------------------
  # 8. code_block/1
  # ---------------------------------------------------------------------------

  attr :language, :string, default: nil,
    doc: "Language label shown as a badge in the top-right corner."

  attr :class, :string, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  @doc """
  Renders a multi-line code block with optional language badge.

  ## Examples

      <.code_block language="elixir">
        def hello, do: :world
      </.code_block>
  """
  def code_block(assigns) do
    ~H"""
    <div class="relative">
      <div :if={@language} class="absolute right-3 top-3 rounded bg-muted px-2 py-0.5 text-xs text-muted-foreground font-mono">
        {@language}
      </div>
      <pre class={cn(["overflow-x-auto rounded-lg border bg-muted p-4", @class])} {@rest}><code class="font-mono text-sm leading-relaxed">{render_slot(@inner_block)}</code></pre>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # 9. mark/1
  # ---------------------------------------------------------------------------

  attr :color, :atom, values: [:default, :yellow, :green, :blue, :red], default: :default,
    doc: "Highlight color. `:default` uses primary/20; others use direct color utilities."

  attr :class, :string, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  @doc """
  Renders a `<mark>` element for highlighted text.

  Note: yellow/green/blue colors use direct Tailwind color utilities (not semantic
  tokens) since no highlight-color semantic tokens exist.

  ## Examples

      <.mark>important</.mark>
      <.mark color={:yellow}>highlighted</.mark>
  """
  def mark(assigns) do
    ~H"""
    <mark class={cn(["rounded-sm px-0.5 text-foreground", mark_color_class(@color), @class])} {@rest}>
      {render_slot(@inner_block)}
    </mark>
    """
  end

  # ---------------------------------------------------------------------------
  # 10. text_link/1
  # ---------------------------------------------------------------------------

  attr :href, :string, required: true
  attr :external, :boolean, default: false,
    doc: "When true, adds target=_blank and rel=noopener noreferrer."

  attr :variant, :atom, values: [:default, :muted], default: :default
  attr :class, :string, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  @doc """
  Renders a semantic anchor with focus and hover styles.

  ## Examples

      <.text_link href="/docs">Documentation</.text_link>
      <.text_link href="https://example.com" external={true}>External</.text_link>
      <.text_link href="/about" variant={:muted}>About</.text_link>
  """
  def text_link(assigns) do
    ~H"""
    <a
      href={@href}
      target={if @external, do: "_blank"}
      rel={if @external, do: "noopener noreferrer"}
      class={cn([link_variant_class(@variant), @class])}
      {@rest}
    >
      {render_slot(@inner_block)}
    </a>
    """
  end

  # ---------------------------------------------------------------------------
  # 11. overline/1
  # ---------------------------------------------------------------------------

  attr :class, :string, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  @doc """
  Renders an uppercase, tracking-widest label for categories or section tags.

  ## Examples

      <.overline>Category</.overline>
  """
  def overline(assigns) do
    ~H"""
    <span class={cn(["text-xs font-semibold uppercase tracking-widest text-muted-foreground", @class])} {@rest}>
      {render_slot(@inner_block)}
    </span>
    """
  end

  # ---------------------------------------------------------------------------
  # 12. caption/1
  # ---------------------------------------------------------------------------

  attr :as, :atom, values: [:figcaption, :span, :p], default: :figcaption,
    doc: "HTML element to render."

  attr :class, :string, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  @doc """
  Renders a caption for figures or images.

  ## Examples

      <figure>
        <img src="/chart.png" alt="Sales chart" />
        <.caption>Figure 1: Monthly sales data</.caption>
      </figure>
  """
  def caption(assigns) do
    render_caption(assigns)
  end

  # ---------------------------------------------------------------------------
  # 13. abbr/1
  # ---------------------------------------------------------------------------

  attr :title, :string, required: true,
    doc: "Full form of the abbreviation, shown as browser tooltip."

  attr :class, :string, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  @doc """
  Renders an `<abbr>` with a dotted underline and browser tooltip.

  ## Examples

      <.abbr title="HyperText Markup Language">HTML</.abbr>
  """
  def abbr(assigns) do
    ~H"""
    <abbr title={@title} class={cn(["cursor-help border-b border-dotted border-muted-foreground", @class])} {@rest}>
      {render_slot(@inner_block)}
    </abbr>
    """
  end

  # ---------------------------------------------------------------------------
  # 14. prose_list/1
  # ---------------------------------------------------------------------------

  attr :variant, :atom, values: [:disc, :circle, :none], default: :disc
  attr :spacing, :atom, values: [:sm, :base], default: :base
  attr :class, :string, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  @doc """
  Renders an unordered list with typographic spacing.

  ## Examples

      <.prose_list>
        <li>First item</li>
        <li>Second item</li>
      </.prose_list>

      <.prose_list variant={:none} spacing={:sm}>
        <li>Compact item</li>
      </.prose_list>
  """
  def prose_list(assigns) do
    ~H"""
    <ul class={cn([ul_variant_class(@variant), list_spacing_class(@spacing), @class])} {@rest}>
      {render_slot(@inner_block)}
    </ul>
    """
  end

  # ---------------------------------------------------------------------------
  # 15. ordered_list/1
  # ---------------------------------------------------------------------------

  attr :variant, :atom, values: [:decimal, :alpha, :roman], default: :decimal
  attr :spacing, :atom, values: [:sm, :base], default: :base
  attr :class, :string, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  @doc """
  Renders an ordered list with typographic spacing.

  ## Examples

      <.ordered_list>
        <li>First step</li>
        <li>Second step</li>
      </.ordered_list>

      <.ordered_list variant={:roman}>
        <li>Part I</li>
      </.ordered_list>
  """
  def ordered_list(assigns) do
    ~H"""
    <ol class={cn([ol_variant_class(@variant), list_spacing_class(@spacing), @class])} {@rest}>
      {render_slot(@inner_block)}
    </ol>
    """
  end

  # ---------------------------------------------------------------------------
  # 16. gradient_text/1
  # ---------------------------------------------------------------------------

  attr :from, :atom, values: [:primary, :secondary, :destructive, :muted], default: :primary
  attr :to, :atom, values: [:primary, :secondary, :destructive, :muted], default: :secondary

  attr :angle, :atom, values: [:r, :l, :t, :b, :tr, :tl, :br, :bl], default: :r,
    doc: "Gradient direction. :r = left-to-right, :tr = bottom-left-to-top-right, etc."

  attr :class, :string, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  @doc """
  Renders gradient-clipped text using `bg-clip-text text-transparent`.

  Must be a `<span>` (inline) for the gradient to render correctly.

  ## Examples

      <.gradient_text>Hello World</.gradient_text>
      <.gradient_text from={:primary} to={:destructive} angle={:tr}>Error</.gradient_text>
  """
  def gradient_text(assigns) do
    ~H"""
    <span class={"bg-clip-text #{cn(["text-transparent inline-block", gradient_angle_class(@angle), gradient_from_class(@from), gradient_to_class(@to), @class])}"} {@rest}>
      {render_slot(@inner_block)}
    </span>
    """
  end

  # ---------------------------------------------------------------------------
  # 17. truncated_text/1
  # ---------------------------------------------------------------------------

  attr :lines, :integer, values: [1, 2, 3, 4, 5, 6], default: 2,
    doc: "Maximum number of lines before overflow is clipped."

  attr :class, :string, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  @doc """
  Renders a paragraph clamped to N lines with overflow ellipsis.

  ## Examples

      <.truncated_text lines={3}>
        Long text that will be clamped to three lines...
      </.truncated_text>
  """
  def truncated_text(assigns) do
    ~H"""
    <p class={cn(["overflow-hidden", line_clamp_class(@lines), @class])} {@rest}>
      {render_slot(@inner_block)}
    </p>
    """
  end

  # ---------------------------------------------------------------------------
  # 18. prose/1
  # ---------------------------------------------------------------------------

  attr :size, :atom, values: [:sm, :base, :lg, :xl], default: :base,
    doc: "Base font size for all child text."

  attr :invert, :boolean, default: false,
    doc: "Reduce text opacity for use on dark or coloured backgrounds."

  attr :class, :string, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  @doc """
  Renders a prose container that applies typographic rhythm to child HTML.

  Uses Tailwind child selectors — no `@tailwindcss/typography` plugin required.

  ## Examples

      <.prose>
        <h1>Article Title</h1>
        <p>Introduction paragraph.</p>
        <h2>Section</h2>
        <p>Section content.</p>
        <ul><li>List item</li></ul>
      </.prose>
  """
  def prose(assigns) do
    ~H"""
    <div class={cn([prose_base_class(), prose_size_class(@size), @invert && "text-foreground/80", @class])} {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  # ===========================================================================
  # Private — render helpers (pattern-matched by tag type)
  # ===========================================================================

  # heading — one clause per level so the correct <hN> element is emitted
  # When @fluid is true, the fluid size class is used instead of the static one.
  defp render_heading(%{level: 1} = assigns) do
    assigns = assign(assigns, :resolved_class, resolve_heading_class(1, assigns.size, assigns.fluid))

    ~H"""
    <h1 class={cn([@resolved_class, align_class(@align), tracking_class(@tracking), @class])} {@rest}>
      {render_slot(@inner_block)}
    </h1>
    """
  end

  defp render_heading(%{level: 2} = assigns) do
    assigns = assign(assigns, :resolved_class, resolve_heading_class(2, assigns.size, assigns.fluid))

    ~H"""
    <h2 class={cn([@resolved_class, align_class(@align), tracking_class(@tracking), @class])} {@rest}>
      {render_slot(@inner_block)}
    </h2>
    """
  end

  defp render_heading(%{level: 3} = assigns) do
    assigns = assign(assigns, :resolved_class, resolve_heading_class(3, assigns.size, assigns.fluid))

    ~H"""
    <h3 class={cn([@resolved_class, align_class(@align), tracking_class(@tracking), @class])} {@rest}>
      {render_slot(@inner_block)}
    </h3>
    """
  end

  defp render_heading(%{level: 4} = assigns) do
    assigns = assign(assigns, :resolved_class, resolve_heading_class(4, assigns.size, assigns.fluid))

    ~H"""
    <h4 class={cn([@resolved_class, align_class(@align), tracking_class(@tracking), @class])} {@rest}>
      {render_slot(@inner_block)}
    </h4>
    """
  end

  defp render_heading(%{level: 5} = assigns) do
    assigns = assign(assigns, :resolved_class, resolve_heading_class(5, assigns.size, assigns.fluid))

    ~H"""
    <h5 class={cn([@resolved_class, align_class(@align), tracking_class(@tracking), @class])} {@rest}>
      {render_slot(@inner_block)}
    </h5>
    """
  end

  defp render_heading(%{level: 6} = assigns) do
    assigns = assign(assigns, :resolved_class, resolve_heading_class(6, assigns.size, assigns.fluid))

    ~H"""
    <h6 class={cn([@resolved_class, align_class(@align), tracking_class(@tracking), @class])} {@rest}>
      {render_slot(@inner_block)}
    </h6>
    """
  end

  # text — one clause per :as value
  defp render_text(%{as: :span} = assigns) do
    ~H"""
    <span class={cn([text_size_class(@size), weight_class(@weight), color_class(@color), align_class(@align), @truncate && "truncate", @italic && "italic", @underline && "underline", @strikethrough && "line-through", @class])} {@rest}>
      {render_slot(@inner_block)}
    </span>
    """
  end

  defp render_text(%{as: :p} = assigns) do
    ~H"""
    <p class={cn([text_size_class(@size), weight_class(@weight), color_class(@color), align_class(@align), @truncate && "truncate", @italic && "italic", @underline && "underline", @strikethrough && "line-through", @class])} {@rest}>
      {render_slot(@inner_block)}
    </p>
    """
  end

  defp render_text(%{as: :div} = assigns) do
    ~H"""
    <div class={cn([text_size_class(@size), weight_class(@weight), color_class(@color), align_class(@align), @truncate && "truncate", @italic && "italic", @underline && "underline", @strikethrough && "line-through", @class])} {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  defp render_text(%{as: :label} = assigns) do
    ~H"""
    <label class={cn([text_size_class(@size), weight_class(@weight), color_class(@color), align_class(@align), @truncate && "truncate", @italic && "italic", @underline && "underline", @strikethrough && "line-through", @class])} {@rest}>
      {render_slot(@inner_block)}
    </label>
    """
  end

  # caption — one clause per :as value
  defp render_caption(%{as: :figcaption} = assigns) do
    ~H"""
    <figcaption class={cn(["text-sm text-muted-foreground leading-normal", @class])} {@rest}>
      {render_slot(@inner_block)}
    </figcaption>
    """
  end

  defp render_caption(%{as: :span} = assigns) do
    ~H"""
    <span class={cn(["text-sm text-muted-foreground leading-normal", @class])} {@rest}>
      {render_slot(@inner_block)}
    </span>
    """
  end

  defp render_caption(%{as: :p} = assigns) do
    ~H"""
    <p class={cn(["text-sm text-muted-foreground leading-normal", @class])} {@rest}>
      {render_slot(@inner_block)}
    </p>
    """
  end

  # ===========================================================================
  # Private — class helpers
  # ===========================================================================

  # heading level + size
  defp heading_level_class(1, :auto), do: "scroll-m-20 text-4xl font-semibold leading-none"
  defp heading_level_class(2, :auto), do: "scroll-m-20 text-3xl font-semibold leading-tight border-b pb-2"
  defp heading_level_class(3, :auto), do: "scroll-m-20 text-2xl font-semibold leading-tight"
  defp heading_level_class(4, :auto), do: "scroll-m-20 text-xl font-semibold leading-tight"
  defp heading_level_class(5, :auto), do: "scroll-m-20 text-lg font-semibold"
  defp heading_level_class(6, :auto), do: "scroll-m-20 text-base font-semibold"
  defp heading_level_class(_, :xs), do: "scroll-m-20 text-xs font-semibold leading-tight"
  defp heading_level_class(_, :sm), do: "scroll-m-20 text-sm font-semibold leading-tight"
  defp heading_level_class(_, :base), do: "scroll-m-20 text-base font-semibold leading-tight"
  defp heading_level_class(_, :lg), do: "scroll-m-20 text-lg font-semibold leading-tight"
  defp heading_level_class(_, :xl), do: "scroll-m-20 text-xl font-semibold leading-tight"
  defp heading_level_class(_, :"2xl"), do: "scroll-m-20 text-2xl font-semibold leading-tight"
  defp heading_level_class(_, :"3xl"), do: "scroll-m-20 text-3xl font-semibold leading-tight"
  defp heading_level_class(_, :"4xl"), do: "scroll-m-20 text-4xl font-semibold leading-tight"

  # resolve heading class — picks fluid or static based on flag
  defp resolve_heading_class(level, size, true = _fluid), do: fluid_heading_level_class(level, size)
  defp resolve_heading_class(level, size, false = _fluid), do: heading_level_class(level, size)

  # fluid heading level + size — mirrors heading_level_class but with fluid tokens
  defp fluid_heading_level_class(1, :auto), do: "scroll-m-20 text-[length:var(--font-size-fluid-4xl)] font-semibold leading-none"
  defp fluid_heading_level_class(2, :auto), do: "scroll-m-20 text-[length:var(--font-size-fluid-3xl)] font-semibold leading-tight border-b pb-2"
  defp fluid_heading_level_class(3, :auto), do: "scroll-m-20 text-[length:var(--font-size-fluid-2xl)] font-semibold leading-tight"
  defp fluid_heading_level_class(4, :auto), do: "scroll-m-20 text-[length:var(--font-size-fluid-xl)] font-semibold leading-tight"
  defp fluid_heading_level_class(5, :auto), do: "scroll-m-20 text-[length:var(--font-size-fluid-lg)] font-semibold"
  defp fluid_heading_level_class(6, :auto), do: "scroll-m-20 text-[length:var(--font-size-fluid-base)] font-semibold"
  defp fluid_heading_level_class(_, :xs), do: "scroll-m-20 text-[length:var(--font-size-fluid-sm)] font-semibold leading-tight"
  defp fluid_heading_level_class(_, :sm), do: "scroll-m-20 text-[length:var(--font-size-fluid-sm)] font-semibold leading-tight"
  defp fluid_heading_level_class(_, :base), do: "scroll-m-20 text-[length:var(--font-size-fluid-base)] font-semibold leading-tight"
  defp fluid_heading_level_class(_, :lg), do: "scroll-m-20 text-[length:var(--font-size-fluid-lg)] font-semibold leading-tight"
  defp fluid_heading_level_class(_, :xl), do: "scroll-m-20 text-[length:var(--font-size-fluid-xl)] font-semibold leading-tight"
  defp fluid_heading_level_class(_, :"2xl"), do: "scroll-m-20 text-[length:var(--font-size-fluid-2xl)] font-semibold leading-tight"
  defp fluid_heading_level_class(_, :"3xl"), do: "scroll-m-20 text-[length:var(--font-size-fluid-3xl)] font-semibold leading-tight"
  defp fluid_heading_level_class(_, :"4xl"), do: "scroll-m-20 text-[length:var(--font-size-fluid-4xl)] font-semibold leading-tight"

  # display size
  defp display_size_class(:"5xl"), do: "text-5xl"
  defp display_size_class(:"6xl"), do: "text-6xl"
  defp display_size_class(:"7xl"), do: "text-7xl"

  # fluid display size — maps to closest available fluid token
  defp fluid_display_size_class(:"5xl"), do: "text-[length:var(--font-size-fluid-4xl)]"
  defp fluid_display_size_class(:"6xl"), do: "text-[length:var(--font-size-fluid-4xl)]"
  defp fluid_display_size_class(:"7xl"), do: "text-[length:var(--font-size-fluid-4xl)]"

  # paragraph size
  defp paragraph_size_class(:sm), do: "text-sm"
  defp paragraph_size_class(:base), do: "text-base"
  defp paragraph_size_class(:lg), do: "text-lg"

  # fluid paragraph size
  defp fluid_paragraph_size_class(:sm), do: "text-[length:var(--font-size-fluid-sm)]"
  defp fluid_paragraph_size_class(:base), do: "text-[length:var(--font-size-fluid-base)]"
  defp fluid_paragraph_size_class(:lg), do: "text-[length:var(--font-size-fluid-lg)]"

  # text size
  defp text_size_class(:xs), do: "text-xs"
  defp text_size_class(:sm), do: "text-sm"
  defp text_size_class(:base), do: "text-base"
  defp text_size_class(:lg), do: "text-lg"
  defp text_size_class(:xl), do: "text-xl"

  # shared
  defp weight_class(:normal), do: "font-normal"
  defp weight_class(:medium), do: "font-medium"
  defp weight_class(:semibold), do: "font-semibold"

  defp color_class(:default), do: "text-foreground"
  defp color_class(:muted), do: "text-muted-foreground"
  defp color_class(:primary), do: "text-primary"
  defp color_class(:destructive), do: "text-destructive"

  defp align_class(:start), do: "text-left"
  defp align_class(:center), do: "text-center"
  defp align_class(:end), do: "text-right"

  defp tracking_class(:tight), do: "tracking-tight"
  defp tracking_class(:normal), do: "tracking-normal"
  defp tracking_class(:wide), do: "tracking-wide"

  # mark color
  defp mark_color_class(:default), do: "bg-primary/20"
  defp mark_color_class(:yellow), do: "bg-yellow-200/80 dark:bg-yellow-900/50"
  defp mark_color_class(:green), do: "bg-green-200/80 dark:bg-green-900/50"
  defp mark_color_class(:blue), do: "bg-blue-200/80 dark:bg-blue-900/50"
  defp mark_color_class(:red), do: "bg-destructive/20"

  # text_link variant
  defp link_variant_class(:default),
    do: "text-primary underline-offset-4 hover:underline focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 rounded-sm"

  defp link_variant_class(:muted),
    do: "text-muted-foreground hover:text-foreground underline-offset-4 hover:underline rounded-sm"

  # list variants
  defp ul_variant_class(:disc), do: "list-disc"
  defp ul_variant_class(:circle), do: "list-[circle]"
  defp ul_variant_class(:none), do: "list-none"

  defp ol_variant_class(:decimal), do: "list-decimal"
  defp ol_variant_class(:alpha), do: "list-[lower-alpha]"
  defp ol_variant_class(:roman), do: "list-[lower-roman]"

  defp list_spacing_class(:base), do: "my-6 ml-6 [&>li]:mt-2"
  defp list_spacing_class(:sm), do: "my-2 ml-4 [&>li]:mt-1"

  # gradient
  defp gradient_angle_class(:r), do: "bg-gradient-to-r"
  defp gradient_angle_class(:l), do: "bg-gradient-to-l"
  defp gradient_angle_class(:t), do: "bg-gradient-to-t"
  defp gradient_angle_class(:b), do: "bg-gradient-to-b"
  defp gradient_angle_class(:tr), do: "bg-gradient-to-tr"
  defp gradient_angle_class(:tl), do: "bg-gradient-to-tl"
  defp gradient_angle_class(:br), do: "bg-gradient-to-br"
  defp gradient_angle_class(:bl), do: "bg-gradient-to-bl"

  defp gradient_from_class(:primary), do: "from-primary/90"
  defp gradient_from_class(:secondary), do: "from-secondary/90"
  defp gradient_from_class(:destructive), do: "from-destructive/90"
  defp gradient_from_class(:muted), do: "from-muted-foreground/90"

  defp gradient_to_class(:primary), do: "to-primary/90"
  defp gradient_to_class(:secondary), do: "to-secondary/90"
  defp gradient_to_class(:destructive), do: "to-destructive/90"
  defp gradient_to_class(:muted), do: "to-muted-foreground/90"

  # truncated_text
  defp line_clamp_class(1), do: "line-clamp-1"
  defp line_clamp_class(2), do: "line-clamp-2"
  defp line_clamp_class(3), do: "line-clamp-3"
  defp line_clamp_class(4), do: "line-clamp-4"
  defp line_clamp_class(5), do: "line-clamp-5"
  defp line_clamp_class(6), do: "line-clamp-6"

  # prose container
  defp prose_base_class do
    "text-foreground max-w-none " <>
      "[&_h1]:scroll-m-20 [&_h1]:text-3xl [&_h1]:font-semibold [&_h1]:leading-tight [&_h1]:mt-8 [&_h1]:mb-4 " <>
      "[&_h2]:scroll-m-20 [&_h2]:text-2xl [&_h2]:font-semibold [&_h2]:leading-tight [&_h2]:mt-6 [&_h2]:mb-3 " <>
      "[&_h3]:scroll-m-20 [&_h3]:text-xl [&_h3]:font-semibold [&_h3]:leading-tight [&_h3]:mt-4 [&_h3]:mb-2 " <>
      "[&_p]:leading-7 [&_p]:mt-6 " <>
      "[&_blockquote]:border-l-4 [&_blockquote]:border-border [&_blockquote]:pl-6 [&_blockquote]:italic [&_blockquote]:mt-6 [&_blockquote]:text-muted-foreground " <>
      "[&_ul]:my-4 [&_ul]:ml-6 [&_ul]:list-disc [&_ul_li]:mt-2 " <>
      "[&_ol]:my-4 [&_ol]:ml-6 [&_ol]:list-decimal [&_ol_li]:mt-2 " <>
      "[&_code]:font-mono [&_code]:text-sm [&_code]:rounded-sm [&_code]:bg-muted [&_code]:px-1 " <>
      "[&_pre]:overflow-x-auto [&_pre]:rounded-lg [&_pre]:border [&_pre]:bg-muted [&_pre]:p-4 [&_pre]:mt-6"
  end

  defp prose_size_class(:sm), do: "text-sm"
  defp prose_size_class(:base), do: "text-base"
  defp prose_size_class(:lg), do: "text-lg"
  defp prose_size_class(:xl), do: "text-xl"
end
