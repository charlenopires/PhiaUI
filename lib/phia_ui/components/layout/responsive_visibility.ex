defmodule PhiaUi.Components.Layout.ResponsiveVisibility do
  @moduledoc """
  Responsive visibility components for declaratively showing or hiding content
  at specific breakpoints.

  These components eliminate ad-hoc `hidden md:block` class strings by encoding
  the intent as a component with a typed `:at` or `:from`/`:to` attribute.

  ## Components

  - `show_on/1` — shows content **at or above** a breakpoint
  - `hide_on/1` — hides content **at or above** a breakpoint
  - `show_between/1` — shows content **between** two breakpoints

  ## Examples

      <%!-- Desktop-only sidebar --%>
      <.show_on at={:lg}>
        <aside>Sidebar content</aside>
      </.show_on>

      <%!-- Hide verbose text on small screens --%>
      <.hide_on at={:md}>
        <p>This paragraph is only visible on mobile.</p>
      </.hide_on>

      <%!-- Tablet-only content --%>
      <.show_between from={:md} to={:xl}>
        <p>Visible on tablets only.</p>
      </.show_between>
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  # ---------------------------------------------------------------------------
  # show_on
  # ---------------------------------------------------------------------------

  attr :at, :atom,
    default: :md,
    values: [:sm, :md, :lg, :xl, :"2xl"],
    doc: "Breakpoint at or above which the content becomes visible."

  attr :as, :atom,
    default: :div,
    values: [:div, :span],
    doc: "HTML element to render — `:div` uses `block`, `:span` uses `inline`."

  attr :class, :string, default: nil, doc: "Additional CSS classes merged via cn/1."

  attr :rest, :global, doc: "HTML attributes forwarded to the root element."

  slot :inner_block, required: true, doc: "Content to show at the specified breakpoint."

  @doc "Shows content only at or above the specified breakpoint."
  def show_on(assigns) do
    ~H"""
    <div
      :if={@as == :div}
      class={cn(["hidden", show_block_class(@at), @class])}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </div>
    <span
      :if={@as == :span}
      class={cn(["hidden", show_inline_class(@at), @class])}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </span>
    """
  end

  # ---------------------------------------------------------------------------
  # hide_on
  # ---------------------------------------------------------------------------

  attr :at, :atom,
    default: :md,
    values: [:sm, :md, :lg, :xl, :"2xl"],
    doc: "Breakpoint at or above which the content becomes hidden."

  attr :class, :string, default: nil, doc: "Additional CSS classes merged via cn/1."

  attr :rest, :global, doc: "HTML attributes forwarded to the root element."

  slot :inner_block, required: true, doc: "Content to hide at the specified breakpoint."

  @doc "Hides content at or above the specified breakpoint."
  def hide_on(assigns) do
    ~H"""
    <div class={cn([hide_class(@at), @class])} {@rest}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # show_between
  # ---------------------------------------------------------------------------

  attr :from, :atom,
    default: :sm,
    values: [:sm, :md, :lg, :xl, :"2xl"],
    doc: "Lower breakpoint (content becomes visible here)."

  attr :to, :atom,
    default: :lg,
    values: [:sm, :md, :lg, :xl, :"2xl"],
    doc: "Upper breakpoint (content becomes hidden here)."

  attr :class, :string, default: nil, doc: "Additional CSS classes merged via cn/1."

  attr :rest, :global, doc: "HTML attributes forwarded to the root element."

  slot :inner_block, required: true, doc: "Content visible between the two breakpoints."

  @doc "Shows content between two breakpoints (visible from `:from`, hidden at `:to`)."
  def show_between(assigns) do
    ~H"""
    <div
      class={cn(["hidden", show_block_class(@from), hide_class(@to), @class])}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  defp show_block_class(:sm), do: "sm:block"
  defp show_block_class(:md), do: "md:block"
  defp show_block_class(:lg), do: "lg:block"
  defp show_block_class(:xl), do: "xl:block"
  defp show_block_class(:"2xl"), do: "2xl:block"

  defp show_inline_class(:sm), do: "sm:inline"
  defp show_inline_class(:md), do: "md:inline"
  defp show_inline_class(:lg), do: "lg:inline"
  defp show_inline_class(:xl), do: "xl:inline"
  defp show_inline_class(:"2xl"), do: "2xl:inline"

  defp hide_class(:sm), do: "sm:hidden"
  defp hide_class(:md), do: "md:hidden"
  defp hide_class(:lg), do: "lg:hidden"
  defp hide_class(:xl), do: "xl:hidden"
  defp hide_class(:"2xl"), do: "2xl:hidden"
end
