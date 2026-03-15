defmodule PhiaUiDesign.Canvas.Layout do
  @moduledoc """
  Converts node layout properties to Tailwind CSS v4 classes.

  Layout properties on frame nodes (`:layout`, `:gap`, `:padding`, etc.)
  are translated to their Tailwind equivalents. Non-standard values use
  arbitrary value syntax (e.g., `gap-[13px]`).
  """

  @tailwind_spacing %{
    0 => "0",
    1 => "px",
    2 => "0.5",
    4 => "1",
    6 => "1.5",
    8 => "2",
    10 => "2.5",
    12 => "3",
    14 => "3.5",
    16 => "4",
    20 => "5",
    24 => "6",
    28 => "7",
    32 => "8",
    36 => "9",
    40 => "10",
    44 => "11",
    48 => "12",
    56 => "14",
    64 => "16",
    80 => "20",
    96 => "24",
    112 => "28",
    128 => "32",
    144 => "36",
    160 => "40",
    176 => "44",
    192 => "48",
    208 => "52",
    224 => "56",
    240 => "60",
    256 => "64",
    288 => "72",
    320 => "80",
    384 => "96"
  }

  @doc """
  Convert a node's layout properties to a Tailwind class string.

  Accepts a `Node` struct or a map with layout keys.
  Returns an empty string if no layout properties are set.

  ## Examples

      iex> Layout.to_classes(%{layout: :vertical, gap: 16})
      "flex flex-col gap-4"

      iex> Layout.to_classes(%{layout: :horizontal, padding: [8, 16, 8, 16]})
      "flex flex-row pt-2 pr-4 pb-2 pl-4"

      iex> Layout.to_classes(%{width: :fill, height: :hug})
      "w-full h-fit"
  """
  @spec to_classes(map()) :: String.t()
  def to_classes(node) do
    [
      layout_class(node),
      gap_class(node),
      padding_classes(node),
      justify_class(node),
      align_class(node),
      wrap_class(node),
      width_class(node),
      height_class(node)
    ]
    |> List.flatten()
    |> Enum.reject(&is_nil/1)
    |> Enum.reject(&(&1 == ""))
    |> Enum.join(" ")
  end

  @doc """
  Check if a node has any layout properties set.
  """
  @spec has_layout?(map()) :: boolean()
  def has_layout?(node) do
    layout_fields()
    |> Enum.any?(fn field -> Map.get(node, field) not in [nil, false] end)
  end

  @doc "List of layout field names"
  @spec layout_fields() :: [atom()]
  def layout_fields do
    [:layout, :gap, :padding, :justify_content, :align_items, :wrap, :width, :height]
  end

  # ---------------------------------------------------------------------------
  # Layout direction
  # ---------------------------------------------------------------------------

  defp layout_class(%{layout: :vertical}), do: "flex flex-col"
  defp layout_class(%{layout: :horizontal}), do: "flex flex-row"
  defp layout_class(_), do: nil

  # ---------------------------------------------------------------------------
  # Gap
  # ---------------------------------------------------------------------------

  defp gap_class(%{gap: nil}), do: nil
  defp gap_class(%{gap: "$" <> _}), do: nil
  defp gap_class(%{gap: px}) when is_integer(px), do: spacing_class("gap", px)
  defp gap_class(_), do: nil

  # ---------------------------------------------------------------------------
  # Padding
  # ---------------------------------------------------------------------------

  defp padding_classes(%{padding: nil}), do: nil
  defp padding_classes(%{padding: "$" <> _}), do: nil

  defp padding_classes(%{padding: px}) when is_integer(px) do
    spacing_class("p", px)
  end

  defp padding_classes(%{padding: [t, r, b, l]})
       when is_integer(t) and is_integer(r) and is_integer(b) and is_integer(l) do
    if t == r and r == b and b == l do
      spacing_class("p", t)
    else
      [
        spacing_class("pt", t),
        spacing_class("pr", r),
        spacing_class("pb", b),
        spacing_class("pl", l)
      ]
    end
  end

  defp padding_classes(_), do: nil

  # ---------------------------------------------------------------------------
  # Justify content
  # ---------------------------------------------------------------------------

  defp justify_class(%{justify_content: :start}), do: "justify-start"
  defp justify_class(%{justify_content: :center}), do: "justify-center"
  defp justify_class(%{justify_content: :end}), do: "justify-end"
  defp justify_class(%{justify_content: :between}), do: "justify-between"
  defp justify_class(%{justify_content: :around}), do: "justify-around"
  defp justify_class(_), do: nil

  # ---------------------------------------------------------------------------
  # Align items
  # ---------------------------------------------------------------------------

  defp align_class(%{align_items: :start}), do: "items-start"
  defp align_class(%{align_items: :center}), do: "items-center"
  defp align_class(%{align_items: :end}), do: "items-end"
  defp align_class(%{align_items: :stretch}), do: "items-stretch"
  defp align_class(_), do: nil

  # ---------------------------------------------------------------------------
  # Wrap
  # ---------------------------------------------------------------------------

  defp wrap_class(%{wrap: true}), do: "flex-wrap"
  defp wrap_class(_), do: nil

  # ---------------------------------------------------------------------------
  # Width
  # ---------------------------------------------------------------------------

  defp width_class(%{width: :fill}), do: "w-full"
  defp width_class(%{width: :hug}), do: "w-fit"

  defp width_class(%{width: px}) when is_integer(px) do
    "w-[#{px}px]"
  end

  defp width_class(%{width: pct}) when is_binary(pct) do
    if String.ends_with?(pct, "%"), do: "w-[#{pct}]", else: nil
  end

  defp width_class(_), do: nil

  # ---------------------------------------------------------------------------
  # Height
  # ---------------------------------------------------------------------------

  defp height_class(%{height: :fill}), do: "h-full"
  defp height_class(%{height: :hug}), do: "h-fit"

  defp height_class(%{height: px}) when is_integer(px) do
    "h-[#{px}px]"
  end

  defp height_class(_), do: nil

  # ---------------------------------------------------------------------------
  # Spacing helper
  # ---------------------------------------------------------------------------

  defp spacing_class(prefix, px) when is_integer(px) do
    case Map.get(@tailwind_spacing, px) do
      nil -> "#{prefix}-[#{px}px]"
      tw -> "#{prefix}-#{tw}"
    end
  end
end
