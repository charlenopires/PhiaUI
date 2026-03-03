defmodule PhiaUi.Components.Toggle do
  @moduledoc """
  Toggle button component for PhiaUI.

  A two-state button with `aria-pressed` semantics. Use it for toolbar
  actions (Bold, Italic, Underline) or any on/off feature that the user
  activates by clicking.

  State is owned by the server — pass `:pressed` from your LiveView assigns
  and update it via `phx-click`. For purely client-side toggling, wire up
  `Phoenix.LiveView.JS` instead.

  ## Examples

      <%!-- Basic unpressed --%>
      <.toggle pressed={false} phx-click="toggle_bold">
        B
      </.toggle>

      <%!-- Pressed state --%>
      <.toggle pressed={@bold} phx-click="toggle_bold">
        <.icon name="bold" size="sm" />
      </.toggle>

      <%!-- Outline variant --%>
      <.toggle pressed={@italic} variant="outline" phx-click="toggle_italic">
        I
      </.toggle>

      <%!-- Small size --%>
      <.toggle pressed={false} size="sm" phx-click="toggle_strike">
        S
      </.toggle>

  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  attr(:pressed, :boolean,
    required: true,
    doc: "Whether the toggle is in the pressed (active) state."
  )

  attr(:variant, :string,
    default: "default",
    values: ~w(default outline),
    doc: "Visual style: \"default\" (ghost-like) or \"outline\" (bordered)."
  )

  attr(:size, :string,
    default: "default",
    values: ~w(default sm lg),
    doc: "Size of the toggle button: \"default\", \"sm\", or \"lg\"."
  )

  attr(:class, :string,
    default: nil,
    doc: "Additional CSS classes applied to the button."
  )

  attr(:rest, :global,
    include: ~w(disabled form name value type phx-click phx-value),
    doc: "HTML attributes forwarded to the button element."
  )

  slot(:inner_block, required: true, doc: "Toggle label or icon content.")

  @doc """
  Renders a pressable toggle button with `aria-pressed` state.
  """
  def toggle(assigns) do
    ~H"""
    <button
      type="button"
      aria-pressed={to_string(@pressed)}
      class={cn([base_class(), variant_class(@variant, @pressed), size_class(@size), @class])}
      {@rest}
    >
      {render_slot(@inner_block)}
    </button>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  defp base_class do
    "inline-flex items-center justify-center rounded-md text-sm font-medium " <>
      "transition-colors focus-visible:outline-none focus-visible:ring-2 " <>
      "focus-visible:ring-ring focus-visible:ring-offset-2 " <>
      "disabled:pointer-events-none disabled:opacity-50"
  end

  defp variant_class("default", false),
    do: "bg-transparent hover:bg-muted hover:text-muted-foreground"

  defp variant_class("default", true), do: "bg-accent text-accent-foreground"

  defp variant_class("outline", false),
    do: "border border-input bg-transparent hover:bg-accent hover:text-accent-foreground"

  defp variant_class("outline", true), do: "border border-input bg-accent text-accent-foreground"

  defp size_class("default"), do: "h-10 px-3"
  defp size_class("sm"), do: "h-9 px-2.5 text-xs"
  defp size_class("lg"), do: "h-11 px-5"
end
