defmodule PhiaUi.Components.Layout.DescriptionList do
  @moduledoc """
  Semantic `<dl>/<dt>/<dd>` key-value display component.

  Three layout variants:

  - `:vertical` — term stacked above description (default)
  - `:horizontal` — term and description side-by-side, separated by divider lines
  - `:grid` — two-column grid for dense data displays

  ## Sub-components

  - `dl_item/1` — wraps a term+description pair
  - `dl_term/1` — renders `<dt>` with muted label styling
  - `dl_description/1` — renders `<dd>` with foreground value styling

  ## Examples

      <%!-- Vertical (default) --%>
      <.description_list>
        <.dl_item>
          <:term>Status</:term>
          <:description>Active</:description>
        </.dl_item>
        <.dl_item>
          <:term>Plan</:term>
          <:description>Pro</:description>
        </.dl_item>
      </.description_list>

      <%!-- Horizontal with dividers --%>
      <.description_list variant={:horizontal}>
        <.dl_item>
          <:term>Created</:term>
          <:description>Jan 1, 2026</:description>
        </.dl_item>
      </.description_list>

      <%!-- Grid layout --%>
      <.description_list variant={:grid}>
        <.dl_item>
          <:term>Owner</:term>
          <:description>Jane Doe</:description>
        </.dl_item>
        <.dl_item>
          <:term>Team</:term>
          <:description>Engineering</:description>
        </.dl_item>
      </.description_list>
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  # ---------------------------------------------------------------------------
  # description_list/1
  # ---------------------------------------------------------------------------

  attr(:variant, :atom,
    default: :vertical,
    values: [:vertical, :horizontal, :grid],
    doc: "Layout variant."
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes merged via cn/1.")

  attr(:rest, :global, doc: "HTML attributes forwarded to the `<dl>` element.")

  slot(:inner_block, required: true, doc: "One or more `dl_item/1` components.")

  @doc "Renders a semantic description list."
  def description_list(assigns) do
    ~H"""
    <dl class={cn([dl_class(@variant), @class])} {@rest}>
      <%= render_slot(@inner_block) %>
    </dl>
    """
  end

  defp dl_class(:vertical), do: "space-y-4"
  defp dl_class(:horizontal), do: "divide-y divide-border"
  defp dl_class(:grid), do: "grid grid-cols-2 gap-x-8 gap-y-4"

  # ---------------------------------------------------------------------------
  # dl_item/1
  # ---------------------------------------------------------------------------

  attr(:class, :string, default: nil, doc: "Additional CSS classes merged via cn/1.")

  attr(:rest, :global, doc: "HTML attributes forwarded to the wrapper element.")

  slot(:term, required: true, doc: "The key/label (`<dt>`).")
  slot(:description, required: true, doc: "The value (`<dd>`).")

  @doc "Renders a key-value pair within a `description_list`."
  def dl_item(assigns) do
    ~H"""
    <div class={cn(["flex flex-col gap-1 sm:flex-row sm:gap-4 sm:items-baseline py-2", @class])} {@rest}>
      <dt class="text-sm font-medium text-muted-foreground min-w-[8rem] shrink-0">
        <%= render_slot(@term) %>
      </dt>
      <dd class="text-sm text-foreground">
        <%= render_slot(@description) %>
      </dd>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # dl_term/1
  # ---------------------------------------------------------------------------

  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  @doc "Renders a `<dt>` term label."
  def dl_term(assigns) do
    ~H"""
    <dt class={cn(["text-sm font-medium text-muted-foreground", @class])} {@rest}>
      <%= render_slot(@inner_block) %>
    </dt>
    """
  end

  # ---------------------------------------------------------------------------
  # dl_description/1
  # ---------------------------------------------------------------------------

  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  @doc "Renders a `<dd>` description value."
  def dl_description(assigns) do
    ~H"""
    <dd class={cn(["text-sm text-foreground", @class])} {@rest}>
      <%= render_slot(@inner_block) %>
    </dd>
    """
  end
end
