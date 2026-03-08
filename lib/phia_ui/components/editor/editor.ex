defmodule PhiaUi.Components.Editor do
  @moduledoc """
  Editor Suite — 19 components for building rich text editing experiences.

  Inspired by **TipTap** — the most popular headless rich text editor (2.5M+ weekly
  npm downloads, built on ProseMirror, used by Notion, Linear, Vercel, and more) —
  this module provides all the building blocks needed to assemble a full-featured editor.

  ## Research: Most Popular Rich Text Editors (2025)

  | Editor       | Weekly DLs  | Foundation    | Used by                        |
  |--------------|-------------|---------------|--------------------------------|
  | **TipTap**   | 2.5M+       | ProseMirror   | Notion clones, Linear, Vercel  |
  | Quill v2     | 1.8M+       | Custom        | Slack, LinkedIn, Figma, Airtable |
  | Lexical      | 1.2M+       | Custom (Meta) | Facebook, WhatsApp Web         |
  | ProseMirror  | 900K+       | —             | Base for TipTap/Remirror       |
  | CKEditor 5   | 600K+       | Custom        | Enterprise / CMS               |

  TipTap wins on DX: headless, framework-agnostic, tree-shakable, collaborative.
  `advanced_editor/1` is a PhiaUI transpilation of TipTap's editor design.

  ## Components

  ### Group A — Toolbar Primitives (no JS hooks)
  - `editor_toolbar/1`     — `role="toolbar"` wrapper
  - `toolbar_button/1`     — single action button (active, disabled, size variants)
  - `toolbar_group/1`      — `role="group"` semantic grouping
  - `toolbar_separator/1`  — vertical `role="separator"` divider

  ### Group B — Floating / Contextual (JS hooks)
  - `bubble_menu/1`         — floating toolbar above text selection (PhiaBubbleMenu)
  - `floating_menu/1`       — block-insertion menu at empty cursor (PhiaFloatingMenu)
  - `slash_command_menu/1`  — `/` trigger command palette (PhiaSlashCommand)

  ### Group C — Enhanced Inline Editing
  - `inline_edit/1`         — extended editable with type/validation/buttons (PhiaEditable)
  - `inline_edit_group/1`   — wrapper for bulk-editing multiple inline fields

  ### Group D — Rich Text Utilities
  - `editor_color_picker/1`       — text/bg color palette toolbar dropdown (PhiaEditorColorPicker)
  - `editor_toolbar_dropdown/1`   — generic toolbar dropdown (PhiaEditorDropdown)
  - `editor_link_dialog/1`        — modal for insert/edit link
  - `editor_code_block/1`         — language badge + copy button + line numbers
  - `editor_character_count/1`    — char/word counter with optional progress bar
  - `markdown_editor/1`           — split-pane textarea + preview (PhiaMarkdownEditor)
  - `rich_text_viewer/1`          — read-only HTML container with prose sizing
  - `editor_find_replace/1`       — slide-in search+replace bar (PhiaEditorFindReplace)
  - `editor_word_count/1`         — words / reading-time display widget

  ### Bonus — TipTap-Inspired Full Editor
  - `advanced_editor/1`           — complete WYSIWYG combining all primitives (PhiaAdvancedEditor)
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  # ============================================================================
  # Group A — Toolbar Primitives
  # ============================================================================

  # ----------------------------------------------------------------------------
  # editor_toolbar/1
  # ----------------------------------------------------------------------------

  attr :id, :string, default: nil
  attr :variant, :atom, default: :default, values: [:default, :floating, :compact]
  attr :aria_label, :string, default: "Editor toolbar"
  attr :class, :string, default: nil
  attr :rest, :global

  slot :inner_block, required: true

  @doc """
  Renders a `role="toolbar"` container for editor controls.

  Variants:
  - `:default` — bordered bar, wraps to multiple lines
  - `:floating` — elevated popover-style (shadow, backdrop blur)
  - `:compact` — minimal single-line strip

  ## Example

      <.editor_toolbar aria_label="Formatting toolbar">
        <.toolbar_button action="bold" aria_label="Bold">
          <svg .../>
        </.toolbar_button>
      </.editor_toolbar>
  """
  def editor_toolbar(assigns) do
    ~H"""
    <div
      id={@id}
      role="toolbar"
      aria-label={@aria_label}
      class={cn([toolbar_variant(@variant), @class])}
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end

  defp toolbar_variant(:default),
    do: "flex flex-wrap items-center gap-0.5 rounded-md border border-input bg-background p-1"

  defp toolbar_variant(:floating),
    do:
      "flex items-center gap-0.5 rounded-lg border border-border bg-popover px-1.5 py-1 shadow-lg backdrop-blur-sm"

  defp toolbar_variant(:compact),
    do: "flex items-center gap-px rounded border border-input bg-muted/30 px-0.5 py-0.5"

  # ----------------------------------------------------------------------------
  # toolbar_button/1
  # ----------------------------------------------------------------------------

  attr :action, :string, required: true
  attr :aria_label, :string, required: true
  attr :active, :boolean, default: false
  attr :disabled, :boolean, default: false
  attr :tooltip, :string, default: nil
  attr :size, :atom, default: :sm, values: [:xs, :sm, :md]
  attr :class, :string, default: nil
  attr :rest, :global

  slot :inner_block, required: true

  @doc """
  Renders a single toolbar action button.

  The hook reads `data-action` to dispatch formatting commands and toggles
  `aria-pressed` and the `is-active` CSS class automatically.

  ## Example

      <.toolbar_button action="bold" aria_label="Bold" tooltip="Bold (Ctrl+B)" active={@bold_active}>
        <svg class="h-4 w-4" viewBox="0 0 16 16" fill="none">
          <path d="M5 3h4.5a2.5 2.5 0 010 5H5V3zM5 8h5a2.5 2.5 0 010 5H5V8z"
                stroke="currentColor" stroke-width="1.5" stroke-linecap="round"/>
        </svg>
      </.toolbar_button>
  """
  def toolbar_button(assigns) do
    ~H"""
    <button
      type="button"
      data-action={@action}
      aria-label={@aria_label}
      aria-pressed={to_string(@active)}
      disabled={@disabled}
      title={@tooltip}
      class={cn([
        "inline-flex items-center justify-center rounded text-foreground transition-colors",
        "hover:bg-accent hover:text-accent-foreground",
        "focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring",
        "disabled:pointer-events-none disabled:opacity-40",
        "is-active:bg-accent is-active:text-accent-foreground",
        @active && "bg-accent text-accent-foreground",
        toolbar_btn_size(@size),
        @class
      ])}
      {@rest}
    >
      {render_slot(@inner_block)}
    </button>
    """
  end

  defp toolbar_btn_size(:xs), do: "h-6 w-6 p-1"
  defp toolbar_btn_size(:sm), do: "h-7 w-7 p-1.5"
  defp toolbar_btn_size(:md), do: "h-8 w-8 p-2"

  # ----------------------------------------------------------------------------
  # toolbar_group/1
  # ----------------------------------------------------------------------------

  attr :label, :string, default: nil
  attr :class, :string, default: nil

  slot :inner_block, required: true

  @doc """
  Renders a `role="group"` semantic group for related toolbar buttons.

  ## Example

      <.toolbar_group label="Text formatting">
        <.toolbar_button action="bold" aria_label="Bold">...</.toolbar_button>
        <.toolbar_button action="italic" aria_label="Italic">...</.toolbar_button>
      </.toolbar_group>
  """
  def toolbar_group(assigns) do
    ~H"""
    <div
      role="group"
      aria-label={@label}
      class={cn(["flex items-center gap-0.5", @class])}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end

  # ----------------------------------------------------------------------------
  # toolbar_separator/1
  # ----------------------------------------------------------------------------

  attr :class, :string, default: nil

  @doc """
  Renders a thin vertical `role="separator"` divider between toolbar groups.

  ## Example

      <.toolbar_group label="Marks">...</.toolbar_group>
      <.toolbar_separator />
      <.toolbar_group label="Blocks">...</.toolbar_group>
  """
  def toolbar_separator(assigns) do
    ~H"""
    <div
      role="separator"
      aria-orientation="vertical"
      class={cn(["mx-1 h-5 w-px shrink-0 bg-border", @class])}
    />
    """
  end

  # ============================================================================
  # Group B — Floating / Contextual
  # ============================================================================

  # ----------------------------------------------------------------------------
  # bubble_menu/1
  # ----------------------------------------------------------------------------

  attr :id, :string, required: true
  attr :editor_id, :string, required: true
  attr :class, :string, default: nil

  slot :inner_block, required: true

  @doc """
  Renders a floating toolbar that appears above the user's text selection.

  The `PhiaBubbleMenu` hook listens to `selectionchange`, computes the selection
  bounding rect, and positions this div above the selected text. Clamps to viewport.

  ## Example

      <.bubble_menu id="bubble" editor_id="my-editor">
        <.toolbar_button action="bold" aria_label="Bold" size={:xs}>
          <svg .../>
        </.toolbar_button>
      </.bubble_menu>
  """
  def bubble_menu(assigns) do
    ~H"""
    <div
      id={@id}
      phx-hook="PhiaBubbleMenu"
      data-editor-id={@editor_id}
      class={"hidden " <> cn([
        "fixed z-50 flex items-center gap-0.5 rounded-lg",
        "border border-border bg-popover px-1.5 py-1 shadow-lg",
        @class
      ])}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end

  # ----------------------------------------------------------------------------
  # floating_menu/1
  # ----------------------------------------------------------------------------

  attr :id, :string, required: true
  attr :editor_id, :string, required: true
  attr :trigger, :atom, default: :empty_line, values: [:empty_line, :slash]
  attr :class, :string, default: nil

  slot :inner_block, required: true

  @doc """
  Renders a block-insertion menu that floats at the empty cursor line.

  The `PhiaFloatingMenu` hook shows this panel when the cursor is on an empty block,
  and hides it on any text input or Escape.

  ## Example

      <.floating_menu id="float-menu" editor_id="my-editor" trigger={:empty_line}>
        <.toolbar_button action="bulletList" aria_label="Bullet list">...</.toolbar_button>
        <.toolbar_button action="h1" aria_label="Heading 1">...</.toolbar_button>
      </.floating_menu>
  """
  def floating_menu(assigns) do
    ~H"""
    <div
      id={@id}
      phx-hook="PhiaFloatingMenu"
      data-editor-id={@editor_id}
      data-trigger={to_string(@trigger)}
      class={"hidden " <> cn([
        "fixed z-50 flex items-center gap-1",
        "rounded-lg border border-border bg-popover px-2 py-1.5 shadow-md",
        @class
      ])}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end

  # ----------------------------------------------------------------------------
  # slash_command_menu/1
  # ----------------------------------------------------------------------------

  attr :id, :string, required: true
  attr :editor_id, :string, required: true
  attr :on_select, :string, required: true
  attr :class, :string, default: nil

  slot :item do
    attr :value, :string, required: true
    attr :label, :string, required: true
    attr :icon, :string
    attr :description, :string
    attr :shortcut, :string
  end

  @doc """
  Renders a `/` trigger command palette for block-level actions.

  The `PhiaSlashCommand` hook activates when the user types `/` at the start of an
  empty block. It fuzzy-filters items, supports arrow-key navigation and Enter to select.

  ## Example

      <.slash_command_menu id="slash" editor_id="my-editor" on_select="block_inserted">
        <:item value="h1" label="Heading 1" icon="H1" description="Large section heading" shortcut="/h1" />
        <:item value="bulletList" label="Bullet List" icon="•" description="Simple unordered list" />
        <:item value="codeBlock" label="Code Block" icon="<>" description="Insert code snippet" />
      </.slash_command_menu>
  """
  def slash_command_menu(assigns) do
    items_data =
      Enum.map(assigns.item, fn item ->
        %{
          value: Map.get(item, :value, ""),
          label: Map.get(item, :label, ""),
          icon: Map.get(item, :icon, nil),
          description: Map.get(item, :description, nil),
          shortcut: Map.get(item, :shortcut, nil)
        }
      end)

    assigns = assign(assigns, :items_json, Jason.encode!(items_data))

    ~H"""
    <div
      id={@id}
      phx-hook="PhiaSlashCommand"
      data-editor-id={@editor_id}
      data-on-select={@on_select}
      data-items={@items_json}
      class={cn([
        "hidden fixed z-50 w-72 rounded-lg border border-border bg-popover p-1 shadow-xl",
        @class
      ])}
    >
      <div class="px-2 py-1.5">
        <input
          type="text"
          placeholder="Search commands..."
          data-slash-search
          class="w-full bg-transparent text-sm text-foreground outline-none placeholder:text-muted-foreground"
        />
      </div>
      <div class="mx-1 h-px bg-border" />
      <div class="max-h-64 overflow-y-auto py-1" data-slash-list>
        <div
          :for={item <- @item}
          data-value={item.value}
          data-slash-item
          class="flex cursor-pointer items-start gap-2 rounded-md px-2 py-1.5 text-sm hover:bg-accent"
        >
          <span
            :if={Map.get(item, :icon)}
            class="mt-0.5 flex h-5 w-5 shrink-0 items-center justify-center rounded bg-muted font-mono text-xs text-muted-foreground"
          >
            {Map.get(item, :icon, "")}
          </span>
          <div class="min-w-0 flex-1">
            <div class="font-medium text-foreground">{item.label}</div>
            <div :if={Map.get(item, :description)} class="truncate text-xs text-muted-foreground">
              {Map.get(item, :description, "")}
            </div>
          </div>
          <kbd
            :if={Map.get(item, :shortcut)}
            class="ml-auto shrink-0 rounded border border-border bg-muted px-1.5 py-0.5 font-mono text-xs text-muted-foreground"
          >
            {Map.get(item, :shortcut, "")}
          </kbd>
        </div>
      </div>
    </div>
    """
  end

  # ============================================================================
  # Group C — Enhanced Inline Editing
  # ============================================================================

  # ----------------------------------------------------------------------------
  # inline_edit/1
  # ----------------------------------------------------------------------------

  attr :id, :string, required: true
  attr :value, :string, default: nil
  attr :type, :atom, default: :text, values: [:text, :number, :textarea, :select]
  attr :placeholder, :string, default: "Click to edit"
  attr :on_submit, :string, default: nil
  attr :on_cancel, :string, default: nil
  attr :show_buttons, :boolean, default: false
  attr :loading, :boolean, default: false
  attr :error, :string, default: nil
  attr :required, :boolean, default: false
  attr :min, :any, default: nil
  attr :max, :any, default: nil
  attr :options, :list, default: []
  attr :class, :string, default: nil

  slot :preview

  @doc """
  Enhanced inline editable field. Extends `editable/1` with input type variants,
  validation errors, loading state, and optional confirm/cancel buttons.

  Uses the `PhiaEditable` hook (same as `editable/1`).

  ## Example

      <.inline_edit id="title-edit" value={@title} type={:text} on_submit="update_title"
                    show_buttons placeholder="Enter a title...">
        <:preview>{@title}</:preview>
      </.inline_edit>
  """
  def inline_edit(assigns) do
    ~H"""
    <div
      id={@id}
      phx-hook="PhiaEditable"
      data-on-submit={@on_submit}
      data-on-cancel={@on_cancel}
      data-placeholder={@placeholder}
      class={cn(["group relative w-full", @class])}
    >
      <%!-- Preview mode --%>
      <div
        data-editable-preview
        role="button"
        tabindex="0"
        aria-label={@placeholder}
        class="flex min-h-8 cursor-pointer items-center rounded-md px-2 py-1 ring-1 ring-transparent hover:ring-border"
      >
        <span class="flex-1">
          {if @preview != [],
            do: render_slot(@preview),
            else: @value || @placeholder}
        </span>
        <span
          :if={@loading}
          class="ml-2 inline-block h-3 w-3 animate-spin rounded-full border border-muted-foreground border-t-transparent"
        />
      </div>

      <%!-- Edit mode --%>
      <div data-editable-input class="hidden space-y-1.5">
        <input
          :if={@type == :text}
          type="text"
          value={@value}
          placeholder={@placeholder}
          required={@required}
          data-edit-input
          class={cn([
            "w-full rounded-md border border-input bg-background px-3 py-1.5 text-sm",
            "placeholder:text-muted-foreground focus:outline-none focus:ring-2 focus:ring-ring",
            @error && "border-destructive focus:ring-destructive"
          ])}
        />
        <input
          :if={@type == :number}
          type="number"
          value={@value}
          placeholder={@placeholder}
          required={@required}
          min={@min}
          max={@max}
          data-edit-input
          class={cn([
            "w-full rounded-md border border-input bg-background px-3 py-1.5 text-sm",
            "placeholder:text-muted-foreground focus:outline-none focus:ring-2 focus:ring-ring",
            @error && "border-destructive focus:ring-destructive"
          ])}
        />
        <textarea
          :if={@type == :textarea}
          placeholder={@placeholder}
          required={@required}
          rows="3"
          data-edit-input
          class={cn([
            "w-full resize-none rounded-md border border-input bg-background px-3 py-1.5 text-sm",
            "placeholder:text-muted-foreground focus:outline-none focus:ring-2 focus:ring-ring",
            @error && "border-destructive focus:ring-destructive"
          ])}
        >{@value}</textarea>
        <select
          :if={@type == :select}
          required={@required}
          data-edit-input
          class={cn([
            "w-full rounded-md border border-input bg-background px-3 py-1.5 text-sm",
            "focus:outline-none focus:ring-2 focus:ring-ring",
            @error && "border-destructive focus:ring-destructive"
          ])}
        >
          <option :for={opt <- @options} value={inline_opt_value(opt)} selected={inline_opt_value(opt) == @value}>
            {inline_opt_label(opt)}
          </option>
        </select>

        <p :if={@error} class="text-xs text-destructive">{@error}</p>

        <div :if={@show_buttons} class="flex gap-2">
          <button
            type="button"
            data-edit-submit
            class="inline-flex h-7 items-center rounded-md bg-primary px-3 text-xs font-medium text-primary-foreground hover:bg-primary/90"
          >
            Save
          </button>
          <button
            type="button"
            data-edit-cancel
            class="inline-flex h-7 items-center rounded-md border border-input bg-background px-3 text-xs font-medium text-foreground hover:bg-accent"
          >
            Cancel
          </button>
        </div>
      </div>
    </div>
    """
  end

  defp inline_opt_value({v, _l}), do: to_string(v)
  defp inline_opt_value(v) when is_binary(v), do: v
  defp inline_opt_value(v), do: to_string(v)

  defp inline_opt_label({_v, l}), do: l
  defp inline_opt_label(v) when is_binary(v), do: v
  defp inline_opt_label(v), do: to_string(v)

  # ----------------------------------------------------------------------------
  # inline_edit_group/1
  # ----------------------------------------------------------------------------

  attr :id, :string, required: true
  attr :on_save_all, :string, default: nil
  attr :on_cancel_all, :string, default: nil
  attr :class, :string, default: nil

  slot :inner_block, required: true
  slot :actions

  @doc """
  Wrapper for grouping multiple `inline_edit/1` fields that share a bulk save/cancel flow.

  Pass custom action buttons via the `:actions` slot, or use `on_save_all`/`on_cancel_all`
  to auto-render default Save all / Cancel buttons.

  ## Example

      <.inline_edit_group id="profile-edit" on_save_all="save_profile" on_cancel_all="reset_profile">
        <.inline_edit id="name-edit" value={@name} on_submit="update_name" />
        <.inline_edit id="email-edit" value={@email} on_submit="update_email" />
      </.inline_edit_group>
  """
  def inline_edit_group(assigns) do
    ~H"""
    <div id={@id} class={cn(["space-y-2", @class])}>
      {render_slot(@inner_block)}

      <div :if={@actions != []} class="flex gap-2 pt-2">
        {render_slot(@actions)}
      </div>

      <div :if={@actions == [] && (@on_save_all || @on_cancel_all)} class="flex gap-2 pt-2">
        <button
          :if={@on_save_all}
          type="button"
          phx-click={@on_save_all}
          class="inline-flex h-8 items-center rounded-md bg-primary px-4 text-sm font-medium text-primary-foreground hover:bg-primary/90"
        >
          Save all
        </button>
        <button
          :if={@on_cancel_all}
          type="button"
          phx-click={@on_cancel_all}
          class="inline-flex h-8 items-center rounded-md border border-input bg-background px-4 text-sm font-medium hover:bg-accent"
        >
          Cancel
        </button>
      </div>
    </div>
    """
  end

  # ============================================================================
  # Group D — Rich Text Utilities
  # ============================================================================

  # ----------------------------------------------------------------------------
  # editor_color_picker/1
  # ----------------------------------------------------------------------------

  @default_colors ~w[
    #000000 #374151 #6B7280 #9CA3AF #D1D5DB #F9FAFB #FFFFFF
    #EF4444 #F97316 #EAB308 #22C55E #3B82F6 #8B5CF6 #EC4899
  ]

  attr :id, :string, default: nil
  attr :action, :string, default: "foreColor"
  attr :label, :string, default: "Text color"
  attr :colors, :list, default: []
  attr :value, :string, default: nil
  attr :class, :string, default: nil

  @doc """
  Renders a color palette picker toolbar dropdown for text/background colors.

  The `PhiaEditorColorPicker` hook dispatches `execCommand(action, false, hex)`
  on swatch click and tracks the current color via `queryCommandValue` on selection change.

  ## Example

      <.editor_color_picker action="foreColor" label="Text color" />
      <.editor_color_picker action="hiliteColor" label="Highlight" value="#EAB308" />
  """
  def editor_color_picker(assigns) do
    palette = if assigns.colors == [], do: @default_colors, else: assigns.colors
    picker_id = assigns.id || "phia-color-picker-#{System.unique_integer([:positive])}"

    assigns =
      assigns
      |> assign(:palette, palette)
      |> assign(:picker_id, picker_id)

    ~H"""
    <div
      id={@picker_id}
      class={cn(["relative z-50", @class])}
      phx-hook="PhiaEditorColorPicker"
      data-action={@action}
    >
      <button
        type="button"
        aria-label={@label}
        data-color-trigger
        class="inline-flex h-7 w-7 items-center justify-center rounded hover:bg-accent focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring"
      >
        <span class="relative flex h-5 w-5 flex-col items-center justify-center">
          <%!-- Letter A icon --%>
          <svg class="h-3.5 w-3.5" viewBox="0 0 14 14" fill="none" xmlns="http://www.w3.org/2000/svg">
            <path d="M2 11L5.5 3L9 11M3.5 8h4" stroke="currentColor" stroke-width="1.4" stroke-linecap="round" stroke-linejoin="round"/>
          </svg>
          <%!-- Color indicator bar --%>
          <span
            class="mt-0.5 h-1 w-4 rounded-full"
            style={if @value, do: "background-color: #{@value}", else: "background-color: currentColor"}
            data-color-indicator
          />
        </span>
      </button>

      <%!-- Palette panel --%>
      <div
        data-color-panel
        class="absolute left-0 top-full z-50 mt-1 hidden w-44 rounded-lg border border-border bg-popover p-2.5 shadow-lg"
      >
        <p class="mb-2 text-xs font-medium text-muted-foreground">{@label}</p>
        <div class="grid grid-cols-7 gap-1.5">
          <button
            :for={color <- @palette}
            type="button"
            data-color-swatch={color}
            title={color}
            class="phia-swatch h-5 w-5 rounded border border-white/20 shadow-sm transition-transform hover:scale-110 focus:outline-none focus-visible:ring-1 focus-visible:ring-ring"
            style={"background-color: #{color}"}
          />
        </div>
      </div>
    </div>
    """
  end

  # ----------------------------------------------------------------------------
  # editor_toolbar_dropdown/1
  # ----------------------------------------------------------------------------

  attr :id, :string, required: true
  attr :label, :string, required: true
  attr :value, :string, default: nil
  attr :class, :string, default: nil

  slot :item do
    attr :value, :string, required: true
    attr :action, :string
    attr :label, :string, required: true
  end

  @doc """
  Renders a generic dropdown inside a toolbar (heading level, font size, etc.).

  The `PhiaEditorDropdown` hook toggles the panel on trigger click and dispatches
  the selected item's `data-action` to the linked editor.

  ## Example

      <.editor_toolbar_dropdown id="heading-dd" label="Paragraph">
        <:item value="paragraph" action="paragraph" label="Paragraph" />
        <:item value="h1" action="h1" label="Heading 1" />
        <:item value="h2" action="h2" label="Heading 2" />
        <:item value="h3" action="h3" label="Heading 3" />
      </.editor_toolbar_dropdown>
  """
  def editor_toolbar_dropdown(assigns) do
    ~H"""
    <div
      id={@id}
      class={cn(["relative z-50", @class])}
      phx-hook="PhiaEditorDropdown"
    >
      <button
        type="button"
        data-dropdown-trigger
        aria-expanded="false"
        aria-haspopup="listbox"
        class="inline-flex h-7 items-center gap-1 rounded px-2 text-sm font-medium text-foreground hover:bg-accent focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring"
      >
        <span data-dropdown-label>{@value || @label}</span>
        <svg class="h-3 w-3 text-muted-foreground" viewBox="0 0 12 12" fill="none">
          <path
            d="M2 4L6 8L10 4"
            stroke="currentColor"
            stroke-width="1.5"
            stroke-linecap="round"
            stroke-linejoin="round"
          />
        </svg>
      </button>

      <div
        data-dropdown-panel
        role="listbox"
        class="absolute left-0 top-full z-50 mt-1 hidden min-w-[9rem] rounded-lg border border-border bg-popover py-1 shadow-lg"
      >
        <div
          :for={item <- @item}
          role="option"
          data-value={item.value}
          data-action={Map.get(item, :action, item.value)}
          class="cursor-pointer px-3 py-1.5 text-sm text-foreground hover:bg-accent"
        >
          {item.label}
        </div>
      </div>
    </div>
    """
  end

  # ----------------------------------------------------------------------------
  # editor_link_dialog/1
  # ----------------------------------------------------------------------------

  attr :id, :string, required: true
  attr :on_submit, :string, default: nil
  attr :initial_url, :string, default: nil
  attr :initial_title, :string, default: nil
  attr :class, :string, default: nil

  @doc """
  Renders a modal dialog for inserting or editing a hyperlink.

  Fields: URL, title (optional), open-in-new-tab checkbox.
  The dialog is shown/hidden programmatically via the editor hook calling
  `document.getElementById(id).classList.remove('hidden')`.

  ## Example

      <.editor_link_dialog id="link-dialog" on_submit="insert_link" />
  """
  def editor_link_dialog(assigns) do
    ~H"""
    <div
      id={@id}
      class={cn(["hidden", @class])}
      data-link-dialog
    >
      <%!-- Backdrop --%>
      <div
        class="fixed inset-0 z-40 bg-background/80 backdrop-blur-sm"
        data-link-backdrop
        aria-hidden="true"
      />

      <%!-- Dialog panel --%>
      <div class="fixed left-1/2 top-1/2 z-50 w-full max-w-sm -translate-x-1/2 -translate-y-1/2 rounded-xl border border-border bg-popover p-6 shadow-xl">
        <div class="mb-4 flex items-center justify-between">
          <h3 class="text-base font-semibold text-foreground">Insert link</h3>
          <button
            type="button"
            data-link-close
            aria-label="Close"
            class="inline-flex h-7 w-7 items-center justify-center rounded text-muted-foreground hover:bg-accent hover:text-foreground"
          >
            <svg class="h-4 w-4" viewBox="0 0 16 16" fill="none">
              <path
                d="M12 4L4 12M4 4L12 12"
                stroke="currentColor"
                stroke-width="1.5"
                stroke-linecap="round"
              />
            </svg>
          </button>
        </div>

        <div class="space-y-3">
          <div class="space-y-1.5">
            <label class="text-sm font-medium text-foreground" for={"#{@id}-url"}>URL</label>
            <input
              id={"#{@id}-url"}
              type="url"
              value={@initial_url}
              placeholder="https://example.com"
              data-link-url
              class="w-full rounded-md border border-input bg-background px-3 py-2 text-sm placeholder:text-muted-foreground focus:outline-none focus:ring-2 focus:ring-ring"
            />
          </div>

          <div class="space-y-1.5">
            <label class="text-sm font-medium text-foreground" for={"#{@id}-title"}>
              Title <span class="text-muted-foreground font-normal">(optional)</span>
            </label>
            <input
              id={"#{@id}-title"}
              type="text"
              value={@initial_title}
              placeholder="Link description"
              data-link-title
              class="w-full rounded-md border border-input bg-background px-3 py-2 text-sm placeholder:text-muted-foreground focus:outline-none focus:ring-2 focus:ring-ring"
            />
          </div>

          <label class="flex cursor-pointer items-center gap-2.5">
            <input
              type="checkbox"
              id={"#{@id}-new-tab"}
              data-link-new-tab
              class="rounded border-input accent-primary"
            />
            <span class="text-sm text-foreground">Open in new tab</span>
          </label>
        </div>

        <div class="mt-5 flex justify-end gap-2">
          <button
            type="button"
            data-link-close
            class="inline-flex h-9 items-center rounded-md border border-input bg-background px-4 text-sm font-medium hover:bg-accent"
          >
            Cancel
          </button>
          <button
            type="button"
            data-link-submit
            phx-click={@on_submit}
            class="inline-flex h-9 items-center rounded-md bg-primary px-4 text-sm font-medium text-primary-foreground hover:bg-primary/90"
          >
            Insert link
          </button>
        </div>
      </div>
    </div>
    """
  end

  # ----------------------------------------------------------------------------
  # editor_code_block/1
  # ----------------------------------------------------------------------------

  attr :id, :string, default: "editor-code-block"
  attr :language, :string, default: nil
  attr :filename, :string, default: nil
  attr :show_copy, :boolean, default: true
  attr :copy_value, :string, default: nil
  attr :show_line_numbers, :boolean, default: false
  attr :class, :string, default: nil

  slot :inner_block, required: true

  @doc """
  Renders a styled code block with a header bar (language badge, filename, copy button).

  The copy button reuses `PhiaCopyButton` via `data-value={copy_value}`.
  Pass `copy_value` with the raw code string for clipboard support.

  ## Example

      <.editor_code_block id="my-snippet" language="elixir" filename="hello.ex"
                          copy_value={@raw_code}>
        def hello, do: IO.puts("Hello, world!")
      </.editor_code_block>
  """
  def editor_code_block(assigns) do
    ~H"""
    <div
      class={cn(["group overflow-hidden rounded-lg border border-border bg-muted/50", @class])}
      data-code-block
    >
      <%!-- Header bar --%>
      <div class="flex items-center justify-between border-b border-border bg-muted/80 px-3 py-1.5">
        <div class="flex items-center gap-2">
          <%!-- Traffic-light dots --%>
          <div class="flex gap-1.5" aria-hidden="true">
            <span class="h-3 w-3 rounded-full bg-red-400/70" />
            <span class="h-3 w-3 rounded-full bg-yellow-400/70" />
            <span class="h-3 w-3 rounded-full bg-green-400/70" />
          </div>

          <span :if={@filename} class="font-mono text-xs font-medium text-muted-foreground">
            {@filename}
          </span>

          <span
            :if={@language && !@filename}
            class="rounded bg-primary/10 px-1.5 py-0.5 font-mono text-xs font-medium text-primary"
          >
            {@language}
          </span>
        </div>

        <button
          :if={@show_copy && @copy_value}
          id={"#{@id}-copy-btn"}
          type="button"
          phx-hook="PhiaCopyButton"
          data-value={@copy_value}
          aria-label="Copy code"
          class="inline-flex h-6 items-center gap-1 rounded px-2 text-xs text-muted-foreground opacity-0 transition-opacity hover:bg-background hover:text-foreground group-hover:opacity-100"
        >
          <svg data-copy-icon class="h-3 w-3" viewBox="0 0 16 16" fill="none">
            <rect x="5" y="5" width="9" height="9" rx="1.5" stroke="currentColor" stroke-width="1.5" />
            <path
              d="M11 5V3.5A1.5 1.5 0 009.5 2h-6A1.5 1.5 0 002 3.5v6A1.5 1.5 0 003.5 11H5"
              stroke="currentColor"
              stroke-width="1.5"
            />
          </svg>
          <svg data-copy-check class="hidden h-3 w-3" viewBox="0 0 16 16" fill="none">
            <path
              d="M3 8L6.5 11.5L13 5"
              stroke="currentColor"
              stroke-width="1.5"
              stroke-linecap="round"
              stroke-linejoin="round"
            />
          </svg>
          <span aria-live="polite" class="sr-only"></span>
          Copy
        </button>
      </div>

      <%!-- Code area with optional line numbers --%>
      <div class="overflow-x-auto">
        <div class="flex">
          <%!-- Line numbers --%>
          <div
            :if={@show_line_numbers}
            class="select-none border-r border-border bg-muted/30 px-3 py-4 text-right font-mono text-xs leading-relaxed text-muted-foreground/60"
            aria-hidden="true"
          >
            1
          </div>
          <pre
            id={"#{@id}-content"}
            class="flex-1 p-4 font-mono text-sm leading-relaxed text-foreground"
          ><code>{render_slot(@inner_block)}</code></pre>
        </div>
      </div>
    </div>
    """
  end

  # ----------------------------------------------------------------------------
  # editor_character_count/1
  # ----------------------------------------------------------------------------

  attr :count, :integer, default: 0
  attr :max, :integer, default: nil
  attr :mode, :atom, default: :characters, values: [:characters, :words, :both]
  attr :show_bar, :boolean, default: false
  attr :class, :string, default: nil

  @doc """
  Renders a server-side character/word counter with optional progress bar.

  Drives via `phx-change` on the editor: the LiveView counts characters/words
  and assigns `:count`. The progress bar fills and changes colour as `count` nears `max`.

  ## Example

      <.editor_character_count count={@char_count} max={500} mode={:characters} show_bar />
      <.editor_character_count count={@word_count} max={100} mode={:words} />
      <.editor_character_count count={@char_count} mode={:both} />
  """
  def editor_character_count(assigns) do
    ~H"""
    <div class={cn(["space-y-1", @class])}>
      <div class="flex items-center justify-between text-xs text-muted-foreground">
        <span :if={@mode == :characters || @mode == :both}>
          <span class={cn(["font-medium", @max && @count >= @max && "text-destructive"])}>
            {@count}
          </span>
          {if @max, do: " / #{@max}", else: ""} characters
        </span>
        <span :if={@mode == :words || @mode == :both}>
          <span class="font-medium text-foreground">{char_to_words(@count)}</span> words
        </span>
      </div>

      <div :if={@show_bar && @max && @max > 0} class="h-1 w-full overflow-hidden rounded-full bg-muted">
        <div
          class={cn(["h-full rounded-full transition-all duration-300", count_bar_color(@count, @max)])}
          style={"width: #{min(100, trunc(@count * 100 / @max))}%"}
        />
      </div>
    </div>
    """
  end

  defp char_to_words(0), do: 0
  defp char_to_words(chars), do: max(0, div(chars, 5))

  defp count_bar_color(count, max) when not is_nil(max) and count >= max, do: "bg-destructive"

  defp count_bar_color(count, max)
       when not is_nil(max) and count >= div(max * 9, 10),
       do: "bg-orange-500"

  defp count_bar_color(_count, _max), do: "bg-primary"

  # ----------------------------------------------------------------------------
  # markdown_editor/1
  # ----------------------------------------------------------------------------

  attr :id, :string, required: true
  attr :value, :string, default: nil
  attr :preview_html, :string, default: nil
  attr :on_change, :string, default: nil
  attr :label, :string, default: nil
  attr :placeholder, :string, default: "Write in Markdown..."
  attr :min_height, :string, default: "200px"
  attr :class, :string, default: nil

  slot :toolbar

  @doc """
  Renders a split-pane Markdown editor: textarea (write) + server-rendered preview.

  The `PhiaMarkdownEditor` hook debounces textarea `input` events (300 ms) and
  calls `pushEvent(on_change, {raw, length, words})`. The LiveView re-renders
  with the updated `preview_html` after server-side Markdown parsing.

  ## Example

      <.markdown_editor id="body-editor" value={@draft} preview_html={@preview}
                        on_change="md_changed" label="Article body" />
  """
  def markdown_editor(assigns) do
    ~H"""
    <div id={@id} class={cn(["space-y-2", @class])}>
      <label :if={@label} class="text-sm font-medium text-foreground">{@label}</label>

      <div class="overflow-hidden rounded-lg border border-border">
        <%!-- Tab bar --%>
        <div class="flex items-center border-b border-border bg-muted/30">
          <button
            type="button"
            data-md-tab="write"
            data-md-active
            class="border-b-2 border-primary bg-background px-4 py-2 text-sm font-medium text-foreground"
          >
            Write
          </button>
          <button
            type="button"
            data-md-tab="preview"
            class="border-b-2 border-transparent px-4 py-2 text-sm font-medium text-muted-foreground hover:text-foreground"
          >
            Preview
          </button>
          <div :if={@toolbar != []} class="ml-auto flex items-center border-l border-border px-2">
            {render_slot(@toolbar)}
          </div>
        </div>

        <%!-- Content panes --%>
        <div class="relative">
          <textarea
            id={"#{@id}-write"}
            phx-hook="PhiaMarkdownEditor"
            data-md-write
            data-on-change={@on_change}
            placeholder={@placeholder}
            style={"min-height: #{@min_height}"}
            class="w-full resize-none bg-background px-4 py-3 font-mono text-sm text-foreground placeholder:text-muted-foreground focus:outline-none"
          >{@value}</textarea>

          <div
            data-md-preview
            class="hidden bg-background px-4 py-3"
            style={"min-height: #{@min_height}"}
          >
            {if @preview_html do
              Phoenix.HTML.raw(@preview_html)
            else
              Phoenix.HTML.raw(~s[<p class="text-sm text-muted-foreground">Nothing to preview.</p>])
            end}
          </div>
        </div>
      </div>
    </div>
    """
  end

  # ----------------------------------------------------------------------------
  # rich_text_viewer/1
  # ----------------------------------------------------------------------------

  attr :content, :string, required: true
  attr :prose_size, :atom, default: :base, values: [:sm, :base, :lg]
  attr :class, :string, default: nil
  attr :rest, :global

  @doc """
  Renders a read-only `Phoenix.HTML.raw` container with prose sizing.

  **Security:** Always sanitize `content` server-side before passing to this
  component. Use `HtmlSanitizeEx` or equivalent.

  ## Example

      <.rich_text_viewer content={@post.body} prose_size={:lg} />
  """
  def rich_text_viewer(assigns) do
    ~H"""
    <div
      class={cn(["prose max-w-none", viewer_prose_class(@prose_size), @class])}
      {@rest}
    >
      {Phoenix.HTML.raw(@content)}
    </div>
    """
  end

  defp viewer_prose_class(:sm), do: "prose-sm"
  defp viewer_prose_class(:base), do: ""
  defp viewer_prose_class(:lg), do: "prose-lg"

  # ----------------------------------------------------------------------------
  # editor_find_replace/1
  # ----------------------------------------------------------------------------

  attr :id, :string, required: true
  attr :editor_id, :string, required: true
  attr :class, :string, default: nil

  @doc """
  Renders a slide-in search-and-replace bar for a `contenteditable` editor.

  The `PhiaEditorFindReplace` hook opens on Ctrl/Cmd+F inside the editor,
  injects `<mark>` elements for matches, and provides find prev/next and replace.

  ## Example

      <.editor_find_replace id="find-bar" editor_id="my-editor" />
  """
  def editor_find_replace(assigns) do
    ~H"""
    <div
      id={@id}
      phx-hook="PhiaEditorFindReplace"
      data-editor-id={@editor_id}
      data-find-bar
      class={cn([
        "hidden overflow-hidden border-b border-border bg-muted/30",
        @class
      ])}
    >
      <div class="flex items-center gap-2 px-3 py-2">
        <%!-- Search icon --%>
        <svg class="h-3.5 w-3.5 shrink-0 text-muted-foreground" viewBox="0 0 16 16" fill="none">
          <circle cx="6.5" cy="6.5" r="4" stroke="currentColor" stroke-width="1.5" />
          <path d="M11 11L14 14" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" />
        </svg>

        <%!-- Find input --%>
        <input
          type="text"
          placeholder="Find"
          data-find-input
          class="flex-1 bg-transparent text-sm text-foreground placeholder:text-muted-foreground focus:outline-none"
        />
        <span class="text-xs text-muted-foreground" data-find-count></span>

        <%!-- Prev / Next --%>
        <button
          type="button"
          data-find-prev
          aria-label="Previous match"
          class="inline-flex h-5 w-5 items-center justify-center rounded hover:bg-border"
        >
          <svg class="h-3 w-3" viewBox="0 0 12 12" fill="none">
            <path
              d="M8 2L4 6L8 10"
              stroke="currentColor"
              stroke-width="1.5"
              stroke-linecap="round"
              stroke-linejoin="round"
            />
          </svg>
        </button>
        <button
          type="button"
          data-find-next
          aria-label="Next match"
          class="inline-flex h-5 w-5 items-center justify-center rounded hover:bg-border"
        >
          <svg class="h-3 w-3" viewBox="0 0 12 12" fill="none">
            <path
              d="M4 2L8 6L4 10"
              stroke="currentColor"
              stroke-width="1.5"
              stroke-linecap="round"
              stroke-linejoin="round"
            />
          </svg>
        </button>

        <div class="mx-1 h-4 w-px bg-border" />

        <%!-- Replace input --%>
        <input
          type="text"
          placeholder="Replace"
          data-replace-input
          class="flex-1 bg-transparent text-sm text-foreground placeholder:text-muted-foreground focus:outline-none"
        />
        <button
          type="button"
          data-replace-one
          class="rounded px-2 py-0.5 text-xs text-muted-foreground hover:bg-accent hover:text-foreground"
        >
          Replace
        </button>
        <button
          type="button"
          data-replace-all
          class="rounded px-2 py-0.5 text-xs text-muted-foreground hover:bg-accent hover:text-foreground"
        >
          All
        </button>

        <button
          type="button"
          data-find-close
          aria-label="Close find bar"
          class="ml-1 inline-flex h-5 w-5 items-center justify-center rounded hover:bg-border"
        >
          <svg class="h-3 w-3" viewBox="0 0 12 12" fill="none">
            <path
              d="M9 3L3 9M3 3L9 9"
              stroke="currentColor"
              stroke-width="1.5"
              stroke-linecap="round"
            />
          </svg>
        </button>
      </div>
    </div>
    """
  end

  # ----------------------------------------------------------------------------
  # editor_word_count/1
  # ----------------------------------------------------------------------------

  attr :content, :string, default: ""
  attr :show_reading_time, :boolean, default: true
  attr :words_per_minute, :integer, default: 200
  attr :class, :string, default: nil

  @doc """
  Renders a standalone words / characters / reading-time display widget.

  All computation is server-side — pass the raw text content.

  ## Example

      <.editor_word_count content={@body_text} show_reading_time words_per_minute={250} />
  """
  def editor_word_count(assigns) do
    words = count_words(assigns.content)
    chars = String.length(assigns.content || "")
    wpm = max(1, assigns.words_per_minute)
    reading_min = max(1, ceil(words / wpm))

    assigns =
      assigns
      |> assign(:word_count, words)
      |> assign(:char_count, chars)
      |> assign(:reading_min, reading_min)

    ~H"""
    <div class={cn(["flex flex-wrap items-center gap-4 text-xs text-muted-foreground", @class])}>
      <span>
        <span class="font-medium text-foreground">{@word_count}</span> words
      </span>
      <span>
        <span class="font-medium text-foreground">{@char_count}</span> characters
      </span>
      <span :if={@show_reading_time}>
        <span class="font-medium text-foreground">{@reading_min}</span> min read
      </span>
    </div>
    """
  end

  defp count_words(nil), do: 0
  defp count_words(""), do: 0
  defp count_words(text), do: text |> String.split(~r/\s+/, trim: true) |> length()

  # ============================================================================
  # Bonus — TipTap-Inspired Advanced Editor
  # ============================================================================

  # ----------------------------------------------------------------------------
  # advanced_editor/1
  # ----------------------------------------------------------------------------

  attr :id, :string, required: true
  attr :field, Phoenix.HTML.FormField, default: nil
  attr :value, :string, default: nil
  attr :placeholder, :string, default: "Type '/' for commands, or start writing..."
  attr :min_height, :string, default: "300px"
  attr :toolbar_variant, :atom, default: :default, values: [:default, :compact, :floating]
  attr :show_word_count, :boolean, default: true
  attr :show_find_replace, :boolean, default: false
  attr :class, :string, default: nil

  @doc """
  Full-featured WYSIWYG editor inspired by TipTap's design.

  **TipTap** is the most popular headless rich text editor (built on ProseMirror,
  2.5M+ weekly npm downloads). This component transpiles TipTap's UX patterns
  to PhiaUI: same toolbar layout, bubble menus, slash commands, and inline SVG icons —
  powered entirely by vanilla JS + `execCommand` via the `PhiaAdvancedEditor` hook.

  Features:
  - Full toolbar: undo/redo, heading dropdown, marks (bold/italic/underline/strike/code),
    lists (bullet/ordered), links (insert/remove), text color picker, find & replace toggle
  - Bubble menu for quick inline formatting of selected text
  - Floating menu at empty cursor for block insertion
  - Find & replace bar (Ctrl/Cmd+F)
  - Live word/character count footer
  - `Phoenix.HTML.FormField` integration via hidden `<input>`
  - Dark mode support via `.dark` class

  ## Example

      <%!-- Standalone --%>
      <.advanced_editor id="blog-editor" placeholder="Write your post..." min_height="400px" />

      <%!-- Form-integrated --%>
      <.form for={@form} phx-submit="publish">
        <.advanced_editor id="post-editor" field={@form[:body]} show_word_count />
      </.form>

  ## Hook registration

      import PhiaAdvancedEditor from "./hooks/advanced_editor"
      let liveSocket = new LiveSocket("/live", Socket, {
        hooks: { PhiaAdvancedEditor, PhiaBubbleMenu, PhiaEditorColorPicker, PhiaEditorFindReplace }
      })
  """
  def advanced_editor(assigns) do
    field = assigns.field
    id = assigns.id

    assigns =
      assigns
      |> assign(:editor_id, "#{id}-content")
      |> assign(:bubble_id, "#{id}-bubble")
      |> assign(:float_id, "#{id}-float")
      |> assign(:find_id, "#{id}-find")
      |> assign(:link_id, "#{id}-link")
      |> assign(:hidden_id, if(field, do: field.id, else: "#{id}-value"))
      |> assign(:hidden_name, if(field, do: field.name, else: id))
      |> assign(:initial_html, if(field, do: field.value || "", else: assigns.value || ""))
      |> assign(:errors, if(field, do: field.errors, else: []))

    ~H"""
    <div
      id={@id}
      phx-hook="PhiaAdvancedEditor"
      data-editor-id={@editor_id}
      data-bubble-id={@bubble_id}
      data-find-id={@find_id}
      data-link-id={@link_id}
      class={cn([
        "flex flex-col rounded-xl border border-border bg-background shadow-sm",
        "focus-within:ring-2 focus-within:ring-ring focus-within:ring-offset-1",
        @class
      ])}
    >
      <%!-- Find & Replace bar (hidden by default, opened by Ctrl+F) --%>
      <.editor_find_replace :if={@show_find_replace} id={@find_id} editor_id={@editor_id} />

      <%!-- Main toolbar --%>
      <div class="border-b border-border">
        <.editor_toolbar
          variant={@toolbar_variant}
          aria_label="Editor formatting toolbar"
          class="px-2 py-1.5"
        >
          <%!-- History --%>
          <.toolbar_group label="History">
            <.toolbar_button action="undo" aria_label="Undo" tooltip="Undo (Ctrl+Z)">
              <svg class="h-4 w-4" viewBox="0 0 16 16" fill="none">
                <path
                  d="M3.5 7H10a3 3 0 110 6H7"
                  stroke="currentColor"
                  stroke-width="1.4"
                  stroke-linecap="round"
                  stroke-linejoin="round"
                />
                <path
                  d="M6 4L3 7L6 10"
                  stroke="currentColor"
                  stroke-width="1.4"
                  stroke-linecap="round"
                  stroke-linejoin="round"
                />
              </svg>
            </.toolbar_button>
            <.toolbar_button action="redo" aria_label="Redo" tooltip="Redo (Ctrl+Shift+Z)">
              <svg class="h-4 w-4" viewBox="0 0 16 16" fill="none">
                <path
                  d="M12.5 7H6a3 3 0 100 6h3"
                  stroke="currentColor"
                  stroke-width="1.4"
                  stroke-linecap="round"
                  stroke-linejoin="round"
                />
                <path
                  d="M10 4L13 7L10 10"
                  stroke="currentColor"
                  stroke-width="1.4"
                  stroke-linecap="round"
                  stroke-linejoin="round"
                />
              </svg>
            </.toolbar_button>
          </.toolbar_group>

          <.toolbar_separator />

          <%!-- Block format dropdown --%>
          <.editor_toolbar_dropdown id={"#{@id}-block-dd"} label="Paragraph">
            <:item value="paragraph" action="paragraph" label="Paragraph" />
            <:item value="h1" action="h1" label="Heading 1" />
            <:item value="h2" action="h2" label="Heading 2" />
            <:item value="h3" action="h3" label="Heading 3" />
            <:item value="blockquote" action="blockquote" label="Blockquote" />
            <:item value="codeBlock" action="codeBlock" label="Code Block" />
          </.editor_toolbar_dropdown>

          <.toolbar_separator />

          <%!-- Inline marks --%>
          <.toolbar_group label="Text formatting">
            <.toolbar_button action="bold" aria_label="Bold" tooltip="Bold (Ctrl+B)">
              <svg class="h-4 w-4" viewBox="0 0 16 16" fill="none">
                <path
                  d="M5 3h4.5a2.5 2.5 0 010 5H5V3zM5 8h5a2.5 2.5 0 010 5H5V8z"
                  stroke="currentColor"
                  stroke-width="1.5"
                  stroke-linecap="round"
                  stroke-linejoin="round"
                />
              </svg>
            </.toolbar_button>
            <.toolbar_button action="italic" aria_label="Italic" tooltip="Italic (Ctrl+I)">
              <svg class="h-4 w-4" viewBox="0 0 16 16" fill="none">
                <path d="M10 3H6M10 13H6M9 3L7 13" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" />
              </svg>
            </.toolbar_button>
            <.toolbar_button action="underline" aria_label="Underline" tooltip="Underline (Ctrl+U)">
              <svg class="h-4 w-4" viewBox="0 0 16 16" fill="none">
                <path
                  d="M5 3v5a3 3 0 006 0V3"
                  stroke="currentColor"
                  stroke-width="1.5"
                  stroke-linecap="round"
                />
                <line
                  x1="3.5"
                  y1="13"
                  x2="12.5"
                  y2="13"
                  stroke="currentColor"
                  stroke-width="1.5"
                  stroke-linecap="round"
                />
              </svg>
            </.toolbar_button>
            <.toolbar_button action="strike" aria_label="Strikethrough" tooltip="Strikethrough">
              <svg class="h-4 w-4" viewBox="0 0 16 16" fill="none">
                <path
                  d="M5.5 10.5c0 1.105.895 2 2 2h1c1.105 0 2-.895 2-2"
                  stroke="currentColor"
                  stroke-width="1.4"
                  stroke-linecap="round"
                />
                <path
                  d="M10.5 5.5c0-1.105-.895-2-2-2h-1"
                  stroke="currentColor"
                  stroke-width="1.4"
                  stroke-linecap="round"
                />
                <line
                  x1="2"
                  y1="8"
                  x2="14"
                  y2="8"
                  stroke="currentColor"
                  stroke-width="1.5"
                  stroke-linecap="round"
                />
              </svg>
            </.toolbar_button>
            <.toolbar_button action="code" aria_label="Inline code" tooltip="Inline code">
              <svg class="h-4 w-4" viewBox="0 0 16 16" fill="none">
                <path
                  d="M5 5L2 8L5 11M11 5L14 8L11 11"
                  stroke="currentColor"
                  stroke-width="1.5"
                  stroke-linecap="round"
                  stroke-linejoin="round"
                />
              </svg>
            </.toolbar_button>
          </.toolbar_group>

          <.toolbar_separator />

          <%!-- Lists --%>
          <.toolbar_group label="Lists">
            <.toolbar_button action="bulletList" aria_label="Bullet list" tooltip="Bullet list">
              <svg class="h-4 w-4" viewBox="0 0 16 16" fill="none">
                <circle cx="3" cy="4.5" r="1" fill="currentColor" />
                <circle cx="3" cy="8" r="1" fill="currentColor" />
                <circle cx="3" cy="11.5" r="1" fill="currentColor" />
                <line x1="6" y1="4.5" x2="13" y2="4.5" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" />
                <line x1="6" y1="8" x2="13" y2="8" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" />
                <line x1="6" y1="11.5" x2="13" y2="11.5" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" />
              </svg>
            </.toolbar_button>
            <.toolbar_button action="orderedList" aria_label="Ordered list" tooltip="Ordered list">
              <svg class="h-4 w-4" viewBox="0 0 16 16" fill="none">
                <path d="M3 3h1v3H2.5" stroke="currentColor" stroke-width="1.2" stroke-linecap="round" stroke-linejoin="round" />
                <path d="M2.5 9h2l-2 2.5h2" stroke="currentColor" stroke-width="1.2" stroke-linecap="round" stroke-linejoin="round" />
                <line x1="7" y1="4.5" x2="13" y2="4.5" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" />
                <line x1="7" y1="8" x2="13" y2="8" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" />
                <line x1="7" y1="11.5" x2="13" y2="11.5" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" />
              </svg>
            </.toolbar_button>
          </.toolbar_group>

          <.toolbar_separator />

          <%!-- Links --%>
          <.toolbar_group label="Links">
            <.toolbar_button action="link" aria_label="Insert link" tooltip="Insert link">
              <svg class="h-4 w-4" viewBox="0 0 16 16" fill="none">
                <path
                  d="M6.5 9.5A3.5 3.5 0 009.5 13L11 11.5a3.5 3.5 0 00-4.95-4.95L4.5 8"
                  stroke="currentColor"
                  stroke-width="1.4"
                  stroke-linecap="round"
                />
                <path
                  d="M9.5 6.5A3.5 3.5 0 006.5 3L5 4.5a3.5 3.5 0 004.95 4.95L11.5 8"
                  stroke="currentColor"
                  stroke-width="1.4"
                  stroke-linecap="round"
                />
              </svg>
            </.toolbar_button>
            <.toolbar_button action="unlink" aria_label="Remove link" tooltip="Remove link">
              <svg class="h-4 w-4" viewBox="0 0 16 16" fill="none">
                <path d="M5 5L2.5 2.5" stroke="currentColor" stroke-width="1.4" stroke-linecap="round" />
                <path d="M13 13L10.5 10.5" stroke="currentColor" stroke-width="1.4" stroke-linecap="round" />
                <path d="M6.5 9.5a3.5 3.5 0 003 2.9" stroke="currentColor" stroke-width="1.4" stroke-linecap="round" />
                <path d="M9.5 6.5a3.5 3.5 0 00-3-2.9" stroke="currentColor" stroke-width="1.4" stroke-linecap="round" />
              </svg>
            </.toolbar_button>
          </.toolbar_group>

          <.toolbar_separator />

          <%!-- Color picker --%>
          <.editor_color_picker action="foreColor" label="Text color" />

          <.toolbar_separator />

          <%!-- Find & replace toggle --%>
          <.toolbar_button action="findReplace" aria_label="Find and replace" tooltip="Find and replace (Ctrl+F)">
            <svg class="h-4 w-4" viewBox="0 0 16 16" fill="none">
              <circle cx="6.5" cy="6.5" r="3.5" stroke="currentColor" stroke-width="1.4" />
              <path d="M10 10L13 13" stroke="currentColor" stroke-width="1.4" stroke-linecap="round" />
              <path
                d="M6.5 4.5v4M4.5 6.5h4"
                stroke="currentColor"
                stroke-width="1.2"
                stroke-linecap="round"
              />
            </svg>
          </.toolbar_button>
        </.editor_toolbar>
      </div>

      <%!-- Bubble menu (appears above selection) --%>
      <.bubble_menu id={@bubble_id} editor_id={@editor_id}>
        <.toolbar_button action="bold" aria_label="Bold" size={:xs}>
          <svg class="h-3.5 w-3.5" viewBox="0 0 16 16" fill="none">
            <path
              d="M5 3h4.5a2.5 2.5 0 010 5H5V3zM5 8h5a2.5 2.5 0 010 5H5V8z"
              stroke="currentColor"
              stroke-width="1.5"
              stroke-linecap="round"
              stroke-linejoin="round"
            />
          </svg>
        </.toolbar_button>
        <.toolbar_button action="italic" aria_label="Italic" size={:xs}>
          <svg class="h-3.5 w-3.5" viewBox="0 0 16 16" fill="none">
            <path d="M10 3H6M10 13H6M9 3L7 13" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" />
          </svg>
        </.toolbar_button>
        <.toolbar_button action="underline" aria_label="Underline" size={:xs}>
          <svg class="h-3.5 w-3.5" viewBox="0 0 16 16" fill="none">
            <path
              d="M5 3v5a3 3 0 006 0V3"
              stroke="currentColor"
              stroke-width="1.5"
              stroke-linecap="round"
            />
            <line
              x1="3.5"
              y1="13"
              x2="12.5"
              y2="13"
              stroke="currentColor"
              stroke-width="1.5"
              stroke-linecap="round"
            />
          </svg>
        </.toolbar_button>
        <.toolbar_button action="strike" aria_label="Strikethrough" size={:xs}>
          <svg class="h-3.5 w-3.5" viewBox="0 0 16 16" fill="none">
            <line x1="2" y1="8" x2="14" y2="8" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" />
            <path d="M5.5 10.5c0 1.105.895 2 2 2h1c1.105 0 2-.895 2-2" stroke="currentColor" stroke-width="1.4" stroke-linecap="round" />
          </svg>
        </.toolbar_button>
        <.toolbar_separator />
        <.toolbar_button action="link" aria_label="Link" size={:xs}>
          <svg class="h-3.5 w-3.5" viewBox="0 0 16 16" fill="none">
            <path
              d="M6.5 9.5A3.5 3.5 0 009.5 13L11 11.5a3.5 3.5 0 00-4.95-4.95L4.5 8"
              stroke="currentColor"
              stroke-width="1.4"
              stroke-linecap="round"
            />
            <path
              d="M9.5 6.5A3.5 3.5 0 006.5 3L5 4.5a3.5 3.5 0 004.95 4.95L11.5 8"
              stroke="currentColor"
              stroke-width="1.4"
              stroke-linecap="round"
            />
          </svg>
        </.toolbar_button>
        <.toolbar_button action="code" aria_label="Code" size={:xs}>
          <svg class="h-3.5 w-3.5" viewBox="0 0 16 16" fill="none">
            <path
              d="M5 5L2 8L5 11M11 5L14 8L11 11"
              stroke="currentColor"
              stroke-width="1.5"
              stroke-linecap="round"
              stroke-linejoin="round"
            />
          </svg>
        </.toolbar_button>
      </.bubble_menu>

      <%!-- Editor content area --%>
      <div
        id={@editor_id}
        data-phia-editor
        data-content={@initial_html}
        data-placeholder={@placeholder}
        style={"min-height: #{@min_height}"}
        class={cn([
          "prose prose-sm max-w-none flex-1 px-4 py-3 text-foreground focus:outline-none",
          "[&.is-empty]:before:pointer-events-none [&.is-empty]:before:float-left",
          "[&.is-empty]:before:h-0 [&.is-empty]:before:text-muted-foreground",
          "[&.is-empty]:before:content-[attr(data-placeholder)]"
        ])}
      />

      <%!-- Footer --%>
      <div
        :if={@show_word_count || @errors != []}
        class="flex items-center justify-between border-t border-border px-4 py-1.5"
      >
        <.editor_word_count :if={@show_word_count} content={@initial_html} show_reading_time />
        <div :if={@errors != []} class="text-xs text-destructive">
          {Enum.map_join(@errors, "; ", fn {msg, _} -> msg end)}
        </div>
      </div>

      <%!-- Link dialog --%>
      <.editor_link_dialog id={@link_id} />

      <%!-- Hidden input for form integration --%>
      <input
        type="hidden"
        id={@hidden_id}
        name={@hidden_name}
        value={@initial_html}
      />
    </div>
    """
  end
end
