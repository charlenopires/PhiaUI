defmodule PhiaUi.Components.Data.ChartScales do
  @moduledoc false
  # Scale functions for mapping data domains to pixel ranges.
  # Inspired by visx/d3 scales. Returns closures for composition.
  # Not registered in ComponentRegistry — internal only.

  alias PhiaUi.Components.Data.ChartAxisHelpers

  # ---------------------------------------------------------------------------
  # Linear Scale
  # ---------------------------------------------------------------------------

  @doc """
  Creates a linear scale mapping values from `[domain_min, domain_max]` to
  `[range_min, range_max]` pixels.

  Returns `fn(value) -> pixel_position`.

  ## Examples

      scale = linear_scale(0, 100, 0, 400)
      scale.(50) #=> 200.0
  """
  def linear_scale(domain_min, domain_max, range_min, range_max) do
    d_range = domain_max - domain_min
    p_range = range_max - range_min

    fn value ->
      if d_range == 0 do
        (range_min + range_max) / 2
      else
        range_min + (value - domain_min) / d_range * p_range
      end
    end
  end

  # ---------------------------------------------------------------------------
  # Band Scale
  # ---------------------------------------------------------------------------

  @doc """
  Creates a band scale for categorical data.

  Maps a list of categories to evenly-spaced bands in `[range_min, range_max]`.

  Options:
  - `:padding` — outer padding ratio (0.0–1.0, default 0.1)
  - `:inner_padding` — gap between bands ratio (0.0–1.0, default 0.1)

  Returns `%{positions: %{category => center_x}, bandwidth: float, scale: fn}`.

  ## Examples

      result = band_scale(["A", "B", "C"], 0, 300)
      result.positions["B"] #=> center pixel of band B
      result.bandwidth       #=> width of each band
  """
  def band_scale(categories, range_min, range_max, opts \\ []) do
    n = length(categories)
    padding = Keyword.get(opts, :padding, 0.1)
    inner_padding = Keyword.get(opts, :inner_padding, 0.1)
    total = range_max - range_min

    if n == 0 do
      %{positions: %{}, bandwidth: 0.0, scale: fn _v -> (range_min + range_max) / 2 end}
    else
      outer = total * padding
      usable = total - 2 * outer
      gaps = max(n - 1, 0)
      gap_total = usable * inner_padding * gaps / max(gaps + n, 1)
      band_w = (usable - gap_total) / n
      step = if n > 1, do: (usable - band_w) / (n - 1), else: 0.0

      positions =
        categories
        |> Enum.with_index()
        |> Enum.map(fn {cat, i} ->
          center = range_min + outer + i * step + band_w / 2
          {cat, center}
        end)
        |> Map.new()

      scale_fn = fn cat -> Map.get(positions, cat, (range_min + range_max) / 2) end

      %{positions: positions, bandwidth: band_w, scale: scale_fn}
    end
  end

  # ---------------------------------------------------------------------------
  # Log Scale
  # ---------------------------------------------------------------------------

  @doc """
  Creates a logarithmic scale mapping values from `[domain_min, domain_max]`
  to `[range_min, range_max]` pixels.

  `domain_min` must be > 0. `base` defaults to 10.

  Returns `fn(value) -> pixel_position`.

  ## Examples

      scale = log_scale(1, 1000, 0, 300)
      scale.(100) #=> 200.0
  """
  def log_scale(domain_min, domain_max, range_min, range_max, base \\ 10) do
    log_fn = fn v -> :math.log(max(v, 1.0e-10)) / :math.log(base) end
    log_min = log_fn.(domain_min)
    log_max = log_fn.(domain_max)
    log_range = log_max - log_min
    p_range = range_max - range_min

    fn value ->
      if log_range == 0 do
        (range_min + range_max) / 2
      else
        log_val = log_fn.(value)
        range_min + (log_val - log_min) / log_range * p_range
      end
    end
  end

  # ---------------------------------------------------------------------------
  # Ordinal Scale
  # ---------------------------------------------------------------------------

  @doc """
  Creates an ordinal scale mapping categories to colors.

  Returns `fn(category) -> color_string`.

  ## Examples

      scale = ordinal_scale(["Revenue", "Cost"], ["blue", "red"])
      scale.("Cost") #=> "red"
  """
  def ordinal_scale(categories, colors) when is_list(categories) and is_list(colors) do
    mapping =
      categories
      |> Enum.with_index()
      |> Enum.map(fn {cat, i} ->
        color = Enum.at(colors, rem(i, max(length(colors), 1)), "currentColor")
        {cat, color}
      end)
      |> Map.new()

    fn category -> Map.get(mapping, category, "currentColor") end
  end

  # ---------------------------------------------------------------------------
  # Time Scale
  # ---------------------------------------------------------------------------

  @doc """
  Creates a time scale mapping DateTime/NaiveDateTime values to pixels.

  `date_min` and `date_max` are DateTime or NaiveDateTime structs.
  Maps linearly based on Unix timestamps (seconds).

  Returns `fn(datetime) -> pixel_position`.
  """
  def time_scale(date_min, date_max, range_min, range_max) do
    t_min = to_unix(date_min)
    t_max = to_unix(date_max)
    t_range = t_max - t_min
    p_range = range_max - range_min

    fn datetime ->
      if t_range == 0 do
        (range_min + range_max) / 2
      else
        t = to_unix(datetime)
        range_min + (t - t_min) / t_range * p_range
      end
    end
  end

  # ---------------------------------------------------------------------------
  # Invert
  # ---------------------------------------------------------------------------

  @doc """
  Inverts a linear scale: given a pixel position, returns the data value.

  Useful for tooltips and crosshairs.

  ## Examples

      scale = linear_scale(0, 100, 0, 400)
      invert_linear(0, 100, 0, 400, 200.0) #=> 50.0
  """
  def invert_linear(domain_min, domain_max, range_min, range_max, pixel) do
    d_range = domain_max - domain_min
    p_range = range_max - range_min

    if p_range == 0 do
      (domain_min + domain_max) / 2
    else
      domain_min + (pixel - range_min) / p_range * d_range
    end
  end

  # ---------------------------------------------------------------------------
  # Nice Domain
  # ---------------------------------------------------------------------------

  @doc """
  Rounds domain boundaries to "nice" values for human-readable axes.

  Uses `ChartAxisHelpers.nice_ticks/3` to find the rounded boundaries.

  ## Examples

      nice_domain(3.2, 97.8) #=> {0.0, 100.0}
  """
  def nice_domain(min, max, tick_count \\ 5) do
    ticks = ChartAxisHelpers.nice_ticks(min, max, tick_count)
    {Enum.min(ticks), Enum.max(ticks)}
  end

  # ---------------------------------------------------------------------------
  # Private
  # ---------------------------------------------------------------------------

  defp to_unix(%DateTime{} = dt), do: DateTime.to_unix(dt, :second) * 1.0
  defp to_unix(%NaiveDateTime{} = ndt), do: NaiveDateTime.diff(ndt, ~N[1970-01-01 00:00:00]) * 1.0
  defp to_unix(unix) when is_number(unix), do: unix * 1.0
end
