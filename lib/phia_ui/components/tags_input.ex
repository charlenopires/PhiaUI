defmodule PhiaUi.Components.TagsInput do
  @moduledoc """
  Tags input component for PhiaUI.

  Provides `tags_input/1` — a multi-tag input field that renders existing tags
  as removable badge chips and lets users add new tags by typing and pressing
  Enter (or a configurable separator character).

  Tags are managed client-side by the `PhiaTagsInput` JS hook, which handles:
  - Adding a tag on Enter or separator key
  - Removing a tag via the × button or Backspace on an empty input
  - Deduplication (ignores duplicate values)
  - Syncing the hidden `<input>` with the current tag CSV for form submission

  The component integrates with `Phoenix.HTML.FormField` so changeset validation
  errors are displayed automatically.

  ## When to use

  Use `tags_input/1` for any field that accepts a variable number of string
  values — article labels, skill tags, email recipients, keyword lists, etc.

  ## Registration

  Register the hook in `app.js`:

      import PhiaTagsInput from "./hooks/tags_input"
      let liveSocket = new LiveSocket("/live", Socket, {
        hooks: { PhiaTagsInput }
      })

  ## Basic form example

      <.form for={@form} phx-submit="save_article">
        <.tags_input
          field={@form[:tags]}
          label="Tags"
          placeholder="Add a tag..."
        />
        <.button type="submit">Save</.button>
      </.form>

  ## Custom separator

  By default, pressing `,` (comma) or Enter adds a tag. You can change the
  separator to `;` or any other character:

      <.tags_input
        field={@form[:emails]}
        label="Recipients"
        placeholder="Type an email and press Enter..."
        separator=";"
      />

  ## Value formats

  The component accepts the field value in either format:

  | Format            | Example                           |
  |-------------------|-----------------------------------|
  | CSV string        | `"elixir,phoenix,liveview"`       |
  | List of strings   | `["elixir", "phoenix"]`           |

  Empty strings and whitespace-only values are filtered out automatically.

  ## Changeset integration

  Tags are serialised as a comma-separated string in the hidden input.
  In your changeset, cast and split the CSV field:

      defmodule MyApp.Article do
        use Ecto.Schema
        import Ecto.Changeset

        schema "articles" do
          field :tags, {:array, :string}
        end

        def changeset(article, attrs) do
          # tags arrive as CSV string "elixir,phoenix" from the form
          tags =
            case attrs["tags"] do
              nil -> []
              csv -> String.split(csv, ",", trim: true)
            end

          article
          |> cast(Map.put(attrs, "tags", tags), [:tags])
          |> validate_required([:tags])
        end
      end

  Alternatively, store tags as a single delimited string and split on read.
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
    doc: """
    A `Phoenix.HTML.FormField` from `@form[:field_name]`.
    Provides `id`, `name`, `value`, and `errors` for full form integration.
    """
  )

  attr(:label, :string,
    default: nil,
    doc: "Label text rendered above the input. Pass `nil` to omit the label."
  )

  attr(:placeholder, :string,
    default: "Add tag...",
    doc: "Placeholder text shown in the text input when it is empty"
  )

  attr(:separator, :string,
    default: ",",
    doc: """
    Character that triggers adding the current input value as a new tag,
    in addition to the Enter key. Defaults to `","`.
    The `PhiaTagsInput` hook reads this from `data-separator`.
    """
  )

  attr(:class, :string,
    default: nil,
    doc: "Additional CSS classes for the outer wrapper div"
  )

  @doc """
  Renders a multi-tag input integrated with `Phoenix.HTML.FormField`.

  Initial tags are parsed from `field.value` (list or CSV string) and rendered
  server-side. The `PhiaTagsInput` hook takes over on mount and manages all
  client-side add/remove/dedup/sync behaviour.

  The hidden `<input>` is kept in sync by the hook and carries the current
  tag CSV on form submit, which the changeset receives as a string.
  """
  def tags_input(assigns) do
    # Parse the field value once at render time so the template stays declarative.
    assigns = assign(assigns, :tags, parse_tags(assigns.field.value))

    ~H"""
    <div class={cn(["space-y-2", @class])}>
      <%!-- Label — the `for` points to the text input, not the hidden input --%>
      <label
        :if={@label}
        for={"#{@field.id}-tags-input"}
        class="text-sm font-medium leading-none peer-disabled:cursor-not-allowed peer-disabled:opacity-70"
      >
        {@label}
      </label>

      <%!-- Hook container — the PhiaTagsInput hook manages everything inside this div.
           `data-separator` communicates the separator character to the hook. --%>
      <div
        id={"#{@field.id}-tags-hook"}
        phx-hook="PhiaTagsInput"
        data-separator={@separator}
        class="flex flex-wrap gap-1.5 rounded-md border border-input bg-background p-2 focus-within:ring-2 focus-within:ring-ring focus-within:ring-offset-2"
      >
        <%!-- Server-rendered tag chips — the hook re-reads them from the hidden input on mount
             so they stay in sync even if LiveView re-renders the component. --%>
        <div :for={tag <- @tags} data-tag={tag} class="inline-flex items-center">
          <.badge variant={:secondary} class="gap-1 pr-1">
            {tag}
            <%!-- Remove button — the hook attaches a click handler via `data-remove-tag` --%>
            <button
              type="button"
              data-remove-tag={tag}
              aria-label={"Remove #{tag}"}
              class="ml-0.5 rounded-sm opacity-70 hover:opacity-100 focus:outline-none"
            >
              <.icon name="x" size={:xs} />
            </button>
          </.badge>
        </div>

        <%!-- Text input for new tags — NOT submitted with the form (no `name` attr).
             `data-tags-input` marks it for the hook to attach event listeners. --%>
        <input
          type="text"
          id={"#{@field.id}-tags-input"}
          placeholder={@placeholder}
          data-tags-input
          autocomplete="off"
          class="flex-1 min-w-[120px] bg-transparent text-sm outline-none placeholder:text-muted-foreground"
        />
      </div>

      <%!-- Hidden input — carries the CSV tag string on form submit.
           The hook updates this input's value whenever tags change. --%>
      <input
        type="hidden"
        id={@field.id}
        name={@field.name}
        value={Enum.join(@tags, ",")}
        data-tags-hidden
      />

      <%!-- Changeset validation errors from field.errors --%>
      <.form_message field={@field} />
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  # Parse tags from the form field value, which can arrive in two forms:
  # 1. A CSV string: "elixir,phoenix,liveview"
  # 2. A list of strings: ["elixir", "phoenix"]
  # In both cases, whitespace is trimmed and empty values are rejected.

  defp parse_tags(nil), do: []
  defp parse_tags([]), do: []

  defp parse_tags(list) when is_list(list) do
    list |> Enum.map(&to_string/1) |> Enum.map(&String.trim/1) |> Enum.reject(&(&1 == ""))
  end

  defp parse_tags(csv) when is_binary(csv) do
    csv |> String.split(",") |> Enum.map(&String.trim/1) |> Enum.reject(&(&1 == ""))
  end
end
