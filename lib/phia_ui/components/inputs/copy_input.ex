defmodule PhiaUi.Components.CopyInput do
  @moduledoc """
  Read-only input with an inline copy-to-clipboard button.

  Provides `copy_input/1` — a styled read-only text field designed to display
  values that users need to copy: API keys, tokens, share links, embed codes,
  and similar credentials or URLs.

  The copy button uses the `PhiaCopyButton` JS hook (already bundled with
  PhiaUI) which writes the input value to the clipboard and briefly shows a
  "Copied!" confirmation.

  ## Optional masking

  Set `:masked` to `true` to render the value as `•••••••••` dots. A toggle
  button lets users reveal the actual value (uses `JS.toggle_attribute` — no
  server round-trip).

  ## Basic usage

      <%!-- API key display --%>
      <.copy_input
        label="API Key"
        value="sk-live-abc123def456"
        masked={true}
      />

      <%!-- Share link --%>
      <.copy_input
        label="Share link"
        value="https://example.com/share/abc123"
      />

      <%!-- Embed code --%>
      <.copy_input value={~s(<script src="https://cdn.example.com/widget.js"></script>)} />
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  # ---------------------------------------------------------------------------
  # copy_input/1
  # ---------------------------------------------------------------------------

  attr(:id, :string,
    default: nil,
    doc: "HTML id for the `<input>`. Auto-generated if nil."
  )

  attr(:value, :string,
    required: true,
    doc: "The value to display and copy."
  )

  attr(:label, :string,
    default: nil,
    doc: "Label text rendered above the input group."
  )

  attr(:description, :string,
    default: nil,
    doc: "Helper text rendered below the label."
  )

  attr(:masked, :boolean,
    default: false,
    doc: """
    When true, the input renders as password-type (showing •••••). A reveal
    button is shown to toggle visibility. The copy button always copies the
    real value regardless of masking.
    """
  )

  attr(:size, :string,
    default: "default",
    values: ~w(sm default lg),
    doc: "Input height — `sm`, `default`, or `lg`."
  )

  attr(:class, :string,
    default: nil,
    doc: "Additional CSS classes applied to the outer wrapper."
  )

  @doc """
  Renders a read-only input with a copy-to-clipboard button.

  The copy button is powered by the `PhiaCopyButton` JS hook which must be
  registered in your app's `hooks` config:

      // app.js
      import { PhiaCopyButton } from "./hooks"
      let liveSocket = new LiveSocket("/live", Socket, { hooks: { PhiaCopyButton } })

  ## Examples

      <.copy_input label="API Key" value={@api_key} masked={true} />

      <.copy_input label="Webhook URL" value={@webhook_url} />

      <.copy_input value={@share_link} size="sm" />
  """
  def copy_input(assigns) do
    id = assigns.id || "copy-input-#{:erlang.unique_integer([:positive])}"
    assigns = assign(assigns, :id, id)
    assigns = assign(assigns, :input_id, id <> "-field")

    ~H"""
    <div class={cn(["space-y-2", @class])}>
      <label
        :if={@label}
        for={@input_id}
        class="text-sm font-medium leading-none"
      >
        {@label}
      </label>
      <p :if={@description} class="text-sm text-muted-foreground">{@description}</p>

      <div class="flex items-stretch rounded-md border border-input bg-background overflow-hidden focus-within:ring-2 focus-within:ring-ring focus-within:ring-offset-2">
        <%!-- The read-only input --%>
        <input
          id={@input_id}
          type={if @masked, do: "password", else: "text"}
          value={@value}
          readonly
          class={cn([
            "flex-1 min-w-0 bg-transparent px-3 py-2 text-sm font-mono text-foreground",
            "focus-visible:outline-none disabled:cursor-not-allowed disabled:opacity-50",
            size_class(@size)
          ])}
          aria-label={@label || "Copy value"}
        />

        <%!-- Reveal toggle (masked only) --%>
        <button
          :if={@masked}
          type="button"
          aria-label="Reveal value"
          class="flex items-center justify-center border-l border-input bg-muted px-2.5 text-muted-foreground transition-colors hover:bg-accent hover:text-foreground"
          phx-click={
            Phoenix.LiveView.JS.toggle_attribute({"type", "password", "text"},
              to: "##{@input_id}"
            )
          }
        >
          <svg
            xmlns="http://www.w3.org/2000/svg"
            class="h-4 w-4"
            viewBox="0 0 24 24"
            fill="none"
            stroke="currentColor"
            stroke-width="2"
            stroke-linecap="round"
            stroke-linejoin="round"
            aria-hidden="true"
          >
            <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z" />
            <circle cx="12" cy="12" r="3" />
          </svg>
        </button>

        <%!-- Copy button — powered by PhiaCopyButton hook --%>
        <button
          id={"#{@id}-copy-btn"}
          type="button"
          phx-hook="PhiaCopyButton"
          data-copy-target={"##{@input_id}"}
          aria-label="Copy to clipboard"
          class="flex items-center gap-1.5 border-l border-input bg-muted px-3 text-sm text-muted-foreground transition-colors hover:bg-accent hover:text-foreground whitespace-nowrap"
        >
          <svg
            xmlns="http://www.w3.org/2000/svg"
            class="h-3.5 w-3.5"
            viewBox="0 0 24 24"
            fill="none"
            stroke="currentColor"
            stroke-width="2"
            stroke-linecap="round"
            stroke-linejoin="round"
            aria-hidden="true"
          >
            <rect width="14" height="14" x="8" y="8" rx="2" ry="2" />
            <path d="M4 16c-1.1 0-2-.9-2-2V4c0-1.1.9-2 2-2h10c1.1 0 2 .9 2 2" />
          </svg>
          Copy
        </button>
      </div>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  defp size_class("sm"), do: "h-8 text-xs"
  defp size_class("lg"), do: "h-12 text-base"
  defp size_class(_), do: "h-10"
end
