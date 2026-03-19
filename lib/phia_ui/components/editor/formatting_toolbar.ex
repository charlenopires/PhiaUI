defmodule PhiaUi.Components.Editor.FormattingToolbar do
  @moduledoc """
  Pre-composed formatting toolbars — 4 components for common toolbar layouts.
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]
  import PhiaUi.Components.Editor.Formatting

  defp editor_command(editor_id, command) do
    Phoenix.LiveView.JS.push("editor:command",
      value: %{editor_id: editor_id, command: command}
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

  # ── 17. formatting_toolbar ──────────────────────────────────────────────────

  attr :id, :string, required: true
  attr :editor_id, :string, required: true
  attr :active_marks, :list, default: []
  attr :active_nodes, :list, default: []
  attr :heading_level, :any, default: nil
  attr :active_alignment, :string, default: "left"
  attr :class, :string, default: nil

  @doc "Pre-composed full toolbar with font, size, color, alignment, lists."
  def formatting_toolbar(assigns) do
    ~H"""
    <div
      id={@id}
      role="toolbar"
      aria-label="Full formatting toolbar"
      class={cn(["flex flex-wrap items-center gap-1 rounded-t-xl border-b border-border px-2 py-1.5", @class])}
    >
      <.font_family_selector id={"#{@id}-font"} editor_id={@editor_id} />
      <.font_size_selector id={"#{@id}-size"} editor_id={@editor_id} />

      <div role="separator" aria-orientation="vertical" class="mx-1 h-5 w-px shrink-0 bg-border" />

      <div role="group" aria-label="Text formatting" class="flex items-center gap-0.5">
        <button type="button" aria-label="Bold" aria-pressed={to_string("bold" in @active_marks)} phx-click={editor_command(@editor_id, "toggleBold")} class={btn_class("bold" in @active_marks)} title="Bold (Ctrl+B)">
          <svg class="h-4 w-4" viewBox="0 0 16 16" fill="none"><path d="M5 3h4.5a2.5 2.5 0 010 5H5V3zM5 8h5a2.5 2.5 0 010 5H5V8z" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" /></svg>
        </button>
        <button type="button" aria-label="Italic" aria-pressed={to_string("italic" in @active_marks)} phx-click={editor_command(@editor_id, "toggleItalic")} class={btn_class("italic" in @active_marks)} title="Italic (Ctrl+I)">
          <svg class="h-4 w-4" viewBox="0 0 16 16" fill="none"><path d="M10 3H6M10 13H6M9 3L7 13" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" /></svg>
        </button>
        <button type="button" aria-label="Underline" aria-pressed={to_string("underline" in @active_marks)} phx-click={editor_command(@editor_id, "toggleUnderline")} class={btn_class("underline" in @active_marks)} title="Underline (Ctrl+U)">
          <svg class="h-4 w-4" viewBox="0 0 16 16" fill="none"><path d="M4 3v5a4 4 0 008 0V3M3 13h10" stroke="currentColor" stroke-width="1.4" stroke-linecap="round" /></svg>
        </button>
        <button type="button" aria-label="Strikethrough" aria-pressed={to_string("strike" in @active_marks)} phx-click={editor_command(@editor_id, "toggleStrike")} class={btn_class("strike" in @active_marks)}>
          <svg class="h-4 w-4" viewBox="0 0 16 16" fill="none"><line x1="2" y1="8" x2="14" y2="8" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" /><path d="M5.5 10.5c0 1.1.9 2 2 2h1c1.1 0 2-.9 2-2M10.5 5.5c0-1.1-.9-2-2-2h-1" stroke="currentColor" stroke-width="1.4" stroke-linecap="round" /></svg>
        </button>
      </div>

      <div role="separator" aria-orientation="vertical" class="mx-1 h-5 w-px shrink-0 bg-border" />

      <.text_align_group editor_id={@editor_id} active_alignment={@active_alignment} />

      <div role="separator" aria-orientation="vertical" class="mx-1 h-5 w-px shrink-0 bg-border" />

      <div role="group" aria-label="Lists" class="flex items-center gap-0.5">
        <button type="button" aria-label="Bullet list" aria-pressed={to_string("bulletList" in @active_nodes)} phx-click={editor_command(@editor_id, "toggleBulletList")} class={btn_class("bulletList" in @active_nodes)}>
          <svg class="h-4 w-4" viewBox="0 0 16 16" fill="none"><circle cx="3" cy="4.5" r="1" fill="currentColor" /><circle cx="3" cy="8" r="1" fill="currentColor" /><circle cx="3" cy="11.5" r="1" fill="currentColor" /><line x1="6" y1="4.5" x2="13" y2="4.5" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" /><line x1="6" y1="8" x2="13" y2="8" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" /><line x1="6" y1="11.5" x2="13" y2="11.5" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" /></svg>
        </button>
        <button type="button" aria-label="Ordered list" aria-pressed={to_string("orderedList" in @active_nodes)} phx-click={editor_command(@editor_id, "toggleOrderedList")} class={btn_class("orderedList" in @active_nodes)}>
          <svg class="h-4 w-4" viewBox="0 0 16 16" fill="none"><path d="M3 3h1v3H2.5M2.5 9h2l-2 2.5h2" stroke="currentColor" stroke-width="1.2" stroke-linecap="round" stroke-linejoin="round" /><line x1="7" y1="4.5" x2="13" y2="4.5" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" /><line x1="7" y1="10.5" x2="13" y2="10.5" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" /></svg>
        </button>
      </div>

      <div role="separator" aria-orientation="vertical" class="mx-1 h-5 w-px shrink-0 bg-border" />

      <.indent_controls editor_id={@editor_id} />
      <.clear_formatting_button editor_id={@editor_id} />
    </div>
    """
  end

  # ── 18. formatting_toolbar_compact ──────────────────────────────────────────

  attr :id, :string, required: true
  attr :editor_id, :string, required: true
  attr :active_marks, :list, default: []
  attr :class, :string, default: nil

  @doc "Minimal toolbar: bold/italic/underline/link."
  def formatting_toolbar_compact(assigns) do
    ~H"""
    <div
      id={@id}
      role="toolbar"
      aria-label="Compact formatting toolbar"
      class={cn(["flex items-center gap-0.5 px-1.5 py-1", @class])}
    >
      <button type="button" aria-label="Bold" aria-pressed={to_string("bold" in @active_marks)} phx-click={editor_command(@editor_id, "toggleBold")} class={btn_class("bold" in @active_marks)}>
        <svg class="h-4 w-4" viewBox="0 0 16 16" fill="none"><path d="M5 3h4.5a2.5 2.5 0 010 5H5V3zM5 8h5a2.5 2.5 0 010 5H5V8z" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" /></svg>
      </button>
      <button type="button" aria-label="Italic" aria-pressed={to_string("italic" in @active_marks)} phx-click={editor_command(@editor_id, "toggleItalic")} class={btn_class("italic" in @active_marks)}>
        <svg class="h-4 w-4" viewBox="0 0 16 16" fill="none"><path d="M10 3H6M10 13H6M9 3L7 13" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" /></svg>
      </button>
      <button type="button" aria-label="Underline" aria-pressed={to_string("underline" in @active_marks)} phx-click={editor_command(@editor_id, "toggleUnderline")} class={btn_class("underline" in @active_marks)}>
        <svg class="h-4 w-4" viewBox="0 0 16 16" fill="none"><path d="M4 3v5a4 4 0 008 0V3M3 13h10" stroke="currentColor" stroke-width="1.4" stroke-linecap="round" /></svg>
      </button>
      <button type="button" aria-label="Link" aria-pressed={to_string("link" in @active_marks)} phx-click={editor_command(@editor_id, "setLink")} class={btn_class("link" in @active_marks)}>
        <svg class="h-4 w-4" viewBox="0 0 16 16" fill="none"><path d="M6.5 9.5a3 3 0 004.24 0l2-2a3 3 0 00-4.24-4.24l-1 1M9.5 6.5a3 3 0 00-4.24 0l-2 2a3 3 0 004.24 4.24l1-1" stroke="currentColor" stroke-width="1.4" stroke-linecap="round" /></svg>
      </button>
    </div>
    """
  end

  # ── 19. formatting_toolbar_ribbon ───────────────────────────────────────────

  attr :id, :string, required: true
  attr :editor_id, :string, required: true
  attr :active_tab, :atom, default: :home, values: [:home, :insert, :format]
  attr :active_marks, :list, default: []
  attr :active_nodes, :list, default: []
  attr :class, :string, default: nil

  @doc "Office-style multi-row ribbon with tabs."
  def formatting_toolbar_ribbon(assigns) do
    ~H"""
    <div id={@id} class={cn(["rounded-t-xl border-b border-border", @class])}>
      <%!-- Tab bar --%>
      <div role="tablist" class="flex border-b border-border px-2">
        <button :for={tab <- [:home, :insert, :format]}
          type="button"
          role="tab"
          aria-selected={to_string(@active_tab == tab)}
          phx-click={Phoenix.LiveView.JS.push("editor:ribbon_tab", value: %{tab: tab})}
          class={cn([
            "px-3 py-1.5 text-xs font-medium transition-colors",
            @active_tab == tab && "border-b-2 border-primary text-primary",
            @active_tab != tab && "text-muted-foreground hover:text-foreground"
          ])}
        >
          {tab |> to_string() |> String.capitalize()}
        </button>
      </div>

      <%!-- Tab panels --%>
      <div class="px-2 py-1.5">
        <div :if={@active_tab == :home} class="flex flex-wrap items-center gap-1">
          <.font_family_selector id={"#{@id}-font"} editor_id={@editor_id} />
          <.font_size_selector id={"#{@id}-size"} editor_id={@editor_id} />
          <div role="separator" aria-orientation="vertical" class="mx-1 h-5 w-px shrink-0 bg-border" />
          <div role="group" aria-label="Text formatting" class="flex items-center gap-0.5">
            <button type="button" aria-label="Bold" aria-pressed={to_string("bold" in @active_marks)} phx-click={editor_command(@editor_id, "toggleBold")} class={btn_class("bold" in @active_marks)}>
              <svg class="h-4 w-4" viewBox="0 0 16 16" fill="none"><path d="M5 3h4.5a2.5 2.5 0 010 5H5V3zM5 8h5a2.5 2.5 0 010 5H5V8z" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" /></svg>
            </button>
            <button type="button" aria-label="Italic" aria-pressed={to_string("italic" in @active_marks)} phx-click={editor_command(@editor_id, "toggleItalic")} class={btn_class("italic" in @active_marks)}>
              <svg class="h-4 w-4" viewBox="0 0 16 16" fill="none"><path d="M10 3H6M10 13H6M9 3L7 13" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" /></svg>
            </button>
            <button type="button" aria-label="Underline" aria-pressed={to_string("underline" in @active_marks)} phx-click={editor_command(@editor_id, "toggleUnderline")} class={btn_class("underline" in @active_marks)}>
              <svg class="h-4 w-4" viewBox="0 0 16 16" fill="none"><path d="M4 3v5a4 4 0 008 0V3M3 13h10" stroke="currentColor" stroke-width="1.4" stroke-linecap="round" /></svg>
            </button>
          </div>
          <div role="separator" aria-orientation="vertical" class="mx-1 h-5 w-px shrink-0 bg-border" />
          <.text_align_group editor_id={@editor_id} />
        </div>

        <div :if={@active_tab == :insert} class="flex flex-wrap items-center gap-1">
          <button type="button" phx-click={editor_command(@editor_id, "insertTable")} class={btn_class()}>
            <svg class="h-4 w-4" viewBox="0 0 16 16" fill="none"><rect x="2" y="2" width="12" height="12" rx="1" stroke="currentColor" stroke-width="1.3" /><line x1="2" y1="6" x2="14" y2="6" stroke="currentColor" stroke-width="1.3" /><line x1="2" y1="10" x2="14" y2="10" stroke="currentColor" stroke-width="1.3" /><line x1="6" y1="2" x2="6" y2="14" stroke="currentColor" stroke-width="1.3" /><line x1="10" y1="2" x2="10" y2="14" stroke="currentColor" stroke-width="1.3" /></svg>
          </button>
          <button type="button" phx-click={editor_command(@editor_id, "setHorizontalRule")} class={btn_class()} aria-label="Horizontal rule">
            <svg class="h-4 w-4" viewBox="0 0 16 16" fill="none"><line x1="2" y1="8" x2="14" y2="8" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" /></svg>
          </button>
        </div>

        <div :if={@active_tab == :format} class="flex flex-wrap items-center gap-1">
          <.subscript_button editor_id={@editor_id} active={"subscript" in @active_marks} />
          <.superscript_button editor_id={@editor_id} active={"superscript" in @active_marks} />
          <.small_caps_button editor_id={@editor_id} />
          <.drop_cap_toggle editor_id={@editor_id} />
          <div role="separator" aria-orientation="vertical" class="mx-1 h-5 w-px shrink-0 bg-border" />
          <.clear_formatting_button editor_id={@editor_id} />
        </div>
      </div>
    </div>
    """
  end

  # ── 20. formatting_toolbar_floating ─────────────────────────────────────────

  attr :id, :string, required: true
  attr :editor_id, :string, required: true
  attr :active_marks, :list, default: []
  attr :visible, :boolean, default: false
  attr :class, :string, default: nil

  @doc "Notion-style floating toolbar on selection."
  def formatting_toolbar_floating(assigns) do
    ~H"""
    <div
      id={@id}
      role="toolbar"
      aria-label="Floating formatting toolbar"
      class={cn([
        "absolute z-50 rounded-lg border border-border bg-popover px-1 py-0.5 shadow-lg backdrop-blur-sm transition-opacity",
        @visible && "opacity-100",
        !@visible && "pointer-events-none opacity-0",
        @class
      ])}
    >
      <div class="flex items-center gap-0.5">
        <button type="button" aria-label="Bold" aria-pressed={to_string("bold" in @active_marks)} phx-click={editor_command(@editor_id, "toggleBold")} class={btn_class("bold" in @active_marks)}>
          <svg class="h-4 w-4" viewBox="0 0 16 16" fill="none"><path d="M5 3h4.5a2.5 2.5 0 010 5H5V3zM5 8h5a2.5 2.5 0 010 5H5V8z" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" /></svg>
        </button>
        <button type="button" aria-label="Italic" aria-pressed={to_string("italic" in @active_marks)} phx-click={editor_command(@editor_id, "toggleItalic")} class={btn_class("italic" in @active_marks)}>
          <svg class="h-4 w-4" viewBox="0 0 16 16" fill="none"><path d="M10 3H6M10 13H6M9 3L7 13" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" /></svg>
        </button>
        <button type="button" aria-label="Underline" aria-pressed={to_string("underline" in @active_marks)} phx-click={editor_command(@editor_id, "toggleUnderline")} class={btn_class("underline" in @active_marks)}>
          <svg class="h-4 w-4" viewBox="0 0 16 16" fill="none"><path d="M4 3v5a4 4 0 008 0V3M3 13h10" stroke="currentColor" stroke-width="1.4" stroke-linecap="round" /></svg>
        </button>
        <button type="button" aria-label="Strikethrough" aria-pressed={to_string("strike" in @active_marks)} phx-click={editor_command(@editor_id, "toggleStrike")} class={btn_class("strike" in @active_marks)}>
          <svg class="h-4 w-4" viewBox="0 0 16 16" fill="none"><line x1="2" y1="8" x2="14" y2="8" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" /></svg>
        </button>
        <div role="separator" aria-orientation="vertical" class="mx-0.5 h-4 w-px shrink-0 bg-border" />
        <button type="button" aria-label="Link" aria-pressed={to_string("link" in @active_marks)} phx-click={editor_command(@editor_id, "setLink")} class={btn_class("link" in @active_marks)}>
          <svg class="h-4 w-4" viewBox="0 0 16 16" fill="none"><path d="M6.5 9.5a3 3 0 004.24 0l2-2a3 3 0 00-4.24-4.24l-1 1M9.5 6.5a3 3 0 00-4.24 0l-2 2a3 3 0 004.24 4.24l1-1" stroke="currentColor" stroke-width="1.4" stroke-linecap="round" /></svg>
        </button>
        <button type="button" aria-label="Inline code" aria-pressed={to_string("code" in @active_marks)} phx-click={editor_command(@editor_id, "toggleCode")} class={btn_class("code" in @active_marks)}>
          <svg class="h-4 w-4" viewBox="0 0 16 16" fill="none"><path d="M5 5L2 8L5 11M11 5L14 8L11 11" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" /></svg>
        </button>
      </div>
    </div>
    """
  end
end
