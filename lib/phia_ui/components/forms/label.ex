defmodule PhiaUi.Components.Label do
  @moduledoc """
  Accessible label component for form inputs.

  Renders a `<label>` element with optional required indicator and full Tailwind
  styling. Associates with inputs via the `for` attribute.

  ## Example

      <.label for="email">Email address</.label>
      <.label for="password" required={true}>Password</.label>
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  attr(:for, :string, default: nil, doc: "The input element ID to associate this label with")

  attr(:required, :boolean,
    default: false,
    doc: "When true, renders a red asterisk to indicate the field is required"
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:rest, :global, doc: "HTML attributes forwarded to the label element")

  slot(:inner_block, required: true, doc: "Label text or content")

  @doc """
  Renders an accessible `<label>` element.

  ## Examples

      <.label for="email">Email</.label>
      <.label for="password" required={true}>Password</.label>
  """
  def label(assigns) do
    ~H"""
    <label
      for={@for}
      class={cn(["text-sm font-medium leading-none peer-disabled:cursor-not-allowed peer-disabled:opacity-70", @class])}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
      <span :if={@required} aria-hidden="true" class="text-destructive ml-1">*</span>
    </label>
    """
  end
end
