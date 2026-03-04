defmodule PhiaUi.Components.Slider do
  @moduledoc """
  Slider component for range value selection.

  CSS-only `input[type=range]` with semantic Tailwind tokens and full
  WAI-ARIA support. Works standalone or integrated with `Phoenix.HTML.FormField`
  via `form_slider/1`.

  ## Examples

      <.slider value={50} />

      <.slider value={@volume} min={0} max={100} step={5}
               phx-change="volume_changed" />

      <.slider value={@brightness} disabled={true} />

      <%!-- Form-integrated --%>
      <.form_slider field={@form[:rating]} label="Rating" />
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  attr(:value, :integer, default: 0, doc: "Current value of the slider")
  attr(:min, :integer, default: 0, doc: "Minimum value")
  attr(:max, :integer, default: 100, doc: "Maximum value")
  attr(:step, :integer, default: 1, doc: "Step increment")
  attr(:disabled, :boolean, default: false, doc: "Whether the slider is disabled")
  attr(:class, :string, default: nil, doc: "Additional CSS classes")

  attr(:rest, :global,
    include: ~w(phx-change phx-blur name id),
    doc: "HTML attributes forwarded to input"
  )

  @doc """
  Renders a range slider input.

  Uses native `input[type=range]` with WAI-ARIA attributes and styled with
  semantic Tailwind v4 tokens. The slider is CSS-only — no JS hook required.
  """
  def slider(assigns) do
    ~H"""
    <input
      type="range"
      value={@value}
      min={@min}
      max={@max}
      step={@step}
      disabled={@disabled}
      role="slider"
      aria-valuenow={@value}
      aria-valuemin={@min}
      aria-valuemax={@max}
      class={cn([slider_class(), @disabled && "opacity-50 cursor-not-allowed", @class])}
      {@rest}
    />
    """
  end

  attr(:field, Phoenix.HTML.FormField, required: true, doc: "A Phoenix.HTML.FormField struct")
  attr(:label, :string, default: nil, doc: "Label text")
  attr(:description, :string, default: nil, doc: "Helper text")
  attr(:min, :integer, default: 0, doc: "Minimum value")
  attr(:max, :integer, default: 100, doc: "Maximum value")
  attr(:step, :integer, default: 1, doc: "Step increment")
  attr(:class, :string, default: nil, doc: "Additional CSS classes")

  attr(:rest, :global,
    include: ~w(phx-change phx-blur phx-debounce disabled),
    doc: "HTML attributes forwarded to input"
  )

  @doc """
  Renders a form-integrated slider with label, description, and errors.
  """
  def form_slider(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    assigns =
      assigns
      |> assign(:errors, Enum.map(field.errors, &translate_error/1))
      |> assign_new(:id, fn -> field.id end)
      |> assign_new(:name, fn -> field.name end)
      |> assign_new(:value, fn -> field.value || 0 end)

    ~H"""
    <div class="space-y-2">
      <label
        :if={@label}
        for={@id}
        class="text-sm font-medium leading-none peer-disabled:cursor-not-allowed peer-disabled:opacity-70"
      >
        {@label}
      </label>
      <p :if={@description} class="text-sm text-muted-foreground">
        {@description}
      </p>
      <input
        type="range"
        id={@id}
        name={@name}
        value={@value}
        min={@min}
        max={@max}
        step={@step}
        role="slider"
        aria-valuenow={@value}
        aria-valuemin={@min}
        aria-valuemax={@max}
        class={cn([slider_class(), @errors != [] && "accent-destructive", @class])}
        {@rest}
      />
      <p :for={error <- @errors} class="text-sm font-medium text-destructive">
        {error}
      </p>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  defp slider_class do
    "w-full h-2 cursor-pointer accent-primary bg-secondary rounded-full " <>
      "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring " <>
      "focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50"
  end

  defp translate_error({msg, opts}) do
    Enum.reduce(opts, msg, fn
      {key, value}, acc when is_binary(acc) ->
        String.replace(acc, "%{#{key}}", to_string(value))

      _other, acc ->
        acc
    end)
  end
end
