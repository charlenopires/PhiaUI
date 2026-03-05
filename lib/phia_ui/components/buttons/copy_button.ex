defmodule PhiaUi.Components.CopyButton do
  @moduledoc """
  Copy-to-clipboard button component powered by the `PhiaCopyButton` vanilla JS hook.

  Renders an icon-only button that copies the given `value` to the user's
  clipboard on click. After a successful copy, the copy icon is swapped for a
  check icon for the duration of `timeout` milliseconds, providing clear visual
  feedback. A hidden `aria-live` span announces "Copied!" to screen readers.

  The hook uses the `navigator.clipboard.writeText` API where available, with a
  `textarea` + `execCommand("copy")` fallback for older browsers.

  ## Usage

      <%!-- Minimal: copies an npm install command --%>
      <.copy_button id="copy-npm" value="npm install phia_ui" />

      <%!-- With a custom label and extended feedback timeout --%>
      <.copy_button id="copy-api-key" value={@api_key} label="Copy API key" timeout={3000} />

  ## Setup

  1. Ensure `PhiaCopyButton` is registered in your LiveSocket hooks:

         import PhiaCopyButton from "./hooks/copy_button"
         let liveSocket = new LiveSocket("/live", Socket, {
           hooks: { PhiaCopyButton }
         })

  2. Add the `id` attribute — `phx-hook` requires a unique DOM `id`.

  ## Accessibility

  - `aria-label` on the button announces the action to screen readers.
  - `aria-live="polite"` on a visually hidden `<span>` announces "Copied!" to
    screen readers after a successful copy without interrupting ongoing
    announcements.
  - Both icons are `aria-hidden="true"` to avoid redundant announcements.

  ## Theme tokens

  The button uses PhiaUI semantic Tailwind v4 tokens so it adapts automatically
  to dark mode and custom colour presets:

  - `bg-background` / `border-border` — matches card and input surfaces
  - `text-muted-foreground` — de-emphasised icon colour at rest
  - `hover:bg-accent hover:text-foreground` — standard hover state
  - `focus-visible:ring-ring` — accessible keyboard focus ring
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  attr(:id, :string,
    required: true,
    doc: """
    Unique DOM ID for the button element. Required because `phx-hook` targets
    elements by ID. Use a stable, page-unique string like `"copy-api-key"`.
    """
  )

  attr(:value, :string,
    required: true,
    doc: "The text string to copy to the clipboard when the button is clicked."
  )

  attr(:label, :string,
    default: "Copy",
    doc: "Accessible label for the button, used as `aria-label`. Defaults to `\"Copy\"`."
  )

  attr(:timeout, :integer,
    default: 2000,
    doc: """
    Duration in milliseconds to show the check icon after a successful copy.
    After this period the button reverts to the copy icon. Defaults to `2000`.
    """
  )

  attr(:class, :string,
    default: nil,
    doc: "Additional CSS classes merged via `cn/1`. Last-wins conflict resolution applies."
  )

  attr(:rest, :global,
    doc: "HTML attributes forwarded to the `<button>` element (e.g. `data-*`, `phx-*`)."
  )

  @doc """
  Renders a copy-to-clipboard icon button.

  The button shows a clipboard icon at rest and a check icon briefly after the
  user clicks it to confirm the copy succeeded. The hook handles both the
  Clipboard API and an `execCommand` fallback.

  ## Examples

      <%!-- Copy a code snippet --%>
      <.copy_button id="copy-snippet" value="mix phia.add Button" />

      <%!-- Copy an API key with a longer feedback window --%>
      <.copy_button id="copy-key" value={@api_key} label="Copy API key" timeout={3000} />

      <%!-- Override button sizing --%>
      <.copy_button id="copy-sm" value={@value} class="h-6 w-6" />
  """
  def copy_button(assigns) do
    ~H"""
    <button
      id={@id}
      type="button"
      phx-hook="PhiaCopyButton"
      data-value={@value}
      data-timeout={@timeout}
      aria-label={@label}
      class={cn([
        "inline-flex items-center justify-center h-8 w-8 rounded-md",
        "border border-border bg-background text-muted-foreground",
        "hover:bg-accent hover:text-foreground",
        "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring",
        "transition-colors",
        @class
      ])}
      {@rest}
    >
      <%!-- Copy icon — visible by default --%>
      <svg
        xmlns="http://www.w3.org/2000/svg"
        class="h-4 w-4"
        viewBox="0 0 24 24"
        fill="none"
        stroke="currentColor"
        stroke-width="2"
        aria-hidden="true"
        data-copy-icon
      >
        <rect x="9" y="9" width="13" height="13" rx="2" ry="2" />
        <path d="M5 15H4a2 2 0 01-2-2V4a2 2 0 012-2h9a2 2 0 012 2v1" />
      </svg>
      <%!-- Check icon — hidden by default, shown by hook after copy --%>
      <svg
        xmlns="http://www.w3.org/2000/svg"
        class="h-4 w-4 hidden"
        viewBox="0 0 24 24"
        fill="none"
        stroke="currentColor"
        stroke-width="2"
        aria-hidden="true"
        data-copy-check
      >
        <polyline points="20 6 9 17 4 12" />
      </svg>
      <%!-- Screen reader feedback — updated by hook to "Copied!" after copy --%>
      <span class="sr-only" aria-live="polite"></span>
    </button>
    """
  end
end
