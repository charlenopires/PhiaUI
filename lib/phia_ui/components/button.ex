defmodule PhiaUi.Components.Button do
  @moduledoc """
  Stateless Button component with 6 variants and 7 sizes.

  Follows the shadcn/ui Button anatomy adapted for Phoenix LiveView.
  Classes are built via `PhiaUi.ClassMerger.cn/1` so callers can safely
  override individual utilities using the `:class` attribute.

  ## Variants

  | Variant       | Use case                              |
  |---------------|---------------------------------------|
  | `:default`    | Primary call-to-action                |
  | `:destructive`| Dangerous or irreversible actions     |
  | `:outline`    | Secondary actions, cancel             |
  | `:secondary`  | Lower-emphasis actions                |
  | `:ghost`      | Minimal emphasis, toolbar actions     |
  | `:link`       | Inline navigation-like actions        |

  ## Sizes

  | Size       | Dimensions              |
  |------------|-------------------------|
  | `:default` | h-10 px-4 py-2          |
  | `:xs`      | h-7 px-2 text-xs        |
  | `:sm`      | h-9 px-3                |
  | `:lg`      | h-11 px-8               |
  | `:icon`    | h-10 w-10 (square)      |
  | `:icon_sm` | h-8 w-8 (small square)  |
  | `:icon_lg` | h-12 w-12 (large square)|

  ## Examples

      <.button>Save changes</.button>

      <.button variant={:destructive}>Delete account</.button>

      <.button variant={:outline}>Cancel</.button>

      <.button variant={:secondary}>More options</.button>

      <.button variant={:ghost}>Settings</.button>

      <.button variant={:link}>View details</.button>

      <.button size={:sm}>Compact action</.button>

      <.button size={:lg}>Prominent action</.button>

      <.button size={:icon} aria-label="Add item">
        <.icon name="hero-plus" />
      </.button>

      <.button phx-click="save" phx-disable-with="Saving…">
        Save
      </.button>

      <.button disabled={true}>Unavailable</.button>

      <.button class="w-full">Full width</.button>

      <.button size={:xs}>Compact</.button>

      <.button size={:icon_sm} aria-label="Remove">✕</.button>

      <.button>
        <:left_icon><.icon name="hero-arrow-left" /></:left_icon>
        Back
      </.button>

      <.button loading={true}>Saving…</.button>
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  attr(:variant, :atom,
    values: [:default, :destructive, :outline, :secondary, :ghost, :link],
    default: :default,
    doc: "Visual style variant"
  )

  attr(:size, :atom,
    values: [:default, :xs, :sm, :lg, :icon, :icon_sm, :icon_lg],
    default: :default,
    doc: "Size variant"
  )

  attr(:class, :string,
    default: nil,
    doc: "Additional CSS classes (merged via cn/1, last wins)"
  )

  attr(:disabled, :boolean,
    default: false,
    doc: "Disables the button and adds pointer-events-none opacity-50"
  )

  attr(:loading, :boolean,
    default: false,
    doc: "Shows a spinner and prevents interaction while true"
  )

  attr(:rest, :global,
    doc: "HTML attributes forwarded to the <button> element (phx-click, data-*, aria-*, etc.)"
  )

  slot(:left_icon, doc: "Optional icon rendered to the left of the label")
  slot(:right_icon, doc: "Optional icon rendered to the right of the label")
  slot(:inner_block, required: true, doc: "Button label, text or icon content")

  @doc """
  Renders a `<button>` element with semantic PhiaUI theming.
  """
  def button(assigns) do
    assigns =
      assign(assigns, :has_icon, assigns.left_icon != [] or assigns.right_icon != [])

    ~H"""
    <button
      class={cn([
        base_class(),
        variant_class(@variant),
        size_class(@size),
        (@disabled or @loading) && "pointer-events-none opacity-50",
        @has_icon && "gap-2",
        @class
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
          <path
            class="opacity-75"
            fill="currentColor"
            d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z"
          />
        </svg>
      <% end %>
      <%= if @left_icon != [] do %>
        <%= render_slot(@left_icon) %>
      <% end %>
      <%= render_slot(@inner_block) %>
      <%= if @right_icon != [] do %>
        <%= render_slot(@right_icon) %>
      <% end %>
    </button>
    """
  end

  # ---------------------------------------------------------------------------
  # Private class helpers — all via pattern matching, never case/cond
  # ---------------------------------------------------------------------------

  defp base_class do
    "inline-flex items-center justify-center whitespace-nowrap rounded-md " <>
      "text-sm font-medium ring-offset-background transition-colors " <>
      "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring " <>
      "focus-visible:ring-offset-2"
  end

  defp variant_class(:default),
    do: "bg-primary text-primary-foreground shadow hover:bg-primary/90"

  defp variant_class(:destructive),
    do: "bg-destructive text-destructive-foreground shadow-sm hover:bg-destructive/90"

  defp variant_class(:outline),
    do: "border border-input bg-background shadow-sm hover:bg-accent hover:text-accent-foreground"

  defp variant_class(:secondary),
    do: "bg-secondary text-secondary-foreground shadow-sm hover:bg-secondary/80"

  defp variant_class(:ghost),
    do: "hover:bg-accent hover:text-accent-foreground"

  defp variant_class(:link),
    do: "text-primary underline-offset-4 hover:underline"

  defp size_class(:default), do: "h-10 px-4 py-2"
  defp size_class(:xs), do: "h-7 px-2 text-xs"
  defp size_class(:sm), do: "h-9 rounded-md px-3"
  defp size_class(:lg), do: "h-11 rounded-md px-8"
  defp size_class(:icon), do: "h-10 w-10"
  defp size_class(:icon_sm), do: "h-8 w-8"
  defp size_class(:icon_lg), do: "h-12 w-12"
end
