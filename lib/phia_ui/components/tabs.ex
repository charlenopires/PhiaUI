defmodule PhiaUi.Components.Tabs do
  @moduledoc """
  Tabs component for PhiaUI.

  Provides accessible content-switching with a `tabs_list/1` trigger bar
  and `tabs_content/1` panels. Active/inactive state is server-rendered —
  no JavaScript hook required.

  Use the `:default_value` attr to set the initially active tab.
  For server-driven tab switching, manage the selected value in your
  LiveView assigns and re-render.

  WAI-ARIA:
  - Container: no special role (generic wrapper)
  - Trigger list: `role="tablist"`
  - Each trigger: `role="tab"`, `aria-selected`, `aria-controls`
  - Each panel: `role="tabpanel"`, `aria-labelledby`, `id`

  ## Examples

      <%!-- Default usage --%>
      <.tabs default_value="description">
        <.tabs_list>
          <.tabs_trigger value="description">Description</.tabs_trigger>
          <.tabs_trigger value="comments">Comments</.tabs_trigger>
          <.tabs_trigger value="activity">Activity</.tabs_trigger>
        </.tabs_list>
        <.tabs_content value="description">
          <p>Task description here…</p>
        </.tabs_content>
        <.tabs_content value="comments">
          <p>No comments yet.</p>
        </.tabs_content>
        <.tabs_content value="activity">
          <p>Recent activity…</p>
        </.tabs_content>
      </.tabs>

      <%!-- Server-driven switching --%>
      <.tabs default_value={@active_tab}>
        <.tabs_list>
          <.tabs_trigger value="a" phx-click="set_tab" phx-value-tab="a">A</.tabs_trigger>
          <.tabs_trigger value="b" phx-click="set_tab" phx-value-tab="b">B</.tabs_trigger>
        </.tabs_list>
        <.tabs_content value="a">Panel A</.tabs_content>
        <.tabs_content value="b">Panel B</.tabs_content>
      </.tabs>

  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  attr(:default_value, :string,
    required: true,
    doc: "Value of the tab that should be active on render."
  )

  attr(:class, :string,
    default: nil,
    doc: "Additional CSS classes applied to the outer wrapper."
  )

  attr(:rest, :global, doc: "HTML attributes forwarded to the wrapper div.")

  slot(:inner_block, required: true, doc: "tabs_list/1 followed by tabs_content/1 panels.")

  @doc """
  Renders the tabs root wrapper and exposes active-tab context via `:let`.

  Use `:let={ctx}` in sub-components to inherit the current `default_value`:

      <.tabs :let={ctx} default_value="tab1">
        <.tabs_list>
          <.tabs_trigger {ctx} value="tab1">Tab 1</.tabs_trigger>
        </.tabs_list>
        <.tabs_content {ctx} value="tab1">Content</.tabs_content>
      </.tabs>

  """
  def tabs(assigns) do
    ~H"""
    <div class={cn(["w-full", @class])} {@rest}>
      {render_slot(@inner_block, %{active: @default_value})}
    </div>
    """
  end

  attr(:class, :string,
    default: nil,
    doc: "Additional CSS classes applied to the tab list."
  )

  attr(:rest, :global, doc: "HTML attributes forwarded to the tablist div.")

  slot(:inner_block, required: true, doc: "One or more `tabs_trigger/1` components.")

  @doc """
  Renders the tab trigger list container (`role="tablist"`).
  """
  def tabs_list(assigns) do
    ~H"""
    <div
      role="tablist"
      class={cn(["inline-flex h-10 items-center justify-center rounded-md bg-muted p-1 text-muted-foreground", @class])}
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end

  attr(:value, :string,
    required: true,
    doc: "Unique value identifying this tab trigger."
  )

  attr(:active, :string,
    default: nil,
    doc: "Currently active tab value (inherited from tabs :let context)."
  )

  attr(:disabled, :boolean,
    default: false,
    doc: "When `true`, the trigger is non-interactive."
  )

  attr(:class, :string,
    default: nil,
    doc: "Additional CSS classes applied to the trigger button."
  )

  attr(:rest, :global,
    include: ~w(phx-click phx-value phx-value-tab),
    doc: "HTML attributes forwarded to the button."
  )

  slot(:inner_block, required: true, doc: "Trigger label content.")

  @doc """
  Renders a single tab trigger button.
  """
  def tabs_trigger(assigns) do
    assigns = assign(assigns, :selected, assigns.active == assigns.value)

    ~H"""
    <button
      type="button"
      role="tab"
      id={"trigger-#{@value}"}
      aria-selected={to_string(@selected)}
      aria-controls={"panel-#{@value}"}
      disabled={@disabled}
      class={cn([
        "inline-flex items-center justify-center whitespace-nowrap rounded-sm px-3 py-1.5",
        "text-sm font-medium ring-offset-background transition-all",
        "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2",
        @selected && "bg-background text-foreground shadow-sm",
        !@selected && "hover:bg-background/50",
        @disabled && "pointer-events-none opacity-50",
        @class
      ])}
      {@rest}
    >
      {render_slot(@inner_block)}
    </button>
    """
  end

  attr(:value, :string,
    required: true,
    doc: "Unique value matching a `tabs_trigger/1` value."
  )

  attr(:active, :string,
    default: nil,
    doc: "Currently active tab value (inherited from tabs :let context)."
  )

  attr(:class, :string,
    default: nil,
    doc: "Additional CSS classes applied to the panel."
  )

  attr(:rest, :global, doc: "HTML attributes forwarded to the panel div.")

  slot(:inner_block, required: true, doc: "Panel content.")

  @doc """
  Renders a tab content panel (`role="tabpanel"`).

  The panel is shown when its `:value` matches the tabs `:default_value`,
  and hidden otherwise (via Tailwind `hidden` class).
  """
  def tabs_content(assigns) do
    assigns = assign(assigns, :visible, assigns.active == assigns.value)

    ~H"""
    <div
      role="tabpanel"
      id={"panel-#{@value}"}
      aria-labelledby={"trigger-#{@value}"}
      class={cn(["mt-2 ring-offset-background focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2", !@visible && "hidden", @class])}
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end
end
