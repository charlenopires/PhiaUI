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
  """

  use Phoenix.Component
  import PhiaUi.ClassMerger, only: [cn: 1]

  attr(:value, :integer, default: 0, doc: "Current rating value (0 to max)")
  attr(:max, :integer, default: 5, doc: "Maximum number of stars")
  attr(:readonly, :boolean, default: false, doc: "Whether the rating is read-only")
  attr(:size, :string, default: "default", values: ~w(sm default lg), doc: "Size of the stars")
  attr(:name, :string, default: "rating", doc: "Input name attribute")
  attr(:class, :string, default: nil, doc: "Additional CSS classes")

  attr(:rest, :global,
    include: ~w(phx-change phx-blur id),
    doc: "HTML attributes forwarded to the fieldset"
  )

  @doc """
  Renders a star rating with radio inputs.

  Each star is a radio input visually hidden, with an SVG star label.
  The currently selected value is highlighted via the `value` comparison in
  the template — stars at or below `value` receive `text-yellow-400` while
  stars above receive `text-muted-foreground/30`. In readonly mode, inputs
  are disabled.
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
        <label class={cn(["cursor-pointer", @readonly && "cursor-default", star_label_class(@size)])}>
          <input
            type="radio"
            name={@name}
            value={star}
            checked={star <= @value}
            disabled={@readonly}
            class="sr-only peer"
            aria-label={"#{star} star#{if star == 1, do: "", else: "s"}"}
          />
          <svg
            xmlns="http://www.w3.org/2000/svg"
            viewBox="0 0 24 24"
            fill="currentColor"
            class={cn([
              star_icon_class(@size),
              star <= @value && "text-yellow-400",
              star > @value && "text-muted-foreground/30"
            ])}
            aria-hidden="true"
          >
            <path d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z" />
          </svg>
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
  attr(:class, :string, default: nil, doc: "Additional CSS classes")

  attr(:rest, :global,
    include: ~w(phx-change phx-blur phx-debounce),
    doc: "HTML attributes forwarded to fieldset"
  )

  @doc """
  Renders a form-integrated star rating with label, description, and errors.

  Reads `field.value` and `field.errors` from a `Phoenix.HTML.FormField` struct
  (e.g., `@form[:rating]`). Errors are translated via `translate_error/1` and
  rendered below the stars in destructive color.
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

  defp parse_value(nil), do: 0
  defp parse_value(v) when is_integer(v), do: v

  defp parse_value(v) when is_binary(v) do
    case Integer.parse(v) do
      {n, _} -> n
      :error -> 0
    end
  end

  # Interpolates %{key} placeholders from the opts keyword list.
  # Lightweight fallback — after ejection can be replaced with Gettext for i18n.
  defp translate_error({msg, opts}) do
    Enum.reduce(opts, msg, fn
      {key, value}, acc when is_binary(acc) ->
        String.replace(acc, "%{#{key}}", to_string(value))

      _other, acc ->
        acc
    end)
  end
end
