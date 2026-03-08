defmodule PhiaUi.Components.SplitButton do
  @moduledoc """
  Split button: primary action (left) + dropdown caret (right).

  Requires the `PhiaSplitButton` JS hook registered in your LiveSocket.

  ## Example

      <.split_button id="actions-btn" variant={:default}>
        Save
        <:dropdown>
          <div data-split-item role="menuitem" phx-click="save_draft"
               class="flex cursor-pointer select-none items-center rounded-sm px-2 py-1.5 text-sm hover:bg-accent">
            Save as draft
          </div>
          <div data-split-item role="menuitem" phx-click="publish"
               class="flex cursor-pointer select-none items-center rounded-sm px-2 py-1.5 text-sm hover:bg-accent">
            Publish
          </div>
        </:dropdown>
      </.split_button>

  ## Setup

  Register `PhiaSplitButton` in your LiveSocket hooks:

      import PhiaSplitButton from "./hooks/split_button"
      let liveSocket = new LiveSocket("/live", Socket, { hooks: { PhiaSplitButton } })
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  attr :id, :string,
    required: true,
    doc: "Unique DOM ID for the hook target"

  attr :variant, :atom,
    values: [:default, :destructive, :outline, :secondary],
    default: :default,
    doc: "Visual style variant"

  attr :size, :atom,
    values: [:sm, :default, :lg],
    default: :default,
    doc: "Size variant"

  attr :disabled, :boolean, default: false
  attr :loading, :boolean, default: false
  attr :class, :string, default: nil
  attr :rest, :global, doc: "HTML attributes forwarded to the primary button"

  slot :inner_block, required: true, doc: "Primary button label"
  slot :dropdown, required: true, doc: "Dropdown menu items (use data-split-item on each)"

  @doc """
  Renders a split button with a primary action and a dropdown caret.

  The dropdown opens on caret click, closes on outside click or Escape, and
  supports roving focus on `[data-split-item]` elements via the
  `PhiaSplitButton` JS hook.
  """
  def split_button(assigns) do
    ~H"""
    <div
      id={@id}
      phx-hook="PhiaSplitButton"
      class={cn(["relative inline-flex z-50", @class])}
    >
      <%!-- Primary action button --%>
      <button
        type="button"
        class={cn([
          base_class(),
          variant_class(@variant),
          size_class(@size),
          "rounded-r-none",
          (@disabled or @loading) && "pointer-events-none opacity-50"
        ])}
        disabled={@disabled}
        aria-busy={@loading && "true"}
        {@rest}
      >
        <%= if @loading do %>
          <svg
            class="animate-spin h-4 w-4"
            xmlns="http://www.w3.org/2000/svg"
            fill="none"
            viewBox="0 0 24 24"
            aria-hidden="true"
          >
            <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4" />
            <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z" />
          </svg>
        <% end %>
        <%= render_slot(@inner_block) %>
      </button>

      <%!-- Caret / dropdown trigger button --%>
      <button
        type="button"
        data-split-caret
        aria-expanded="false"
        aria-haspopup="true"
        class={cn([
          base_class(),
          variant_class(@variant),
          caret_size_class(@size),
          "rounded-l-none",
          caret_divider_class(@variant),
          (@disabled or @loading) && "pointer-events-none opacity-50"
        ])}
        disabled={@disabled}
      >
        <svg
          xmlns="http://www.w3.org/2000/svg"
          class="h-4 w-4"
          viewBox="0 0 24 24"
          fill="none"
          stroke="currentColor"
          stroke-width="2"
          aria-hidden="true"
        >
          <polyline points="6 9 12 15 18 9" />
        </svg>
      </button>

      <%!-- Dropdown panel --%>
      <div
        id={"#{@id}-dropdown"}
        data-split-dropdown
        class="hidden absolute top-full mt-1 z-50 min-w-max rounded-md border border-border bg-popover text-popover-foreground shadow-md"
        role="menu"
      >
        <%= render_slot(@dropdown) %>
      </div>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  defp base_class do
    "inline-flex items-center justify-center whitespace-nowrap text-sm font-medium " <>
      "ring-offset-background transition-colors " <>
      "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2"
  end

  defp variant_class(:default),
    do: "bg-primary text-primary-foreground shadow hover:bg-primary/90"

  defp variant_class(:destructive),
    do: "bg-destructive text-destructive-foreground shadow-sm hover:bg-destructive/90"

  defp variant_class(:outline),
    do: "border border-input bg-background shadow-sm hover:bg-accent hover:text-accent-foreground"

  defp variant_class(:secondary),
    do: "bg-secondary text-secondary-foreground shadow-sm hover:bg-secondary/80"

  defp size_class(:sm), do: "h-9 px-3"
  defp size_class(:default), do: "h-10 px-4 py-2"
  defp size_class(:lg), do: "h-11 px-8"

  defp caret_size_class(:sm), do: "h-9 px-2"
  defp caret_size_class(:default), do: "h-10 px-2"
  defp caret_size_class(:lg), do: "h-11 px-3"

  # For outline: use -ml-px to merge double border with primary button
  defp caret_divider_class(:outline), do: "-ml-px border-l border-l-input"
  defp caret_divider_class(_), do: "border-l border-l-white/20"
end
