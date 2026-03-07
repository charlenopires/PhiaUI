defmodule PhiaUi.Components.Utilities do
  @moduledoc """
  General-purpose utility display components for PhiaUI.

  15 components covering accessibility wrappers, text display helpers,
  time formatting, print/screen visibility, and client-side focus management.

  All components are tier `:primitive` except `focus_trap` (`:interactive`).

  ## Components

  | Component          | Purpose                                                    |
  |--------------------|------------------------------------------------------------|
  | `visually_hidden`  | `sr-only` wrapper for accessibility text                   |
  | `line_clamp`       | Truncate text with a read-more toggle (no server round-trip)|
  | `highlight_text`   | Highlight query matches in text                            |
  | `relative_time`    | Format a `DateTime` as "X minutes ago"                    |
  | `number_format`    | Format numbers with compact, prefix, suffix                |
  | `reading_time`     | Estimate reading time from text                            |
  | `label_with_tooltip` | Label + help icon with tooltip                           |
  | `print_only`       | Content visible only when printing                         |
  | `screen_only`      | Content hidden when printing                               |
  | `color_mode_value` | Render different slots in light vs dark mode               |
  | `diff_display`     | Word-level diff with added/removed markup                  |
  | `stat_unit`        | Value + unit display pair                                  |
  | `word_count`       | Display word count with label                              |
  | `focus_trap`       | Focus trap wrapper (requires `PhiaFocusTrap` JS hook)      |
  | `sticky_wrapper`   | Sticky-positioned wrapper with configurable top offset     |
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  # ---------------------------------------------------------------------------
  # visually_hidden/1
  # ---------------------------------------------------------------------------

  attr(:as, :string, default: "span", doc: "HTML element to render: 'span' or 'div'")
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  @doc """
  Renders content that is visually hidden but accessible to screen readers.

  Uses the `sr-only` utility class. Use this for labels, descriptions, and
  context text that sighted users can infer visually but screen reader users need.

  ## Example

      <.visually_hidden>Current step: 3 of 5</.visually_hidden>
  """
  def visually_hidden(%{as: "div"} = assigns) do
    ~H"""
    <div class={cn(["sr-only", @class])} {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  def visually_hidden(assigns) do
    ~H"""
    <span class={cn(["sr-only", @class])} {@rest}>
      {render_slot(@inner_block)}
    </span>
    """
  end

  # ---------------------------------------------------------------------------
  # line_clamp/1
  # ---------------------------------------------------------------------------

  attr(:lines, :integer, default: 3, doc: "Number of lines to clamp to initially")
  attr(:read_more_label, :string, default: "Read more")
  attr(:read_less_label, :string, default: "Read less")
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  @doc """
  Clamps text to a number of lines with a client-side read-more/less toggle.

  Uses `JS.toggle_class` to flip the clamp — no server round-trip needed.
  The clamped state uses CSS `line-clamp-{n}` utilities.

  ## Example

      <.line_clamp lines={3}>
        A very long article excerpt that goes on for many lines...
      </.line_clamp>
  """
  def line_clamp(assigns) do
    id = "line-clamp-#{:erlang.unique_integer([:positive])}"
    btn_id = "#{id}-btn"
    assigns = assign(assigns, id: id, btn_id: btn_id)

    ~H"""
    <div class={cn(["space-y-1", @class])} {@rest}>
      <div
        id={@id}
        class={"overflow-hidden line-clamp-#{@lines}"}
        style={"display: -webkit-box; -webkit-box-orient: vertical;"}
      >
        {render_slot(@inner_block)}
      </div>
      <button
        id={@btn_id}
        type="button"
        class="text-sm text-primary hover:underline focus:outline-none"
        phx-click={
          Phoenix.LiveView.JS.toggle_class("line-clamp-none", to: "##{@id}")
          |> Phoenix.LiveView.JS.toggle_attribute({"data-expanded", "true"}, to: "##{@btn_id}")
        }
      >
        <span data-expanded-show class="hidden">{@read_less_label}</span>
        <span data-collapsed-show>{@read_more_label}</span>
      </button>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # highlight_text/1
  # ---------------------------------------------------------------------------

  attr(:text, :string, required: true, doc: "Full text to render")
  attr(:query, :string, default: "", doc: "Search query to highlight")
  attr(:mark_class, :string, default: nil, doc: "CSS classes for highlighted `<mark>` elements")
  attr(:class, :string, default: nil)

  @doc """
  Renders text with query matches highlighted in `<mark>` elements.

  XSS-safe: splits in Elixir and renders via HEEx — no `raw/1` used.
  Case-insensitive matching. Renders plain text when query is empty.

  ## Example

      <.highlight_text text="Hello World" query="world" />
  """
  def highlight_text(assigns) do
    parts = split_on_query(assigns.text, assigns.query)
    assigns = assign(assigns, :parts, parts)

    ~H"""
    <span class={cn(["", @class])}>
      <%= for {chunk, highlight?} <- @parts do %>
        <%= if highlight? do %>
          <mark class={cn(["bg-yellow-200 dark:bg-yellow-500/40 rounded-sm px-0.5", @mark_class])}>
            {chunk}
          </mark>
        <% else %>
          {chunk}
        <% end %>
      <% end %>
    </span>
    """
  end

  defp split_on_query(_text, ""), do: [{"", false}]
  defp split_on_query(_text, nil), do: [{"", false}]

  defp split_on_query(text, query) do
    escaped = Regex.escape(query)

    case Regex.compile(escaped, "i") do
      {:ok, re} ->
        parts = Regex.split(re, text, include_captures: true)

        Enum.map(parts, fn part ->
          match? = String.downcase(part) == String.downcase(query)
          {part, match?}
        end)

      _ ->
        [{text, false}]
    end
  end

  # ---------------------------------------------------------------------------
  # relative_time/1
  # ---------------------------------------------------------------------------

  attr(:datetime, :any, required: true, doc: "A `DateTime` or `NaiveDateTime` struct")
  attr(:now, :any, default: nil, doc: "Override 'now' (for testing). Defaults to `DateTime.utc_now()`")
  attr(:class, :string, default: nil)
  attr(:rest, :global)

  @doc """
  Renders a `DateTime` as a relative human-readable string.

  Returns values like "just now", "5 minutes ago", "2 hours ago", "3 days ago",
  "4 months ago", "2 years ago". Negative differences show "in X minutes", etc.

  ## Example

      <.relative_time datetime={@post.inserted_at} />
  """
  def relative_time(assigns) do
    now = assigns.now || DateTime.utc_now()

    dt =
      case assigns.datetime do
        %DateTime{} = d -> d
        %NaiveDateTime{} = d -> DateTime.from_naive!(d, "Etc/UTC")
        _ -> DateTime.utc_now()
      end

    label = format_relative(dt, now)
    assigns = assign(assigns, :label, label)

    ~H"""
    <time
      datetime={DateTime.to_iso8601(@datetime)}
      class={cn(["", @class])}
      {@rest}
    >
      {@label}
    </time>
    """
  end

  defp format_relative(dt, now) do
    diff = DateTime.diff(now, dt, :second)
    abs_diff = abs(diff)
    future? = diff < 0

    cond do
      abs_diff < 60 ->
        "just now"

      abs_diff < 3600 ->
        n = div(abs_diff, 60)
        if future?, do: "in #{n} #{pluralize(n, "minute")}", else: "#{n} #{pluralize(n, "minute")} ago"

      abs_diff < 86_400 ->
        n = div(abs_diff, 3600)
        if future?, do: "in #{n} #{pluralize(n, "hour")}", else: "#{n} #{pluralize(n, "hour")} ago"

      abs_diff < 2_592_000 ->
        n = div(abs_diff, 86_400)
        if future?, do: "in #{n} #{pluralize(n, "day")}", else: "#{n} #{pluralize(n, "day")} ago"

      abs_diff < 31_536_000 ->
        n = div(abs_diff, 2_592_000)
        if future?, do: "in #{n} #{pluralize(n, "month")}", else: "#{n} #{pluralize(n, "month")} ago"

      true ->
        n = div(abs_diff, 31_536_000)
        if future?, do: "in #{n} #{pluralize(n, "year")}", else: "#{n} #{pluralize(n, "year")} ago"
    end
  end

  defp pluralize(1, word), do: word
  defp pluralize(_, word), do: "#{word}s"

  # ---------------------------------------------------------------------------
  # number_format/1
  # ---------------------------------------------------------------------------

  attr(:value, :any, required: true, doc: "Numeric value to format")
  attr(:compact, :boolean, default: false, doc: "Use compact notation: 1K, 1M, 1B")
  attr(:decimals, :integer, default: 0, doc: "Decimal places (non-compact mode)")
  attr(:prefix, :string, default: nil, doc: "Prefix string (e.g. '$')")
  attr(:suffix, :string, default: nil, doc: "Suffix string (e.g. '%')")
  attr(:class, :string, default: nil)
  attr(:rest, :global)

  @doc """
  Renders a formatted number with optional compact notation, prefix, and suffix.

  Compact notation: 1000 → "1K", 1_000_000 → "1M", 1_000_000_000 → "1B".

  ## Example

      <.number_format value={1234567} compact={true} prefix="$" />
      <%!-- Renders: $1.2M --%>

      <.number_format value={3.14159} decimals={2} suffix="%" />
      <%!-- Renders: 3.14% --%>
  """
  def number_format(assigns) do
    n = to_float(assigns.value)
    formatted = format_number(n, assigns.compact, assigns.decimals)
    display = "#{assigns.prefix}#{formatted}#{assigns.suffix}"
    assigns = assign(assigns, :display, display)

    ~H"""
    <span class={cn(["tabular-nums", @class])} {@rest}>
      {@display}
    </span>
    """
  end

  defp to_float(v) when is_integer(v), do: v * 1.0
  defp to_float(v) when is_float(v), do: v
  defp to_float(v), do: elem(Float.parse(to_string(v)), 0)

  defp format_number(n, true, _decimals) do
    cond do
      n >= 1_000_000_000 -> "#{:erlang.float_to_binary(n / 1_000_000_000, decimals: 1)}B"
      n >= 1_000_000 -> "#{:erlang.float_to_binary(n / 1_000_000, decimals: 1)}M"
      n >= 1_000 -> "#{:erlang.float_to_binary(n / 1_000, decimals: 1)}K"
      true -> :erlang.float_to_binary(n, decimals: 0)
    end
  end

  defp format_number(n, false, decimals) do
    :erlang.float_to_binary(n, decimals: decimals)
  end

  # ---------------------------------------------------------------------------
  # reading_time/1
  # ---------------------------------------------------------------------------

  attr(:text, :string, required: true, doc: "Plain text content to estimate reading time for")
  attr(:wpm, :integer, default: 238, doc: "Words per minute reading speed (default: 238)")
  attr(:label, :string, default: "min read", doc: "Label appended after the minute count")
  attr(:class, :string, default: nil)
  attr(:rest, :global)

  @doc """
  Estimates and displays reading time for a block of text.

  Uses `ceil(word_count / wpm)` rounding up to the nearest minute.
  Default WPM is 238, which is the average adult silent reading speed.

  ## Example

      <.reading_time text={@article.body} />
      <%!-- Renders: "5 min read" --%>

      <.reading_time text={@post.content} wpm={200} label="minute read" />
  """
  def reading_time(assigns) do
    words = assigns.text |> String.split(~r/\s+/, trim: true) |> length()
    minutes = max(1, ceil(words / assigns.wpm))
    assigns = assign(assigns, :minutes, minutes)

    ~H"""
    <span class={cn(["text-sm text-muted-foreground", @class])} {@rest}>
      {@minutes} {@label}
    </span>
    """
  end

  # ---------------------------------------------------------------------------
  # label_with_tooltip/1
  # ---------------------------------------------------------------------------

  attr(:label, :string, required: true, doc: "Label text")
  attr(:tooltip, :string, required: true, doc: "Tooltip text shown on hover/focus")
  attr(:for, :string, default: nil, doc: "HTML `for` attribute for the label")
  attr(:required, :boolean, default: false, doc: "Show required asterisk")
  attr(:class, :string, default: nil)

  @doc """
  Renders a form label with an attached help icon and tooltip on hover.

  The tooltip is implemented with CSS `:hover`/`:focus-visible` using a
  `group` parent — no JS hook needed.

  ## Example

      <.label_with_tooltip
        label="API Key"
        tooltip="Your secret API key. Never share this."
        for="api-key-input"
      />
  """
  def label_with_tooltip(assigns) do
    ~H"""
    <div class={cn(["flex items-center gap-1", @class])}>
      <label
        for={@for}
        class="text-sm font-medium leading-none peer-disabled:cursor-not-allowed peer-disabled:opacity-70"
      >
        {@label}
        <span :if={@required} class="text-destructive ml-0.5" aria-hidden="true">*</span>
      </label>
      <div class="relative group">
        <button
          type="button"
          aria-label={"Help: #{@tooltip}"}
          class="inline-flex h-4 w-4 items-center justify-center rounded-full text-muted-foreground hover:text-foreground focus:outline-none focus-visible:ring-2 focus-visible:ring-ring"
        >
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
          >
            <circle cx="12" cy="12" r="10" />
            <path d="M9.09 9a3 3 0 0 1 5.83 1c0 2-3 3-3 3" />
            <path d="M12 17h.01" />
          </svg>
        </button>
        <div
          role="tooltip"
          class="absolute bottom-full left-1/2 -translate-x-1/2 mb-2 z-50 hidden group-hover:block group-focus-within:block w-48 rounded-md bg-popover border border-border px-3 py-2 text-xs text-popover-foreground shadow-md"
        >
          {@tooltip}
          <div class="absolute top-full left-1/2 -translate-x-1/2 w-2 h-2 bg-popover border-r border-b border-border rotate-45 -mt-1"></div>
        </div>
      </div>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # print_only/1
  # ---------------------------------------------------------------------------

  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  @doc """
  Wraps content that should only be visible when printing.

  Hidden on screen (`hidden`), shown when printing (`print:block`).

  ## Example

      <.print_only>
        <h1>Invoice #1234</h1>
        <p>Printed at: 2026-01-01</p>
      </.print_only>
  """
  def print_only(assigns) do
    ~H"""
    <div class={cn(["hidden print:block", @class])} {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # screen_only/1
  # ---------------------------------------------------------------------------

  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  @doc """
  Wraps content that should be hidden when printing.

  Visible on screen, hidden when printing (`print:hidden`).

  ## Example

      <.screen_only>
        <nav>...</nav>
        <button phx-click="action">Click me</button>
      </.screen_only>
  """
  def screen_only(assigns) do
    ~H"""
    <div class={cn(["print:hidden", @class])} {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # color_mode_value/1
  # ---------------------------------------------------------------------------

  slot(:light, required: true, doc: "Content rendered in light mode only")
  slot(:dark, required: true, doc: "Content rendered in dark mode only")
  attr(:class, :string, default: nil)

  @doc """
  Renders different content in light mode vs dark mode.

  Uses CSS `dark:hidden` / `dark:block` — no JS needed. The `:light` slot
  is hidden in dark mode; the `:dark` slot is hidden in light mode.

  ## Example

      <.color_mode_value>
        <:light><img src="/logo-light.png" alt="Logo" /></:light>
        <:dark><img src="/logo-dark.png" alt="Logo" /></:dark>
      </.color_mode_value>
  """
  def color_mode_value(assigns) do
    ~H"""
    <span class={cn(["", @class])}>
      <span class="dark:hidden">{render_slot(@light)}</span>
      <span class="hidden dark:inline">{render_slot(@dark)}</span>
    </span>
    """
  end

  # ---------------------------------------------------------------------------
  # diff_display/1
  # ---------------------------------------------------------------------------

  attr(:before, :string, required: true, doc: "Original text (words removed will be highlighted)")
  attr(:after, :string, required: true, doc: "New text (words added will be highlighted)")
  attr(:class, :string, default: nil)

  @doc """
  Renders a word-level diff between two strings.

  Removed words are rendered in `<del>` with a red background.
  Added words are rendered in `<ins>` with a green background.
  Unchanged words are rendered as plain text.

  ## Example

      <.diff_display before="The quick brown fox" after="The slow green fox" />
  """
  def diff_display(assigns) do
    before_words = String.split(assigns.before, " ", trim: true)
    after_words = String.split(assigns.after, " ", trim: true)
    diff = word_diff(before_words, after_words)
    assigns = assign(assigns, :diff, diff)

    ~H"""
    <div class={cn(["text-sm leading-relaxed", @class])}>
      <%= for {type, word} <- @diff do %>
        <%= case type do %>
          <% :equal -> %>
            {word}{" "}
          <% :del -> %>
            <del class="bg-red-100 dark:bg-red-900/30 line-through text-red-700 dark:text-red-400 rounded-sm px-0.5 no-underline">
              {word}
            </del>{" "}
          <% :ins -> %>
            <ins class="bg-green-100 dark:bg-green-900/30 text-green-700 dark:text-green-400 rounded-sm px-0.5 no-underline">
              {word}
            </ins>{" "}
        <% end %>
      <% end %>
    </div>
    """
  end

  defp word_diff(before_words, after_words) do
    # Simple LCS-based diff
    lcs = longest_common_subsequence(before_words, after_words)
    build_diff(before_words, after_words, lcs)
  end

  defp longest_common_subsequence(a, b) do
    m = length(a)
    n = length(b)
    a_arr = List.to_tuple(a)
    b_arr = List.to_tuple(b)

    table =
      for i <- 0..m, j <- 0..n, into: %{} do
        {{i, j}, 0}
      end

    table =
      Enum.reduce(1..m, table, fn i, acc ->
        Enum.reduce(1..n, acc, fn j, inner_acc ->
          ai = elem(a_arr, i - 1)
          bj = elem(b_arr, j - 1)

          val =
            if ai == bj do
              inner_acc[{i - 1, j - 1}] + 1
            else
              max(inner_acc[{i - 1, j}], inner_acc[{i, j - 1}])
            end

          Map.put(inner_acc, {i, j}, val)
        end)
      end)

    backtrack(table, a_arr, b_arr, m, n, [])
  end

  defp backtrack(_table, _a, _b, 0, 0, acc), do: acc

  defp backtrack(table, a, b, i, j, acc) when i > 0 and j > 0 do
    if elem(a, i - 1) == elem(b, j - 1) do
      backtrack(table, a, b, i - 1, j - 1, [elem(a, i - 1) | acc])
    else
      if table[{i - 1, j}] >= table[{i, j - 1}] do
        backtrack(table, a, b, i - 1, j, acc)
      else
        backtrack(table, a, b, i, j - 1, acc)
      end
    end
  end

  defp backtrack(table, a, b, 0, j, acc) when j > 0,
    do: backtrack(table, a, b, 0, j - 1, acc)

  defp backtrack(table, a, b, i, 0, acc) when i > 0,
    do: backtrack(table, a, b, i - 1, 0, acc)

  defp build_diff(before_words, after_words, []) do
    Enum.map(before_words, &{:del, &1}) ++ Enum.map(after_words, &{:ins, &1})
  end

  defp build_diff(before_words, after_words, common) do
    {result, rem_b, rem_a} =
      Enum.reduce(common, {[], before_words, after_words}, fn word, {acc, rem_b, rem_a} ->
        {del, rest_b} = take_until(rem_b, word)
        {ins, rest_a} = take_until(rem_a, word)

        new_acc =
          acc ++
            Enum.map(del, &{:del, &1}) ++
            Enum.map(ins, &{:ins, &1}) ++
            [{:equal, word}]

        {new_acc, rest_b, rest_a}
      end)

    result ++
      Enum.map(rem_b, &{:del, &1}) ++
      Enum.map(rem_a, &{:ins, &1})
  end

  defp take_until([], _word), do: {[], []}

  defp take_until([h | t], word) do
    if h == word do
      {[], t}
    else
      {taken, rest} = take_until(t, word)
      {[h | taken], rest}
    end
  end

  # ---------------------------------------------------------------------------
  # stat_unit/1
  # ---------------------------------------------------------------------------

  attr(:value, :string, required: true, doc: "The primary numeric or text value")
  attr(:unit, :string, required: true, doc: "The unit label displayed after the value")
  attr(:value_class, :string, default: nil, doc: "Additional classes for the value element")
  attr(:unit_class, :string, default: nil, doc: "Additional classes for the unit element")
  attr(:class, :string, default: nil)
  attr(:rest, :global)

  @doc """
  Renders a value+unit pair for metric or stat displays.

  The value is bold; the unit is muted and slightly smaller.

  ## Example

      <.stat_unit value="42" unit="requests/sec" />
      <.stat_unit value="99.9" unit="%" value_class="text-3xl" />
  """
  def stat_unit(assigns) do
    ~H"""
    <span class={cn(["inline-flex items-baseline gap-1", @class])} {@rest}>
      <span class={cn(["font-bold", @value_class])}>{@value}</span>
      <span class={cn(["text-sm text-muted-foreground", @unit_class])}>{@unit}</span>
    </span>
    """
  end

  # ---------------------------------------------------------------------------
  # word_count/1
  # ---------------------------------------------------------------------------

  attr(:text, :string, required: true, doc: "Text to count words in")
  attr(:label, :string, default: "words", doc: "Label appended after the word count")
  attr(:class, :string, default: nil)
  attr(:rest, :global)

  @doc """
  Displays the word count of a string.

  Splits on whitespace and counts non-empty tokens.

  ## Example

      <.word_count text={@body} />
      <%!-- Renders: "247 words" --%>

      <.word_count text={@body} label="word count" />
  """
  def word_count(assigns) do
    count = assigns.text |> String.split(~r/\s+/, trim: true) |> length()
    assigns = assign(assigns, :count, count)

    ~H"""
    <span class={cn(["text-sm text-muted-foreground tabular-nums", @class])} {@rest}>
      {@count} {@label}
    </span>
    """
  end

  # ---------------------------------------------------------------------------
  # focus_trap/1
  # ---------------------------------------------------------------------------

  attr(:id, :string, required: true, doc: "Unique element ID (required by phx-hook)")
  attr(:enabled, :boolean, default: true, doc: "When false, the trap is disabled")
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  @doc """
  Wraps content in a focus trap managed by the `PhiaFocusTrap` JS hook.

  When enabled, Tab/Shift+Tab cycle only within focusable elements inside
  this wrapper. Pressing Escape fires a `"focus-trap-escape"` push event
  to the parent LiveView.

  Requires the `PhiaFocusTrap` JS hook to be installed.

  ## Example

      <.focus_trap id="modal-trap" enabled={@modal_open}>
        <form>...</form>
        <button phx-click="close">Close</button>
      </.focus_trap>

  ## LiveView handler

      def handle_event("focus-trap-escape", _params, socket) do
        {:noreply, assign(socket, modal_open: false)}
      end
  """
  def focus_trap(assigns) do
    ~H"""
    <div
      id={@id}
      phx-hook="PhiaFocusTrap"
      data-enabled={to_string(@enabled)}
      class={cn(["contents", @class])}
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # sticky_wrapper/1
  # ---------------------------------------------------------------------------

  attr(:offset_top, :integer, default: 0, doc: "Top offset in pixels for the sticky position")
  attr(:z_index, :integer, default: 10, doc: "z-index for the sticky element")
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  @doc """
  Renders a sticky-positioned wrapper at a configurable top offset.

  Use for headers, toolbars, or sidebars that should remain visible
  during scrolling within a scrollable container.

  ## Example

      <.sticky_wrapper offset_top={64}>
        <.data_grid_toolbar>...</.data_grid_toolbar>
      </.sticky_wrapper>
  """
  def sticky_wrapper(assigns) do
    ~H"""
    <div
      class={cn(["sticky bg-background", @class])}
      style={"top: #{@offset_top}px; z-index: #{@z_index};"}
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end
end
