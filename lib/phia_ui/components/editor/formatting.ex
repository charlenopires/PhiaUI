defmodule PhiaUi.Components.Editor.Formatting do
  @moduledoc """
  Editor Formatting Suite — 16 components for text formatting controls.

  Provides font selection, color pickers, alignment, spacing, and
  typographic controls for the PhiaUI rich text editor.
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  @default_colors ~w(#000000 #434343 #666666 #999999 #b7b7b7 #cccccc #d9d9d9 #efefef #f3f3f3 #ffffff
                      #980000 #ff0000 #ff9900 #ffff00 #00ff00 #00ffff #4a86e8 #0000ff #9900ff #ff00ff)

  @font_sizes [8, 9, 10, 11, 12, 14, 16, 18, 20, 24, 28, 32, 36, 48, 60, 72]

  # ── Helpers ──────────────────────────────────────────────────────────────────

  defp editor_command(editor_id, command, attrs \\ %{}) do
    Phoenix.LiveView.JS.push("editor:command",
      value: Map.merge(%{editor_id: editor_id, command: command}, attrs)
    )
  end

  defp btn_class(active \\ false) do
    cn([
      "inline-flex h-7 w-7 items-center justify-center rounded text-foreground transition-colors",
      "hover:bg-accent hover:text-accent-foreground",
      "focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring",
      active && "bg-accent text-accent-foreground"
    ])
  end

  # ── 1. font_family_selector ─────────────────────────────────────────────────

  attr :id, :string, required: true
  attr :editor_id, :string, required: true
  attr :value, :string, default: "sans-serif"
  attr :class, :string, default: nil

  @doc "Dropdown with font family preview (sans/serif/mono)."
  def font_family_selector(assigns) do
    ~H"""
    <div class={cn(["relative", @class])}>
      <select
        id={@id}
        aria-label="Font family"
        phx-change={editor_command(@editor_id, "setFontFamily")}
        name="font"
        class="h-7 rounded border border-border bg-background px-2 text-xs text-foreground focus:outline-none focus:ring-1 focus:ring-ring"
      >
        <option value="sans-serif" selected={@value == "sans-serif"} style="font-family:sans-serif">Sans Serif</option>
        <option value="serif" selected={@value == "serif"} style="font-family:serif">Serif</option>
        <option value="monospace" selected={@value == "monospace"} style="font-family:monospace">Monospace</option>
        <option value="Georgia, serif" selected={@value == "Georgia, serif"} style="font-family:Georgia,serif">Georgia</option>
        <option value="Verdana, sans-serif" selected={@value == "Verdana, sans-serif"} style="font-family:Verdana,sans-serif">Verdana</option>
      </select>
    </div>
    """
  end

  # ── 2. font_size_selector ───────────────────────────────────────────────────

  attr :id, :string, required: true
  attr :editor_id, :string, required: true
  attr :value, :any, default: nil
  attr :class, :string, default: nil

  @doc "Dropdown 8-72pt with common font sizes."
  def font_size_selector(assigns) do
    assigns = assign(assigns, :sizes, @font_sizes)

    ~H"""
    <div class={cn(["relative", @class])}>
      <select
        id={@id}
        aria-label="Font size"
        phx-change={editor_command(@editor_id, "setFontSize")}
        name="size"
        class="h-7 w-16 rounded border border-border bg-background px-1 text-xs text-foreground focus:outline-none focus:ring-1 focus:ring-ring"
      >
        <option :for={s <- @sizes} value={s} selected={to_string(@value) == to_string(s)}>{s}</option>
      </select>
    </div>
    """
  end

  # ── 3. text_color_picker ────────────────────────────────────────────────────

  attr :id, :string, required: true
  attr :editor_id, :string, required: true
  attr :value, :string, default: nil
  attr :colors, :list, default: @default_colors
  attr :class, :string, default: nil

  @doc "Foreground color palette with swatches."
  def text_color_picker(assigns) do
    ~H"""
    <div id={@id} class={cn(["relative", @class])} role="group" aria-label="Text color">
      <div class="grid grid-cols-10 gap-0.5 p-1">
        <button
          :for={color <- @colors}
          type="button"
          title={color}
          aria-label={"Text color #{color}"}
          phx-click={editor_command(@editor_id, "setColor", %{color: color})}
          class={cn([
            "h-5 w-5 rounded-sm border border-border transition-transform hover:scale-125",
            "focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring",
            @value == color && "ring-2 ring-primary ring-offset-1"
          ])}
          style={"background-color: #{color}"}
        />
      </div>
    </div>
    """
  end

  # ── 4. bg_color_picker ─────────────────────────────────────────────────────

  attr :id, :string, required: true
  attr :editor_id, :string, required: true
  attr :value, :string, default: nil
  attr :colors, :list, default: @default_colors
  attr :class, :string, default: nil

  @doc "Background/highlight color palette."
  def bg_color_picker(assigns) do
    ~H"""
    <div id={@id} class={cn(["relative", @class])} role="group" aria-label="Highlight color">
      <div class="grid grid-cols-10 gap-0.5 p-1">
        <button
          :for={color <- @colors}
          type="button"
          title={color}
          aria-label={"Highlight color #{color}"}
          phx-click={editor_command(@editor_id, "setHighlight", %{color: color})}
          class={cn([
            "h-5 w-5 rounded-sm border border-border transition-transform hover:scale-125",
            "focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring",
            @value == color && "ring-2 ring-primary ring-offset-1"
          ])}
          style={"background-color: #{color}"}
        />
      </div>
    </div>
    """
  end

  # ── 5. text_case_toggle ────────────────────────────────────────────────────

  attr :editor_id, :string, required: true
  attr :current_case, :atom, default: :original
  attr :class, :string, default: nil

  @doc "Cycle: original → UPPER → lower → Title."
  def text_case_toggle(assigns) do
    label = case assigns.current_case do
      :upper -> "Aa"
      :lower -> "aa"
      :title -> "Aa"
      _ -> "Aa"
    end

    assigns = assign(assigns, :label, label)

    ~H"""
    <button
      type="button"
      aria-label="Toggle text case"
      title="Text case"
      phx-click={editor_command(@editor_id, "toggleTextCase")}
      class={cn([btn_class(), @class])}
    >
      <span class="text-xs font-medium">{@label}</span>
    </button>
    """
  end

  # ── 6. clear_formatting_button ─────────────────────────────────────────────

  attr :editor_id, :string, required: true
  attr :class, :string, default: nil

  @doc "Strip all marks from selection."
  def clear_formatting_button(assigns) do
    ~H"""
    <button
      type="button"
      aria-label="Clear formatting"
      title="Clear formatting"
      phx-click={editor_command(@editor_id, "clearFormatting")}
      class={cn([btn_class(), @class])}
    >
      <svg class="h-4 w-4" viewBox="0 0 16 16" fill="none">
        <path d="M3 13h10M7 3l-3 8M9 3l3 8M5.5 8h5" stroke="currentColor" stroke-width="1.4" stroke-linecap="round" />
        <path d="M12 3l-8 10" stroke="currentColor" stroke-width="1.4" stroke-linecap="round" opacity="0.5" />
      </svg>
    </button>
    """
  end

  # ── 7. format_painter ──────────────────────────────────────────────────────

  attr :id, :string, required: true
  attr :editor_id, :string, required: true
  attr :active, :boolean, default: false
  attr :class, :string, default: nil

  @doc "Copy formatting, apply to next selection."
  def format_painter(assigns) do
    ~H"""
    <button
      id={@id}
      type="button"
      aria-label="Format painter"
      aria-pressed={to_string(@active)}
      title="Format painter"
      phx-click={editor_command(@editor_id, "formatPainter")}
      class={cn([btn_class(@active), @class])}
    >
      <svg class="h-4 w-4" viewBox="0 0 16 16" fill="none">
        <rect x="3" y="2" width="7" height="5" rx="1" stroke="currentColor" stroke-width="1.3" />
        <path d="M6 7v2M6 9h1a1 1 0 011 1v3" stroke="currentColor" stroke-width="1.3" stroke-linecap="round" />
      </svg>
    </button>
    """
  end

  # ── 8. text_align_group ────────────────────────────────────────────────────

  attr :editor_id, :string, required: true
  attr :active_alignment, :string, default: "left"
  attr :class, :string, default: nil

  @doc "4-button alignment group: left/center/right/justify."
  def text_align_group(assigns) do
    ~H"""
    <div role="group" aria-label="Text alignment" class={cn(["flex items-center gap-0.5", @class])}>
      <button
        type="button"
        aria-label="Align left"
        aria-pressed={to_string(@active_alignment == "left")}
        phx-click={editor_command(@editor_id, "setTextAlign", %{alignment: "left"})}
        class={btn_class(@active_alignment == "left")}
      >
        <svg class="h-4 w-4" viewBox="0 0 16 16" fill="none">
          <path d="M2 3h12M2 6h8M2 9h10M2 12h6" stroke="currentColor" stroke-width="1.4" stroke-linecap="round" />
        </svg>
      </button>
      <button
        type="button"
        aria-label="Align center"
        aria-pressed={to_string(@active_alignment == "center")}
        phx-click={editor_command(@editor_id, "setTextAlign", %{alignment: "center"})}
        class={btn_class(@active_alignment == "center")}
      >
        <svg class="h-4 w-4" viewBox="0 0 16 16" fill="none">
          <path d="M2 3h12M4 6h8M3 9h10M5 12h6" stroke="currentColor" stroke-width="1.4" stroke-linecap="round" />
        </svg>
      </button>
      <button
        type="button"
        aria-label="Align right"
        aria-pressed={to_string(@active_alignment == "right")}
        phx-click={editor_command(@editor_id, "setTextAlign", %{alignment: "right"})}
        class={btn_class(@active_alignment == "right")}
      >
        <svg class="h-4 w-4" viewBox="0 0 16 16" fill="none">
          <path d="M2 3h12M6 6h8M4 9h10M8 12h6" stroke="currentColor" stroke-width="1.4" stroke-linecap="round" />
        </svg>
      </button>
      <button
        type="button"
        aria-label="Justify"
        aria-pressed={to_string(@active_alignment == "justify")}
        phx-click={editor_command(@editor_id, "setTextAlign", %{alignment: "justify"})}
        class={btn_class(@active_alignment == "justify")}
      >
        <svg class="h-4 w-4" viewBox="0 0 16 16" fill="none">
          <path d="M2 3h12M2 6h12M2 9h12M2 12h12" stroke="currentColor" stroke-width="1.4" stroke-linecap="round" />
        </svg>
      </button>
    </div>
    """
  end

  # ── 9. indent_controls ─────────────────────────────────────────────────────

  attr :editor_id, :string, required: true
  attr :class, :string, default: nil

  @doc "2-button: indent/outdent."
  def indent_controls(assigns) do
    ~H"""
    <div role="group" aria-label="Indentation" class={cn(["flex items-center gap-0.5", @class])}>
      <button
        type="button"
        aria-label="Decrease indent"
        title="Decrease indent"
        phx-click={editor_command(@editor_id, "outdent")}
        class={btn_class()}
      >
        <svg class="h-4 w-4" viewBox="0 0 16 16" fill="none">
          <path d="M2 3h12M6 6h8M6 9h8M2 12h12" stroke="currentColor" stroke-width="1.4" stroke-linecap="round" />
          <path d="M4 7.5L2 6L4 4.5" stroke="currentColor" stroke-width="1.4" stroke-linecap="round" stroke-linejoin="round" />
        </svg>
      </button>
      <button
        type="button"
        aria-label="Increase indent"
        title="Increase indent"
        phx-click={editor_command(@editor_id, "indent")}
        class={btn_class()}
      >
        <svg class="h-4 w-4" viewBox="0 0 16 16" fill="none">
          <path d="M2 3h12M6 6h8M6 9h8M2 12h12" stroke="currentColor" stroke-width="1.4" stroke-linecap="round" />
          <path d="M2 4.5L4 6L2 7.5" stroke="currentColor" stroke-width="1.4" stroke-linecap="round" stroke-linejoin="round" />
        </svg>
      </button>
    </div>
    """
  end

  # ── 10. line_height_selector ───────────────────────────────────────────────

  attr :id, :string, required: true
  attr :editor_id, :string, required: true
  attr :value, :string, default: "1.5"
  attr :class, :string, default: nil

  @doc "Dropdown: 1.0/1.15/1.5/2.0 line height."
  def line_height_selector(assigns) do
    ~H"""
    <div class={cn(["relative", @class])}>
      <select
        id={@id}
        aria-label="Line height"
        phx-change={editor_command(@editor_id, "setLineHeight")}
        name="line_height"
        class="h-7 rounded border border-border bg-background px-2 text-xs text-foreground focus:outline-none focus:ring-1 focus:ring-ring"
      >
        <option value="1" selected={@value == "1"}>1.0</option>
        <option value="1.15" selected={@value == "1.15"}>1.15</option>
        <option value="1.5" selected={@value == "1.5"}>1.5</option>
        <option value="2" selected={@value == "2"}>2.0</option>
        <option value="2.5" selected={@value == "2.5"}>2.5</option>
      </select>
    </div>
    """
  end

  # ── 11. letter_spacing_selector ────────────────────────────────────────────

  attr :id, :string, required: true
  attr :editor_id, :string, required: true
  attr :value, :string, default: "normal"
  attr :class, :string, default: nil

  @doc "Dropdown: tight/normal/wide letter spacing."
  def letter_spacing_selector(assigns) do
    ~H"""
    <div class={cn(["relative", @class])}>
      <select
        id={@id}
        aria-label="Letter spacing"
        phx-change={editor_command(@editor_id, "setLetterSpacing")}
        name="letter_spacing"
        class="h-7 rounded border border-border bg-background px-2 text-xs text-foreground focus:outline-none focus:ring-1 focus:ring-ring"
      >
        <option value="-0.05em" selected={@value == "tight"}>Tight</option>
        <option value="normal" selected={@value == "normal"}>Normal</option>
        <option value="0.05em" selected={@value == "wide"}>Wide</option>
        <option value="0.1em" selected={@value == "wider"}>Wider</option>
      </select>
    </div>
    """
  end

  # ── 12. paragraph_spacing ──────────────────────────────────────────────────

  attr :id, :string, required: true
  attr :editor_id, :string, required: true
  attr :space_before, :string, default: "0"
  attr :space_after, :string, default: "0.5em"
  attr :class, :string, default: nil

  @doc "Before/after spacing controls."
  def paragraph_spacing(assigns) do
    ~H"""
    <div id={@id} class={cn(["flex items-center gap-2 text-xs", @class])} role="group" aria-label="Paragraph spacing">
      <label class="flex items-center gap-1 text-muted-foreground">
        Before
        <input
          type="text"
          name="space_before"
          value={@space_before}
          phx-blur={editor_command(@editor_id, "setParagraphSpacing")}
          class="h-6 w-14 rounded border border-border bg-background px-1 text-xs text-foreground"
          aria-label="Space before paragraph"
        />
      </label>
      <label class="flex items-center gap-1 text-muted-foreground">
        After
        <input
          type="text"
          name="space_after"
          value={@space_after}
          phx-blur={editor_command(@editor_id, "setParagraphSpacing")}
          class="h-6 w-14 rounded border border-border bg-background px-1 text-xs text-foreground"
          aria-label="Space after paragraph"
        />
      </label>
    </div>
    """
  end

  # ── 13. subscript_button ───────────────────────────────────────────────────

  attr :editor_id, :string, required: true
  attr :active, :boolean, default: false
  attr :class, :string, default: nil

  @doc "Toggle subscript mark."
  def subscript_button(assigns) do
    ~H"""
    <button
      type="button"
      aria-label="Subscript"
      aria-pressed={to_string(@active)}
      title="Subscript"
      phx-click={editor_command(@editor_id, "toggleSubscript")}
      class={cn([btn_class(@active), @class])}
    >
      <svg class="h-4 w-4" viewBox="0 0 16 16" fill="none">
        <path d="M3 4l4 5M7 4L3 9" stroke="currentColor" stroke-width="1.4" stroke-linecap="round" />
        <text x="10" y="14" font-size="7" fill="currentColor" font-family="sans-serif">2</text>
      </svg>
    </button>
    """
  end

  # ── 14. superscript_button ─────────────────────────────────────────────────

  attr :editor_id, :string, required: true
  attr :active, :boolean, default: false
  attr :class, :string, default: nil

  @doc "Toggle superscript mark."
  def superscript_button(assigns) do
    ~H"""
    <button
      type="button"
      aria-label="Superscript"
      aria-pressed={to_string(@active)}
      title="Superscript"
      phx-click={editor_command(@editor_id, "toggleSuperscript")}
      class={cn([btn_class(@active), @class])}
    >
      <svg class="h-4 w-4" viewBox="0 0 16 16" fill="none">
        <path d="M3 6l4 5M7 6L3 11" stroke="currentColor" stroke-width="1.4" stroke-linecap="round" />
        <text x="10" y="7" font-size="7" fill="currentColor" font-family="sans-serif">2</text>
      </svg>
    </button>
    """
  end

  # ── 15. small_caps_button ──────────────────────────────────────────────────

  attr :editor_id, :string, required: true
  attr :active, :boolean, default: false
  attr :class, :string, default: nil

  @doc "Toggle small-caps styling."
  def small_caps_button(assigns) do
    ~H"""
    <button
      type="button"
      aria-label="Small caps"
      aria-pressed={to_string(@active)}
      title="Small caps"
      phx-click={editor_command(@editor_id, "toggleSmallCaps")}
      class={cn([btn_class(@active), @class])}
    >
      <span class="text-[10px] font-semibold tracking-wider">SC</span>
    </button>
    """
  end

  # ── 16. drop_cap_toggle ────────────────────────────────────────────────────

  attr :editor_id, :string, required: true
  attr :active, :boolean, default: false
  attr :class, :string, default: nil

  @doc "Apply drop-cap to first letter."
  def drop_cap_toggle(assigns) do
    ~H"""
    <button
      type="button"
      aria-label="Drop cap"
      aria-pressed={to_string(@active)}
      title="Drop cap"
      phx-click={editor_command(@editor_id, "toggleDropCap")}
      class={cn([btn_class(@active), @class])}
    >
      <svg class="h-4 w-4" viewBox="0 0 16 16" fill="none">
        <text x="1" y="12" font-size="13" font-weight="bold" fill="currentColor" font-family="serif">A</text>
        <path d="M9 6h5M9 9h5M9 12h5" stroke="currentColor" stroke-width="1.2" stroke-linecap="round" />
      </svg>
    </button>
    """
  end
end
