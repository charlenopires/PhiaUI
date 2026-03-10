defmodule PhiaUiDesign.Catalog.Introspector do
  @moduledoc """
  Introspects Phoenix component modules to extract attrs, slots, and metadata.

  Uses Phoenix.Component's `__components__/0` callback which returns component
  function metadata at runtime — always up-to-date, no stale JSON risk.
  """

  @type attr_info :: %{
          name: atom(),
          type: atom(),
          required: boolean(),
          default: term(),
          values: [term()] | nil,
          doc: String.t() | nil
        }

  @type slot_info :: %{
          name: atom(),
          required: boolean(),
          doc: String.t() | nil
        }

  @type component_info :: %{
          name: atom(),
          module: module(),
          attrs: [attr_info()],
          slots: [slot_info()],
          doc: String.t() | nil
        }

  @doc """
  Introspect a single Phoenix component module.

  Returns a list of component definitions with their attrs and slots.
  Uses `__components__/0` which Phoenix.Component exposes on compiled modules.
  """
  @spec introspect_module(module()) :: [component_info()]
  def introspect_module(module) when is_atom(module) do
    Code.ensure_loaded(module)

    if function_exported?(module, :__components__, 0) do
      for {func_name, meta} <- module.__components__() do
        %{
          name: func_name,
          module: module,
          attrs: normalize_attrs(Map.get(meta, :attrs, [])),
          slots: normalize_slots(Map.get(meta, :slots, [])),
          doc: get_component_doc(module, func_name)
        }
      end
    else
      []
    end
  end

  @doc """
  Introspect a specific component function from a module.
  """
  @spec introspect_component(module(), atom()) :: component_info() | nil
  def introspect_component(module, func_name) do
    module
    |> introspect_module()
    |> Enum.find(&(&1.name == func_name))
  end

  @doc """
  Introspect ALL registered PhiaUI components by combining the registry
  with runtime module introspection.
  """
  @spec introspect_all() :: [map()]
  def introspect_all do
    for {key, meta} <- PhiaUi.ComponentRegistry.all(),
        meta.status == :implemented do
      func_name = String.to_atom(meta.name)
      module_info = introspect_component(meta.module, func_name)

      %{
        key: key,
        name: meta.name,
        module: meta.module,
        tier: meta.tier,
        js_hooks: meta.js_hooks,
        dependencies: meta.dependencies,
        attrs: (module_info && module_info.attrs) || [],
        slots: (module_info && module_info.slots) || [],
        doc: module_info && module_info.doc
      }
    end
  end

  @doc """
  Get component info by registry key (atom).
  """
  @spec get_component_info(atom()) :: map() | nil
  def get_component_info(component_key) do
    case PhiaUi.ComponentRegistry.get(component_key) do
      nil ->
        nil

      meta ->
        func_name = String.to_atom(meta.name)
        module_info = introspect_component(meta.module, func_name)

        %{
          key: component_key,
          name: meta.name,
          module: meta.module,
          tier: meta.tier,
          js_hooks: meta.js_hooks,
          dependencies: meta.dependencies,
          attrs: (module_info && module_info.attrs) || [],
          slots: (module_info && module_info.slots) || [],
          doc: module_info && module_info.doc
        }
    end
  end

  # Private helpers

  defp normalize_attrs(attrs) when is_list(attrs) do
    attrs
    |> Enum.reject(fn attr -> attr.name == :rest end)
    |> Enum.map(fn attr ->
      opts = Map.get(attr, :opts, [])

      %{
        name: attr.name,
        type: Map.get(attr, :type, :any),
        required: Map.get(attr, :required, false),
        default: Keyword.get(opts, :default),
        values: Keyword.get(opts, :values),
        doc: Map.get(attr, :doc)
      }
    end)
    |> Enum.sort_by(& &1.name)
  end

  defp normalize_attrs(_), do: []

  defp normalize_slots(slots) when is_list(slots) do
    slots
    |> Enum.map(fn slot ->
      %{
        name: slot.name,
        required: Map.get(slot, :required, false),
        doc: Map.get(slot, :doc)
      }
    end)
    |> Enum.sort_by(& &1.name)
  end

  defp normalize_slots(_), do: []

  defp get_component_doc(module, func_name) do
    case Code.fetch_docs(module) do
      {:docs_v1, _, _, _, _, _, docs} ->
        Enum.find_value(docs, fn
          {{:function, ^func_name, _arity}, _, _, %{"en" => doc}, _} -> doc
          _ -> nil
        end)

      _ ->
        nil
    end
  end
end
