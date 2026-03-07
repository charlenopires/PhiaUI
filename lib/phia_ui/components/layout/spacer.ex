defmodule PhiaUi.Components.Layout.Spacer do
  @moduledoc """
  Flex spacer that grows to fill remaining space in a flex container.

  Drop a `<.spacer />` between two items in a flex row/column to push the
  trailing item to the far end — equivalent to `margin-left: auto` patterns.

  ## Examples

      <%!-- Push actions to the right in a toolbar --%>
      <div class="flex items-center">
        <span>Title</span>
        <.spacer />
        <.button>Action</.button>
      </div>

      <%!-- Fixed-size gap --%>
      <div class="flex flex-col">
        <p>Top</p>
        <.spacer size={:md} />
        <p>Below with fixed gap</p>
      </div>
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  attr(:size, :atom,
    default: :auto,
    values: [:auto, :xs, :sm, :md, :lg, :xl],
    doc: "`auto` grows to fill remaining flex space; others add a fixed dimension."
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes merged via cn/1.")

  attr(:rest, :global, doc: "HTML attributes forwarded to the root element.")

  @doc "Renders a flex spacer element."
  def spacer(assigns) do
    ~H"""
    <div class={cn([spacer_class(@size), @class])} aria-hidden="true" {@rest}></div>
    """
  end

  defp spacer_class(:auto), do: "flex-1"
  defp spacer_class(:xs), do: "w-2 h-2 shrink-0"
  defp spacer_class(:sm), do: "w-4 h-4 shrink-0"
  defp spacer_class(:md), do: "w-6 h-6 shrink-0"
  defp spacer_class(:lg), do: "w-8 h-8 shrink-0"
  defp spacer_class(:xl), do: "w-12 h-12 shrink-0"
end
