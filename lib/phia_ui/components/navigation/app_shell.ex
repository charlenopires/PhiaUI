defmodule PhiaUi.Components.AppShell do
  @moduledoc """
  Application shell layout component providing a full-page grid structure.

  Provides six components:

  - `app_shell/1` — root CSS grid layout container
  - `app_shell_header/1` — sticky top header
  - `app_shell_sidebar/1` — fixed-height sidebar
  - `app_shell_aside/1` — right aside panel
  - `app_shell_footer/1` — sticky footer
  - `app_shell_main/1` — scrollable main content area
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  # ---------------------------------------------------------------------------
  # app_shell/1
  # ---------------------------------------------------------------------------

  attr(:class, :string, default: nil)
  attr(:sidebar_width, :atom, values: [:sm, :md, :lg, :xl], default: :md)
  attr(:with_sidebar, :boolean, default: true)
  attr(:with_aside, :boolean, default: false)
  attr(:with_header, :boolean, default: true)
  attr(:with_footer, :boolean, default: false)
  attr(:rest, :global)

  slot(:header)
  slot(:sidebar)
  slot(:aside)
  slot(:footer)
  slot(:inner_block, doc: "Main content area")

  def app_shell(assigns) do
    assigns = assign(assigns, :sidebar_w, sidebar_width_value(assigns.sidebar_width))

    ~H"""
    <div
      class={cn(["flex h-screen flex-col overflow-hidden", @class])}
      style={"--shell-sidebar-w: #{@sidebar_w}"}
      {@rest}
    >
      <header
        :if={@with_header && @header != []}
        class="shrink-0 sticky top-0 z-40 border-b bg-background"
      >
        {render_slot(@header)}
      </header>
      <div class={cn([
        "flex flex-1 overflow-hidden",
      ])}>
        <aside
          :if={@with_sidebar && @sidebar != []}
          class="shrink-0 border-r bg-background overflow-y-auto"
          style={"width: var(--shell-sidebar-w, 18rem)"}
        >
          {render_slot(@sidebar)}
        </aside>
        <main class="flex-1 overflow-y-auto">
          {render_slot(@inner_block)}
        </main>
        <aside
          :if={@with_aside && @aside != []}
          class="shrink-0 border-l bg-background overflow-y-auto w-64"
        >
          {render_slot(@aside)}
        </aside>
      </div>
      <footer
        :if={@with_footer && @footer != []}
        class="shrink-0 sticky bottom-0 z-40 border-t bg-background"
      >
        {render_slot(@footer)}
      </footer>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # app_shell_header/1
  # ---------------------------------------------------------------------------

  attr(:class, :string, default: nil)
  attr(:height, :atom, values: [:sm, :md, :lg], default: :md)
  attr(:rest, :global)

  slot(:inner_block, required: true)

  def app_shell_header(assigns) do
    ~H"""
    <header
      class={cn([
        "sticky top-0 z-40 flex items-center border-b bg-background px-4",
        shell_header_height_class(@height),
        @class
      ])}
      {@rest}
    >
      {render_slot(@inner_block)}
    </header>
    """
  end

  # ---------------------------------------------------------------------------
  # app_shell_sidebar/1
  # ---------------------------------------------------------------------------

  attr(:class, :string, default: nil)
  attr(:collapsible, :boolean, default: false)
  attr(:collapsed, :boolean, default: false)
  attr(:rest, :global)

  slot(:inner_block, required: true)

  def app_shell_sidebar(assigns) do
    ~H"""
    <aside
      class={cn([
        "h-full border-r overflow-y-auto bg-background transition-all",
        @collapsed && "w-0 overflow-hidden",
        @class
      ])}
      {@rest}
    >
      {render_slot(@inner_block)}
    </aside>
    """
  end

  # ---------------------------------------------------------------------------
  # app_shell_aside/1
  # ---------------------------------------------------------------------------

  attr(:class, :string, default: nil)
  attr(:rest, :global)

  slot(:inner_block, required: true)

  def app_shell_aside(assigns) do
    ~H"""
    <aside
      class={cn(["h-full border-l overflow-y-auto bg-background w-64", @class])}
      {@rest}
    >
      {render_slot(@inner_block)}
    </aside>
    """
  end

  # ---------------------------------------------------------------------------
  # app_shell_footer/1
  # ---------------------------------------------------------------------------

  attr(:class, :string, default: nil)
  attr(:rest, :global)

  slot(:inner_block, required: true)

  def app_shell_footer(assigns) do
    ~H"""
    <footer
      class={cn(["sticky bottom-0 z-40 flex items-center border-t bg-background px-4 h-14", @class])}
      {@rest}
    >
      {render_slot(@inner_block)}
    </footer>
    """
  end

  # ---------------------------------------------------------------------------
  # app_shell_main/1
  # ---------------------------------------------------------------------------

  attr(:class, :string, default: nil)
  attr(:padding, :atom, values: [:none, :sm, :md, :lg], default: :md)
  attr(:rest, :global)

  slot(:inner_block, required: true)

  def app_shell_main(assigns) do
    ~H"""
    <main
      class={cn([
        "flex-1 overflow-y-auto",
        shell_main_padding_class(@padding),
        @class
      ])}
      {@rest}
    >
      {render_slot(@inner_block)}
    </main>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  defp sidebar_width_value(:sm), do: "16rem"
  defp sidebar_width_value(:md), do: "18rem"
  defp sidebar_width_value(:lg), do: "20rem"
  defp sidebar_width_value(:xl), do: "24rem"

  defp shell_header_height_class(:sm), do: "h-14"
  defp shell_header_height_class(:md), do: "h-16"
  defp shell_header_height_class(:lg), do: "h-20"

  defp shell_main_padding_class(:none), do: ""
  defp shell_main_padding_class(:sm), do: "p-4"
  defp shell_main_padding_class(:md), do: "p-6"
  defp shell_main_padding_class(:lg), do: "p-8"
end
