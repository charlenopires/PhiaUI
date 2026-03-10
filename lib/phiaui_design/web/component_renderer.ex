defmodule PhiaUiDesign.Web.ComponentRenderer do
  @moduledoc """
  Renders real PhiaUI components dynamically for the design canvas.

  Attempts to call the actual component function with the node's attrs and
  slots. Falls back gracefully to `{:error, reason}` on any failure so the
  editor can show a placeholder instead.

  ## Slot construction

  `inner_block` text content is wrapped in a proper Phoenix slot struct so
  that `render_slot(@inner_block)` works inside the target component. Named
  slots are not supported yet (they require compile-time HEEx).
  """

  use Phoenix.Component

  # ---------------------------------------------------------------------------
  # Public API
  # ---------------------------------------------------------------------------

  @doc """
  Render a PhiaUI component to an HTML string.

  Returns `{:ok, html_string}` on success, `{:error, reason}` on failure.
  """
  @spec render_to_html(module() | nil, atom(), map(), map()) ::
          {:ok, String.t()} | {:error, String.t()}
  def render_to_html(nil, _func, _attrs, _slots), do: {:error, "no module"}

  def render_to_html(module, func_name, attrs, slots)
      when is_atom(module) and is_atom(func_name) do
    Code.ensure_loaded(module)

    unless function_exported?(module, func_name, 1) do
      throw({:error, "#{inspect(module)}.#{func_name}/1 not exported"})
    end

    assigns = build_assigns(module, func_name, attrs, slots)
    rendered = apply(module, func_name, [assigns])
    html = rendered |> Phoenix.HTML.Safe.to_iodata() |> IO.iodata_to_binary()
    {:ok, html}
  rescue
    e -> {:error, Exception.message(e)}
  catch
    :throw, {:error, reason} -> {:error, reason}
    kind, reason -> {:error, "#{kind}: #{inspect(reason)}"}
  end

  # ---------------------------------------------------------------------------
  # Slot helper component (compiled HEEx — always produces valid Rendered)
  # ---------------------------------------------------------------------------

  @doc false
  attr :text, :string, default: ""

  def slot_text(assigns) do
    ~H"{@text}"
  end

  # ---------------------------------------------------------------------------
  # Private — assign building
  # ---------------------------------------------------------------------------

  defp build_assigns(module, func_name, attrs, slots) do
    meta = get_component_meta(module, func_name)

    %{__changed__: nil}
    |> Map.merge(attrs || %{})
    |> build_inner_block(slots)
    |> apply_attr_defaults(meta)
    |> Map.put_new(:rest, %{})
  end

  defp build_inner_block(assigns, nil), do: assigns
  defp build_inner_block(assigns, %{} = slots) do
    text =
      Map.get(slots, :inner_block) ||
        Map.get(slots, "inner_block")

    case text do
      nil -> assigns
      "" -> assigns
      t when is_binary(t) ->
        Map.put(assigns, :inner_block, [
          %{
            __slot__: :inner_block,
            inner_block: fn _changed, _arg ->
              slot_text(%{__changed__: nil, text: t})
            end
          }
        ])

      _ ->
        assigns
    end
  end

  defp get_component_meta(module, func_name) do
    if function_exported?(module, :__components__, 0) do
      Map.get(module.__components__(), func_name)
    end
  end

  defp apply_attr_defaults(assigns, nil), do: assigns

  defp apply_attr_defaults(assigns, meta) do
    attrs = Map.get(meta, :attrs, [])

    Enum.reduce(attrs, assigns, fn attr, acc ->
      name = attr.name

      # Skip :rest — handled separately
      if name == :rest do
        acc
      else
        if Map.has_key?(acc, name) do
          acc
        else
          opts = Map.get(attr, :opts, [])

          if Keyword.has_key?(opts, :default) do
            Map.put(acc, name, Keyword.get(opts, :default))
          else
            Map.put(acc, name, default_for_type(Map.get(attr, :type, :any)))
          end
        end
      end
    end)
  end

  defp default_for_type(:string), do: ""
  defp default_for_type(:boolean), do: false
  defp default_for_type(:integer), do: 0
  defp default_for_type(:float), do: 0.0
  defp default_for_type(:list), do: []
  defp default_for_type(:global), do: %{}
  defp default_for_type(_), do: nil
end
