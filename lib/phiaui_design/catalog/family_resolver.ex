defmodule PhiaUiDesign.Catalog.FamilyResolver do
  @moduledoc """
  Detects composable component families by analyzing which components share
  the same module and have naming prefix patterns.

  For example: card, card_header, card_title, card_content, card_footer
  all belong to the "card" family.
  """

  @type family :: %{
          root: atom(),
          root_name: String.t(),
          module: module(),
          children: [atom()],
          tier: atom()
        }

  @doc """
  Resolve all component families from the registry.

  Returns families where a root component has 1+ child components
  in the same module with matching name prefix.
  """
  @spec resolve_families() :: [family()]
  def resolve_families do
    PhiaUi.ComponentRegistry.all()
    |> Map.values()
    |> Enum.filter(&(&1.status == :implemented))
    |> Enum.group_by(& &1.module)
    |> Enum.filter(fn {_mod, entries} -> length(entries) > 1 end)
    |> Enum.map(&build_family/1)
    |> Enum.reject(&is_nil/1)
  end

  @doc """
  Get the family for a specific component.
  Returns nil if the component is standalone (no family).
  """
  @spec family_for(atom()) :: family() | nil
  def family_for(component_key) do
    case PhiaUi.ComponentRegistry.get(component_key) do
      nil ->
        nil

      _meta ->
        resolve_families()
        |> Enum.find(fn fam ->
          fam.root == component_key or component_key in fam.children
        end)
    end
  end

  @doc """
  Get the typical children for a component family.
  Returns an ordered list suitable for auto-scaffolding.
  """
  @spec scaffold_order(atom()) :: [atom()]
  def scaffold_order(root_key) do
    case family_for(root_key) do
      nil -> [root_key]
      %{root: ^root_key, children: children} -> [root_key | children]
      %{root: root, children: children} -> [root | children]
    end
  end

  # Private

  defp build_family({_module, entries}) do
    # Sort by name length — shortest is likely the root
    sorted = Enum.sort_by(entries, fn e -> String.length(e.name) end)

    case sorted do
      [root | rest] when rest != [] ->
        root_name = root.name

        # Filter children that actually share the root prefix
        children =
          rest
          |> Enum.filter(fn e -> String.starts_with?(e.name, root_name <> "_") end)
          |> Enum.map(fn e ->
            # Convert name string back to registry key atom
            String.to_atom(e.name)
          end)

        if children != [] do
          %{
            root: String.to_atom(root_name),
            root_name: root_name,
            module: root.module,
            children: children,
            tier: root.tier
          }
        else
          nil
        end

      _ ->
        nil
    end
  end
end
