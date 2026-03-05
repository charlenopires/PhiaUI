defmodule PhiaUi.Components.Toolbar do
  @moduledoc """
  Toolbar component — a horizontal row of action buttons with separators and groups.

  Standalone toolbar for formatting, editing actions, or any grouped action bar.
  Zero JavaScript — all toggle state is managed by the LiveView. Composes well
  with buttons and separators.

  ## Variants

  | Variant      | Description                                      |
  |--------------|--------------------------------------------------|
  | `:default`   | Simple inline toolbar with border                |
  | `:floating`  | Elevated toolbar with shadow and rounded corners |

  ## Sizes

  | Size   | Button height |
  |--------|---------------|
  | `:sm`  | h-8  (32 px)  |
  | `:md`  | h-9  (36 px)  |
  | `:lg`  | h-10 (40 px)  |

  ## Examples

      <%!-- Basic formatting toolbar --%>
      <.toolbar>
        <:item aria_label="Bold" pressed={@bold} on_click="toggle_bold">B</:item>
        <:item aria_label="Italic" pressed={@italic} on_click="toggle_italic">I</:item>
        <:separator />
        <:item aria_label="Link" on_click="add_link">🔗</:item>
      </.toolbar>

      <%!-- Floating variant --%>
      <.toolbar variant={:floating}>
        <:item aria_label="Align left" on_click="align_left">←</:item>
        <:item aria_label="Align center" on_click="align_center">↔</:item>
      </.toolbar>
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  attr(:variant, :atom,
    values: [:default, :floating],
    default: :default,
    doc: "Visual style — :default (inline) or :floating (elevated, rounded)"
  )

  attr(:size, :atom,
    values: [:sm, :md, :lg],
    default: :md,
    doc: "Button height size"
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes merged via cn/1")

  attr(:rest, :global, doc: "HTML attributes forwarded to the root element")

  slot(:item,
    doc: "An action button in the toolbar",
    validate_attrs: false
  )

  slot(:separator, doc: "A visual divider between toolbar sections", validate_attrs: false)

  slot(:group,
    doc: "A logical group of toolbar items",
    validate_attrs: false
  )

  @doc """
  Renders a horizontal toolbar with action buttons, separators and groups.

  ## Examples

      <.toolbar>
        <:item aria_label="Bold" pressed={@bold} on_click="toggle_bold">B</:item>
        <:separator />
        <:item aria_label="Italic" on_click="toggle_italic">I</:item>
      </.toolbar>
  """
  def toolbar(assigns) do
    ~H"""
    <div
      role="toolbar"
      class={cn([
        "inline-flex items-center gap-1 p-1",
        "border border-border bg-background",
        @variant == :floating && "shadow-md rounded-lg",
        @class
      ])}
      {@rest}
    >
      <%= for item <- @item do %>
        <button
          type="button"
          phx-click={Map.get(item, :on_click)}
          aria-label={Map.get(item, :aria_label)}
          aria-pressed={to_string(Map.get(item, :pressed, false))}
          class={cn([
            "inline-flex items-center justify-center rounded-md px-2",
            "font-medium transition-colors",
            "hover:bg-accent hover:text-accent-foreground",
            "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring",
            Map.get(item, :pressed, false) && "bg-accent text-accent-foreground",
            item_size_class(@size)
          ])}
        >
          {render_slot(item)}
        </button>
      <% end %>

      <%= for _sep <- @separator do %>
        <div
          role="separator"
          aria-orientation="vertical"
          class="w-px self-stretch bg-border mx-0.5"
        />
      <% end %>

      <%= for group <- @group do %>
        <div class="inline-flex items-center gap-1">
          {render_slot(group)}
        </div>
      <% end %>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  defp item_size_class(:sm), do: "h-8 text-xs"
  defp item_size_class(:md), do: "h-9 text-sm"
  defp item_size_class(:lg), do: "h-10 text-base"
end
