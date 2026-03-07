defmodule PhiaUi.Components.UrlInput do
  @moduledoc """
  URL input with a lockable protocol prefix selector.

  Provides `url_input/1` — a text input that prepends an `https://` / `http://`
  selector as a visual prefix. The selected protocol is stored in a separate
  hidden input so it can be captured independently on form submit.

  Also provides `form_url_input/1` for full changeset integration with label,
  description, and error messages.

  ## When to use

  Use for any field that expects a full URL — website links, webhook endpoints,
  redirect URLs, CDN origins, or API base URLs. The prefix selector prevents
  users from accidentally omitting the protocol.

  ## Basic usage

      <.url_input
        name="website"
        value={@website}
        placeholder="example.com"
        phx-change="update_website"
      />

      <%!-- With protocol selector name --%>
      <.url_input
        name="endpoint"
        protocol_name="endpoint_protocol"
        protocol={@protocol}
        value={@endpoint}
        placeholder="api.example.com/v1"
      />

  ## Form-integrated

      <.form_url_input
        field={@form[:webhook_url]}
        label="Webhook URL"
        description="We'll POST events to this endpoint."
      />
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  # ---------------------------------------------------------------------------
  # url_input/1
  # ---------------------------------------------------------------------------

  attr(:id, :string,
    default: nil,
    doc: "HTML id for the URL `<input>`. Auto-generated if nil."
  )

  attr(:name, :string,
    default: nil,
    doc: "HTML name for the URL path field."
  )

  attr(:protocol_name, :string,
    default: nil,
    doc: "HTML name for the protocol `<select>`. Defaults to `name <> \"_protocol\"`."
  )

  attr(:value, :string,
    default: nil,
    doc: "Current URL value (path portion, without the protocol prefix)."
  )

  attr(:protocol, :string,
    default: "https",
    values: ~w(https http),
    doc: "Currently selected protocol."
  )

  attr(:placeholder, :string,
    default: "example.com",
    doc: "Placeholder for the URL path portion."
  )

  attr(:disabled, :boolean,
    default: false,
    doc: "Disables both the protocol selector and the URL input."
  )

  attr(:class, :string,
    default: nil,
    doc: "Additional CSS classes applied to the wrapper."
  )

  attr(:rest, :global,
    include: ~w(phx-change phx-debounce phx-keydown required autocomplete),
    doc: "HTML attributes forwarded to the URL `<input>` element."
  )

  @doc """
  Renders a URL input with an `https://` / `http://` protocol selector prefix.

  The protocol selector is a native `<select>` styled to match the input.
  A second hidden-ish URL `<input>` receives the actual path (without protocol).
  Both values are submitted together on form submit.

  ## Examples

      <.url_input name="site" value={@site} phx-change="update_site" />

      <.url_input name="api" protocol="http" value={@api_url} placeholder="localhost:4000/api" />
  """
  def url_input(assigns) do
    id = assigns.id || "url-input-#{:erlang.unique_integer([:positive])}"
    assigns = assign(assigns, :id, id)

    assigns =
      if assigns.protocol_name do
        assigns
      else
        assign(assigns, :protocol_name, if(assigns.name, do: assigns.name <> "_protocol", else: nil))
      end

    ~H"""
    <div class={cn([
      "flex items-stretch h-10 w-full rounded-md border border-input bg-background overflow-hidden",
      "focus-within:ring-2 focus-within:ring-ring focus-within:ring-offset-2",
      @disabled && "cursor-not-allowed opacity-50",
      @class
    ])}>
      <%!-- Protocol selector --%>
      <select
        name={@protocol_name}
        disabled={@disabled}
        aria-label="Protocol"
        class="flex items-center border-r border-input bg-muted px-2 text-sm text-muted-foreground focus:outline-none cursor-pointer"
      >
        <option value="https" selected={@protocol == "https"}>https://</option>
        <option value="http" selected={@protocol == "http"}>http://</option>
      </select>

      <%!-- URL path input --%>
      <input
        type="text"
        id={@id}
        name={@name}
        value={@value}
        placeholder={@placeholder}
        disabled={@disabled}
        inputmode="url"
        class="flex-1 min-w-0 bg-transparent px-3 py-2 text-sm placeholder:text-muted-foreground focus:outline-none disabled:cursor-not-allowed"
        {@rest}
      />
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # form_url_input/1
  # ---------------------------------------------------------------------------

  attr(:field, Phoenix.HTML.FormField,
    required: true,
    doc: "A `Phoenix.HTML.FormField` struct from `@form[:field_name]`."
  )

  attr(:label, :string,
    default: nil,
    doc: "Label text rendered above the input group."
  )

  attr(:description, :string,
    default: nil,
    doc: "Helper text rendered below the label."
  )

  attr(:protocol, :string,
    default: "https",
    values: ~w(https http),
    doc: "Currently selected protocol."
  )

  attr(:placeholder, :string,
    default: "example.com",
    doc: "Placeholder for the URL path."
  )

  attr(:class, :string,
    default: nil,
    doc: "Additional CSS classes applied to the wrapper."
  )

  attr(:rest, :global,
    include: ~w(phx-change phx-debounce disabled required),
    doc: "HTML attributes forwarded to `url_input/1`."
  )

  @doc """
  Renders a form-integrated URL input with label and error messages.

  ## Examples

      <.form_url_input field={@form[:website]} label="Website" />

      <.form_url_input field={@form[:api_url]} label="API URL" protocol="http" />
  """
  def form_url_input(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    assigns =
      assigns
      |> assign(:errors, Enum.map(field.errors, &translate_error/1))
      |> assign_new(:id, fn -> field.id end)
      |> assign_new(:name, fn -> field.name end)
      |> assign_new(:value, fn -> field.value end)

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
      <.url_input
        id={@id}
        name={@name}
        value={@value}
        protocol={@protocol}
        placeholder={@placeholder}
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

  defp error_class([]), do: nil
  defp error_class(_), do: "border-destructive"

  defp translate_error({msg, opts}) do
    Enum.reduce(opts, msg, fn
      {key, value}, acc when is_binary(acc) ->
        String.replace(acc, "%{#{key}}", to_string(value))

      _other, acc ->
        acc
    end)
  end
end
