defmodule PhiaUi.Components.ProfileCard do
  @moduledoc """
  ProfileCard — a user profile display card with avatar, name, role, online status, and composable slots.

  Renders a `Card` containing an avatar (with optional status dot), the user's
  name, an optional role/title, and three optional content slots: biography
  text, tags/labels, and action buttons.

  ## Layout variants

  | `:variant`     | Layout                               |
  |----------------|--------------------------------------|
  | `:vertical`    | Centered column — avatar on top      |
  | `:horizontal`  | Row — avatar left, content right     |

  ## Status dot colours

  When `:status` is provided, a small coloured dot is overlaid on the bottom-right
  corner of the avatar:

  | `:status`   | Dot colour       |
  |-------------|------------------|
  | `:online`   | `emerald-500`    |
  | `:offline`  | `gray-400`       |
  | `:busy`     | `red-500`        |
  | `:away`     | `amber-500`      |

  ## Examples

      <%!-- Minimal card --%>
      <.profile_card name="Alice Smith" fallback="AS" />

      <%!-- With role and online status --%>
      <.profile_card
        name="Alice Smith"
        role="Senior Engineer"
        src="/avatars/alice.jpg"
        fallback="AS"
        status={:online}
      />

      <%!-- Horizontal layout with bio, tags, and actions --%>
      <.profile_card name="Bob" fallback="B" variant={:horizontal} role="Designer">
        <:bio>Open-source enthusiast and Elixir advocate.</:bio>
        <:tags>
          <span class="text-xs bg-muted rounded px-1 py-0.5">Elixir</span>
          <span class="text-xs bg-muted rounded px-1 py-0.5">Phoenix</span>
        </:tags>
        <:actions>
          <.button size={:sm}>Follow</.button>
          <.button size={:sm} variant={:outline}>Message</.button>
        </:actions>
      </.profile_card>

      <%!-- Team grid --%>
      <div class="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
        <.profile_card
          :for={member <- @team_members}
          name={member.name}
          role={member.title}
          src={member.avatar_url}
          fallback={member.initials}
          status={member.status}
        />
      </div>
  """

  use Phoenix.Component

  import PhiaUi.Components.Card
  import PhiaUi.Components.Avatar
  import PhiaUi.ClassMerger, only: [cn: 1]

  attr(:name, :string, required: true, doc: "Display name")
  attr(:role, :string, default: nil, doc: "Job title or role")
  attr(:src, :string, default: nil, doc: "Avatar image URL")
  attr(:fallback, :string, default: nil, doc: "Initials for the avatar fallback")

  attr(:status, :atom,
    default: nil,
    values: [nil, :online, :offline, :busy, :away],
    doc: "Online presence status"
  )

  attr(:variant, :atom,
    default: :vertical,
    values: [:vertical, :horizontal],
    doc: "Layout variant: :vertical (centered) or :horizontal (row)"
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:rest, :global, doc: "HTML attributes forwarded to the outer card")

  slot(:bio, doc: "Short biography text")
  slot(:tags, doc: "Tag chips or labels")
  slot(:actions, doc: "Action buttons (follow, message, etc.)")

  @doc """
  Renders a user profile card.

  Wraps all content inside a `PhiaUi.Components.Card`. The inner layout is
  controlled by the `variant` attribute:

  - `:vertical` — avatar centered above the name/role text (default)
  - `:horizontal` — avatar on the left, name/role/bio/tags/actions on the right

  The optional status dot is a `<span>` with `ring-2 ring-background` so it
  renders cleanly over any card background colour.

  ## Examples

      <.profile_card name="Alice" fallback="AL" status={:online} />

      <.profile_card name="Bob" role="CTO" variant={:horizontal}>
        <:bio>Building the future of developer tooling.</:bio>
        <:actions><.button size={:sm}>Follow</.button></:actions>
      </.profile_card>
  """
  def profile_card(assigns) do
    ~H"""
    <.card class={cn(["p-6", @class])} {@rest}>
      <div class={cn([variant_layout(@variant)])}>
        <%!-- Avatar with optional status dot --%>
        <div class="relative shrink-0">
          <.avatar size="lg">
            <.avatar_image :if={@src} src={@src} alt={@name} />
            <.avatar_fallback name={@fallback || @name} />
          </.avatar>
          <span
            :if={@status != nil}
            class={cn([
              "absolute bottom-0 right-0 block h-3 w-3 rounded-full ring-2 ring-background",
              status_color(@status)
            ])}
          />
        </div>

        <%!-- Text content --%>
        <div class={cn([content_layout(@variant)])}>
          <p class="text-lg font-semibold leading-none">{@name}</p>
          <p :if={@role} class="mt-1 text-sm text-muted-foreground">{@role}</p>
          <div :if={@bio != []} class="mt-2 text-sm text-muted-foreground">
            {render_slot(@bio)}
          </div>
          <div :if={@tags != []} class="mt-3 flex flex-wrap gap-1">
            {render_slot(@tags)}
          </div>
          <div :if={@actions != []} class="mt-4 flex gap-2">
            {render_slot(@actions)}
          </div>
        </div>
      </div>
    </.card>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers — pattern matching only, no case/cond
  # ---------------------------------------------------------------------------

  defp variant_layout(:vertical), do: "flex flex-col items-center text-center gap-3"
  defp variant_layout(:horizontal), do: "flex flex-row items-start gap-4"

  defp content_layout(:vertical), do: "flex flex-col items-center"
  defp content_layout(:horizontal), do: "flex flex-col"

  defp status_color(:online), do: "bg-emerald-500"
  defp status_color(:offline), do: "bg-gray-400"
  defp status_color(:busy), do: "bg-red-500"
  defp status_color(:away), do: "bg-amber-500"
end
