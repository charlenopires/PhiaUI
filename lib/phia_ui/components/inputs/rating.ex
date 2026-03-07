defmodule PhiaUi.Components.Rating do
  @moduledoc """
  Star Rating component for PhiaUI.

  CSS-only implementation using native radio inputs and SVG star icons.
  Supports read-only display and interactive selection. Form integration
  is available via `form_rating/1`.

  ## Examples

      <%!-- Display only --%>
      <.rating value={4} readonly={true} />

      <%!-- Interactive --%>
      <.rating value={@rating} phx-change="set_rating" />

      <%!-- Form-integrated --%>
      <.form_rating field={@form[:rating]} label="Rating" />

      <%!-- Large size --%>
      <.rating value={3} size="lg" />

      <%!-- Half-star display --%>
      <.rating value={3.5} half={true} readonly={true} />

      <%!-- Heart icon --%>
      <.rating value={4} icon={:heart} />

      <%!-- With hover labels --%>
      <.rating value={3} labels={["Poor", "Fair", "Good", "Great", "Excellent"]} />
  """

  use Phoenix.Component
  import PhiaUi.ClassMerger, only: [cn: 1]

  attr(:value, :any, default: 0, doc: "Current rating value (0 to max). Float when half=true.")
  attr(:max, :integer, default: 5, doc: "Maximum number of stars")
  attr(:readonly, :boolean, default: false, doc: "Whether the rating is read-only")
  attr(:size, :string, default: "default", values: ~w(sm default lg), doc: "Size of the stars")
  attr(:name, :string, default: "rating", doc: "Input name attribute")
  attr(:half, :boolean, default: false, doc: "Enable half-star display for float values")
  attr(:icon, :atom, values: [:star, :heart, :thumb], default: :star, doc: "Icon style")
  attr(:labels, :list, default: [], doc: "Hover label strings per position (e.g. ['Poor','Good'])")
  attr(:class, :string, default: nil, doc: "Additional CSS classes")

  attr(:rest, :global,
    include: ~w(phx-change phx-blur id),
    doc: "HTML attributes forwarded to the fieldset"
  )

  @doc """
  Renders a star rating with radio inputs.

  When `half=false` (default): integer-only values, simple SVG path per star.
  When `half=true`: float values display with a clip overlay (50% fill for .5 values).
  The `icon` attr switches the SVG shape to `:star`, `:heart`, or `:thumb`.
  The `labels` list adds `title` tooltip text to each star label.
  """
  def rating(assigns) do
    assigns = assign(assigns, :stars, Enum.to_list(1..assigns.max))

    ~H"""
    <fieldset
      role="radiogroup"
      class={cn(["flex items-center gap-0.5", @class])}
      aria-label="Rating"
      {@rest}
    >
      <%= for star <- @stars do %>
        <% hover_label = Enum.at(@labels, star - 1) %>
        <label
          class={cn(["cursor-pointer", @readonly && "cursor-default", star_label_class(@size)])}
          title={hover_label}
        >
          <input
            type="radio"
            name={@name}
            value={star}
            checked={star <= int_value(@value)}
            disabled={@readonly}
            class="sr-only peer"
            aria-label={"#{star} star#{if star == 1, do: "", else: "s"}"}
          />
          <%= if @half do %>
            <%# Overlay approach: background (muted) + foreground (yellow) clipped to fill_pct % %>
            <span
              class={cn(["relative block pointer-events-none", star_icon_class(@size)])}
            >
              <svg
                xmlns="http://www.w3.org/2000/svg"
                viewBox="0 0 24 24"
                fill="currentColor"
                class={cn(["absolute inset-0", star_icon_class(@size), "text-muted-foreground/30"])}
                aria-hidden="true"
              >
                <path d={icon_path(@icon)} />
              </svg>
              <span
                class="absolute inset-0 overflow-hidden"
                style={"width: #{fill_pct(star, @value)}%"}
              >
                <svg
                  xmlns="http://www.w3.org/2000/svg"
                  viewBox="0 0 24 24"
                  fill="currentColor"
                  class={cn([star_icon_class(@size), "text-yellow-400"])}
                  aria-hidden="true"
                >
                  <path d={icon_path(@icon)} />
                </svg>
              </span>
            </span>
          <% else %>
            <svg
              xmlns="http://www.w3.org/2000/svg"
              viewBox="0 0 24 24"
              fill="currentColor"
              class={cn([
                star_icon_class(@size),
                star <= int_value(@value) && "text-yellow-400",
                star > int_value(@value) && "text-muted-foreground/30"
              ])}
              aria-hidden="true"
            >
              <path d={icon_path(@icon)} />
            </svg>
          <% end %>
        </label>
      <% end %>
    </fieldset>
    """
  end

  attr(:field, Phoenix.HTML.FormField, required: true, doc: "A Phoenix.HTML.FormField struct")
  attr(:label, :string, default: nil, doc: "Label text")
  attr(:description, :string, default: nil, doc: "Helper text")
  attr(:max, :integer, default: 5, doc: "Maximum number of stars")
  attr(:size, :string, default: "default", values: ~w(sm default lg), doc: "Star size")
  attr(:half, :boolean, default: false, doc: "Enable half-star display for float values")
  attr(:icon, :atom, values: [:star, :heart, :thumb], default: :star, doc: "Icon style")
  attr(:labels, :list, default: [], doc: "Hover label strings per position")
  attr(:class, :string, default: nil, doc: "Additional CSS classes")

  attr(:rest, :global,
    include: ~w(phx-change phx-blur phx-debounce),
    doc: "HTML attributes forwarded to fieldset"
  )

  @doc """
  Renders a form-integrated star rating with label, description, and errors.
  """
  def form_rating(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    assigns =
      assigns
      |> assign(:errors, Enum.map(field.errors, &translate_error/1))
      |> assign_new(:name, fn -> field.name end)
      |> assign_new(:value, fn -> parse_value(field.value) end)

    ~H"""
    <div class="space-y-2">
      <label :if={@label} class="text-sm font-medium leading-none">
        {@label}
      </label>
      <p :if={@description} class="text-sm text-muted-foreground">
        {@description}
      </p>
      <.rating
        value={@value}
        max={@max}
        size={@size}
        name={@name}
        half={@half}
        icon={@icon}
        labels={@labels}
        class={@class}
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

  defp star_label_class("sm"), do: "text-sm"
  defp star_label_class("default"), do: "text-base"
  defp star_label_class("lg"), do: "text-lg"

  defp star_icon_class("sm"), do: "h-4 w-4 transition-colors"
  defp star_icon_class("default"), do: "h-5 w-5 transition-colors"
  defp star_icon_class("lg"), do: "h-7 w-7 transition-colors"

  # Returns integer value for checked comparison (half=false mode)
  defp int_value(v) when is_integer(v), do: v
  defp int_value(v) when is_float(v), do: round(v)
  defp int_value(v) when is_binary(v), do: parse_value(v) |> int_value()
  defp int_value(_), do: 0

  # Returns fill percentage (0, 50, or 100) for half-star overlay mode
  defp fill_pct(star, value) when is_integer(value) do
    if star <= value, do: 100, else: 0
  end

  defp fill_pct(star, value) when is_float(value) do
    cond do
      star <= trunc(value) -> 100
      star - 0.5 <= value -> 50
      true -> 0
    end
  end

  defp fill_pct(star, value) when is_binary(value) do
    fill_pct(star, parse_value(value))
  end

  defp fill_pct(_, _), do: 0

  # SVG path data for each icon style
  defp icon_path(:star),
    do: "M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z"

  defp icon_path(:heart),
    do: "M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z"

  defp icon_path(:thumb),
    do: "M7 22H4a2 2 0 0 1-2-2v-7a2 2 0 0 1 2-2h3m0 11V9l4-9a3 3 0 0 1 3 3v4h5.28a2 2 0 0 1 2 2l-1.38 9a2 2 0 0 1-2 2H7z"

  defp parse_value(nil), do: 0
  defp parse_value(v) when is_integer(v), do: v
  defp parse_value(v) when is_float(v), do: v

  defp parse_value(v) when is_binary(v) do
    case Float.parse(v) do
      {n, ""} ->
        n

      _ ->
        case Integer.parse(v) do
          {n, _} -> n
          :error -> 0
        end
    end
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
