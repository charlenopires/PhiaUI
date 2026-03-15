defmodule PhiaUiDesign.Canvas.Variables do
  @moduledoc """
  Variable/token system for the PhiaUI Design canvas.

  Variables are stored in the scene's ETS table under the `:__variables__` key.
  Each variable has a name, value, type, and optional theme overrides.

  Variable references in attrs use the `"$name"` syntax. The `resolve/3` function
  replaces these references with concrete values based on the current theme.

  ## Variable definition

      %{
        value: "#3b82f6",
        type: :color,
        theme_overrides: %{dark: "#60a5fa"}
      }
  """

  @type variable_def :: %{
          value: term(),
          type: :color | :spacing | :number | :string,
          theme_overrides: %{optional(atom()) => term()}
        }

  # ---------------------------------------------------------------------------
  # Storage
  # ---------------------------------------------------------------------------

  @doc "Get all variables from the scene."
  @spec get_all(reference()) :: %{String.t() => variable_def()}
  def get_all(scene) do
    case :ets.lookup(scene, :__variables__) do
      [{:__variables__, vars}] when is_map(vars) -> vars
      _ -> %{}
    end
  end

  @doc "Set a single variable."
  @spec put(reference(), String.t(), variable_def()) :: :ok
  def put(scene, name, definition) when is_binary(name) and is_map(definition) do
    vars = get_all(scene)
    normalized = normalize_def(definition)
    :ets.insert(scene, {:__variables__, Map.put(vars, name, normalized)})
    :ok
  end

  @doc "Delete a single variable."
  @spec delete(reference(), String.t()) :: :ok
  def delete(scene, name) when is_binary(name) do
    vars = get_all(scene)
    :ets.insert(scene, {:__variables__, Map.delete(vars, name)})
    :ok
  end

  @doc "Merge multiple variables at once."
  @spec put_all(reference(), %{String.t() => variable_def()}) :: :ok
  def put_all(scene, variables_map) when is_map(variables_map) do
    vars = get_all(scene)
    normalized = Map.new(variables_map, fn {k, v} -> {k, normalize_def(v)} end)
    :ets.insert(scene, {:__variables__, Map.merge(vars, normalized)})
    :ok
  end

  # ---------------------------------------------------------------------------
  # Resolution
  # ---------------------------------------------------------------------------

  @doc """
  Resolve a value that may be a variable reference.

  If the value is a string starting with `"$"`, look it up in the scene's
  variables and return the concrete value (respecting theme overrides).
  Otherwise, return the value as-is.
  """
  @spec resolve(term(), reference(), atom()) :: term()
  def resolve("$" <> name, scene, theme) do
    vars = get_all(scene)

    case Map.get(vars, name) do
      nil -> "$#{name}"
      definition -> resolve_definition(definition, theme)
    end
  end

  def resolve(value, _scene, _theme), do: value

  @doc """
  Resolve all variable references in an attrs map.
  """
  @spec resolve_attrs(map(), reference(), atom()) :: map()
  def resolve_attrs(attrs, scene, theme) when is_map(attrs) do
    Map.new(attrs, fn {k, v} -> {k, resolve(v, scene, theme)} end)
  end

  @doc """
  Check if a value is a variable reference (`"$..."`).
  """
  @spec is_variable_ref?(term()) :: boolean()
  def is_variable_ref?("$" <> _), do: true
  def is_variable_ref?(_), do: false

  # ---------------------------------------------------------------------------
  # Private
  # ---------------------------------------------------------------------------

  defp normalize_def(definition) do
    %{
      value: Map.get(definition, :value) || Map.get(definition, "value"),
      type: normalize_type(Map.get(definition, :type) || Map.get(definition, "type")),
      theme_overrides:
        normalize_overrides(
          Map.get(definition, :theme_overrides) || Map.get(definition, "theme_overrides") || %{}
        )
    }
  end

  defp normalize_type(type) when is_atom(type), do: type
  defp normalize_type(type) when is_binary(type), do: safe_to_atom(type)
  defp normalize_type(_), do: :string

  defp normalize_overrides(overrides) when is_map(overrides) do
    Map.new(overrides, fn {k, v} ->
      key = if is_binary(k), do: safe_to_atom(k), else: k
      {key, v}
    end)
  end

  defp normalize_overrides(_), do: %{}

  defp resolve_definition(%{theme_overrides: overrides, value: value}, theme) do
    Map.get(overrides, theme, value)
  end

  defp safe_to_atom(str) when is_binary(str) do
    String.to_existing_atom(str)
  rescue
    ArgumentError -> String.to_atom(str)
  end
end
