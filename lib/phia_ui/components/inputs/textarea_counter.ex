defmodule PhiaUi.Components.TextareaCounter do
  @moduledoc """
  Textarea with a character counter and optional max-length enforcement.

  Provides `textarea_counter/1` — a standalone `<textarea>` with a live
  character count display — and `phia_textarea_counter/1` — the form-integrated
  version with label, description, and changeset error messages.

  The counter shows `current / max` when `max_length` is set, or just the
  current count when it is not. The counter changes colour as the limit
  approaches or is exceeded:

  - Default: `text-muted-foreground`
  - Warning (≥ 80% of max): `text-warning` (amber)
  - Exceeded (> max): `text-destructive` (red)

  ## When to use

  Use when users need character-limit guidance — post bodies, bio fields,
  tweet-style inputs, SMS templates, support messages, or form fields with
  explicit limits.

  ## Basic usage

      <.textarea_counter
        name="body"
        value={@body}
        max_length={280}
        placeholder="What's on your mind?"
        phx-change="update_body"
      />

  ## Form-integrated

      <.phia_textarea_counter
        field={@form[:bio]}
        label="Bio"
        description="Tell us a bit about yourself."
        max_length={160}
        rows={4}
      />
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  # ---------------------------------------------------------------------------
  # textarea_counter/1
  # ---------------------------------------------------------------------------

  attr(:id, :string,
    default: nil,
    doc: "HTML id for the `<textarea>`. Auto-generated if nil."
  )

  attr(:name, :string,
    default: nil,
    doc: "HTML name attribute."
  )

  attr(:value, :string,
    default: "",
    doc: "Current textarea content. Used to compute the live character count."
  )

  attr(:max_length, :integer,
    default: nil,
    doc: "Maximum allowed character count. When set, enforces `maxlength` on the native element."
  )

  attr(:rows, :integer,
    default: 4,
    doc: "Number of visible text rows."
  )

  attr(:placeholder, :string,
    default: nil,
    doc: "Placeholder text."
  )

  attr(:show_count, :boolean,
    default: true,
    doc: "Whether to show the character counter below the textarea."
  )

  attr(:disabled, :boolean,
    default: false,
    doc: "Disables the textarea."
  )

  attr(:class, :string,
    default: nil,
    doc: "Additional CSS classes merged into the `<textarea>` element."
  )

  attr(:rest, :global,
    include: ~w(phx-change phx-debounce phx-keydown required readonly autofocus),
    doc: "HTML attributes forwarded to the `<textarea>` element."
  )

  @doc """
  Renders a textarea with an inline character counter.

  The counter's colour changes as the limit is reached:
  - Normal: muted foreground
  - Warning (≥ 80%): amber
  - Exceeded (> 100%): destructive red

  ## Examples

      <.textarea_counter name="tweet" value={@tweet} max_length={280} />

      <.textarea_counter name="bio" value={@bio} max_length={160} rows={3} />
  """
  def textarea_counter(assigns) do
    id = assigns.id || "textarea-#{:erlang.unique_integer([:positive])}"
    assigns = assign(assigns, :id, id)
    current = String.length(assigns.value || "")
    assigns = assign(assigns, :current, current)

    ~H"""
    <div class="space-y-1">
      <textarea
        id={@id}
        name={@name}
        rows={@rows}
        placeholder={@placeholder}
        disabled={@disabled}
        maxlength={@max_length}
        class={cn([
          "flex w-full rounded-md border border-input bg-background px-3 py-2 text-sm",
          "placeholder:text-muted-foreground resize-y min-h-[80px]",
          "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2",
          "disabled:cursor-not-allowed disabled:opacity-50",
          @class
        ])}
        phx-debounce="blur"
        {@rest}
      >{@value}</textarea>

      <div :if={@show_count} class="flex justify-end"><span class={cn(["text-xs tabular-nums", counter_class(@current, @max_length)])}>{if @max_length, do: "#{@current} / #{@max_length}", else: "#{@current}"}</span></div>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # phia_textarea_counter/1
  # ---------------------------------------------------------------------------

  attr(:field, Phoenix.HTML.FormField,
    required: true,
    doc: "A `Phoenix.HTML.FormField` struct from `@form[:field_name]`."
  )

  attr(:label, :string,
    default: nil,
    doc: "Label text rendered above the textarea."
  )

  attr(:description, :string,
    default: nil,
    doc: "Helper text rendered below the label."
  )

  attr(:max_length, :integer,
    default: nil,
    doc: "Maximum allowed character count."
  )

  attr(:rows, :integer,
    default: 4,
    doc: "Number of visible text rows."
  )

  attr(:show_count, :boolean,
    default: true,
    doc: "Whether to show the character counter."
  )

  attr(:class, :string,
    default: nil,
    doc: "Additional CSS classes merged into the `<textarea>` element."
  )

  attr(:rest, :global,
    include: ~w(phx-change phx-debounce placeholder disabled required readonly),
    doc: "HTML attributes forwarded to `textarea_counter/1`."
  )

  @doc """
  Renders a form-integrated textarea with label, description, character counter,
  and changeset error messages.

  ## Examples

      <.phia_textarea_counter field={@form[:bio]} label="Bio" max_length={160} />

      <.phia_textarea_counter
        field={@form[:message]}
        label="Message"
        description="Maximum 500 characters."
        max_length={500}
        rows={6}
      />
  """
  def phia_textarea_counter(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    assigns =
      assigns
      |> assign(:errors, Enum.map(field.errors, &translate_error/1))
      |> assign_new(:id, fn -> field.id end)
      |> assign_new(:name, fn -> field.name end)
      |> assign_new(:value, fn -> field.value || "" end)

    ~H"""
    <div class="space-y-2">
      <label
        :if={@label}
        for={@id}
        class="text-sm font-medium leading-none peer-disabled:cursor-not-allowed peer-disabled:opacity-70"
      >
        {@label}
      </label>
      <p :if={@description} class="text-sm text-muted-foreground">{@description}</p>
      <.textarea_counter
        id={@id}
        name={@name}
        value={@value}
        max_length={@max_length}
        rows={@rows}
        show_count={@show_count}
        class={cn([error_class(@errors), @class])}
        {@rest}
      />
      <p :for={error <- @errors} class="text-sm font-medium text-destructive">{error}</p>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  defp counter_class(current, nil), do: "text-muted-foreground"

  defp counter_class(current, max) when current > max, do: "text-destructive font-medium"

  defp counter_class(current, max) when current >= round(max * 0.8),
    do: "text-amber-500 dark:text-amber-400"

  defp counter_class(_current, _max), do: "text-muted-foreground"

  defp error_class([]), do: nil
  defp error_class(_), do: "border-destructive focus-visible:ring-destructive"

  defp translate_error({msg, opts}) do
    Enum.reduce(opts, msg, fn
      {key, value}, acc when is_binary(acc) ->
        String.replace(acc, "%{#{key}}", to_string(value))

      _other, acc ->
        acc
    end)
  end
end
