defmodule PhiaUi.Components.Slider do
  @moduledoc """
  Range slider component for continuous numeric value selection.

  `slider/1` is a CSS-only `input[type=range]` with semantic Tailwind tokens and
  full WAI-ARIA attributes. `form_slider/1` integrates it with `Phoenix.HTML.FormField`
  and Ecto changesets, adding label, description, and error display.

  No JavaScript is required — the browser handles all drag, click, and keyboard
  interaction natively.

  ## Enhancements

  - `marks` — renders tick marks + labels below the track at specified values
  - `vertical` — rotates the slider 90° for vertical orientation
  - `show_value` — renders a badge above the thumb showing the current value

  ## Examples

      <%!-- Basic slider --%>
      <.slider value={50} phx-change="update_value" name="value" />

      <%!-- With marks --%>
      <.slider value={@speed} min={0} max={100} step={25}
               marks={[%{value: 0, label: "Slow"}, %{value: 100, label: "Fast"}]}
               phx-change="set_speed" name="speed" />

      <%!-- Vertical orientation --%>
      <.slider value={@vol} vertical={true} phx-change="set_vol" name="vol" />

      <%!-- Show current value badge --%>
      <.slider value={@size} min={8} max={72} show_value={true} phx-change="set_size" name="size" />
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  # ---------------------------------------------------------------------------
  # slider/1 — standalone
  # ---------------------------------------------------------------------------

  attr(:value, :integer, default: 0, doc: "The current value of the slider.")
  attr(:min, :integer, default: 0, doc: "Minimum allowed value.")
  attr(:max, :integer, default: 100, doc: "Maximum allowed value.")
  attr(:step, :integer, default: 1, doc: "Step increment between valid values.")

  attr(:disabled, :boolean,
    default: false,
    doc: "When `true`, disables the slider."
  )

  attr(:marks, :list,
    default: [],
    doc: """
    List of tick mark maps: `[%{value: 0, label: \"Min\"}, %{value: 100, label: \"Max\"}]`.
    Marks are positioned below the track at their corresponding percentage.
    """
  )

  attr(:vertical, :boolean,
    default: false,
    doc: "When `true`, renders the slider in vertical orientation (rotated 90°)."
  )

  attr(:show_value, :boolean,
    default: false,
    doc: "When `true`, renders a badge above the thumb showing the current value."
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes.")

  attr(:rest, :global,
    include: ~w(phx-change phx-blur name id),
    doc: "HTML attributes forwarded to the `<input>` element."
  )

  @doc """
  Renders a range slider input.

  When `marks`, `vertical`, or `show_value` are used the slider is wrapped in
  a positioned `<div>` container. Otherwise a bare `<input>` is rendered
  (backward-compatible with existing usage).
  """
  def slider(assigns) do
    needs_wrapper = assigns.marks != [] or assigns.vertical or assigns.show_value
    assigns = assign(assigns, :needs_wrapper, needs_wrapper)

    ~H"""
    <%= if @needs_wrapper do %>
      <div class={cn([wrapper_class(@vertical), not @vertical && @marks != [] && "pb-6"])}>
        <%= if @show_value do %>
          <% pct = value_pct(@value, @min, @max) %>
          <div class="relative mb-1">
            <span
              class="absolute -translate-x-1/2 -top-1 bg-foreground text-background text-xs px-1.5 py-0.5 rounded"
              style={"left: #{pct}%"}
            >
              {@value}
            </span>
          </div>
        <% end %>
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
          class={cn(["phia-touch-target", slider_input_class(@vertical), @disabled && "opacity-50 cursor-not-allowed", @class])}
          {@rest}
        />
        <%= if @marks != [] and not @vertical do %>
          <div class="relative mt-1">
            <%= for mark <- @marks do %>
              <% mpct = value_pct(Map.get(mark, :value, 0), @min, @max) %>
              <span
                class="absolute -translate-x-1/2 flex flex-col items-center"
                style={"left: #{mpct}%"}
              >
                <span class="w-px h-1.5 bg-border block"></span>
                <span class="text-xs text-muted-foreground mt-0.5">{Map.get(mark, :label, "")}</span>
              </span>
            <% end %>
          </div>
        <% end %>
      </div>
    <% else %>
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
        class={cn(["phia-touch-target", slider_class(), @disabled && "opacity-50 cursor-not-allowed", @class])}
        {@rest}
      />
    <% end %>
    """
  end

  # ---------------------------------------------------------------------------
  # form_slider/1 — FormField-integrated
  # ---------------------------------------------------------------------------

  attr(:field, Phoenix.HTML.FormField,
    required: true,
    doc: "A `Phoenix.HTML.FormField` struct."
  )

  attr(:label, :string, default: nil, doc: "Text rendered in a `<label>` above the slider.")
  attr(:description, :string, default: nil, doc: "Helper text rendered below the label.")
  attr(:min, :integer, default: 0, doc: "Minimum allowed value.")
  attr(:max, :integer, default: 100, doc: "Maximum allowed value.")
  attr(:step, :integer, default: 1, doc: "Step increment between valid values.")

  attr(:marks, :list,
    default: [],
    doc: "List of tick mark maps: `[%{value: N, label: \"text\"}]`."
  )

  attr(:vertical, :boolean, default: false, doc: "Vertical orientation.")
  attr(:show_value, :boolean, default: false, doc: "Show current value badge above thumb.")

  attr(:class, :string, default: nil, doc: "Additional CSS classes.")

  attr(:rest, :global,
    include: ~w(phx-change phx-blur phx-debounce disabled),
    doc: "HTML attributes forwarded to the `<input>` element."
  )

  @doc """
  Renders a form-integrated slider with label, description, and changeset errors.
  """
  def form_slider(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    assigns =
      assigns
      |> assign(:errors, Enum.map(field.errors, &translate_error/1))
      |> assign_new(:id, fn -> field.id end)
      |> assign_new(:name, fn -> field.name end)
      |> assign_new(:value, fn -> field.value || 0 end)

    ~H"""
    <div class={cn(["space-y-2", @vertical && "inline-flex flex-col"])}>
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
      <div :if={@show_value} class="relative mb-1">
        <% pct = value_pct(@value, @min, @max) %>
        <span
          class="absolute -translate-x-1/2 -top-1 bg-foreground text-background text-xs px-1.5 py-0.5 rounded"
          style={"left: #{pct}%"}
        >
          {@value}
        </span>
      </div>
      <div class={cn([not @vertical && @marks != [] && "pb-6 relative"])}>
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
          class={cn([
            "phia-touch-target",
            @vertical && slider_input_class(true) || slider_class(),
            @errors != [] && "accent-destructive",
            @class
          ])}
          {@rest}
        />
        <%= if @marks != [] and not @vertical do %>
          <div class="relative mt-1">
            <%= for mark <- @marks do %>
              <% mpct = value_pct(Map.get(mark, :value, 0), @min, @max) %>
              <span
                class="absolute -translate-x-1/2 flex flex-col items-center"
                style={"left: #{mpct}%"}
              >
                <span class="w-px h-1.5 bg-border block"></span>
                <span class="text-xs text-muted-foreground mt-0.5">
                  {Map.get(mark, :label, "")}
                </span>
              </span>
            <% end %>
          </div>
        <% end %>
      </div>
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

  defp slider_input_class(true = _vertical) do
    "h-32 w-2 cursor-pointer accent-primary bg-secondary rounded-full " <>
      "-rotate-90 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring " <>
      "focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50"
  end

  defp slider_input_class(_), do: slider_class()

  defp wrapper_class(true = _vertical), do: "inline-flex items-center justify-center"
  defp wrapper_class(_), do: "relative"

  defp value_pct(value, min, max) when max > min do
    Float.round((value - min) / (max - min) * 100, 1)
  end

  defp value_pct(_, _, _), do: 0

  defp translate_error({msg, opts}) do
    Enum.reduce(opts, msg, fn
      {key, value}, acc when is_binary(acc) ->
        String.replace(acc, "%{#{key}}", to_string(value))

      _other, acc ->
        acc
    end)
  end
end
