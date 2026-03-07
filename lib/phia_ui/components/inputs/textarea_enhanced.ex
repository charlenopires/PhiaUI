defmodule PhiaUi.Components.TextareaEnhanced do
  @moduledoc """
  Enhanced textarea components for PhiaUI.

  13 components extending the base `phia_textarea/1` with auto-growth,
  chat-style entry, code editing, action bars, side-by-side preview,
  ghost style, and expandable behaviour.

  ## Component Overview

  | Standalone              | Form-integrated                 | Key Feature             |
  |-------------------------|---------------------------------|-------------------------|
  | `autoresize_textarea`   | `phia_autoresize_textarea`      | Auto-grows with content |
  | `chat_textarea`         | —                               | Enter-to-submit         |
  | `code_textarea`         | `phia_code_textarea`            | Monospace + Tab indent  |
  | `textarea_with_actions` | `phia_textarea_with_actions`    | Bottom action bar slot  |
  | `split_textarea`        | `phia_split_textarea`           | Live preview panel      |
  | `ghost_textarea`        | `phia_ghost_textarea`           | Borderless / transparent|
  | `expandable_textarea`   | `phia_expandable_textarea`      | Collapsed + expand btn  |

  ## Hooks required

  - `PhiaAutoresize` — autoresize_textarea, phia_autoresize_textarea
  - `PhiaChatTextarea` — chat_textarea
  - `PhiaCodeTextarea` — code_textarea, phia_code_textarea
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]
  import PhiaUi.Components.Form, only: [form_field: 1]

  # ---------------------------------------------------------------------------
  # autoresize_textarea/1
  # ---------------------------------------------------------------------------

  attr(:id, :string, default: nil, doc: "HTML id. Auto-generated if nil.")
  attr(:name, :string, default: nil, doc: "HTML name attribute.")
  attr(:value, :string, default: "", doc: "Textarea content.")
  attr(:placeholder, :string, default: nil)
  attr(:min_rows, :integer, default: 2, doc: "Minimum rows before auto-grow kicks in.")
  attr(:max_rows, :integer, default: 12, doc: "Maximum rows allowed (caps auto-grow).")
  attr(:disabled, :boolean, default: false)
  attr(:class, :string, default: nil)
  attr(:rest, :global, include: ~w(phx-change phx-debounce phx-keydown required readonly autofocus))

  @doc """
  Auto-growing textarea that expands with content.

  Feature-detects `field-sizing: content` (Chrome 123+) for native resize.
  Falls back to JS `scrollHeight` via the `PhiaAutoresize` hook.

  ## Example

      <.autoresize_textarea
        name="message"
        value={@message}
        placeholder="Type your message..."
        phx-change="update_message"
      />
  """
  def autoresize_textarea(assigns) do
    id = assigns.id || "autoresize-#{:erlang.unique_integer([:positive])}"
    assigns = assign(assigns, :id, id)

    ~H"""
    <textarea
      id={@id}
      name={@name}
      placeholder={@placeholder}
      disabled={@disabled}
      rows={@min_rows}
      phx-hook="PhiaAutoresize"
      data-min-rows={to_string(@min_rows)}
      data-max-rows={to_string(@max_rows)}
      class={cn([
        "border rounded-md bg-background px-3 py-2 text-sm w-full resize-none overflow-hidden",
        "min-h-[80px] focus:outline-none focus:ring-2 focus:ring-ring focus:ring-offset-0",
        @disabled && "cursor-not-allowed opacity-50",
        @class
      ])}
      {@rest}
    >{@value}</textarea>
    """
  end

  # ---------------------------------------------------------------------------
  # phia_autoresize_textarea/1
  # ---------------------------------------------------------------------------

  attr(:field, Phoenix.HTML.FormField, required: true)
  attr(:label, :string, default: nil)
  attr(:description, :string, default: nil)
  attr(:placeholder, :string, default: nil)
  attr(:min_rows, :integer, default: 2)
  attr(:max_rows, :integer, default: 12)
  attr(:class, :string, default: nil)

  @doc """
  Form-integrated auto-resizing textarea.

  Wraps `autoresize_textarea` in `form_field/1` with label, description,
  and changeset error display.

  ## Example

      <.phia_autoresize_textarea
        field={@form[:message]}
        label="Message"
        min_rows={3}
        max_rows={10}
      />
  """
  def phia_autoresize_textarea(assigns) do
    ~H"""
    <.form_field field={@field} label={@label} description={@description}>
      <.autoresize_textarea
        id={@field.id}
        name={@field.name}
        value={@field.value}
        placeholder={@placeholder}
        min_rows={@min_rows}
        max_rows={@max_rows}
        class={@class}
        phx-debounce="blur"
      />
    </.form_field>
    """
  end

  # ---------------------------------------------------------------------------
  # chat_textarea/1
  # ---------------------------------------------------------------------------

  attr(:id, :string, required: true, doc: "Unique ID (required for phx-hook).")
  attr(:name, :string, default: nil)
  attr(:value, :string, default: "")
  attr(:placeholder, :string, default: "Type a message… (Enter to send, Shift+Enter for newline)")
  attr(:on_submit, :string, default: "chat_submit", doc: "push_event name fired on Enter key.")
  attr(:min_rows, :integer, default: 1)
  attr(:max_rows, :integer, default: 6)
  attr(:disabled, :boolean, default: false)
  attr(:class, :string, default: nil)
  attr(:rest, :global, include: ~w(phx-change phx-debounce))

  slot(:actions, doc: "Right-side action buttons (send button, file attach, emoji, etc.)")

  @doc """
  A chat-style textarea with Enter-to-submit and Shift+Enter for newlines.

  Fires `push_event(@on_submit, %{"value" => textarea_value})` on Enter,
  then clears and resets the textarea height. Shift+Enter inserts a newline.

  Requires the `PhiaChatTextarea` JS hook.

  ## Example

      <.chat_textarea
        id="chat-input"
        name="message"
        on_submit="send_message"
        placeholder="Message #general"
      >
        <:actions>
          <button type="button" phx-click="attach_file">
            <.icon name="paperclip" />
          </button>
        </:actions>
      </.chat_textarea>
  """
  def chat_textarea(assigns) do
    ~H"""
    <div class={cn(["flex items-end gap-2 rounded-md border border-input bg-background px-3 py-2", @class])}>
      <textarea
        id={@id}
        name={@name}
        placeholder={@placeholder}
        disabled={@disabled}
        rows={@min_rows}
        phx-hook="PhiaChatTextarea"
        data-on-submit={@on_submit}
        data-min-rows={to_string(@min_rows)}
        data-max-rows={to_string(@max_rows)}
        class={cn([
          "flex-1 resize-none overflow-hidden bg-transparent text-sm focus:outline-none",
          "min-h-[24px] max-h-[150px] placeholder:text-muted-foreground",
          @disabled && "cursor-not-allowed opacity-50"
        ])}
        {@rest}
      >{@value}</textarea>
      <div :if={@actions != []} class="flex items-center gap-1 shrink-0">
        {render_slot(@actions)}
      </div>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # code_textarea/1
  # ---------------------------------------------------------------------------

  attr(:id, :string, default: nil, doc: "HTML id. Auto-generated if nil.")
  attr(:name, :string, default: nil)
  attr(:value, :string, default: "")
  attr(:placeholder, :string, default: nil)
  attr(:tab_size, :integer, default: 2, doc: "Number of spaces inserted on Tab key.")
  attr(:show_line_numbers, :boolean, default: true, doc: "Show line numbers overlay.")
  attr(:rows, :integer, default: 10)
  attr(:disabled, :boolean, default: false)
  attr(:class, :string, default: nil)
  attr(:rest, :global, include: ~w(phx-change phx-debounce required readonly autofocus))

  @doc """
  A monospace code textarea with Tab-indentation and optional line numbers.

  - **Tab key** inserts `tab_size` spaces instead of moving focus.
  - **Enter key** carries forward the leading whitespace of the current line.
  - **Line numbers** are rendered as an absolutely-positioned `<ol>` that
    scrolls in sync with the textarea.

  Requires the `PhiaCodeTextarea` JS hook.

  ## Example

      <.code_textarea
        name="snippet"
        value={@snippet}
        tab_size={4}
        show_line_numbers={true}
        rows={15}
      />
  """
  def code_textarea(assigns) do
    id = assigns.id || "code-ta-#{:erlang.unique_integer([:positive])}"
    line_count = assigns.value |> String.split("\n") |> length()
    assigns = assign(assigns, id: id, line_count: line_count)

    ~H"""
    <div class="phia-code-textarea-wrap relative font-mono text-sm">
      <ol
        :if={@show_line_numbers}
        class={cn([
          "phia-line-numbers select-none text-right text-muted-foreground",
          "px-3 pt-2 text-xs leading-6 bg-muted/30 border-r border-border min-w-[3rem]"
        ])}
        aria-hidden="true"
      >
        <li :for={n <- 1..max(1, @line_count)} class="list-none leading-6">
          {n}
        </li>
      </ol>
      <textarea
        id={@id}
        name={@name}
        rows={@rows}
        placeholder={@placeholder}
        disabled={@disabled}
        phx-hook="PhiaCodeTextarea"
        data-tab-size={to_string(@tab_size)}
        data-show-line-numbers={to_string(@show_line_numbers)}
        class={cn([
          "w-full bg-background px-3 py-2 text-sm font-mono resize-y",
          "focus:outline-none focus:ring-2 focus:ring-ring leading-6",
          @show_line_numbers && "pl-2",
          @disabled && "cursor-not-allowed opacity-50",
          @class
        ])}
        {@rest}
      >{@value}</textarea>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # phia_code_textarea/1
  # ---------------------------------------------------------------------------

  attr(:field, Phoenix.HTML.FormField, required: true)
  attr(:label, :string, default: nil)
  attr(:description, :string, default: nil)
  attr(:tab_size, :integer, default: 2)
  attr(:show_line_numbers, :boolean, default: true)
  attr(:rows, :integer, default: 10)
  attr(:class, :string, default: nil)

  @doc """
  Form-integrated code textarea.

  Wraps `code_textarea` in `form_field/1` for changeset integration.

  ## Example

      <.phia_code_textarea
        field={@form[:code]}
        label="SQL Query"
        tab_size={4}
        rows={12}
      />
  """
  def phia_code_textarea(assigns) do
    ~H"""
    <.form_field field={@field} label={@label} description={@description}>
      <.code_textarea
        id={@field.id}
        name={@field.name}
        value={@field.value}
        tab_size={@tab_size}
        show_line_numbers={@show_line_numbers}
        rows={@rows}
        class={@class}
        phx-debounce="blur"
      />
    </.form_field>
    """
  end

  # ---------------------------------------------------------------------------
  # textarea_with_actions/1
  # ---------------------------------------------------------------------------

  attr(:id, :string, default: nil)
  attr(:name, :string, default: nil)
  attr(:value, :string, default: "")
  attr(:placeholder, :string, default: nil)
  attr(:rows, :integer, default: 4)
  attr(:disabled, :boolean, default: false)
  attr(:class, :string, default: nil)
  attr(:rest, :global, include: ~w(phx-change phx-debounce required readonly autofocus))

  slot(:actions, doc: "Content rendered in the bottom action bar (buttons, counters, etc.)")

  @doc """
  Textarea with a bottom action bar for buttons, character counts, or quick actions.

  The action bar is separated from the textarea by a subtle `border-t`.

  ## Example

      <.textarea_with_actions name="post" value={@post} placeholder="Write a post...">
        <:actions>
          <button type="button" phx-click="add_emoji">Emoji</button>
          <button type="submit" class="ml-auto">Post</button>
        </:actions>
      </.textarea_with_actions>
  """
  def textarea_with_actions(assigns) do
    id = assigns.id || "ta-actions-#{:erlang.unique_integer([:positive])}"
    assigns = assign(assigns, :id, id)

    ~H"""
    <div class={cn(["rounded-md border border-input bg-background", @class])}>
      <textarea
        id={@id}
        name={@name}
        rows={@rows}
        placeholder={@placeholder}
        disabled={@disabled}
        class={cn([
          "w-full bg-transparent px-3 py-2 text-sm resize-y",
          "focus:outline-none placeholder:text-muted-foreground",
          @disabled && "cursor-not-allowed opacity-50"
        ])}
        {@rest}
      >{@value}</textarea>
      <div :if={@actions != []} class="border-t border-border px-3 py-2 flex items-center gap-2">
        {render_slot(@actions)}
      </div>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # phia_textarea_with_actions/1
  # ---------------------------------------------------------------------------

  attr(:field, Phoenix.HTML.FormField, required: true)
  attr(:label, :string, default: nil)
  attr(:description, :string, default: nil)
  attr(:placeholder, :string, default: nil)
  attr(:rows, :integer, default: 4)
  attr(:class, :string, default: nil)

  slot(:actions)

  @doc """
  Form-integrated textarea with bottom action bar.

  ## Example

      <.phia_textarea_with_actions field={@form[:body]} label="Post body">
        <:actions>
          <button type="submit">Publish</button>
        </:actions>
      </.phia_textarea_with_actions>
  """
  def phia_textarea_with_actions(assigns) do
    ~H"""
    <.form_field field={@field} label={@label} description={@description}>
      <.textarea_with_actions
        id={@field.id}
        name={@field.name}
        value={@field.value}
        placeholder={@placeholder}
        rows={@rows}
        class={@class}
        phx-debounce="blur"
      >
        <:actions>{render_slot(@actions)}</:actions>
      </.textarea_with_actions>
    </.form_field>
    """
  end

  # ---------------------------------------------------------------------------
  # split_textarea/1
  # ---------------------------------------------------------------------------

  attr(:id, :string, default: nil)
  attr(:name, :string, default: nil)
  attr(:value, :string, default: "")
  attr(:placeholder, :string, default: "Write Markdown here...")
  attr(:rows, :integer, default: 10)
  attr(:class, :string, default: nil)
  attr(:rest, :global, include: ~w(phx-change phx-debounce))

  slot(:preview, required: true, doc: "Preview panel content (rendered HTML, live preview, etc.)")

  @doc """
  Side-by-side editor with a live preview panel.

  The left column is the raw textarea; the right column is the `:preview` slot.
  Update the preview by handling `phx-change` in your LiveView and re-rendering
  the preview slot with processed content.

  ## Example

      <.split_textarea
        name="markdown"
        value={@markdown}
        phx-change="update_markdown"
      >
        <:preview>
          <div class="prose">{Phoenix.HTML.raw(@preview_html)}</div>
        </:preview>
      </.split_textarea>
  """
  def split_textarea(assigns) do
    id = assigns.id || "split-ta-#{:erlang.unique_integer([:positive])}"
    assigns = assign(assigns, :id, id)

    ~H"""
    <div class={cn(["grid grid-cols-2 divide-x divide-border rounded-md border border-input", @class])}>
      <div>
        <div class="px-3 py-1.5 border-b border-border bg-muted/30">
          <span class="text-xs font-medium text-muted-foreground uppercase tracking-wider">Write</span>
        </div>
        <textarea
          id={@id}
          name={@name}
          rows={@rows}
          placeholder={@placeholder}
          class="w-full bg-transparent px-3 py-2 text-sm resize-none focus:outline-none placeholder:text-muted-foreground font-mono"
          {@rest}
        >{@value}</textarea>
      </div>
      <div>
        <div class="px-3 py-1.5 border-b border-border bg-muted/30">
          <span class="text-xs font-medium text-muted-foreground uppercase tracking-wider">Preview</span>
        </div>
        <div class="px-3 py-2 min-h-[100px] overflow-auto">
          {render_slot(@preview)}
        </div>
      </div>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # phia_split_textarea/1
  # ---------------------------------------------------------------------------

  attr(:field, Phoenix.HTML.FormField, required: true)
  attr(:label, :string, default: nil)
  attr(:description, :string, default: nil)
  attr(:placeholder, :string, default: "Write Markdown here...")
  attr(:rows, :integer, default: 10)
  attr(:class, :string, default: nil)

  slot(:preview, required: true)

  @doc """
  Form-integrated split textarea with live preview.

  ## Example

      <.phia_split_textarea field={@form[:content]} label="Content">
        <:preview>
          <div class="prose">{Phoenix.HTML.raw(@preview)}</div>
        </:preview>
      </.phia_split_textarea>
  """
  def phia_split_textarea(assigns) do
    ~H"""
    <.form_field field={@field} label={@label} description={@description}>
      <.split_textarea
        id={@field.id}
        name={@field.name}
        value={@field.value}
        placeholder={@placeholder}
        rows={@rows}
        class={@class}
        phx-debounce="blur"
      >
        <:preview>{render_slot(@preview)}</:preview>
      </.split_textarea>
    </.form_field>
    """
  end

  # ---------------------------------------------------------------------------
  # ghost_textarea/1
  # ---------------------------------------------------------------------------

  attr(:id, :string, default: nil)
  attr(:name, :string, default: nil)
  attr(:value, :string, default: "")
  attr(:placeholder, :string, default: nil)
  attr(:rows, :integer, default: 3)
  attr(:disabled, :boolean, default: false)
  attr(:class, :string, default: nil)
  attr(:rest, :global, include: ~w(phx-change phx-debounce required readonly autofocus))

  @doc """
  A borderless, transparent textarea for inline editing contexts.

  No border, no background, no focus ring — blends into any surface.
  Ideal for in-place text editing in cards, lists, or comment flows.

  ## Example

      <.ghost_textarea name="note" value={@note} placeholder="Add a note..." />
  """
  def ghost_textarea(assigns) do
    id = assigns.id || "ghost-ta-#{:erlang.unique_integer([:positive])}"
    assigns = assign(assigns, :id, id)

    ~H"""
    <textarea
      id={@id}
      name={@name}
      rows={@rows}
      placeholder={@placeholder}
      disabled={@disabled}
      class={cn([
        "w-full bg-transparent border-0 shadow-none outline-none resize-none",
        "text-sm placeholder:text-muted-foreground focus-visible:ring-0",
        @disabled && "cursor-not-allowed opacity-50",
        @class
      ])}
      {@rest}
    >{@value}</textarea>
    """
  end

  # ---------------------------------------------------------------------------
  # phia_ghost_textarea/1
  # ---------------------------------------------------------------------------

  attr(:field, Phoenix.HTML.FormField, required: true)
  attr(:label, :string, default: nil)
  attr(:description, :string, default: nil)
  attr(:placeholder, :string, default: nil)
  attr(:rows, :integer, default: 3)
  attr(:class, :string, default: nil)

  @doc """
  Form-integrated ghost (borderless) textarea.

  ## Example

      <.phia_ghost_textarea field={@form[:note]} label="Internal note" />
  """
  def phia_ghost_textarea(assigns) do
    ~H"""
    <.form_field field={@field} label={@label} description={@description}>
      <.ghost_textarea
        id={@field.id}
        name={@field.name}
        value={@field.value}
        placeholder={@placeholder}
        rows={@rows}
        class={@class}
        phx-debounce="blur"
      />
    </.form_field>
    """
  end

  # ---------------------------------------------------------------------------
  # expandable_textarea/1
  # ---------------------------------------------------------------------------

  attr(:id, :string, default: nil)
  attr(:name, :string, default: nil)
  attr(:value, :string, default: "")
  attr(:placeholder, :string, default: nil)
  attr(:collapsed_rows, :integer, default: 2, doc: "Row count when collapsed.")
  attr(:expanded_rows, :integer, default: 8, doc: "Row count when expanded.")
  attr(:expand_label, :string, default: "Expand")
  attr(:collapse_label, :string, default: "Collapse")
  attr(:disabled, :boolean, default: false)
  attr(:class, :string, default: nil)
  attr(:rest, :global, include: ~w(phx-change phx-debounce required readonly autofocus))

  @doc """
  Textarea that starts collapsed and expands via a client-side button.

  Uses `JS.toggle_attribute` to swap the `rows` attribute — no server
  round-trip or hook needed.

  ## Example

      <.expandable_textarea
        name="description"
        value={@description}
        collapsed_rows={2}
        expanded_rows={8}
      />
  """
  def expandable_textarea(assigns) do
    id = assigns.id || "exp-ta-#{:erlang.unique_integer([:positive])}"
    ta_id = "#{id}-ta"
    btn_id = "#{id}-btn"
    assigns = assign(assigns, id: id, ta_id: ta_id, btn_id: btn_id)

    ~H"""
    <div class={cn(["space-y-1", @class])}>
      <textarea
        id={@ta_id}
        name={@name}
        rows={@collapsed_rows}
        placeholder={@placeholder}
        disabled={@disabled}
        class={cn([
          "border rounded-md bg-background px-3 py-2 text-sm w-full resize-none",
          "focus:outline-none focus:ring-2 focus:ring-ring",
          @disabled && "cursor-not-allowed opacity-50"
        ])}
        {@rest}
      >{@value}</textarea>
      <button
        id={@btn_id}
        type="button"
        class="text-xs text-muted-foreground hover:text-foreground transition-colors"
        phx-click={
          Phoenix.LiveView.JS.toggle_attribute(
            {"rows", to_string(@collapsed_rows), to_string(@expanded_rows)},
            to: "##{@ta_id}"
          )
          |> Phoenix.LiveView.JS.toggle_attribute({"data-expanded", "true"}, to: "##{@btn_id}")
        }
      >
        <span class="[&[data-expanded]_&]:hidden">{@expand_label}</span>
        <span class="hidden [&[data-expanded]_&]:inline">{@collapse_label}</span>
      </button>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # phia_expandable_textarea/1
  # ---------------------------------------------------------------------------

  attr(:field, Phoenix.HTML.FormField, required: true)
  attr(:label, :string, default: nil)
  attr(:description, :string, default: nil)
  attr(:placeholder, :string, default: nil)
  attr(:collapsed_rows, :integer, default: 2)
  attr(:expanded_rows, :integer, default: 8)
  attr(:expand_label, :string, default: "Expand")
  attr(:collapse_label, :string, default: "Collapse")
  attr(:class, :string, default: nil)

  @doc """
  Form-integrated expandable textarea.

  ## Example

      <.phia_expandable_textarea
        field={@form[:description]}
        label="Description"
        collapsed_rows={2}
        expanded_rows={8}
      />
  """
  def phia_expandable_textarea(assigns) do
    ~H"""
    <.form_field field={@field} label={@label} description={@description}>
      <.expandable_textarea
        id={@field.id}
        name={@field.name}
        value={@field.value}
        placeholder={@placeholder}
        collapsed_rows={@collapsed_rows}
        expanded_rows={@expanded_rows}
        expand_label={@expand_label}
        collapse_label={@collapse_label}
        class={@class}
        phx-debounce="blur"
      />
    </.form_field>
    """
  end
end
