defmodule PhiaUi.Components.InputAddon do
  @moduledoc """
  InputAddon component — wraps an input with optional prefix and suffix decorators.

  Renders a flex container that visually attaches a prefix or suffix element
  (currency symbol, units, button, icon) to an input field. Focus ring is applied
  at the container level so the whole group lights up when the inner input is focused.

  ## Examples

      <%!-- Currency prefix --%>
      <.input_addon>
        <:prefix>$</:prefix>
        <input type="number" placeholder="Amount" />
      </.input_addon>

      <%!-- Domain suffix --%>
      <.input_addon>
        <input type="text" placeholder="your-handle" />
        <:suffix>.com</:suffix>
      </.input_addon>

      <%!-- Both prefix and suffix --%>
      <.input_addon>
        <:prefix>https://</:prefix>
        <input type="text" placeholder="example" />
        <:suffix>.com</:suffix>
      </.input_addon>
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  attr(:class, :string, default: nil, doc: "Additional CSS classes merged via cn/1")

  attr(:disabled, :boolean,
    default: false,
    doc: "When true, renders the wrapper as visually disabled"
  )

  attr(:rest, :global, doc: "HTML attributes forwarded to the wrapper element")

  slot(:prefix, doc: "Content rendered before the input (currency symbol, icon, text)")
  slot(:suffix, doc: "Content rendered after the input (units, icon, button)")
  slot(:inner_block, required: true, doc: "The actual input element")

  @doc """
  Renders an input with optional prefix and/or suffix decorators.

  ## Examples

      <.input_addon>
        <:prefix>$</:prefix>
        <input type="number" />
      </.input_addon>
  """
  def input_addon(assigns) do
    ~H"""
    <div
      class={cn([
        "flex h-10 items-stretch rounded-md border border-input bg-background overflow-hidden",
        "focus-within:ring-2 focus-within:ring-ring focus-within:ring-offset-2",
        @disabled && "cursor-not-allowed opacity-50",
        @class
      ])}
      {@rest}
    >
      <div
        :if={@prefix != []}
        class="flex items-center px-3 border-r border-input bg-muted text-sm text-muted-foreground shrink-0"
      >
        {render_slot(@prefix)}
      </div>
      <div class="flex flex-1 min-w-0">
        {render_slot(@inner_block)}
      </div>
      <div
        :if={@suffix != []}
        class="flex items-center px-3 border-l border-input bg-muted text-sm text-muted-foreground shrink-0"
      >
        {render_slot(@suffix)}
      </div>
    </div>
    """
  end
end
