defmodule PhiaUi.Components.Popconfirm do
  @moduledoc """
  Popconfirm — inline confirmation popup attached to a trigger element.

  Inspired by Ant Design `Popconfirm`. Uses Phoenix `JS.toggle/1` — no custom JS hook.
  Shows a small panel with a warning icon, title, optional description,
  and confirm/cancel buttons.

  ## Examples

      <.popconfirm id="delete-confirm" title="Delete this item?" placement={:top}>
        <:trigger>
          <.button variant={:destructive}>Delete</.button>
        </:trigger>
      </.popconfirm>

      <.popconfirm
        id="archive-confirm"
        title="Archive record?"
        description="This action can be undone later."
        confirm_label="Archive"
        cancel_label="Keep"
        placement={:bottom}
      >
        <:trigger><.button>Archive</.button></:trigger>
      </.popconfirm>
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]
  import PhiaUi.Components.Icon, only: [icon: 1]
  import PhiaUi.Components.Button, only: [button: 1]

  alias Phoenix.LiveView.JS

  attr(:id, :string, required: true, doc: "Unique ID — used to reference the panel via JS.toggle.")

  attr(:title, :string,
    required: true,
    doc: "Confirmation question shown in the panel header."
  )

  attr(:description, :string,
    default: nil,
    doc: "Optional secondary description."
  )

  attr(:placement, :atom,
    default: :top,
    values: [:top, :bottom, :left, :right],
    doc: "Position of the panel relative to the trigger."
  )

  attr(:confirm_label, :string, default: "Yes", doc: "Label for the confirm button.")
  attr(:cancel_label, :string, default: "No", doc: "Label for the cancel button.")

  attr(:confirm_variant, :atom,
    default: :destructive,
    doc: "Button variant for confirm action."
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes for the root element.")
  attr(:rest, :global, doc: "HTML attributes forwarded to the root `<div>`.")

  slot(:trigger, required: true, doc: "Element that opens the popconfirm panel on click.")

  def popconfirm(assigns) do
    panel_id = "#{assigns.id}-panel"
    assigns = assign(assigns, :panel_id, panel_id)

    ~H"""
    <div class={cn(["relative inline-block", @class])} {@rest}>
      <%!-- Trigger --%>
      <div
        phx-click={JS.toggle(to: "##{@panel_id}")}
        class="cursor-pointer"
      >
        {render_slot(@trigger)}
      </div>

      <%!-- Panel --%>
      <div
        id={@panel_id}
        class={cn([
          "hidden absolute z-50 w-72 rounded-lg border border-border bg-popover p-4 shadow-md",
          panel_class(@placement)
        ])}
        role="dialog"
        aria-modal="false"
        aria-label={@title}
      >
        <div class="flex gap-3">
          <.icon name="triangle-alert" class="h-4 w-4 shrink-0 text-amber-500 mt-0.5" />
          <div class="flex-1 space-y-1">
            <p class="text-sm font-medium text-foreground">{@title}</p>
            <p :if={@description} class="text-xs text-muted-foreground">{@description}</p>
          </div>
        </div>
        <div class="mt-3 flex justify-end gap-2">
          <.button
            size={:sm}
            variant={:outline}
            phx-click={JS.hide(to: "##{@panel_id}")}
          >
            {@cancel_label}
          </.button>
          <.button
            size={:sm}
            variant={@confirm_variant}
          >
            {@confirm_label}
          </.button>
        </div>
      </div>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers — pattern-matched placement classes
  # ---------------------------------------------------------------------------

  defp panel_class(:top), do: "bottom-full mb-2 left-0"
  defp panel_class(:bottom), do: "top-full mt-2 left-0"
  defp panel_class(:left), do: "right-full mr-2 top-0"
  defp panel_class(:right), do: "left-full ml-2 top-0"
end
