defmodule PhiaUi.Components.RadioGroup do
  @moduledoc """
  RadioGroup component for PhiaUI.

  Renders a group of mutually-exclusive radio buttons with custom styling.
  The visual indicator replaces the default browser radio appearance with a
  themed circle using Tailwind semantic tokens.

  Fully accessible: `role="radiogroup"` on the container, native
  `<input type="radio">` elements (keyboard navigation and screen readers
  work out-of-the-box), and `<label>` elements associated by `for`/`id`.

  Use `radio_group/1` + `radio_group_item/1` for standalone usage, or
  `form_radio_group/1` for integration with `Phoenix.HTML.FormField`.

  ## Examples

      <%!-- Standalone --%>
      <.radio_group :let={group} value={@plan} name="plan" phx-change="set_plan">
        <.radio_group_item value="free"  label="Free"  {group} />
        <.radio_group_item value="pro"   label="Pro"   {group} />
        <.radio_group_item value="team"  label="Team"  {group} />
      </.radio_group>

      <%!-- Horizontal --%>
      <.radio_group :let={group} value={@size} name="size" orientation="horizontal">
        <.radio_group_item value="sm" label="Small" {group} />
        <.radio_group_item value="lg" label="Large" {group} />
      </.radio_group>

      <%!-- Form-integrated --%>
      <.form_radio_group
        field={@form[:plan]}
        label="Subscription plan"
        options={[{"Free", "free"}, {"Pro", "pro"}, {"Team", "team"}]}
      />

  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  attr(:value, :string,
    default: nil,
    doc: "Currently selected value. The matching item will be checked."
  )

  attr(:name, :string,
    default: nil,
    doc: "HTML `name` attribute shared by all radio inputs in the group."
  )

  attr(:orientation, :string,
    default: "vertical",
    values: ~w(vertical horizontal),
    doc: "Layout direction: \"vertical\" (default, stacked) or \"horizontal\" (inline)."
  )

  attr(:class, :string,
    default: nil,
    doc: "Additional CSS classes applied to the group container."
  )

  attr(:rest, :global,
    include: ~w(phx-change phx-value),
    doc: "HTML attributes forwarded to the group div."
  )

  slot(:inner_block, required: true, doc: "One or more `radio_group_item/1` components.")

  @doc """
  Renders a radio button group container.

  Exposes group context via `:let` so items receive their shared name and
  checked state automatically:

      <.radio_group :let={group} value={@selected} name="fruit">
        <.radio_group_item value="apple" label="Apple" {group} />
      </.radio_group>

  """
  def radio_group(assigns) do
    ~H"""
    <div
      role="radiogroup"
      class={cn(["flex gap-2", orientation_class(@orientation), @class])}
      {@rest}
    >
      {render_slot(@inner_block, %{group_value: @value, name: @name})}
    </div>
    """
  end

  attr(:value, :string,
    required: true,
    doc: "The value this radio button represents."
  )

  attr(:label, :string,
    required: true,
    doc: "Label text displayed next to the radio indicator."
  )

  attr(:name, :string,
    default: nil,
    doc: "HTML name attribute. Inherit from group context via `:let`."
  )

  attr(:group_value, :string,
    default: nil,
    doc: "The group's current value. Determines whether this item is checked."
  )

  attr(:disabled, :boolean,
    default: false,
    doc: "When `true`, disables this radio item."
  )

  attr(:class, :string,
    default: nil,
    doc: "Additional CSS classes applied to the item wrapper."
  )

  @doc """
  Renders a single radio button item within a `radio_group/1`.
  """
  def radio_group_item(assigns) do
    assigns =
      assign(assigns,
        checked: assigns.group_value == assigns.value,
        input_id: "radio_#{assigns.name}_#{assigns.value}"
      )

    ~H"""
    <label
      for={@input_id}
      class={cn(["flex items-center gap-2 cursor-pointer", @disabled && "cursor-not-allowed opacity-50", @class])}
    >
      <input
        type="radio"
        id={@input_id}
        name={@name}
        value={@value}
        checked={@checked}
        disabled={@disabled}
        class="sr-only peer"
      />
      <span class={cn([
        "inline-flex h-4 w-4 items-center justify-center rounded-full border border-primary",
        "transition-colors peer-focus-visible:ring-2 peer-focus-visible:ring-ring peer-focus-visible:ring-offset-2"
      ])}>
        <span :if={@checked} class="h-2 w-2 rounded-full bg-primary block"></span>
      </span>
      <span class="text-sm leading-none">{@label}</span>
    </label>
    """
  end

  attr(:field, Phoenix.HTML.FormField,
    required: true,
    doc: "`Phoenix.HTML.FormField` struct from a form."
  )

  attr(:options, :list,
    default: [],
    doc: """
    List of `{label, value}` tuples or `[label: ..., value: ...]` keyword lists.
    Each entry becomes a `radio_group_item/1`.
    """
  )

  attr(:label, :string,
    default: nil,
    doc: "Optional legend/label for the group."
  )

  attr(:orientation, :string,
    default: "vertical",
    values: ~w(vertical horizontal),
    doc: "Layout direction forwarded to the group container."
  )

  attr(:class, :string,
    default: nil,
    doc: "Additional CSS classes applied to the group container."
  )

  @doc """
  Renders a radio group integrated with `Phoenix.HTML.FormField`.

  Options are provided as a list of `{label, value}` tuples. The field's
  current value determines which option is checked.
  """
  def form_radio_group(assigns) do
    assigns = assign(assigns, :group_value, to_string(assigns.field.value || ""))

    ~H"""
    <div class={@class}>
      <p :if={@label} class="text-sm font-medium mb-2">{@label}</p>
      <.radio_group value={@group_value} name={@field.name} orientation={@orientation}>
        <.radio_group_item
          :for={{opt_label, opt_value} <- @options}
          value={to_string(opt_value)}
          label={opt_label}
          name={@field.name}
          group_value={@group_value}
        />
      </.radio_group>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  defp orientation_class("vertical"), do: "flex-col"
  defp orientation_class("horizontal"), do: "flex-row flex-wrap"
end
