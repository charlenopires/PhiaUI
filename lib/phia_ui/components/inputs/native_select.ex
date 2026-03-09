defmodule PhiaUi.Components.NativeSelect do
  @moduledoc """
  Styled native `<select>` wrapper without `Phoenix.HTML.FormField` dependency.

  Unlike `PhiaUi.Components.Select.phia_select/1`, which requires a
  `Phoenix.HTML.FormField` struct (and thus a changeset), `native_select/1`
  accepts plain attrs — `:name`, `:value`, `:options` — making it ideal for
  standalone selects outside of Ecto forms: filters, settings, wizard steps,
  and other non-changeset scenarios.

  ## Variants

  | Variant        | Description                                                |
  |----------------|------------------------------------------------------------|
  | `"default"`    | Label above, bordered select below                        |
  | `"inset"`      | Label inside the border at top-left, select below          |
  | `"overlapping"`| Floating label (`absolute -top-2.5 left-3 bg-background`) |

  ## Sizes

  | Size      | Height   |
  |-----------|----------|
  | `"sm"`    | `h-8`    |
  | `"default"` | `h-10` |
  | `"lg"`    | `h-12`   |

  ## Options format

  Accepts any format supported by `Phoenix.HTML.Form.options_for_select/2`:

      <%!-- Tuple list --%>
      options={[{"Free", "free"}, {"Pro", "pro"}]}

      <%!-- Plain strings --%>
      options={["Small", "Medium", "Large"]}

      <%!-- Keyword list --%>
      options={[Free: "free", Pro: "pro"]}

  ## Grouped options (optgroups)

      grouped_options={[
        {"Fruits", [{"Apple", "apple"}, {"Banana", "banana"}]},
        {"Vegetables", [{"Carrot", "carrot"}, {"Spinach", "spinach"}]}
      ]}

  ## Basic example

      <.native_select
        name="country"
        options={[{"United States", "us"}, {"Canada", "ca"}]}
        label="Country"
        placeholder="Select a country..."
      />

  ## With overlapping label

      <.native_select
        name="role"
        options={[{"Admin", "admin"}, {"Member", "member"}]}
        label="Role"
        variant="overlapping"
      />
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]
  import PhiaUi.Components.Icon, only: [icon: 1]

  # ---------------------------------------------------------------------------
  # native_select/1
  # ---------------------------------------------------------------------------

  attr :id, :string, default: nil, doc: "Element id. Auto-generated when nil."
  attr :name, :string, default: nil, doc: "Form field name."
  attr :value, :any, default: nil, doc: "Currently selected value."

  attr :options, :list,
    default: [],
    doc: "List of options: `[{\"Label\", \"val\"}]`, `[\"val\"]`, or `[label: \"val\"]`."

  attr :grouped_options, :list,
    default: nil,
    doc: "Grouped options for `<optgroup>`: `[{\"Group\", [opts]}]`."

  attr :placeholder, :string, default: nil, doc: "Disabled placeholder first option."
  attr :label, :string, default: nil, doc: "Label text."
  attr :description, :string, default: nil, doc: "Helper text below label."
  attr :error, :any, default: nil, doc: "Error message string."
  attr :required, :boolean, default: false, doc: "Marks the field as required."
  attr :disabled, :boolean, default: false, doc: "Disables the select."

  attr :size, :string,
    values: ~w(sm default lg),
    default: "default",
    doc: "Size variant."

  attr :variant, :string,
    values: ~w(default inset overlapping),
    default: "default",
    doc: "Layout variant."

  attr :class, :string, default: nil, doc: "Additional classes on the `<select>`."
  attr :rest, :global, doc: "Additional HTML attributes."

  slot :icon, doc: "Optional icon rendered inside the select border on the left."

  @doc """
  Renders a styled native `<select>` element without requiring a FormField struct.

  ## Examples

      <.native_select
        name="size"
        options={["Small", "Medium", "Large"]}
        label="Size"
      />

      <.native_select
        name="category"
        grouped_options={[
          {"Fruits", [{"Apple", "apple"}, {"Banana", "banana"}]},
          {"Veggies", [{"Carrot", "carrot"}]}
        ]}
        label="Category"
        variant="inset"
      />
  """
  def native_select(assigns) do
    assigns = assign_new(assigns, :select_id, fn -> assigns.id || "native-select-#{System.unique_integer([:positive])}" end)

    ~H"""
    <div class={variant_wrapper_class(@variant)}>
      <%!-- Label: position varies by variant --%>
      <label
        :if={@label && @variant == "default"}
        for={@select_id}
        class={cn(["text-sm font-medium leading-none peer-disabled:cursor-not-allowed peer-disabled:opacity-70", @error && "text-destructive"])}
      >
        {@label}<span :if={@required} class="text-destructive ml-0.5">*</span>
      </label>

      <%!-- Description (default variant only, above select) --%>
      <p :if={@description && @variant == "default"} class="text-sm text-muted-foreground">
        {@description}
      </p>

      <%!-- Select wrapper --%>
      <div class={cn(["relative", @variant != "default" && "border rounded-md", @variant != "default" && @error && "border-destructive"])}>
        <%!-- Inset label: inside border at top --%>
        <label
          :if={@label && @variant == "inset"}
          for={@select_id}
          class={cn(["block px-3 pt-2 text-xs text-muted-foreground", @error && "text-destructive"])}
        >
          {@label}<span :if={@required} class="text-destructive ml-0.5">*</span>
        </label>

        <%!-- Overlapping label: floating on border --%>
        <label
          :if={@label && @variant == "overlapping"}
          for={@select_id}
          class={cn(["absolute -top-2.5 left-3 bg-background px-1 text-xs text-muted-foreground z-10", @error && "text-destructive"])}
        >
          {@label}<span :if={@required} class="text-destructive ml-0.5">*</span>
        </label>

        <%!-- Icon slot --%>
        <div :if={@icon != []} class="absolute left-3 top-1/2 -translate-y-1/2 pointer-events-none text-muted-foreground">
          {render_slot(@icon)}
        </div>

        <select
          id={@select_id}
          name={@name}
          required={@required}
          disabled={@disabled}
          class={
            cn([
              "phia-touch-target",
              "w-full rounded-md bg-background text-sm",
              "appearance-none cursor-pointer",
              "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring",
              "disabled:cursor-not-allowed disabled:opacity-50",
              size_class(@size),
              select_variant_class(@variant),
              @icon != [] && "pl-9",
              @error && @variant == "default" && "border-destructive",
              @class
            ])
          }
          {@rest}
        >
          <option :if={@placeholder} value="" disabled selected={@value == nil}>
            {@placeholder}
          </option>

          <%= if @grouped_options do %>
            <%= for {group_label, group_opts} <- @grouped_options do %>
              <optgroup label={group_label}>
                {Phoenix.HTML.Form.options_for_select(group_opts, @value)}
              </optgroup>
            <% end %>
          <% else %>
            {Phoenix.HTML.Form.options_for_select(@options, @value)}
          <% end %>
        </select>

        <%!-- Chevron icon --%>
        <div class="absolute right-3 top-1/2 -translate-y-1/2 pointer-events-none text-muted-foreground">
          <.icon name="chevron-down" size={:sm} />
        </div>
      </div>

      <%!-- Description for non-default variants --%>
      <p :if={@description && @variant != "default"} class="text-sm text-muted-foreground mt-1.5">
        {@description}
      </p>

      <%!-- Error message --%>
      <p :if={@error} class="text-sm text-destructive mt-1.5">
        {@error}
      </p>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  defp size_class("sm"), do: "h-8 px-3 py-1 pr-8 text-xs"
  defp size_class("default"), do: "h-10 px-3 py-2 pr-8"
  defp size_class("lg"), do: "h-12 px-4 py-3 pr-10 text-base"

  defp variant_wrapper_class("default"), do: "space-y-2"
  defp variant_wrapper_class("inset"), do: "space-y-1.5"
  defp variant_wrapper_class("overlapping"), do: "relative space-y-1.5"

  defp select_variant_class("default"), do: "border"
  defp select_variant_class("inset"), do: "border-0 pb-2 pt-0 focus-visible:ring-0"
  defp select_variant_class("overlapping"), do: "border-0 focus-visible:ring-0"
end
