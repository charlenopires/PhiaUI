defmodule PhiaUi.Components.Chip do
  @moduledoc """
  Interactive Chip component for tags, filters, and multi-select interfaces.

  Chips are compact elements that represent an input, attribute, or action.
  They can be toggleable (with `on_click`), dismissible (with `dismissible`),
  or purely presentational when neither is set.

  ## Variants

  | Variant     | Use case                                       |
  |-------------|------------------------------------------------|
  | `:default`  | Secondary background, neutral tag              |
  | `:outline`  | Bordered, transparent background               |
  | `:filled`   | Primary background, high-emphasis tag          |

  ## Sizes

  | Size       | Classes                  |
  |------------|--------------------------|
  | `:sm`      | text-xs px-2 py-0.5      |
  | `:default` | text-sm px-3 py-1        |
  | `:lg`      | text-base px-4 py-1.5    |

  ## Examples

      <%!-- Basic chip --%>
      <.chip>React</.chip>

      <%!-- Dismissible chip --%>
      <.chip dismissible={true} on_dismiss="remove_tag" value="elixir">
        Elixir
      </.chip>

      <%!-- Toggleable chip --%>
      <.chip selected={true} on_click="toggle" value="vue">Vue</.chip>

      <%!-- Chip group --%>
      <.chip_group>
        <.chip :for={tech <- @techs} value={tech}>{tech}</.chip>
      </.chip_group>
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  attr(:value, :string, default: nil, doc: "Value sent with phx-value-value for click/dismiss events")

  attr(:variant, :atom,
    values: [:default, :outline, :filled],
    default: :default,
    doc: "Visual style variant"
  )

  attr(:size, :atom,
    values: [:sm, :default, :lg],
    default: :default,
    doc: "Size variant"
  )

  attr(:selected, :boolean, default: false, doc: "Whether the chip is in a selected/active state")

  attr(:dismissible, :boolean, default: false, doc: "Whether to render a dismiss (×) button")

  attr(:on_click, :string, default: nil, doc: "Event name for toggle click; renders chip as <button> when set")

  attr(:on_dismiss, :string, default: nil, doc: "Event name for the dismiss button click")

  attr(:disabled, :boolean, default: false, doc: "Disables the chip and adds pointer-events-none opacity-50")

  attr(:class, :string, default: nil, doc: "Additional CSS classes merged via cn/1")

  attr(:rest, :global, doc: "HTML attributes forwarded to the root element")

  slot(:inner_block, required: true, doc: "Chip label content")

  @doc """
  Renders a chip element.

  When `on_click` is provided, the chip renders as a `<button>` with
  `aria-pressed` reflecting the `selected` state. Otherwise it renders
  as a `<span>`.

  When `dismissible={true}`, a small × button is appended inside the chip.
  Use `on_dismiss` to handle the dismiss event and `value` to identify
  which chip was dismissed.

  ## Examples

      <%!-- Presentational chip --%>
      <.chip>Tag</.chip>

      <%!-- Toggle chip --%>
      <.chip on_click="toggle_filter" value="active" selected={@active}>
        Active
      </.chip>

      <%!-- Dismissible chip with value --%>
      <.chip dismissible={true} on_dismiss="remove_skill" value="elixir">
        Elixir
      </.chip>
  """
  def chip(%{on_click: on_click} = assigns) when not is_nil(on_click) do
    ~H"""
    <button
      type="button"
      phx-click={@on_click}
      phx-value-value={@value}
      aria-pressed={to_string(@selected)}
      disabled={@disabled}
      class={cn([
        base_class(),
        variant_class(@variant),
        size_class(@size),
        @selected && "ring-2 ring-ring ring-offset-1",
        @disabled && "pointer-events-none opacity-50",
        @class
      ])}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
      <%= if @dismissible do %>
        <button
          type="button"
          phx-click={@on_dismiss}
          phx-value-value={@value}
          aria-label="Remove"
          class="ml-1 rounded-full hover:bg-black/20 h-4 w-4 inline-flex items-center justify-center"
        >
          <svg
            xmlns="http://www.w3.org/2000/svg"
            class="h-3 w-3"
            viewBox="0 0 24 24"
            fill="none"
            stroke="currentColor"
            stroke-width="2"
          >
            <line x1="18" y1="6" x2="6" y2="18" /><line x1="6" y1="6" x2="18" y2="18" />
          </svg>
        </button>
      <% end %>
    </button>
    """
  end

  def chip(assigns) do
    ~H"""
    <span
      class={cn([
        base_class(),
        variant_class(@variant),
        size_class(@size),
        @selected && "ring-2 ring-ring ring-offset-1",
        @disabled && "pointer-events-none opacity-50",
        @class
      ])}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
      <%= if @dismissible do %>
        <button
          type="button"
          phx-click={@on_dismiss}
          phx-value-value={@value}
          aria-label="Remove"
          class="ml-1 rounded-full hover:bg-black/20 h-4 w-4 inline-flex items-center justify-center"
        >
          <svg
            xmlns="http://www.w3.org/2000/svg"
            class="h-3 w-3"
            viewBox="0 0 24 24"
            fill="none"
            stroke="currentColor"
            stroke-width="2"
          >
            <line x1="18" y1="6" x2="6" y2="18" /><line x1="6" y1="6" x2="18" y2="18" />
          </svg>
        </button>
      <% end %>
    </span>
    """
  end

  attr(:class, :string, default: nil, doc: "Additional CSS classes merged via cn/1")
  slot(:inner_block, required: true, doc: "Chip items")

  @doc """
  Renders a wrapping container for a group of chips.

  Provides flex layout with wrapping and consistent gap between chips.

  ## Example

      <.chip_group>
        <.chip :for={tag <- @tags} value={tag} on_dismiss="remove_tag" dismissible={true}>
          {tag}
        </.chip>
      </.chip_group>
  """
  def chip_group(assigns) do
    ~H"""
    <div class={cn(["flex flex-wrap gap-2", @class])}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Private class helpers — pattern matching only, no case/cond
  # ---------------------------------------------------------------------------

  defp base_class do
    "inline-flex items-center gap-1.5 rounded-full font-medium transition-colors " <>
      "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring"
  end

  defp variant_class(:default), do: "bg-secondary text-secondary-foreground hover:bg-secondary/80"
  defp variant_class(:outline), do: "border border-border text-foreground hover:bg-accent"
  defp variant_class(:filled), do: "bg-primary text-primary-foreground hover:bg-primary/90"

  defp size_class(:sm), do: "text-xs px-2 py-0.5"
  defp size_class(:default), do: "text-sm px-3 py-1"
  defp size_class(:lg), do: "text-base px-4 py-1.5"
end
