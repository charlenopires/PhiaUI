defmodule PhiaUiDesign.Codegen.AttrFormatter do
  @moduledoc """
  Formats Elixir values for HEEx template attributes.

  Handles the mapping between in-memory attr values and their HEEx text
  representation. Phoenix function component attrs use the Elixir atom
  name directly (underscores), so `:variant` becomes `variant=...`.

  Special rules:
  - `nil` values are omitted (returns nil).
  - `true` booleans emit the bare attr name: `disabled`.
  - `false` booleans are omitted.
  - Atoms are wrapped in curlies: `variant={:destructive}`.
  - Strings are double-quoted: `label="Save"`.
  - Numbers are wrapped in curlies: `count={3}`.
  - Lists and maps use `inspect/1` inside curlies.
  - The `:class` attr always renders as a plain HTML string attribute.
  """

  @doc """
  Format a single attr key-value pair for HEEx output.

  Returns the formatted attribute string, or `nil` if the attr should be
  omitted from the output (nil value, false boolean).

  ## Examples

      iex> AttrFormatter.format(:disabled, true)
      "disabled"

      iex> AttrFormatter.format(:variant, :destructive)
      "variant={:destructive}"

      iex> AttrFormatter.format(:label, "Save")
      ~s(label="Save")

      iex> AttrFormatter.format(:hidden, false)
      nil

      iex> AttrFormatter.format(:tooltip, nil)
      nil
  """
  @spec format(atom(), term()) :: String.t() | nil
  def format(_key, nil), do: nil
  def format(_key, false), do: nil
  def format(key, true) when is_atom(key), do: to_string(key)

  def format(:class, value) when is_binary(value) do
    ~s(class="#{escape_html(value)}")
  end

  def format(key, value) when is_atom(key) and is_atom(value) do
    "#{attr_name(key)}={:#{value}}"
  end

  def format(key, value) when is_atom(key) and is_binary(value) do
    ~s(#{attr_name(key)}="#{escape_html(value)}")
  end

  def format(key, value) when is_atom(key) and is_integer(value) do
    "#{attr_name(key)}={#{value}}"
  end

  def format(key, value) when is_atom(key) and is_float(value) do
    "#{attr_name(key)}={#{value}}"
  end

  def format(key, value) when is_atom(key) and is_list(value) do
    "#{attr_name(key)}={#{inspect(value)}}"
  end

  def format(key, value) when is_atom(key) and is_map(value) do
    "#{attr_name(key)}={#{inspect(value)}}"
  end

  def format(key, value) when is_atom(key) do
    "#{attr_name(key)}={#{inspect(value)}}"
  end

  @doc """
  Format a map of attrs into a single space-separated string suitable for
  insertion into an opening HEEx tag.

  Keys are sorted alphabetically for deterministic output.

  ## Examples

      iex> AttrFormatter.format_attrs(%{variant: :outline, disabled: true})
      "disabled variant={:outline}"

      iex> AttrFormatter.format_attrs(%{})
      ""
  """
  @spec format_attrs(map()) :: String.t()
  def format_attrs(attrs) when is_map(attrs) do
    attrs
    |> Enum.sort_by(fn {k, _v} -> to_string(k) end)
    |> Enum.map(fn {k, v} -> format(k, v) end)
    |> Enum.reject(&is_nil/1)
    |> Enum.join(" ")
  end

  # Convert an atom key to the HEEx attribute name string.
  # Phoenix component attrs use the Elixir atom name as-is (underscores).
  # This is intentionally simple: `to_string/1` on the atom.
  defp attr_name(key), do: to_string(key)

  # Escape characters that are meaningful inside HTML attribute values.
  defp escape_html(str) do
    str
    |> String.replace("&", "&amp;")
    |> String.replace("<", "&lt;")
    |> String.replace(">", "&gt;")
    |> String.replace(~s("), "&quot;")
  end
end
