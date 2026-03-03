defmodule PhiaUi.Components.Accordion do
  @moduledoc """
  Accordion component using exclusively `Phoenix.LiveView.JS` — no JS Hooks required.

  Supports two interaction modes:
  - `:single` — only one item open at a time; opening one closes all others.
  - `:multiple` — multiple items can be open simultaneously.

  ## Sub-components

  | Function              | Element  | Purpose                                 |
  |-----------------------|----------|-----------------------------------------|
  | `accordion/1`         | `div`    | Root container                          |
  | `accordion_item/1`    | `div`    | Per-item wrapper (border + spacing)     |
  | `accordion_trigger/1` | `button` | Toggle button with chevron + ARIA attrs |
  | `accordion_content/1` | `div`    | Collapsible content panel               |

  ## Example — single mode

      <.accordion id="faq" type={:single}>
        <.accordion_item value="q1" type={:single} accordion_id="faq">
          <.accordion_trigger value="q1" type={:single} accordion_id="faq">
            What is PhiaUI?
          </.accordion_trigger>
          <.accordion_content value="q1">
            A Phoenix LiveView component library inspired by shadcn/ui.
          </.accordion_content>
        </.accordion_item>
      </.accordion>

  ## Example — multiple mode

      <.accordion id="faq" type={:multiple}>
        <.accordion_item value="q1" type={:multiple} accordion_id="faq">
          <.accordion_trigger value="q1" type={:multiple} accordion_id="faq">
            Question 1
          </.accordion_trigger>
          <.accordion_content value="q1">Answer 1</.accordion_content>
        </.accordion_item>
        <.accordion_item value="q2" type={:multiple} accordion_id="faq">
          <.accordion_trigger value="q2" type={:multiple} accordion_id="faq">
            Question 2
          </.accordion_trigger>
          <.accordion_content value="q2">Answer 2</.accordion_content>
        </.accordion_item>
      </.accordion>
  """

  use Phoenix.Component

  alias Phoenix.LiveView.JS

  import PhiaUi.ClassMerger, only: [cn: 1]

  # ---------------------------------------------------------------------------
  # accordion/1
  # ---------------------------------------------------------------------------

  attr :id, :string, default: nil, doc: "Unique ID for the root container"

  attr :type, :atom,
    values: [:single, :multiple],
    default: :single,
    doc: "Interaction mode: :single allows one open item, :multiple allows many"

  attr :class, :string, default: nil, doc: "Additional CSS classes"
  attr :rest, :global, doc: "HTML attributes forwarded to the container div"

  slot :inner_block, required: true, doc: "accordion_item sub-components"

  @doc "Renders the accordion root container."
  def accordion(assigns) do
    ~H"""
    <div id={@id} class={cn(["w-full", @class])} {@rest}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # accordion_item/1
  # ---------------------------------------------------------------------------

  attr :value, :string, required: true, doc: "Unique identifier for this item"

  attr :type, :atom,
    values: [:single, :multiple],
    default: :single,
    doc: "Inherited from the parent accordion — controls toggle behaviour"

  attr :accordion_id, :string,
    default: nil,
    doc: "ID of the parent accordion — required for type: :single exclusivity"

  attr :class, :string, default: nil, doc: "Additional CSS classes"
  attr :rest, :global, doc: "HTML attributes forwarded to the wrapper div"

  slot :inner_block, required: true, doc: "accordion_trigger and accordion_content"

  @doc "Renders an accordion item wrapper."
  def accordion_item(assigns) do
    ~H"""
    <div class={cn(["border-b", @class])} {@rest}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # accordion_trigger/1
  # ---------------------------------------------------------------------------

  attr :value, :string, required: true, doc: "Must match the parent accordion_item :value"

  attr :type, :atom,
    values: [:single, :multiple],
    default: :single,
    doc: "Inherited from the parent accordion — controls the JS toggle strategy"

  attr :accordion_id, :string,
    default: nil,
    doc: "ID of the parent accordion — required for type: :single exclusivity"

  attr :class, :string, default: nil, doc: "Additional CSS classes"
  attr :rest, :global, doc: "HTML attributes forwarded to the button element"

  slot :inner_block, required: true, doc: "Trigger label or icon"

  @doc "Renders the accordion trigger button with LiveView.JS-powered toggle."
  def accordion_trigger(assigns) do
    assigns = assign(assigns, :on_click, build_toggle_js(assigns.type, assigns.value, assigns.accordion_id))

    ~H"""
    <button
      id={"accordion-trigger-#{@value}"}
      type="button"
      aria-expanded="false"
      aria-controls={"accordion-content-#{@value}"}
      phx-click={@on_click}
      data-accordion-trigger
      class={cn([
        "flex flex-1 w-full items-center justify-between py-4 font-medium",
        "transition-all hover:underline text-left",
        @class
      ])}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
      <svg
        id={"chevron-#{@value}"}
        xmlns="http://www.w3.org/2000/svg"
        width="24"
        height="24"
        viewBox="0 0 24 24"
        fill="none"
        stroke="currentColor"
        stroke-width="2"
        stroke-linecap="round"
        stroke-linejoin="round"
        class="h-4 w-4 shrink-0 transition-transform duration-200"
        data-chevron
        aria-hidden="true"
      >
        <path d="m6 9 6 6 6-6" />
      </svg>
    </button>
    """
  end

  # ---------------------------------------------------------------------------
  # accordion_content/1
  # ---------------------------------------------------------------------------

  attr :value, :string, required: true, doc: "Must match the parent accordion_item :value"
  attr :class, :string, default: nil, doc: "Additional CSS classes"
  attr :rest, :global, doc: "HTML attributes forwarded to the content div"

  slot :inner_block, required: true, doc: "Content shown when the item is open"

  @doc "Renders the collapsible accordion content panel."
  def accordion_content(assigns) do
    ~H"""
    <div
      id={"accordion-content-#{@value}"}
      style="display: none;"
      class={cn(["overflow-hidden transition-all duration-200", @class])}
      data-accordion-content
      {@rest}
    >
      <div class="pb-4 pt-0">
        <%= render_slot(@inner_block) %>
      </div>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  # Single mode: collapse all items in the accordion, then expand only the
  # clicked one. This also resets all chevrons and aria-expanded attributes.
  defp build_toggle_js(:single, value, accordion_id) when not is_nil(accordion_id) do
    JS.hide(to: "##{accordion_id} [data-accordion-content]")
    |> JS.show(to: "#accordion-content-#{value}")
    |> JS.set_attribute({"aria-expanded", "false"},
      to: "##{accordion_id} [data-accordion-trigger]"
    )
    |> JS.set_attribute({"aria-expanded", "true"},
      to: "#accordion-trigger-#{value}"
    )
    |> JS.remove_class("rotate-180",
      to: "##{accordion_id} [data-chevron]"
    )
    |> JS.add_class("rotate-180", to: "#chevron-#{value}")
  end

  # Multiple mode (or single without accordion_id): toggle the individual item.
  defp build_toggle_js(_type, value, _accordion_id) do
    JS.toggle(to: "#accordion-content-#{value}")
    |> JS.toggle_class("rotate-180", to: "#chevron-#{value}")
  end
end
