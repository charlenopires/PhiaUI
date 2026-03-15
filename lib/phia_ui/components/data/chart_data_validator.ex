defmodule PhiaUi.Components.Data.ChartDataValidator do
  @moduledoc false
  # Runtime data shape validation for chart components.
  # Provides clear error messages when data doesn't match expected shapes.
  # Not registered in ComponentRegistry — internal only.

  @doc """
  Validates standard series data shape: `[%{label, value}]`.
  Raises `ArgumentError` with a descriptive message on invalid data.
  Returns `:ok` on success.
  """
  def validate_series!(data) when is_list(data) do
    Enum.each(data, fn item ->
      unless is_map(item) and Map.has_key?(item, :label) and Map.has_key?(item, :value) do
        raise ArgumentError,
              "Invalid series data: each item must be a map with :label and :value keys. Got: #{inspect(item)}"
      end
    end)

    :ok
  end

  def validate_series!(data) do
    raise ArgumentError, "Series data must be a list, got: #{inspect(data)}"
  end

  @doc """
  Validates OHLC (candlestick) data shape: `[%{label, open, high, low, close}]`.
  Raises `ArgumentError` on invalid data.
  """
  def validate_ohlc!(data) when is_list(data) do
    required = [:label, :open, :high, :low, :close]

    Enum.each(data, fn item ->
      missing = Enum.reject(required, &Map.has_key?(item, &1))

      unless missing == [] do
        raise ArgumentError,
              "Invalid OHLC data: missing keys #{inspect(missing)} in #{inspect(item)}"
      end

      unless item.high >= item.low do
        raise ArgumentError,
              "Invalid OHLC data: :high (#{item.high}) must be >= :low (#{item.low}) for #{item.label}"
      end
    end)

    :ok
  end

  def validate_ohlc!(data) do
    raise ArgumentError, "OHLC data must be a list, got: #{inspect(data)}"
  end

  @doc """
  Validates hierarchical tree data: `[%{label, value, children: [...]}]`.
  Recursively validates children. Raises `ArgumentError` on invalid data.
  """
  def validate_hierarchical!(data) when is_list(data) do
    Enum.each(data, fn item ->
      unless is_map(item) and Map.has_key?(item, :label) do
        raise ArgumentError,
              "Invalid hierarchical data: each node must have a :label key. Got: #{inspect(item)}"
      end

      unless Map.has_key?(item, :value) or Map.has_key?(item, :children) do
        raise ArgumentError,
              "Invalid hierarchical data: node '#{item.label}' must have :value or :children"
      end

      children = Map.get(item, :children, [])

      if is_list(children) and children != [] do
        validate_hierarchical!(children)
      end
    end)

    :ok
  end

  def validate_hierarchical!(data) do
    raise ArgumentError, "Hierarchical data must be a list, got: #{inspect(data)}"
  end

  @doc """
  Validates Sankey flow data: `%{nodes: [%{id, label}], links: [%{source, target, value}]}`.
  Raises `ArgumentError` on invalid data.
  """
  def validate_flow!(data) when is_map(data) do
    unless Map.has_key?(data, :nodes) and Map.has_key?(data, :links) do
      raise ArgumentError,
            "Flow data must have :nodes and :links keys. Got keys: #{inspect(Map.keys(data))}"
    end

    unless is_list(data.nodes) do
      raise ArgumentError, "Flow :nodes must be a list"
    end

    unless is_list(data.links) do
      raise ArgumentError, "Flow :links must be a list"
    end

    Enum.each(data.nodes, fn node ->
      unless is_map(node) and Map.has_key?(node, :id) and Map.has_key?(node, :label) do
        raise ArgumentError,
              "Invalid flow node: must have :id and :label. Got: #{inspect(node)}"
      end
    end)

    node_ids = MapSet.new(data.nodes, & &1.id)

    Enum.each(data.links, fn link ->
      unless is_map(link) and Map.has_key?(link, :source) and Map.has_key?(link, :target) and Map.has_key?(link, :value) do
        raise ArgumentError,
              "Invalid flow link: must have :source, :target, and :value. Got: #{inspect(link)}"
      end

      unless MapSet.member?(node_ids, link.source) do
        raise ArgumentError,
              "Invalid flow link: source '#{link.source}' not found in nodes"
      end

      unless MapSet.member?(node_ids, link.target) do
        raise ArgumentError,
              "Invalid flow link: target '#{link.target}' not found in nodes"
      end
    end)

    :ok
  end

  def validate_flow!(data) do
    raise ArgumentError, "Flow data must be a map with :nodes and :links, got: #{inspect(data)}"
  end
end
