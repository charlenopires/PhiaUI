defmodule PhiaUi.Components.Layout.ContainerQuery do
  @moduledoc """
  Container query wrapper component.

  Wraps children with CSS `@container` so descendant elements can use container
  query breakpoints (`@sm:`, `@md:`, `@lg:`, etc.) in their Tailwind classes.

  In Tailwind CSS v4, the `@container` utility class automatically sets
  `container-type: inline-size`. Named containers use `@container/{name}`.
  For `size` containment (both axes), an inline style is applied.

  ## Examples

      <%!-- Basic container query context --%>
      <.container_query_wrap>
        <div class="@md:flex @md:gap-4">
          <p>Responds to container width, not viewport.</p>
        </div>
      </.container_query_wrap>

      <%!-- Named container for targeted queries --%>
      <.container_query_wrap name="sidebar">
        <nav class="@sm/sidebar:flex-col @lg/sidebar:flex-row">
          ...
        </nav>
      </.container_query_wrap>

      <%!-- Size containment (both inline and block axes) --%>
      <.container_query_wrap type={:size}>
        <div class="@md:grid @md:grid-cols-2">
          ...
        </div>
      </.container_query_wrap>
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  attr :name, :string,
    default: nil,
    doc: "Optional container name for named queries (`@container/name`)."

  attr :type, :atom,
    default: :inline_size,
    values: [:inline_size, :size],
    doc: "Containment type: `:inline_size` (width only) or `:size` (both axes)."

  attr :class, :string, default: nil, doc: "Additional CSS classes merged via cn/1."

  attr :rest, :global, doc: "HTML attributes forwarded to the root element."

  slot :inner_block, required: true, doc: "Content that can use container query breakpoints."

  @doc "Renders a container query wrapper."
  def container_query_wrap(assigns) do
    ~H"""
    <div
      class={cn([container_class(@name, @type), @class])}
      style={container_style(@name, @type)}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  # Tailwind v4 `@container` sets container-type: inline-size automatically.
  # Named containers use `@container/{name}`.
  # For :size type we use inline style instead since the utility only does inline-size.
  defp container_class(nil, :inline_size), do: "@container"
  defp container_class(name, :inline_size), do: "@container/#{name}"
  defp container_class(_name, :size), do: nil

  # Only needed for :size type (both axes) or named :size containers,
  # since the Tailwind utility only covers inline-size.
  defp container_style(_name, :inline_size), do: nil

  defp container_style(nil, :size),
    do: "container-type: size"

  defp container_style(name, :size),
    do: "container-type: size; container-name: #{name}"
end
