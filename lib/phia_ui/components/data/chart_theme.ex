defmodule PhiaUi.Components.Data.ChartTheme do
  @moduledoc false
  # Default chart theme and deep-merge utility.
  # Inspired by Nivo's ThemeProvider — provides a centralized default
  # for font sizes, CSS classes, and stroke widths used across chart components.
  # Not registered in ComponentRegistry — internal only.

  @doc """
  Returns the default chart theme map.

  Keys:
  - `:axis` — font size, label class, tick size for axis rendering
  - `:grid` — stroke width, stroke class, dash array for grid lines
  - `:legend` — font size, label class for legend items
  - `:tooltip` — bg/text/border classes for tooltip styling
  - `:point_label` — font size, class, offset for point labels
  """
  def default do
    %{
      axis: %{
        font_size: "9",
        label_class: "fill-muted-foreground",
        tick_size: 6
      },
      grid: %{
        stroke_width: "0.5",
        stroke_class: "text-border",
        dash_array: nil
      },
      legend: %{
        font_size: "9",
        label_class: "fill-foreground"
      },
      tooltip: %{
        bg_class: "bg-popover",
        text_class: "text-popover-foreground",
        border_class: "border"
      },
      point_label: %{
        font_size: "8",
        label_class: "fill-muted-foreground",
        offset: 8
      }
    }
  end

  @doc """
  Deep-merges custom overrides onto the default theme.

  Only merges maps recursively — scalar values are replaced.
  Returns the merged theme map. Passing an empty map or nil returns the default.

  ## Examples

      iex> ChartTheme.merge(%{axis: %{font_size: "12"}})
      %{axis: %{font_size: "12", label_class: "fill-muted-foreground", tick_size: 6}, ...}
  """
  def merge(nil), do: default()
  def merge(overrides) when overrides == %{}, do: default()

  def merge(overrides) when is_map(overrides) do
    deep_merge(default(), overrides)
  end

  # Deep merge two maps — if both values are maps, recurse; otherwise replace.
  defp deep_merge(base, override) when is_map(base) and is_map(override) do
    Map.merge(base, override, fn
      _key, base_val, override_val when is_map(base_val) and is_map(override_val) ->
        deep_merge(base_val, override_val)

      _key, _base_val, override_val ->
        override_val
    end)
  end

  defp deep_merge(_base, override), do: override
end
