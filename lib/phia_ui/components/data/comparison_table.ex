defmodule PhiaUi.Components.ComparisonTable do
  @moduledoc """
  Comparison table — feature-by-feature grid for plan/product comparison.

  Inspired by pricing page tables in shadcn blocks and PricingCard grid patterns.
  Common use cases: SaaS pricing pages, product spec sheets, feature matrices.

  Highlighted columns (`:highlighted: true` in plan map) receive a distinct
  background and border to draw attention to a recommended plan.

  ## Examples

      <.comparison_table
        plans={[
          %{name: "Starter", highlighted: false},
          %{name: "Pro", highlighted: true},
          %{name: "Enterprise", highlighted: false}
        ]}
        features={[
          %{label: "Users",    values: ["1", "Up to 10", "Unlimited"]},
          %{label: "API Access", values: [false, true, true]},
          %{label: "SLA",      values: [false, false, "99.99%"]}
        ]}
      />
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]
  import PhiaUi.Components.Icon, only: [icon: 1]

  attr(:plans, :list,
    required: true,
    doc: "List of plan maps with `:name` (string) and `:highlighted` (boolean)."
  )

  attr(:features, :list,
    required: true,
    doc:
      "List of feature maps with `:label` (string) and `:values` ([true|false|string]) " <>
        "— one value per plan, in the same order as `:plans`."
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes for the root element.")
  attr(:rest, :global, doc: "HTML attributes forwarded to the root `<div>`.")

  slot(:footer, doc: "Optional content rendered below the table.")

  def comparison_table(assigns) do
    ~H"""
    <div class={cn(["w-full", @class])} {@rest}>
      <div class="overflow-x-auto">
        <table class="w-full text-sm border-collapse">
          <%!-- Plan headers --%>
          <thead>
            <tr>
              <th class="py-3 pr-4 text-left text-muted-foreground font-normal w-40" />
              <th
                :for={plan <- @plans}
                class={cn([
                  "py-3 px-4 text-center font-semibold",
                  plan.highlighted && "bg-primary/5 border-x border-primary/20"
                ])}
              >
                {plan.name}
              </th>
            </tr>
          </thead>
          <%!-- Feature rows --%>
          <tbody>
            <tr
              :for={feature <- @features}
              class="border-t border-border"
            >
              <td class="py-3 pr-4 text-muted-foreground">{feature.label}</td>
              <td
                :for={{value, plan} <- Enum.zip(feature.values, @plans)}
                class={cn([
                  "py-3 px-4 text-center",
                  plan.highlighted && "bg-primary/5 border-x border-primary/20"
                ])}
              >
                <.cell_content value={value} />
              </td>
            </tr>
          </tbody>
        </table>
      </div>
      <div :if={@footer != []} class="mt-4">
        {render_slot(@footer)}
      </div>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Private sub-component for cell display
  # ---------------------------------------------------------------------------

  attr(:value, :any, required: true)

  defp cell_content(%{value: true} = assigns) do
    ~H"""
    <span class="flex justify-center">
      <.icon name="check" class="h-4 w-4 text-green-600" />
    </span>
    """
  end

  defp cell_content(%{value: false} = assigns) do
    ~H"""
    <span class="flex justify-center">
      <.icon name="minus" class="h-4 w-4 text-muted-foreground" />
    </span>
    """
  end

  defp cell_content(assigns) do
    ~H"""
    <span class="text-foreground">{@value}</span>
    """
  end
end
