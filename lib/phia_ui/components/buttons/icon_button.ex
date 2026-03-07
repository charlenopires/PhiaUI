defmodule PhiaUi.Components.IconButton do
  @moduledoc """
  Icon-only button with a required accessible label and an optional CSS tooltip.

  Enforces `label` as a required attribute to ensure every icon-only button
  is accessible by default. The same string is used as `aria-label` on the
  button and as tooltip text shown on hover.

  ## Variants

  | Variant       | Use case                          |
  |---------------|-----------------------------------|
  | `:ghost`      | Default — toolbar / icon actions  |
  | `:default`    | Filled primary icon button        |
  | `:destructive`| Dangerous icon action             |
  | `:outline`    | Bordered icon button              |
  | `:secondary`  | Lower-emphasis icon button        |

  ## Sizes

  | Size       | Dimensions |
  |------------|------------|
  | `:xs`      | h-6 w-6    |
  | `:sm`      | h-8 w-8    |
  | `:default` | h-9 w-9    |
  | `:lg`      | h-11 w-11  |

  ## Example

      <.icon_button icon="trash-2" label="Delete" phx-click="delete" />

      <.icon_button icon="settings" label="Settings" variant={:outline} size={:lg} />

      <.icon_button icon="plus" label="Add item" shape={:circle} />

      <.icon_button icon="x" label="Close" tooltip={false} />
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]
  import PhiaUi.Components.Icon, only: [icon: 1]

  attr :icon, :string,
    required: true,
    doc: "Lucide icon name to render inside the button"

  attr :label, :string,
    required: true,
    doc: "Accessible label — used as aria-label and, when tooltip=true, as tooltip text"

  attr :variant, :atom,
    values: [:default, :destructive, :outline, :secondary, :ghost],
    default: :ghost,
    doc: "Visual style variant"

  attr :size, :atom,
    values: [:xs, :sm, :default, :lg],
    default: :default,
    doc: "Button and icon size"

  attr :shape, :atom,
    values: [:square, :circle],
    default: :square,
    doc: "Corner radius — :square uses rounded-md, :circle uses rounded-full"

  attr :tooltip, :boolean,
    default: true,
    doc: "Show a CSS-only tooltip on hover (uses group-hover, no JS hook required)"

  attr :disabled, :boolean, default: false
  attr :loading, :boolean, default: false
  attr :class, :string, default: nil
  attr :rest, :global

  @doc """
  Renders an icon-only button with an accessible label.

  When `tooltip={true}` (the default), a CSS tooltip is shown above the button
  on hover using `group-hover:opacity-100`. No JS hook is required.

  When `loading={true}`, an animated spinner replaces the icon and
  `aria-busy="true"` is set on the button.
  """
  def icon_button(assigns) do
    ~H"""
    <div class="relative group inline-flex">
      <button
        type="button"
        aria-label={@label}
        class={cn([
          "inline-flex items-center justify-center",
          "ring-offset-background transition-colors",
          "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2",
          variant_class(@variant),
          size_class(@size),
          shape_class(@shape),
          (@disabled or @loading) && "pointer-events-none opacity-50",
          @class
        ])}
        disabled={@disabled}
        aria-busy={@loading && "true"}
        {@rest}
      >
        <%= if @loading do %>
          <svg
            class={"animate-spin #{icon_size_class(@size)}"}
            xmlns="http://www.w3.org/2000/svg"
            fill="none"
            viewBox="0 0 24 24"
            aria-hidden="true"
          >
            <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4" />
            <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z" />
          </svg>
        <% else %>
          <.icon name={@icon} class={icon_size_class(@size)} />
        <% end %>
      </button>

      <%= if @tooltip do %>
        <span
          role="tooltip"
          class={cn([
            "pointer-events-none absolute -top-8 left-1/2 -translate-x-1/2",
            "whitespace-nowrap rounded bg-foreground px-2 py-1 text-xs text-background",
            "opacity-0 transition-opacity group-hover:opacity-100"
          ])}
        >
          {@label}
        </span>
      <% end %>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  defp variant_class(:default),
    do: "bg-primary text-primary-foreground hover:bg-primary/90"

  defp variant_class(:destructive),
    do: "bg-destructive text-destructive-foreground hover:bg-destructive/90"

  defp variant_class(:outline),
    do: "border border-input bg-background hover:bg-accent hover:text-accent-foreground"

  defp variant_class(:secondary),
    do: "bg-secondary text-secondary-foreground hover:bg-secondary/80"

  defp variant_class(:ghost),
    do: "hover:bg-accent hover:text-accent-foreground"

  defp size_class(:xs), do: "h-6 w-6"
  defp size_class(:sm), do: "h-8 w-8"
  defp size_class(:default), do: "h-9 w-9"
  defp size_class(:lg), do: "h-11 w-11"

  defp shape_class(:square), do: "rounded-md"
  defp shape_class(:circle), do: "rounded-full"

  defp icon_size_class(:xs), do: "h-3 w-3"
  defp icon_size_class(:sm), do: "h-4 w-4"
  defp icon_size_class(:default), do: "h-4 w-4"
  defp icon_size_class(:lg), do: "h-5 w-5"
end
