defmodule PhiaUi.Components.Editor.Extensions do
  @moduledoc """
  Extensions Suite — 10 components for extending the PhiaUI rich text editor
  with plugins, emoji, special characters, and block-level controls.

  These components provide the UI layer for editor extension features. They are
  designed to be composed inside the editor toolbar or sidebar slots.

  ## Components

  ### Extension Management
  - `extension_toolbar_slot/1`     — renders extension buttons in the toolbar
  - `extension_sidebar_panel/1`    — sidebar panel listing available extensions

  ### Content Insertion
  - `emoji_picker_block/1`         — tabbed emoji picker with categories and recents
  - `special_character_picker/1`   — tabbed special character picker (math, arrows, etc.)

  ### Block-Level Controls
  - `drag_handle/1`                — six-dot grip icon for block reordering
  - `block_type_menu/1`            — dropdown for changing block type (paragraph, heading, etc.)
  - `placeholder_extension/1`      — gray placeholder text for empty blocks
  - `typography_extension/1`       — status badge for smart typography rules

  ### Node Utilities
  - `unique_id_extension/1`        — hidden div with a data-extension-id attribute
  - `custom_node_renderer/1`       — wrapper div for rendering custom node types
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  # ============================================================================
  # 1. extension_toolbar_slot/1
  # ============================================================================

  attr :id, :string, required: true
  attr :extensions, :list, default: []
  attr :class, :string, default: nil
  attr :rest, :global

  @doc """
  Renders a row of toolbar buttons for registered extensions.

  Each item in `:extensions` should be a map with `:id`, `:label`, and `:icon`
  (an icon name string) keys.

  ## Example

      <.extension_toolbar_slot
        id="ext-toolbar"
        extensions={[
          %{id: "emoji", label: "Emoji", icon: "smile"},
          %{id: "table", label: "Table", icon: "grid"}
        ]}
      />
  """
  def extension_toolbar_slot(assigns) do
    ~H"""
    <div
      id={@id}
      role="group"
      aria-label="Extensions"
      class={cn(["flex items-center gap-0.5", @class])}
      {@rest}
    >
      <button
        :for={ext <- @extensions}
        type="button"
        phx-click="extension:toggle"
        phx-value-extension-id={ext[:id] || ext["id"]}
        aria-label={ext[:label] || ext["label"]}
        title={ext[:label] || ext["label"]}
        class="inline-flex h-7 w-7 items-center justify-center rounded text-foreground transition-colors hover:bg-accent hover:text-accent-foreground focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring"
      >
        <span class="text-xs">{ext[:icon] || ext["icon"] || ext[:label] || ext["label"]}</span>
      </button>
    </div>
    """
  end

  # ============================================================================
  # 2. extension_sidebar_panel/1
  # ============================================================================

  attr :id, :string, required: true
  attr :title, :string, default: "Extensions"
  attr :extensions, :list, default: []
  attr :active_extension, :string, default: nil
  attr :class, :string, default: nil
  attr :rest, :global

  @doc """
  Renders a sidebar panel listing available extensions with active highlighting.

  Each item in `:extensions` should be a map with `:id`, `:label`, and
  optional `:description` keys.

  ## Example

      <.extension_sidebar_panel
        id="ext-panel"
        extensions={[
          %{id: "emoji", label: "Emoji Picker", description: "Insert emoji"},
          %{id: "toc", label: "Table of Contents", description: "Auto-generated TOC"}
        ]}
        active_extension="emoji"
      />
  """
  def extension_sidebar_panel(assigns) do
    ~H"""
    <div
      id={@id}
      class={cn([
        "rounded-xl border border-border bg-background shadow-sm",
        @class
      ])}
      {@rest}
    >
      <div class="border-b border-border px-4 py-3">
        <h3 class="text-sm font-semibold text-foreground">{@title}</h3>
      </div>

      <div :if={@extensions == []} class="px-4 py-6 text-center text-sm text-muted-foreground">
        No extensions available.
      </div>

      <ul :if={@extensions != []} class="divide-y divide-border">
        <li :for={ext <- @extensions}>
          <button
            type="button"
            phx-click="extension:select"
            phx-value-extension-id={ext[:id] || ext["id"]}
            class={cn([
              "flex w-full items-center gap-3 px-4 py-3 text-left transition-colors",
              (ext[:id] || ext["id"]) == @active_extension && "bg-primary/5",
              (ext[:id] || ext["id"]) != @active_extension && "hover:bg-muted/50"
            ])}
          >
            <div class={cn([
              "flex h-8 w-8 items-center justify-center rounded-lg",
              (ext[:id] || ext["id"]) == @active_extension && "bg-primary text-primary-foreground",
              (ext[:id] || ext["id"]) != @active_extension && "bg-muted text-muted-foreground"
            ])}>
              <svg class="h-4 w-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <path d="M12 2L2 7l10 5 10-5-10-5zM2 17l10 5 10-5M2 12l10 5 10-5" />
              </svg>
            </div>
            <div class="min-w-0 flex-1">
              <span class="text-sm font-medium text-foreground">{ext[:label] || ext["label"]}</span>
              <p :if={ext[:description] || ext["description"]} class="text-xs text-muted-foreground">
                {ext[:description] || ext["description"]}
              </p>
            </div>
            <div
              :if={(ext[:id] || ext["id"]) == @active_extension}
              class="h-2 w-2 rounded-full bg-primary"
            />
          </button>
        </li>
      </ul>
    </div>
    """
  end

  # ============================================================================
  # 3. emoji_picker_block/1
  # ============================================================================

  @emoji_categories %{
    smileys: "Smileys & Emotion",
    people: "People & Body",
    nature: "Animals & Nature",
    food: "Food & Drink",
    travel: "Travel & Places",
    activities: "Activities",
    objects: "Objects",
    symbols: "Symbols"
  }

  attr :id, :string, required: true
  attr :visible, :boolean, default: false
  attr :categories, :list, default: [:smileys, :people, :nature, :food, :travel, :activities, :objects, :symbols]
  attr :recent, :list, default: []
  attr :class, :string, default: nil
  attr :rest, :global

  @doc """
  Renders a tabbed emoji picker with category tabs and a grid area.

  Emoji content is populated client-side by a JS hook. This component provides
  the structural UI with category tabs and a placeholder grid.

  ## Example

      <.emoji_picker_block id="emoji" visible={@show_emoji} recent={@recent_emoji} />
  """
  def emoji_picker_block(assigns) do
    assigns = assign(assigns, :emoji_categories, @emoji_categories)

    ~H"""
    <div
      id={@id}
      :if={@visible}
      phx-hook="PhiaEmojiPickerBlock"
      class={cn([
        "w-72 rounded-xl border border-border bg-popover shadow-lg",
        @class
      ])}
      {@rest}
    >
      <%!-- Search --%>
      <div class="border-b border-border p-2">
        <input
          type="text"
          name="emoji_search"
          placeholder="Search emoji..."
          autocomplete="off"
          phx-change="emoji:search"
          phx-value-id={@id}
          class="w-full rounded-lg border border-border bg-background px-3 py-1.5 text-sm text-foreground placeholder:text-muted-foreground focus:outline-none focus:ring-1 focus:ring-ring"
        />
      </div>

      <%!-- Category tabs --%>
      <div class="flex overflow-x-auto border-b border-border px-1">
        <button
          :if={@recent != []}
          type="button"
          phx-click="emoji:category"
          phx-value-category="recent"
          phx-value-id={@id}
          class="shrink-0 px-2 py-1.5 text-xs text-muted-foreground transition-colors hover:text-foreground"
          title="Recent"
        >
          Recent
        </button>
        <button
          :for={cat <- @categories}
          type="button"
          phx-click="emoji:category"
          phx-value-category={cat}
          phx-value-id={@id}
          class="shrink-0 px-2 py-1.5 text-xs text-muted-foreground transition-colors hover:text-foreground"
          title={Map.get(@emoji_categories, cat, to_string(cat))}
        >
          {category_icon(cat)}
        </button>
      </div>

      <%!-- Recent emoji --%>
      <div :if={@recent != []} class="border-b border-border p-2">
        <span class="mb-1 block text-[10px] font-medium text-muted-foreground">Recently used</span>
        <div class="flex flex-wrap gap-0.5">
          <button
            :for={emoji <- @recent}
            type="button"
            phx-click="emoji:insert"
            phx-value-emoji={emoji}
            phx-value-id={@id}
            class="inline-flex h-7 w-7 items-center justify-center rounded text-lg transition-colors hover:bg-muted"
          >
            {emoji}
          </button>
        </div>
      </div>

      <%!-- Emoji grid placeholder — populated by JS hook --%>
      <div
        id={"#{@id}-grid"}
        class="h-48 overflow-y-auto p-2"
        data-emoji-grid
      >
        <p class="py-8 text-center text-xs text-muted-foreground">
          Select a category above
        </p>
      </div>
    </div>
    """
  end

  defp category_icon(:smileys), do: "😀"
  defp category_icon(:people), do: "👋"
  defp category_icon(:nature), do: "🌿"
  defp category_icon(:food), do: "🍕"
  defp category_icon(:travel), do: "✈️"
  defp category_icon(:activities), do: "⚽"
  defp category_icon(:objects), do: "💡"
  defp category_icon(:symbols), do: "♠️"
  defp category_icon(_), do: "•"

  # ============================================================================
  # 4. special_character_picker/1
  # ============================================================================

  @character_categories %{
    math: {"Math", ~w(± × ÷ ≠ ≈ ≤ ≥ ∞ ∑ ∏ √ ∫ ∂ π θ λ μ σ φ ω α β γ δ ε)},
    arrows: {"Arrows", ~w(← → ↑ ↓ ↔ ↕ ⇐ ⇒ ⇑ ⇓ ⇔ ↗ ↘ ↙ ↖ ⟵ ⟶ ⟷)},
    currency: {"Currency", ~w($ € £ ¥ ₹ ₽ ₩ ₺ ₿ ¢ ₡ ₫ ₣ ₤ ₦ ₧ ₪ ₭ ₮ ₯)},
    greek: {"Greek", ~w(α β γ δ ε ζ η θ ι κ λ μ ν ξ ο π ρ σ τ υ φ χ ψ ω Α Β Γ Δ Ε Ζ Η Θ Ι Κ Λ Μ Ν Ξ Ο Π Ρ Σ Τ Υ Φ Χ Ψ Ω)},
    latin: {"Latin", ~w(À Á Â Ã Ä Å Æ Ç È É Ê Ë Ì Í Î Ï Ð Ñ Ò Ó Ô Õ Ö Ø Ù Ú Û Ü Ý Þ ß à á â ã ä å æ ç è é ê ë)}
  }

  attr :id, :string, required: true
  attr :visible, :boolean, default: false
  attr :categories, :list, default: [:math, :arrows, :currency, :greek, :latin]
  attr :class, :string, default: nil
  attr :rest, :global

  @doc """
  Renders a tabbed special character picker with category tabs and character grids.

  Each tab shows a grid of clickable special characters. Clicking a character
  fires `phx-click="special-char:insert"`.

  ## Example

      <.special_character_picker id="chars" visible={@show_chars} />
  """
  def special_character_picker(assigns) do
    active_cat = List.first(assigns.categories)
    {_label, chars} = Map.get(@character_categories, active_cat, {"", []})

    assigns =
      assigns
      |> assign(:char_categories, @character_categories)
      |> assign(:active_category, active_cat)
      |> assign(:active_chars, chars)

    ~H"""
    <div
      id={@id}
      :if={@visible}
      class={cn([
        "w-72 rounded-xl border border-border bg-popover shadow-lg",
        @class
      ])}
      {@rest}
    >
      <%!-- Category tabs --%>
      <div class="flex overflow-x-auto border-b border-border px-1">
        <button
          :for={cat <- @categories}
          type="button"
          phx-click="special-char:category"
          phx-value-category={cat}
          phx-value-id={@id}
          class={cn([
            "shrink-0 px-3 py-2 text-xs font-medium transition-colors",
            cat == @active_category && "border-b-2 border-primary text-primary",
            cat != @active_category && "text-muted-foreground hover:text-foreground"
          ])}
        >
          {elem(Map.get(@char_categories, cat, {"", []}), 0)}
        </button>
      </div>

      <%!-- Character grid --%>
      <div class="h-48 overflow-y-auto p-2">
        <div class="grid grid-cols-8 gap-0.5">
          <button
            :for={ch <- @active_chars}
            type="button"
            phx-click="special-char:insert"
            phx-value-char={ch}
            phx-value-id={@id}
            class="inline-flex h-8 w-8 items-center justify-center rounded text-sm transition-colors hover:bg-muted"
            title={ch}
          >
            {ch}
          </button>
        </div>
      </div>
    </div>
    """
  end

  # ============================================================================
  # 5. drag_handle/1
  # ============================================================================

  attr :class, :string, default: nil
  attr :rest, :global

  @doc """
  Renders a six-dot grip icon for block-level drag reordering.

  ## Example

      <.drag_handle />
  """
  def drag_handle(assigns) do
    ~H"""
    <div
      class={cn([
        "flex cursor-grab items-center justify-center rounded p-0.5 text-muted-foreground/50 transition-colors hover:bg-muted hover:text-muted-foreground active:cursor-grabbing",
        @class
      ])}
      draggable="true"
      role="button"
      aria-label="Drag to reorder"
      aria-roledescription="draggable"
      {@rest}
    >
      <svg class="h-4 w-4" viewBox="0 0 16 16" fill="currentColor">
        <circle cx="5" cy="3" r="1" /><circle cx="11" cy="3" r="1" />
        <circle cx="5" cy="8" r="1" /><circle cx="11" cy="8" r="1" />
        <circle cx="5" cy="13" r="1" /><circle cx="11" cy="13" r="1" />
      </svg>
    </div>
    """
  end

  # ============================================================================
  # 6. block_type_menu/1
  # ============================================================================

  @block_types [
    %{type: "paragraph", label: "Paragraph", icon_path: "M13 4v16M3 4h10a4 4 0 010 8H3"},
    %{type: "heading-1", label: "Heading 1", icon_path: "M4 12h8M4 18V6M12 18V6M17 12l3-6v12"},
    %{type: "heading-2", label: "Heading 2", icon_path: "M4 12h8M4 18V6M12 18V6M21 18h-4c0-4 4-3 4-6 0-1.5-2-2.5-4-1"},
    %{type: "heading-3", label: "Heading 3", icon_path: "M4 12h8M4 18V6M12 18V6M17.5 10.5c1-1 3-1 3 1s-2 2-3 2c1 0 3 1 3 2.5s-2 2-3 1"},
    %{type: "bulletList", label: "Bullet List", icon_path: "M8 6h13M8 12h13M8 18h13M3 6h.01M3 12h.01M3 18h.01"},
    %{type: "orderedList", label: "Numbered List", icon_path: "M10 6h11M10 12h11M10 18h11M4 6h1v4M4 10h2M6 18H4c0-1 2-2 2-3s-1-1.5-2-1"},
    %{type: "blockquote", label: "Quote", icon_path: "M3 21c3 0 7-1 7-8V5c0-1.25-.756-2.017-2-2H4c-1.25 0-2 .75-2 1.972V11c0 1.25.75 2 2 2 1 0 1 0 1 1v1c0 1-1 2-2 2s-1 .008-1 1.031V21zM15 21c3 0 7-1 7-8V5c0-1.25-.757-2.017-2-2h-4c-1.25 0-2 .75-2 1.972V11c0 1.25.75 2 2 2h.75c0 2.25.25 4-2.75 4v3c0 .001 0 1 1 1z"},
    %{type: "codeBlock", label: "Code Block", icon_path: "M16 18l6-6-6-6M8 6l-6 6 6 6"}
  ]

  attr :id, :string, required: true
  attr :visible, :boolean, default: false
  attr :current_type, :string, default: "paragraph"
  attr :class, :string, default: nil
  attr :rest, :global

  @doc """
  Renders a dropdown menu for changing the current block type.

  Shows options for paragraph, heading 1-3, bullet list, numbered list,
  blockquote, and code block. The current type is highlighted.

  ## Example

      <.block_type_menu id="block-menu" visible={@show_block_menu} current_type="heading-1" />
  """
  def block_type_menu(assigns) do
    assigns = assign(assigns, :block_types, @block_types)

    ~H"""
    <div
      id={@id}
      :if={@visible}
      class={cn([
        "absolute z-50 w-56 rounded-lg border border-border bg-popover py-1 shadow-lg",
        @class
      ])}
      role="menu"
      {@rest}
    >
      <button
        :for={bt <- @block_types}
        type="button"
        role="menuitem"
        phx-click="block-type:change"
        phx-value-type={bt.type}
        phx-value-id={@id}
        class={cn([
          "flex w-full items-center gap-3 px-3 py-2 text-left text-sm transition-colors",
          bt.type == @current_type && "bg-accent text-accent-foreground",
          bt.type != @current_type && "text-foreground hover:bg-muted"
        ])}
      >
        <svg class="h-4 w-4 shrink-0" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">
          <path d={bt.icon_path} />
        </svg>
        <span>{bt.label}</span>
      </button>
    </div>
    """
  end

  # ============================================================================
  # 7. placeholder_extension/1
  # ============================================================================

  @placeholder_texts %{
    paragraph: "Type '/' for commands...",
    heading: "Heading",
    blockquote: "Write a quote...",
    code: "Write code...",
    list: "List item"
  }

  attr :type, :atom, default: :paragraph
  attr :text, :string, default: nil
  attr :class, :string, default: nil
  attr :rest, :global

  @doc """
  Renders gray placeholder text for an empty editor block.

  The placeholder text is determined by the block `:type`, or can be overridden
  with the `:text` attr.

  ## Example

      <.placeholder_extension type={:heading} />
      <.placeholder_extension text="Start typing here..." />
  """
  def placeholder_extension(assigns) do
    placeholder = assigns.text || Map.get(@placeholder_texts, assigns.type, "Type something...")
    assigns = assign(assigns, :placeholder, placeholder)

    ~H"""
    <span
      class={cn([
        "pointer-events-none select-none text-muted-foreground/50",
        @class
      ])}
      aria-hidden="true"
      {@rest}
    >{@placeholder}</span>
    """
  end

  # ============================================================================
  # 8. typography_extension/1
  # ============================================================================

  attr :enabled, :boolean, default: true
  attr :rules, :list, default: [:smart_quotes, :em_dash, :ellipsis]
  attr :class, :string, default: nil
  attr :rest, :global

  @doc """
  Renders a small status badge showing whether smart typography is on or off.

  When enabled, displays the active rules count. Rules include `:smart_quotes`,
  `:em_dash`, and `:ellipsis`.

  ## Example

      <.typography_extension enabled={true} rules={[:smart_quotes, :em_dash]} />
  """
  def typography_extension(assigns) do
    ~H"""
    <span
      class={cn([
        "inline-flex items-center gap-1 rounded-full border px-2 py-0.5 text-[10px] font-medium",
        @enabled && "border-primary/30 bg-primary/5 text-primary",
        !@enabled && "border-border bg-muted text-muted-foreground",
        @class
      ])}
      title={if @enabled, do: "Typography: #{Enum.join(@rules, ", ")}", else: "Typography off"}
      {@rest}
    >
      <svg class="h-3 w-3" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
        <polyline points="4 7 4 4 20 4 20 7" />
        <line x1="9" y1="20" x2="15" y2="20" />
        <line x1="12" y1="4" x2="12" y2="20" />
      </svg>
      {if @enabled, do: "On", else: "Off"}
      <span :if={@enabled} class="text-primary/60">({length(@rules)})</span>
    </span>
    """
  end

  # ============================================================================
  # 9. unique_id_extension/1
  # ============================================================================

  attr :prefix, :string, default: "block"
  attr :class, :string, default: nil
  attr :rest, :global

  @doc """
  Renders a hidden `<div>` with a unique `data-extension-id` attribute.

  Used internally to assign stable IDs to editor blocks for collaboration,
  commenting, and version tracking.

  ## Example

      <.unique_id_extension prefix="sec" />
  """
  def unique_id_extension(assigns) do
    uid = "#{assigns.prefix}-#{:crypto.strong_rand_bytes(6) |> Base.url_encode64(padding: false)}"
    assigns = assign(assigns, :uid, uid)

    ~H"""
    <div
      class={cn(["hidden", @class])}
      data-extension-id={@uid}
      aria-hidden="true"
      {@rest}
    />
    """
  end

  # ============================================================================
  # 10. custom_node_renderer/1
  # ============================================================================

  attr :id, :string, required: true
  attr :node_type, :string, required: true
  attr :data, :map, default: %{}
  attr :class, :string, default: nil
  attr :rest, :global

  slot :inner_block

  @doc """
  Renders a wrapper `<div>` for custom editor node types.

  Provides `data-node-type` and `data-node-data` attributes for JS hooks
  to identify and interact with custom blocks.

  ## Example

      <.custom_node_renderer id="embed-1" node_type="youtube" data={%{url: "https://..."}}>
        <iframe src="..." />
      </.custom_node_renderer>
  """
  def custom_node_renderer(assigns) do
    assigns = assign(assigns, :data_json, Jason.encode!(assigns.data))

    ~H"""
    <div
      id={@id}
      data-node-type={@node_type}
      data-node-data={@data_json}
      class={cn([
        "relative rounded-lg border border-border bg-background",
        @class
      ])}
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end
end
