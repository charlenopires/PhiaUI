defmodule PhiaUi.Components.Skeleton do
  @moduledoc """
  Skeleton loading placeholder components.

  Provides animated shimmer placeholders for content that is loading.
  Pure HEEx — no JavaScript required. Uses Tailwind v4 `animate-pulse`.

  ## Sub-components

  - `skeleton/1` — base rectangle or circle placeholder
  - `skeleton_text/1` — stack of text-line placeholders
  - `skeleton_avatar/1` — circular avatar placeholder
  - `skeleton_card/1` — composite card-shaped placeholder

  ## Examples

      <%# Basic rectangle %>
      <.skeleton class="h-4 w-full" />

      <%# Circle (avatar) %>
      <.skeleton shape={:circle} width="40px" height="40px" />

      <%# Text block with 4 lines %>
      <.skeleton_text lines={4} />

      <%# Avatar with custom size %>
      <.skeleton_avatar size="16" />

      <%# Full card skeleton %>
      <.skeleton_card />

  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  attr :shape, :atom,
    values: [:rectangle, :circle],
    default: :rectangle,
    doc: "Shape of the skeleton: :rectangle (default) or :circle"

  attr :width, :string,
    default: nil,
    doc: "CSS width value applied as inline style (e.g. '200px', '100%')"

  attr :height, :string,
    default: nil,
    doc: "CSS height value applied as inline style (e.g. '48px', '2rem')"

  attr :class, :string,
    default: nil,
    doc: "Additional CSS classes (merged via cn/1)"

  attr :rest, :global,
    doc: "HTML attributes forwarded to the root element"

  @doc """
  Renders a single animated skeleton placeholder.

  Use `:rectangle` (default) for blocks, text lines, and images.
  Use `:circle` for avatar placeholders.
  """
  def skeleton(assigns) do
    ~H"""
    <div
      class={cn(["animate-pulse bg-muted", shape_class(@shape), @class])}
      {style_attrs(@width, @height)}
      {@rest}
    >
    </div>
    """
  end

  attr :lines, :integer,
    default: 3,
    doc: "Number of text lines to render (default 3)"

  attr :class, :string,
    default: nil,
    doc: "Additional CSS classes applied to the wrapper div"

  @doc """
  Renders a stack of skeleton lines simulating a paragraph of text.

  The last line is shorter than full width to simulate natural text flow.
  """
  def skeleton_text(assigns) do
    ~H"""
    <div class={cn(["space-y-2", @class])}>
      <%= for i <- 1..@lines do %>
        <.skeleton class={cn(["h-4", if(i == @lines, do: "w-3/4", else: "w-full")])} />
      <% end %>
    </div>
    """
  end

  attr :size, :string,
    default: "10",
    doc: "Tailwind size number for width and height (e.g. '10' → w-10 h-10)"

  attr :class, :string,
    default: nil,
    doc: "Additional CSS classes"

  @doc """
  Renders a circular skeleton placeholder for avatar images.

  The `:size` attr maps to Tailwind's sizing scale: `"10"` → `w-10 h-10` (40px).
  """
  def skeleton_avatar(assigns) do
    ~H"""
    <.skeleton
      shape={:circle}
      class={cn(["w-#{@size} h-#{@size}", @class])}
    />
    """
  end

  attr :class, :string,
    default: nil,
    doc: "Additional CSS classes applied to the card wrapper"

  @doc """
  Renders a composite card-shaped skeleton with a header image area and text lines.
  """
  def skeleton_card(assigns) do
    ~H"""
    <div class={cn(["rounded-lg border p-4 space-y-3", @class])}>
      <.skeleton class="h-40 w-full" />
      <.skeleton_text lines={3} />
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  defp shape_class(:rectangle), do: "rounded-md"
  defp shape_class(:circle), do: "rounded-full"

  defp style_attrs(nil, nil), do: %{}
  defp style_attrs(width, nil), do: %{style: "width: #{width};"}
  defp style_attrs(nil, height), do: %{style: "height: #{height};"}
  defp style_attrs(width, height), do: %{style: "width: #{width}; height: #{height};"}
end
