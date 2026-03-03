defmodule PhiaUi.Components.TagsInput do
  @moduledoc """
  Tags Input Component for Phoenix LiveView.

  Provides `tags_input/1` — a multi-tag input field that renders tags as
  removable badges, backed by a hidden input for form submission via changesets.

  Tags are managed client-side by the `PhiaTagsInput` JS hook. The hook handles
  adding tags (Enter or separator key), removing tags (click X or Backspace on
  empty input), deduplication, and syncing the hidden input.

  ## Registration

  Register the hook in `app.js`:

      import PhiaTagsInput from "./phia_hooks/tags_input.js"
      let liveSocket = new LiveSocket("/live", Socket, { hooks: { PhiaTagsInput } })

  ## Example

      <.tags_input
        field={@form[:tags]}
        label="Tags"
        placeholder="Adicionar tag..."
      />

  ## Value formats

  The `:field` value is parsed from either format:

      field.value = "elixir,phoenix,liveview"   # CSV string
      field.value = ["elixir", "phoenix"]        # list of strings

  ## Changeset integration

  Tags are serialized as a comma-separated string in the hidden input, so your
  changeset can cast the field as a string and split on commas, or use
  `cast_array/3` with a custom parser.
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]
  import PhiaUi.Components.Badge, only: [badge: 1]
  import PhiaUi.Components.Form, only: [form_message: 1]
  import PhiaUi.Components.Icon, only: [icon: 1]

  # ---------------------------------------------------------------------------
  # tags_input/1
  # ---------------------------------------------------------------------------

  attr(:field, Phoenix.HTML.FormField,
    required: true,
    doc: "A `Phoenix.HTML.FormField` from `@form[:field_name]`"
  )

  attr(:label, :string, default: nil, doc: "Label text rendered above the input")

  attr(:placeholder, :string,
    default: "Adicionar tag...",
    doc: "Placeholder text for the tag text input"
  )

  attr(:separator, :string,
    default: ",",
    doc: "Character that confirms a new tag (in addition to Enter)"
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes for the outer wrapper")

  @doc """
  Renders a multi-tag input integrated with `Phoenix.HTML.FormField`.

  Initial tags are read from `field.value` (list or CSV string). The
  `PhiaTagsInput` JS hook manages all client-side interactions.
  """
  def tags_input(assigns) do
    assigns = assign(assigns, :tags, parse_tags(assigns.field.value))

    ~H"""
    <div class={cn(["space-y-2", @class])}>
      <label
        :if={@label}
        for={"#{@field.id}-tags-input"}
        class="text-sm font-medium leading-none peer-disabled:cursor-not-allowed peer-disabled:opacity-70"
      >
        {@label}
      </label>

      <%!-- Hook container: manages add/remove/dedup/sync client-side --%>
      <div
        id={"#{@field.id}-tags-hook"}
        phx-hook="PhiaTagsInput"
        data-separator={@separator}
        class="flex flex-wrap gap-1.5 rounded-md border border-input bg-background p-2 focus-within:ring-2 focus-within:ring-ring focus-within:ring-offset-2"
      >
        <%!-- Initial tags — rendered server-side, hook syncs from hidden input on mount --%>
        <div :for={tag <- @tags} data-tag={tag} class="inline-flex items-center">
          <.badge variant={:secondary} class="gap-1 pr-1">
            {tag}
            <button
              type="button"
              data-remove-tag={tag}
              aria-label={"Remover #{tag}"}
              class="ml-0.5 rounded-sm opacity-70 hover:opacity-100 focus:outline-none"
            >
              <.icon name="x" size={:xs} />
            </button>
          </.badge>
        </div>

        <%!-- Text input for new tags (visually integrated, not form-submitted) --%>
        <input
          type="text"
          id={"#{@field.id}-tags-input"}
          placeholder={@placeholder}
          data-tags-input
          autocomplete="off"
          class="flex-1 min-w-[120px] bg-transparent text-sm outline-none placeholder:text-muted-foreground"
        />
      </div>

      <%!-- Hidden input — carries CSV value for changeset submission --%>
      <input
        type="hidden"
        id={@field.id}
        name={@field.name}
        value={Enum.join(@tags, ",")}
        data-tags-hidden
      />

      <.form_message field={@field} />
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  # AC: tags lidas de @field.value (lista ou string separada por vírgula)
  defp parse_tags(nil), do: []
  defp parse_tags([]), do: []

  defp parse_tags(list) when is_list(list) do
    list |> Enum.map(&to_string/1) |> Enum.map(&String.trim/1) |> Enum.reject(&(&1 == ""))
  end

  defp parse_tags(csv) when is_binary(csv) do
    csv |> String.split(",") |> Enum.map(&String.trim/1) |> Enum.reject(&(&1 == ""))
  end
end
