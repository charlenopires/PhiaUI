defmodule PhiaUi.Components.BarList do
  @moduledoc """
  Horizontal bar list — ranks items by value with proportional bars.

  Inspired by Tremor `BarList` and Ant Design statistics lists.
  Useful for leaderboards, category breakdowns, and ranked metrics.

  The max value is computed server-side; all widths are inline `style` percent
  values (cannot use Tailwind `w-*` for dynamic widths).

  ## Examples

      <.bar_list data={[
        %{name: "Direct", value: 4200},
        %{name: "Referral", value: 2800},
        %{name: "Organic", value: 1100}
      ]} />

      <.bar_list
        data={@traffic}
        color="bg-blue-500"
        value_formatter={fn v -> "\$\#{v}" end}
      />
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  attr(:data, :list,
    required: true,
    doc:
      "List of maps with `:name` (string), `:value` (number), and optional `:href` (string)."
  )

  attr(:value_formatter, :any,
    default: nil,
    doc: "Optional `fn/1` to format displayed values. Receives the raw value."
  )

  attr(:color, :string, default: "bg-primary", doc: "Tailwind bg-* class for the bars.")

  attr(:class, :string, default: nil, doc: "Additional CSS classes for the root element.")
  attr(:rest, :global, doc: "HTML attributes forwarded to the root `<div>`.")

  def bar_list(assigns) do
    max_val = assigns.data |> Enum.map(& &1.value) |> Enum.max(fn -> 1 end)

    items =
      Enum.map(assigns.data, fn item ->
        Map.put(item, :width_pct, Float.round(item.value / max(max_val, 1) * 100, 1))
      end)

    assigns = assign(assigns, :items, items)

    ~H"""
    <div class={cn(["w-full space-y-2", @class])} {@rest}>
      <div :for={item <- @items} class="flex items-center gap-3">
        <%!-- Bar track --%>
        <div class="relative flex-1 h-8 rounded-md bg-muted overflow-hidden">
          <div
            class={cn(["absolute inset-y-0 left-0 rounded-md", @color])}
            style={"width: #{item.width_pct}%"}
            aria-hidden="true"
          />
          <%!-- Name overlaid on bar --%>
          <div class="relative flex items-center h-full px-2">
            <a
              :if={Map.get(item, :href)}
              href={item.href}
              class="text-sm font-medium truncate hover:underline"
            >
              {item.name}
            </a>
            <span :if={!Map.get(item, :href)} class="text-sm font-medium truncate">
              {item.name}
            </span>
          </div>
        </div>
        <%!-- Value --%>
        <span class="text-sm font-medium text-foreground w-16 text-right shrink-0">
          {format_value(item.value, @value_formatter)}
        </span>
      </div>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  defp format_value(v, nil), do: to_string(v)
  defp format_value(v, f) when is_function(f, 1), do: f.(v)
end
