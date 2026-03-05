defmodule PhiaUi.Components.Skeleton do
  @moduledoc """
  Animated loading placeholder components (shimmer / skeleton screens).

  Skeleton screens replace content areas while data is loading, preventing
  layout shift and providing a smoother perceived loading experience than a
  spinner. All components use Tailwind v4 `animate-pulse` — pure HEEx, no
  JavaScript required.

  ## Sub-components

  | Component         | Purpose                                                  |
  |-------------------|----------------------------------------------------------|
  | `skeleton/1`      | Base rectangle or circle placeholder block               |
  | `skeleton_text/1` | Stack of text-line placeholders simulating a paragraph   |
  | `skeleton_avatar/1`| Circular placeholder for avatar images                  |
  | `skeleton_card/1` | Composite card-shaped placeholder (image + text lines)   |

  ## Basic shapes

      <%!-- Rectangle placeholder (for an image, header, or button) --%>
      <.skeleton class="h-4 w-full" />

      <%!-- Circle placeholder (for an avatar) --%>
      <.skeleton shape={:circle} width="40px" height="40px" />

  ## Dashboard card loading skeletons

  Replace stat cards with skeletons while data loads:

      <%= if @loading do %>
        <div class="grid grid-cols-3 gap-4">
          <%= for _ <- 1..3 do %>
            <.skeleton_card />
          <% end %>
        </div>
      <% else %>
        <.metric_grid>
          <%= for stat <- @stats do %>
            <.stat_card title={stat.title} value={stat.value} />
          <% end %>
        </.metric_grid>
      <% end %>

  ## List item skeletons

  Use `skeleton_avatar/1` with `skeleton_text/1` to match a user list:

      <%= if @loading do %>
        <div class="space-y-4">
          <%= for _ <- 1..5 do %>
            <div class="flex items-center gap-4">
              <.skeleton_avatar size="10" />
              <div class="flex-1">
                <.skeleton_text lines={2} />
              </div>
            </div>
          <% end %>
        </div>
      <% else %>
        <%= for user <- @users do %>
          <.user_row user={user} />
        <% end %>
      <% end %>

  ## Article / blog post skeleton

      <div class="space-y-4 max-w-2xl">
        <%!-- Hero image area --%>
        <.skeleton class="h-56 w-full" />
        <%!-- Title --%>
        <.skeleton class="h-8 w-3/4" />
        <%!-- Author line --%>
        <div class="flex items-center gap-2">
          <.skeleton_avatar size="8" />
          <.skeleton class="h-4 w-32" />
        </div>
        <%!-- Body paragraphs --%>
        <.skeleton_text lines={5} />
        <.skeleton_text lines={4} />
      </div>

  ## Table skeleton

  Match the column widths of your real table:

      <table>
        <thead>...</thead>
        <tbody>
          <%= if @loading do %>
            <%= for _ <- 1..8 do %>
              <tr>
                <td class="p-4"><.skeleton class="h-4 w-8" /></td>
                <td class="p-4"><.skeleton class="h-4 w-40" /></td>
                <td class="p-4"><.skeleton class="h-4 w-24" /></td>
                <td class="p-4"><.skeleton class="h-4 w-20" /></td>
              </tr>
            <% end %>
          <% else %>
            ...real rows...
          <% end %>
        </tbody>
      </table>
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  # ---------------------------------------------------------------------------
  # skeleton/1 — base placeholder block
  # ---------------------------------------------------------------------------

  attr(:shape, :atom,
    values: [:rectangle, :circle],
    default: :rectangle,
    doc:
      "Shape of the placeholder. `:rectangle` (default) for blocks and text lines; `:circle` for avatars."
  )

  attr(:width, :string,
    default: nil,
    doc:
      "CSS width applied as an inline style (e.g. `\"200px\"`, `\"50%\"`). When `nil`, width is controlled by the `class` attribute."
  )

  attr(:height, :string,
    default: nil,
    doc:
      "CSS height applied as an inline style (e.g. `\"48px\"`, `\"2rem\"`). When `nil`, height is controlled by the `class` attribute."
  )

  attr(:class, :string,
    default: nil,
    doc: "Additional CSS classes merged via `cn/1`. Use Tailwind `h-N w-N` to size the skeleton."
  )

  attr(:rest, :global, doc: "HTML attributes forwarded to the root `<div>` element.")

  @doc """
  Renders a single animated skeleton placeholder block.

  Use `:rectangle` (default) for any block-level placeholder: image areas,
  text lines, buttons, or card borders. Use `:circle` for avatar placeholders.

  Size the skeleton with Tailwind classes via `:class`, or with explicit
  pixel/rem values via `:width` and `:height`. Both can be used together.

  ## Examples

      <%!-- Full-width text line --%>
      <.skeleton class="h-4 w-full" />

      <%!-- Fixed-size image placeholder --%>
      <.skeleton class="h-40 w-full" />

      <%!-- Circle with explicit pixel size --%>
      <.skeleton shape={:circle} width="48px" height="48px" />
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

  # ---------------------------------------------------------------------------
  # skeleton_text/1 — paragraph placeholder
  # ---------------------------------------------------------------------------

  attr(:lines, :integer,
    default: 3,
    doc:
      "Number of text lines to render. Default: `3`. The last line is rendered at `w-3/4` to simulate natural text flow."
  )

  attr(:class, :string,
    default: nil,
    doc: "Additional CSS classes applied to the wrapper `<div>`."
  )

  @doc """
  Renders a stack of skeleton lines simulating a paragraph of text.

  The last line is always rendered at 75% width (`w-3/4`) to mimic the
  natural way text rarely fills the entire last line of a paragraph.

  ## Example

      <%!-- Simulates 4 lines of body text --%>
      <.skeleton_text lines={4} />
  """
  def skeleton_text(assigns) do
    ~H"""
    <div class={cn(["space-y-2", @class])}>
      <%= for i <- 1..@lines do %>
        <%!-- Last line is narrower to match natural paragraph tail --%>
        <.skeleton class={cn(["h-4", if(i == @lines, do: "w-3/4", else: "w-full")])} />
      <% end %>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # skeleton_avatar/1 — circular avatar placeholder
  # ---------------------------------------------------------------------------

  attr(:size, :string,
    default: "10",
    doc:
      "Tailwind size number that maps to both `w-N` and `h-N`. For example, `\"10\"` produces `w-10 h-10` (40px). Common values: `\"6\"` (24px), `\"8\"` (32px), `\"10\"` (40px), `\"14\"` (56px)."
  )

  attr(:class, :string,
    default: nil,
    doc: "Additional CSS classes merged with the size-derived classes."
  )

  @doc """
  Renders a circular skeleton placeholder for avatar images.

  The `:size` attribute maps directly to Tailwind's numeric sizing scale:

  | size  | output classes | px size |
  |-------|----------------|---------|
  | `"6"` | `w-6 h-6`      | 24 px   |
  | `"8"` | `w-8 h-8`      | 32 px   |
  | `"10"`| `w-10 h-10`    | 40 px   |
  | `"14"`| `w-14 h-14`    | 56 px   |

  ## Example

      <%!-- Default 40px avatar skeleton --%>
      <.skeleton_avatar />

      <%!-- 56px skeleton matching a "lg" avatar --%>
      <.skeleton_avatar size="14" />
  """
  def skeleton_avatar(assigns) do
    ~H"""
    <.skeleton
      shape={:circle}
      class={cn(["w-#{@size} h-#{@size}", @class])}
    />
    """
  end

  # ---------------------------------------------------------------------------
  # skeleton_card/1 — composite card placeholder
  # ---------------------------------------------------------------------------

  attr(:class, :string,
    default: nil,
    doc: "Additional CSS classes applied to the card wrapper `<div>`."
  )

  @doc """
  Renders a composite card-shaped skeleton with a header image area and text
  lines below it.

  Useful as a drop-in replacement for product cards, blog post cards, or
  dashboard stat cards while their content is loading.

  ## Example

      <div class="grid grid-cols-3 gap-4">
        <%= for _ <- 1..3 do %>
          <.skeleton_card />
        <% end %>
      </div>
  """
  def skeleton_card(assigns) do
    ~H"""
    <div class={cn(["rounded-lg border p-4 space-y-3", @class])}>
      <%!-- Tall rectangle simulates a card image or header area --%>
      <.skeleton class="h-40 w-full" />
      <%!-- Three text lines simulate title + excerpt --%>
      <.skeleton_text lines={3} />
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  # Rectangle: moderately rounded corners (matches card, button, input shapes)
  defp shape_class(:rectangle), do: "rounded-md"
  # Circle: fully rounded (for avatar placeholders)
  defp shape_class(:circle), do: "rounded-full"

  # Build inline style from width/height, avoiding empty style="" attributes.
  # Each clause handles a different combination of nil/non-nil values.
  defp style_attrs(nil, nil), do: %{}
  defp style_attrs(width, nil), do: %{style: "width: #{width};"}
  defp style_attrs(nil, height), do: %{style: "height: #{height};"}
  defp style_attrs(width, height), do: %{style: "width: #{width}; height: #{height};"}
end
