defmodule PhiaUi.Components.Tag do
  @moduledoc """
  Removable tag component with dot indicator and close button.

  Tags are compact labels with a `rounded-md` shape. They differ from chips
  (which are `rounded-full` and toggleable) by being simpler, non-toggleable
  labels that can optionally be dismissed.

  ## Variants

  | Variant     | Visual                                      |
  |-------------|---------------------------------------------|
  | `:default`  | Muted background, subtle border             |
  | `:primary`  | Primary color background                    |
  | `:success`  | Green/success background                    |
  | `:warning`  | Yellow/warning background                   |
  | `:error`    | Red/destructive background                  |
  | `:outline`  | Border only, transparent background         |

  ## Examples

      <.tag label="Elixir" />
      <.tag label="Important" variant={:error} dot />
      <.tag label="Feature" variant={:primary} dismissible on_dismiss="remove_tag" value="feature" />
      <.tag label="Custom" variant={:success} size={:lg}>
        <:icon><svg>...</svg></:icon>
      </.tag>
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  attr :label, :string, required: true, doc: "Tag text content"

  attr :variant, :atom,
    values: [:default, :primary, :success, :warning, :error, :outline],
    default: :default,
    doc: "Visual style variant. Controls background, text colour, and border."

  attr :size, :atom,
    values: [:sm, :default, :lg],
    default: :default,
    doc: "Size of the tag. Controls height, padding, and font size."

  attr :dismissible, :boolean, default: false, doc: "Show close button"
  attr :on_dismiss, :string, default: nil, doc: "Phoenix event name for dismiss"
  attr :value, :string, default: nil, doc: "Value sent with dismiss event"
  attr :dot, :boolean, default: false, doc: "Show colored dot indicator"

  attr :class, :string,
    default: nil,
    doc: "Additional CSS classes merged via `cn/1`."

  attr :rest, :global,
    doc: "HTML attributes forwarded to the root `<span>` element."

  slot :icon, doc: "Optional leading icon"

  @doc """
  Renders an inline `<span>` styled as a removable tag.

  Tags support a dot indicator, an optional leading icon slot, and a
  dismissible close button that fires a Phoenix event.

  ## Example

      <.tag label="Elixir" variant={:primary} dot />
      <.tag label="Draft" variant={:outline} dismissible on_dismiss="remove_tag" value="draft" />
  """
  def tag(assigns) do
    ~H"""
    <span
      class={cn([
        base_class(),
        size_class(@size),
        variant_class(@variant),
        @class
      ])}
      {@rest}
    >
      <%= if @dot do %>
        <span class={cn(["shrink-0 rounded-full", dot_size(@size), dot_color(@variant)])} />
      <% end %>

      <%= for icon <- @icon do %>
        <span class={cn(["shrink-0", icon_size(@size)])}>
          {render_slot(icon)}
        </span>
      <% end %>

      <span class="truncate">{@label}</span>

      <%= if @dismissible do %>
        <button
          type="button"
          phx-click={@on_dismiss}
          phx-value-value={@value}
          aria-label={"Remove #{@label}"}
          class={cn([
            "shrink-0 rounded-sm transition-colors",
            "hover:bg-foreground/10 focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring",
            dismiss_size(@size)
          ])}
        >
          <svg
            class={dismiss_icon_size(@size)}
            xmlns="http://www.w3.org/2000/svg"
            viewBox="0 0 24 24"
            fill="none"
            stroke="currentColor"
            stroke-width="2"
            stroke-linecap="round"
            stroke-linejoin="round"
            aria-hidden="true"
          >
            <path d="M18 6 6 18" /><path d="m6 6 12 12" />
          </svg>
        </button>
      <% end %>
    </span>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  defp base_class do
    "inline-flex items-center gap-1.5 rounded-md border font-medium transition-colors"
  end

  defp size_class(:sm), do: "h-6 px-2 text-xs"
  defp size_class(:default), do: "h-7 px-2.5 text-xs"
  defp size_class(:lg), do: "h-8 px-3 text-sm"

  defp variant_class(:default), do: "border-border bg-muted text-muted-foreground"
  defp variant_class(:primary), do: "border-primary/20 bg-primary/10 text-primary"

  defp variant_class(:success),
    do:
      "border-green-200 bg-green-50 text-green-700 dark:border-green-800 dark:bg-green-950 dark:text-green-400"

  defp variant_class(:warning),
    do:
      "border-yellow-200 bg-yellow-50 text-yellow-700 dark:border-yellow-800 dark:bg-yellow-950 dark:text-yellow-400"

  defp variant_class(:error),
    do:
      "border-red-200 bg-red-50 text-red-700 dark:border-red-800 dark:bg-red-950 dark:text-red-400"

  defp variant_class(:outline), do: "border-border bg-transparent text-foreground"

  defp dot_size(:sm), do: "h-1.5 w-1.5"
  defp dot_size(:default), do: "h-2 w-2"
  defp dot_size(:lg), do: "h-2 w-2"

  defp dot_color(:default), do: "bg-muted-foreground"
  defp dot_color(:primary), do: "bg-primary"
  defp dot_color(:success), do: "bg-green-500"
  defp dot_color(:warning), do: "bg-yellow-500"
  defp dot_color(:error), do: "bg-red-500"
  defp dot_color(:outline), do: "bg-foreground"

  defp icon_size(:sm), do: "[&>svg]:h-3 [&>svg]:w-3"
  defp icon_size(:default), do: "[&>svg]:h-3.5 [&>svg]:w-3.5"
  defp icon_size(:lg), do: "[&>svg]:h-4 [&>svg]:w-4"

  defp dismiss_size(:sm), do: "h-4 w-4"
  defp dismiss_size(:default), do: "h-4 w-4"
  defp dismiss_size(:lg), do: "h-5 w-5"

  defp dismiss_icon_size(:sm), do: "h-3 w-3"
  defp dismiss_icon_size(:default), do: "h-3 w-3"
  defp dismiss_icon_size(:lg), do: "h-3.5 w-3.5"
end
