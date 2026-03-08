defmodule PhiaUi.Components.Data.ChartCompose do
  @moduledoc false
  # Functional composition system for building charts.
  # Maps to Highcharts' compose() + pushUnique() — pipeline builder that
  # eliminates duplicated domain/scale/tick computation per chart.
  # Not registered in ComponentRegistry — internal only.

  alias PhiaUi.Components.Data.ChartCoord
  alias PhiaUi.Components.Data.ChartHelpers
  alias PhiaUi.Components.Data.ChartAxisHelpers
  alias PhiaUi.Components.Data.ChartSeriesRegistry
  alias PhiaUi.Components.Data.ChartTheme
  alias PhiaUi.Components.Data.ChartViewport

  @doc """
  Creates a new chart composition context.

  ## Options
  - `:viewport` — viewport keyword list (default: `[]`)
  - `:theme` — theme overrides map (default: `%{}`)
  """
  def new(opts \\ []) do
    vp_opts = Keyword.get(opts, :viewport, [])
    theme_overrides = Keyword.get(opts, :theme, %{})

    %{
      viewport: ChartViewport.build(vp_opts),
      theme: ChartTheme.merge(theme_overrides),
      coord: nil,
      series: [],
      features: MapSet.new(),
      elements: [],
      hooks: []
    }
  end

  @doc """
  Sets or overrides viewport configuration.
  """
  def with_viewport(ctx, opts) when is_list(opts) do
    %{ctx | viewport: ChartViewport.build(opts)}
  end

  @doc """
  Merges theme overrides into the context theme.
  """
  def with_theme(ctx, overrides) when is_map(overrides) do
    %{ctx | theme: deep_merge(ctx.theme, overrides)}
  end

  @doc """
  Sets the coordinate system. Accepts a pre-built coord map or options
  for auto-creation during `build/1`.

  Pass `:auto` to auto-compute from series (default during build).
  """
  def with_coord(ctx, :auto), do: %{ctx | coord: :auto}

  def with_coord(ctx, coord) when is_map(coord) do
    %{ctx | coord: coord}
  end

  @doc """
  Adds series to the context. Auto-domain will be computed during `build/1`.
  """
  def with_series(ctx, series_list) when is_list(series_list) do
    %{ctx | series: ctx.series ++ series_list}
  end

  @doc """
  Registers a feature idempotently. Features drive what elements are generated
  during `build/1`.

  Supported features: `:grid`, `:x_axis`, `:y_axis`, `:legend`, `:tooltip`, `:crosshair`
  """
  def with_feature(ctx, feature) when is_atom(feature) do
    %{ctx | features: MapSet.put(ctx.features, feature)}
  end

  @doc """
  Resolves all derived data: domains, ticks, scales, coordinate systems, and elements.

  Returns an enriched context with:
  - `:coord` — resolved coordinate system
  - `:categories` — extracted categories
  - `:y_ticks` — computed Y-axis ticks
  - `:y_range` — `{y_min, y_max}`
  - `:elements` — rendered visual elements from all series
  - `:legend_items` — legend item maps
  """
  def build(ctx) do
    vp = ctx.viewport
    series = ctx.series

    # Auto-create coordinate system if not explicitly set
    {coord, categories, y_ticks, y_range} =
      case ctx.coord do
        :auto ->
          ChartCoord.auto_cartesian(series, viewport: vp)

        nil ->
          ChartCoord.auto_cartesian(series, viewport: vp)

        coord when is_map(coord) ->
          cats = ChartHelpers.extract_categories(series)
          {ticks, y_min, y_max} = ChartHelpers.compute_y_domain(series)
          {coord, cats, ticks, {y_min, y_max}}
      end

    # Build visual elements for each series
    bar_series = Enum.filter(series, fn s -> Map.get(s, :type, :line) == :bar end)
    n_bar_series = length(bar_series)

    elements =
      series
      |> Enum.with_index()
      |> Enum.flat_map(fn {s, si} ->
        color = Map.get(s, :color) || ChartHelpers.chart_color(si, [])
        type = Map.get(s, :type, :line)
        bar_idx = if type == :bar, do: Enum.find_index(bar_series, &(&1.name == s.name)) || 0, else: 0

        if ChartSeriesRegistry.supported?(type) do
          ChartSeriesRegistry.render(type, s.data, coord, [
            color: color,
            series_index: si,
            bar_index: bar_idx,
            n_bar_series: n_bar_series
          ])
        else
          []
        end
      end)

    # Y-axis tick entries
    y_tick_entries =
      Enum.map(y_ticks, fn tick ->
        py = coord.y_scale.(tick)
        %{py: Float.round(py * 1.0, 2), label: ChartAxisHelpers.format_tick(tick * 1.0)}
      end)

    # X-axis label entries
    x_label_entries =
      Enum.map(categories, fn cat ->
        px = coord.x_scale.(cat)
        %{label: to_string(cat), px: Float.round(px * 1.0, 2)}
      end)

    # Legend items
    legend_items =
      series
      |> Enum.with_index()
      |> Enum.map(fn {s, si} ->
        color = Map.get(s, :color) || ChartHelpers.chart_color(si, [])
        type = Map.get(s, :type, :line)
        shape = case type do
          :bar -> :square
          :scatter -> :circle
          _ -> :line
        end
        %{label: s.name, color: color, shape: shape}
      end)

    ctx
    |> Map.put(:coord, coord)
    |> Map.put(:categories, categories)
    |> Map.put(:y_ticks, y_ticks)
    |> Map.put(:y_range, y_range)
    |> Map.put(:elements, elements)
    |> Map.put(:y_tick_entries, y_tick_entries)
    |> Map.put(:x_label_entries, x_label_entries)
    |> Map.put(:legend_items, legend_items)
  end

  # ---------------------------------------------------------------------------
  # Private
  # ---------------------------------------------------------------------------

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
