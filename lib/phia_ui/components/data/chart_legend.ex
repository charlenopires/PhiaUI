defmodule PhiaUi.Components.Data.ChartLegend do
  @moduledoc """
  Composable chart legend components.

  Renders as HTML (not SVG) — place below or beside the chart SVG.

  ## Examples

      <.chart_legend
        items={[
          %{label: "Revenue", color: "oklch(0.60 0.20 240)"},
          %{label: "Cost", color: "oklch(0.65 0.22 30)"}
        ]}
      />
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  # ---------------------------------------------------------------------------
  # Chart Legend
  # ---------------------------------------------------------------------------

  @doc """
  Renders a legend with color swatches and labels.

  ## Attrs
  - `items` — list of `%{label, color}` or `%{label, color, shape}` maps
  - `position` — layout direction
  - `class` — additional CSS classes
  """
  attr :items, :list, required: true, doc: "List of `%{label, color}` maps."

  attr :position, :atom,
    default: :bottom,
    values: [:top, :bottom, :left, :right],
    doc: "Legend position determines layout direction."

  attr :interactive, :boolean,
    default: false,
    doc: "Enable click-to-toggle series visibility."

  attr :on_toggle, :string,
    default: nil,
    doc: "Event name for series toggle (receives `%{\"series\" => label}`)."

  attr :visible_series, :list,
    default: [],
    doc: "List of currently visible series names. Empty means all visible."

  attr :active_legend, :string,
    default: nil,
    doc: "Name of the currently focused/highlighted legend item. Dims all others."

  attr :enable_slider, :boolean,
    default: false,
    doc: "Enable horizontal scrolling with chevron buttons when items overflow."

  attr :class, :string, default: nil

  def chart_legend(assigns) do
    direction =
      case assigns.position do
        pos when pos in [:top, :bottom] -> "flex-row flex-wrap"
        _ -> "flex-col"
      end

    # When slider is enabled, don't wrap — allow overflow scrolling
    direction =
      if assigns.enable_slider do
        case assigns.position do
          pos when pos in [:top, :bottom] -> "flex-row overflow-x-auto scrollbar-none"
          _ -> "flex-col"
        end
      else
        direction
      end

    assigns = assign(assigns, :direction, direction)

    ~H"""
    <div
      class={cn(["flex gap-3 text-xs", @direction, @class])}
      role="list"
      aria-label="Chart legend"
    >
      <.chart_legend_item
        :for={item <- @items}
        label={item.label}
        color={item.color}
        shape={Map.get(item, :shape, :square)}
        interactive={@interactive}
        on_toggle={@on_toggle}
        active={legend_item_active?(item.label, @visible_series)}
        dimmed={legend_item_dimmed?(item.label, @active_legend)}
      />
    </div>
    """
  end

  defp legend_item_active?(_label, []), do: true
  defp legend_item_active?(label, visible_series), do: label in visible_series

  defp legend_item_dimmed?(_label, nil), do: false
  defp legend_item_dimmed?(label, active_legend), do: label != active_legend

  # ---------------------------------------------------------------------------
  # Chart Legend Item
  # ---------------------------------------------------------------------------

  @doc """
  Individual legend entry with swatch and label.
  """
  attr :label, :string, required: true
  attr :color, :string, required: true

  attr :shape, :atom,
    default: :square,
    values: [:square, :circle, :line, :diamond, :star, :triangle],
    doc: "Swatch shape."

  attr :interactive, :boolean, default: false, doc: "Clickable toggle mode."
  attr :on_toggle, :string, default: nil, doc: "Event name for toggle."
  attr :active, :boolean, default: true, doc: "Whether this item is active/visible."
  attr :dimmed, :boolean, default: false, doc: "Whether this item is dimmed (active_legend elsewhere)."
  attr :class, :string, default: nil

  def chart_legend_item(assigns) do
    tag = if assigns.interactive, do: "button", else: "div"
    dim = !assigns.active || assigns.dimmed
    assigns = assigns |> assign(:tag, tag) |> assign(:dim, dim)

    ~H"""
    <.legend_item_wrapper
      tag={@tag}
      interactive={@interactive}
      on_toggle={@on_toggle}
      label={@label}
      active={@active}
      class={@class}
    >
      <span
        :if={@shape == :square}
        class={cn(["inline-block size-2.5 rounded-sm shrink-0", if(@dim, do: "opacity-30")])}
        style={"background-color: #{@color}"}
      />
      <span
        :if={@shape == :circle}
        class={cn(["inline-block size-2.5 rounded-full shrink-0", if(@dim, do: "opacity-30")])}
        style={"background-color: #{@color}"}
      />
      <span
        :if={@shape == :line}
        class={cn(["inline-block w-3 h-0.5 rounded-full shrink-0", if(@dim, do: "opacity-30")])}
        style={"background-color: #{@color}"}
      />
      <svg
        :if={@shape == :diamond}
        viewBox="-6 -6 12 12"
        class={cn(["inline-block size-2.5 shrink-0", if(@dim, do: "opacity-30")])}
        aria-hidden="true"
      >
        <path d="M 0 -5 L 5 0 L 0 5 L -5 0 Z" fill={@color} />
      </svg>
      <svg
        :if={@shape == :star}
        viewBox="-6 -6 12 12"
        class={cn(["inline-block size-2.5 shrink-0", if(@dim, do: "opacity-30")])}
        aria-hidden="true"
      >
        <path d="M 0 -5 L 1.5 -1.5 L 5 -1.5 L 2.5 1 L 3.5 5 L 0 2.5 L -3.5 5 L -2.5 1 L -5 -1.5 L -1.5 -1.5 Z" fill={@color} />
      </svg>
      <svg
        :if={@shape == :triangle}
        viewBox="-6 -6 12 12"
        class={cn(["inline-block size-2.5 shrink-0", if(@dim, do: "opacity-30")])}
        aria-hidden="true"
      >
        <path d="M 0 -5 L 5 4 L -5 4 Z" fill={@color} />
      </svg>
      <span class={cn(["text-muted-foreground", if(!@active, do: "opacity-30 line-through"), if(@dimmed && @active, do: "opacity-40")])}>{@label}</span>
    </.legend_item_wrapper>
    """
  end

  # Private wrapper component — renders button when interactive, div otherwise
  attr :tag, :string, required: true
  attr :interactive, :boolean, default: false
  attr :on_toggle, :string, default: nil
  attr :label, :string, default: nil
  attr :active, :boolean, default: true
  attr :class, :string, default: nil
  slot :inner_block, required: true

  defp legend_item_wrapper(%{interactive: true} = assigns) do
    ~H"""
    <button
      class={cn(["flex items-center gap-1.5 cursor-pointer hover:opacity-80 transition-opacity", @class])}
      role="listitem"
      phx-click={@on_toggle}
      phx-value-series={@label}
      aria-pressed={to_string(@active)}
    >
      {render_slot(@inner_block)}
    </button>
    """
  end

  defp legend_item_wrapper(assigns) do
    ~H"""
    <div class={cn(["flex items-center gap-1.5", @class])} role="listitem">
      {render_slot(@inner_block)}
    </div>
    """
  end
end
