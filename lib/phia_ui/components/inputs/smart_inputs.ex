defmodule PhiaUi.Components.SmartInputs do
  @moduledoc """
  Smart and interactive input components for PhiaUI.

  Provides inputs with advanced interaction patterns:

  - `drag_number/1` + `form_drag_number/1` — Figma-style scrubber: drag
    horizontally to change a numeric value (PhiaDragNumber hook).
  - `suggestion_input/1` + `form_suggestion_input/1` — text input with an
    inline ghost-text suggestion; Tab accepts (PhiaSuggestionInput hook).
  - `emoji_picker/1` — button that opens an emoji grid popover with category
    tabs and search (PhiaEmojiPicker hook).
  - `keyboard_shortcut_input/1` + `form_keyboard_shortcut_input/1` — input
    that captures and displays a key combination (PhiaKeyShortcut hook).
  """

  use Phoenix.Component
  import PhiaUi.ClassMerger, only: [cn: 1]

  # ---------------------------------------------------------------------------
  # drag_number/1
  # ---------------------------------------------------------------------------

  attr(:id, :string, required: true, doc: "Root element ID — required for PhiaDragNumber hook.")

  attr(:value, :any,
    default: 0,
    doc: "Current numeric value (integer or float)."
  )

  attr(:min, :any, default: nil, doc: "Minimum allowed value.")
  attr(:max, :any, default: nil, doc: "Maximum allowed value.")
  attr(:step, :any, default: 1, doc: "Increment per pixel dragged.")
  attr(:unit, :string, default: nil, doc: "Unit suffix shown after the value (e.g. \"px\", \"%\").")
  attr(:on_change, :string, default: nil, doc: "LiveView event fired with `%{value: N}`.")
  attr(:disabled, :boolean, default: false, doc: "Disables drag interaction.")
  attr(:class, :string, default: nil, doc: "Additional CSS classes.")

  @doc """
  Renders a numeric display that responds to horizontal drag (Figma scrubber style).
  Drag left to decrease, right to increase. The `PhiaDragNumber` hook fires
  `pushEvent(on_change, %{value: newValue})` on each change.
  A hidden `<input>` carries the value for form submission.
  """
  def drag_number(assigns) do
    ~H"""
    <div
      id={@id}
      class={cn([
        "inline-flex items-center gap-1 px-2 py-1 rounded-md border border-border bg-background",
        "select-none",
        not @disabled && "cursor-ew-resize hover:border-ring",
        @disabled && "opacity-50 cursor-not-allowed",
        @class
      ])}
      phx-hook="PhiaDragNumber"
      data-min={@min}
      data-max={@max}
      data-step={@step}
      data-on-change={@on_change}
      role="spinbutton"
      aria-valuenow={@value}
      aria-valuemin={@min}
      aria-valuemax={@max}
      tabindex={@disabled && "-1" || "0"}
    >
      <svg
        xmlns="http://www.w3.org/2000/svg"
        class="h-3 w-3 text-muted-foreground shrink-0"
        viewBox="0 0 24 24"
        fill="none"
        stroke="currentColor"
        stroke-width="2"
        aria-hidden="true"
      >
        <path d="m8 9-3 3 3 3M16 9l3 3-3 3" />
      </svg>
      <span class="text-sm font-mono tabular-nums min-w-8 text-center" data-drag-display>
        {@value}{@unit}
      </span>
      <input type="hidden" name="" value={@value} data-drag-input />
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # form_drag_number/1
  # ---------------------------------------------------------------------------

  attr(:field, Phoenix.HTML.FormField, required: true, doc: "A Phoenix.HTML.FormField struct.")
  attr(:label, :string, default: nil, doc: "Label text.")
  attr(:description, :string, default: nil, doc: "Helper text.")
  attr(:min, :any, default: nil, doc: "Minimum value.")
  attr(:max, :any, default: nil, doc: "Maximum value.")
  attr(:step, :any, default: 1, doc: "Step per pixel.")
  attr(:unit, :string, default: nil, doc: "Unit suffix.")
  attr(:class, :string, default: nil, doc: "Additional CSS classes.")

  @doc """
  FormField-integrated wrapper for `drag_number/1`.
  """
  def form_drag_number(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    assigns =
      assigns
      |> assign(:errors, Enum.map(field.errors, &translate_error/1))
      |> assign_new(:value, fn -> field.value || 0 end)

    id = "drag-#{field.id}"
    assigns = assign(assigns, :_id, id)

    ~H"""
    <div class={cn(["space-y-2", @class])}>
      <label :if={@label} class="text-sm font-medium leading-none">{@label}</label>
      <p :if={@description} class="text-sm text-muted-foreground">{@description}</p>
      <.drag_number
        id={@_id}
        value={@value}
        min={@min}
        max={@max}
        step={@step}
        unit={@unit}
        on_change={@field.name}
      />
      <input type="hidden" name={@field.name} value={@value} />
      <p :for={error <- @errors} class="text-sm font-medium text-destructive">{error}</p>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # suggestion_input/1
  # ---------------------------------------------------------------------------

  attr(:id, :string, required: true, doc: "Root ID — required for PhiaSuggestionInput hook.")
  attr(:name, :string, default: nil, doc: "Input name for form submission.")
  attr(:value, :string, default: "", doc: "Current input value.")

  attr(:suggestion, :string,
    default: nil,
    doc: "Ghost-text suggestion shown inline. Tab key accepts it."
  )

  attr(:on_accept, :string,
    default: nil,
    doc: "LiveView event fired when the user accepts the suggestion (Tab)."
  )

  attr(:on_change, :string, default: nil, doc: "LiveView event fired on input change.")
  attr(:placeholder, :string, default: nil, doc: "Placeholder text.")
  attr(:disabled, :boolean, default: false, doc: "Disables the input.")
  attr(:class, :string, default: nil, doc: "Additional CSS classes.")

  @doc """
  Renders a text input with an inline ghost-text suggestion overlay.
  The `PhiaSuggestionInput` hook positions a transparent `<span>` behind the
  input showing the suggestion completion. Tab accepts, Esc dismisses.
  """
  def suggestion_input(assigns) do
    ~H"""
    <div
      id={@id}
      class={cn(["relative", @class])}
      phx-hook="PhiaSuggestionInput"
      data-suggestion={@suggestion}
      data-on-accept={@on_accept}
      data-on-change={@on_change}
    >
      <%# Ghost text layer (rendered behind the real input) %>
      <div
        class="absolute inset-0 flex items-center px-3 pointer-events-none overflow-hidden"
        aria-hidden="true"
        data-suggestion-ghost
      >
        <span class="invisible text-sm">{@value}</span>
        <span class="text-sm text-muted-foreground/60">
          {if @suggestion && String.starts_with?(@suggestion, @value) do
            String.slice(@suggestion, String.length(@value)..-1//1)
          end}
        </span>
      </div>
      <%# Real input (transparent background to show ghost text through) %>
      <input
        type="text"
        id={"#{@id}-input"}
        name={@name}
        value={@value}
        placeholder={@placeholder}
        disabled={@disabled}
        autocomplete="off"
        data-suggestion-input
        class={cn([
          "w-full px-3 py-2 text-sm border border-border rounded-md bg-transparent text-foreground",
          "placeholder:text-muted-foreground relative z-10",
          "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring",
          "disabled:cursor-not-allowed disabled:opacity-50"
        ])}
        phx-change={@on_change}
        phx-value-suggestion={@suggestion}
      />
      <p :if={@suggestion} class="text-xs text-muted-foreground mt-1">
        Press <kbd class="px-1 py-0.5 text-xs border border-border rounded font-mono">Tab</kbd> to accept
      </p>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # form_suggestion_input/1
  # ---------------------------------------------------------------------------

  attr(:field, Phoenix.HTML.FormField, required: true, doc: "A Phoenix.HTML.FormField struct.")
  attr(:label, :string, default: nil, doc: "Label text.")
  attr(:description, :string, default: nil, doc: "Helper text.")
  attr(:suggestion, :string, default: nil, doc: "Ghost-text suggestion.")
  attr(:on_accept, :string, default: nil, doc: "Accept event name.")
  attr(:placeholder, :string, default: nil, doc: "Placeholder text.")
  attr(:class, :string, default: nil, doc: "Additional CSS classes.")

  @doc """
  FormField-integrated wrapper for `suggestion_input/1`.
  """
  def form_suggestion_input(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    assigns =
      assigns
      |> assign(:errors, Enum.map(field.errors, &translate_error/1))
      |> assign_new(:value, fn -> field.value || "" end)

    id = "suggest-#{field.id}"
    assigns = assign(assigns, :_id, id)

    ~H"""
    <div class={cn(["space-y-2", @class])}>
      <label :if={@label} for={"#{@_id}-input"} class="text-sm font-medium leading-none">
        {@label}
      </label>
      <p :if={@description} class="text-sm text-muted-foreground">{@description}</p>
      <.suggestion_input
        id={@_id}
        name={@field.name}
        value={@value}
        suggestion={@suggestion}
        on_accept={@on_accept}
        on_change={@field.name}
        placeholder={@placeholder}
      />
      <p :for={error <- @errors} class="text-sm font-medium text-destructive">{error}</p>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # emoji_picker/1
  # ---------------------------------------------------------------------------

  attr(:id, :string, required: true, doc: "Root ID — required for PhiaEmojiPicker hook.")
  attr(:on_pick, :string, default: nil, doc: "LiveView event fired with `%{emoji: \"...\"}` on selection.")
  attr(:trigger_label, :string, default: "😊", doc: "Button label / emoji shown on the trigger.")

  attr(:placement, :atom,
    values: [:bottom, :top, :left, :right],
    default: :bottom,
    doc: "Popover placement relative to the trigger."
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes on the root element.")

  @doc """
  Renders a button that opens an emoji picker popover.
  The `PhiaEmojiPicker` hook renders a category-tabbed grid with search.
  Clicking an emoji fires `on_pick` via `pushEvent`.
  """
  def emoji_picker(assigns) do
    ~H"""
    <div
      id={@id}
      class={cn(["relative inline-block", @class])}
      phx-hook="PhiaEmojiPicker"
      data-on-pick={@on_pick}
      data-placement={@placement}
    >
      <button
        type="button"
        class={cn([
          "inline-flex items-center justify-center h-9 w-9 rounded-md border border-border",
          "bg-background hover:bg-accent text-foreground text-lg",
          "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring",
          "transition-colors"
        ])}
        aria-label="Open emoji picker"
        aria-haspopup="dialog"
        aria-expanded="false"
        data-emoji-trigger
      >
        {@trigger_label}
      </button>

      <%# Panel — rendered and populated by the JS hook %>
      <div
        class="hidden absolute z-50 w-72 rounded-lg border border-border bg-popover shadow-lg"
        role="dialog"
        aria-label="Emoji picker"
        data-emoji-panel
      >
        <%# Search bar %>
        <div class="p-2 border-b border-border">
          <input
            type="text"
            placeholder="Search emoji…"
            class={cn([
              "w-full px-2 py-1 text-sm border border-border rounded-md bg-background",
              "focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring"
            ])}
            data-emoji-search
            aria-label="Search emoji"
          />
        </div>
        <%# Category tabs %>
        <div class="flex gap-1 px-2 py-1 border-b border-border overflow-x-auto" data-emoji-tabs>
        </div>
        <%# Emoji grid — populated by hook %>
        <div class="p-2 h-48 overflow-y-auto" data-emoji-grid>
        </div>
      </div>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # keyboard_shortcut_input/1
  # ---------------------------------------------------------------------------

  attr(:id, :string, required: true, doc: "Root ID — required for PhiaKeyShortcut hook.")
  attr(:name, :string, default: nil, doc: "Hidden input name for form submission.")
  attr(:value, :string, default: nil, doc: "Current shortcut string (e.g. \"Ctrl+Shift+K\").")
  attr(:placeholder, :string, default: "Click to record shortcut…", doc: "Placeholder text.")
  attr(:on_change, :string, default: nil, doc: "LiveView event fired with `%{shortcut: \"...\"}` on capture.")
  attr(:disabled, :boolean, default: false, doc: "Disables the input.")
  attr(:class, :string, default: nil, doc: "Additional CSS classes.")

  @doc """
  Renders an input that captures a keyboard shortcut.
  Click to focus, press the key combination, and it is formatted and stored.
  The `PhiaKeyShortcut` hook fires `pushEvent(on_change, %{shortcut: "Ctrl+K"})`.
  """
  def keyboard_shortcut_input(assigns) do
    ~H"""
    <div
      id={@id}
      class={cn([
        "flex items-center gap-2 px-3 py-2 border border-border rounded-md bg-background",
        "text-sm cursor-pointer min-w-40",
        not @disabled && "hover:border-ring focus-within:ring-2 focus-within:ring-ring",
        @disabled && "opacity-50 cursor-not-allowed",
        @class
      ])}
      phx-hook="PhiaKeyShortcut"
      data-on-change={@on_change}
      tabindex={@disabled && "-1" || "0"}
      role="button"
      aria-label="Keyboard shortcut input"
      data-shortcut-container
    >
      <%= if @value && @value != "" do %>
        <div class="flex items-center gap-1 flex-wrap" data-shortcut-display>
          <%= for key <- String.split(@value, "+") do %>
            <kbd class={cn([
              "inline-flex items-center px-1.5 py-0.5 text-xs font-mono",
              "border border-border rounded bg-muted text-foreground"
            ])}>
              {key}
            </kbd>
          <% end %>
        </div>
        <button
          :if={not @disabled}
          type="button"
          class="ml-auto text-muted-foreground hover:text-foreground"
          data-shortcut-clear
          aria-label="Clear shortcut"
        >
          <svg xmlns="http://www.w3.org/2000/svg" class="h-3.5 w-3.5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true">
            <path d="M18 6 6 18M6 6l12 12" />
          </svg>
        </button>
      <% else %>
        <span class="text-muted-foreground" data-shortcut-placeholder>{@placeholder}</span>
      <% end %>
      <input type="hidden" name={@name} value={@value} data-shortcut-input />
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # form_keyboard_shortcut_input/1
  # ---------------------------------------------------------------------------

  attr(:field, Phoenix.HTML.FormField, required: true, doc: "A Phoenix.HTML.FormField struct.")
  attr(:label, :string, default: nil, doc: "Label text.")
  attr(:description, :string, default: nil, doc: "Helper text.")
  attr(:placeholder, :string, default: "Click to record shortcut…", doc: "Placeholder text.")
  attr(:on_change, :string, default: nil, doc: "LiveView event name.")
  attr(:class, :string, default: nil, doc: "Additional CSS classes.")

  @doc """
  FormField-integrated wrapper for `keyboard_shortcut_input/1`.
  """
  def form_keyboard_shortcut_input(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    assigns =
      assigns
      |> assign(:errors, Enum.map(field.errors, &translate_error/1))
      |> assign_new(:value, fn -> field.value end)

    id = "ks-#{field.id}"
    assigns = assign(assigns, :_id, id)

    ~H"""
    <div class={cn(["space-y-2", @class])}>
      <label :if={@label} class="text-sm font-medium leading-none">{@label}</label>
      <p :if={@description} class="text-sm text-muted-foreground">{@description}</p>
      <.keyboard_shortcut_input
        id={@_id}
        name={@field.name}
        value={@value}
        placeholder={@placeholder}
        on_change={@on_change || @field.name}
      />
      <p :for={error <- @errors} class="text-sm font-medium text-destructive">{error}</p>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  defp translate_error({msg, opts}) do
    Enum.reduce(opts, msg, fn
      {key, value}, acc when is_binary(acc) ->
        String.replace(acc, "%{#{key}}", to_string(value))

      _other, acc ->
        acc
    end)
  end
end
