defmodule PhiaUi.Components.TeamCard do
  @moduledoc """
  TeamCard — displays a team member with avatar, name, role, department, email,
  and optional badge/action slots.

  ## Variants

  | Variant       | Description                                       |
  |---------------|---------------------------------------------------|
  | `:default`    | Centered layout, avatar size :lg                  |
  | `:compact`    | Centered layout, avatar size :md, denser spacing  |
  | `:horizontal` | Row layout, avatar left (size :md), content right |

  ## Examples

      <.team_card name="Alice Smith" role="Engineer" department="Platform" email="alice@example.com" />

      <.team_card name="Bob" variant={:compact} fallback="B">
        <:badges><span>Lead</span></:badges>
        <:actions><button>Message</button></:actions>
      </.team_card>

      <.team_card name="Carol" variant={:horizontal} role="Designer" />
  """

  use Phoenix.Component

  import PhiaUi.Components.Card
  import PhiaUi.Components.Avatar
  import PhiaUi.ClassMerger, only: [cn: 1]

  attr(:name, :string, required: true, doc: "Team member's display name")
  attr(:role, :string, default: nil, doc: "Job title")
  attr(:department, :string, default: nil, doc: "Department or team name")
  attr(:src, :string, default: nil, doc: "Avatar image URL")
  attr(:fallback, :string, default: nil, doc: "Initials for avatar fallback")
  attr(:email, :string, default: nil, doc: "Email address")

  attr(:variant, :atom,
    default: :default,
    values: [:default, :compact, :horizontal],
    doc: "Layout variant"
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:rest, :global, doc: "HTML attributes forwarded to the outer card")

  slot(:badges, doc: "Badge chips (role tags, skills, etc.)")
  slot(:actions, doc: "Action buttons")

  @doc """
  Renders a team member card.

  The card layout is controlled by `variant`:

  - `:default` — centered column. Large avatar (`:lg`) above the member's
    name, role, department, and email. Badges and action buttons stack below.
  - `:compact` — centered column, medium avatar and tighter text sizes.
    Use in dense grids where space is limited.
  - `:horizontal` — flex row. Medium avatar on the left; name, role,
    department, email, badges, and actions on the right.

  All text fields (`role`, `department`, `email`, `badges`, `actions`) are
  optional — the layout adapts cleanly when they are not provided.

  ## Examples

      <%!-- Minimal team member --%>
      <.team_card name="Alice Smith" />

      <%!-- Vertical card with all fields --%>
      <.team_card
        name="Alice Smith"
        role="Senior Engineer"
        department="Platform"
        email="alice@example.com"
        src="/avatars/alice.jpg"
        fallback="AS"
      >
        <:badges>
          <.badge>Elixir</.badge>
          <.badge variant={:outline}>Phoenix</.badge>
        </:badges>
        <:actions>
          <.button size={:sm}>Message</.button>
        </:actions>
      </.team_card>

      <%!-- Horizontal compact team list --%>
      <div class="space-y-3">
        <.team_card
          :for={member <- @team}
          name={member.name}
          role={member.title}
          department={member.department}
          src={member.avatar_url}
          variant={:horizontal}
        />
      </div>
  """
  def team_card(assigns) do
    ~H"""
    <.card class={cn(["p-6", @class])} {@rest}>
      <div class={cn([container_class(@variant)])}>
        <%!-- Avatar --%>
        <.avatar size={avatar_size(@variant)}>
          <.avatar_image :if={@src} src={@src} alt={@name} />
          <.avatar_fallback name={@fallback || @name} />
        </.avatar>

        <%!-- Text content --%>
        <div class={cn([content_class(@variant)])}>
          <p class={cn(["font-semibold leading-none", name_size(@variant)])}>{@name}</p>
          <p :if={@role} class={cn(["text-muted-foreground", role_size(@variant)])}>{@role}</p>
          <p :if={@department} class={cn(["text-muted-foreground", dept_size(@variant)])}>
            {@department}
          </p>
          <p :if={@email} class={cn(["text-muted-foreground break-all", email_size(@variant)])}>
            {@email}
          </p>
          <div :if={@badges != []} class="mt-2 flex flex-wrap gap-1">
            {render_slot(@badges)}
          </div>
          <div :if={@actions != []} class="mt-3 flex gap-2">
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

  defp container_class(:default), do: "flex flex-col items-center text-center gap-3"
  defp container_class(:compact), do: "flex flex-col items-center text-center gap-2"
  defp container_class(:horizontal), do: "flex flex-row items-start gap-4"

  defp content_class(:default), do: "flex flex-col items-center"
  defp content_class(:compact), do: "flex flex-col items-center"
  defp content_class(:horizontal), do: "flex flex-col"

  defp avatar_size(:default), do: "lg"
  defp avatar_size(:compact), do: "default"
  defp avatar_size(:horizontal), do: "default"

  defp name_size(:default), do: "text-base mt-1"
  defp name_size(:compact), do: "text-sm mt-0.5"
  defp name_size(:horizontal), do: "text-base"

  defp role_size(:default), do: "text-sm mt-1"
  defp role_size(:compact), do: "text-xs mt-0.5"
  defp role_size(:horizontal), do: "text-sm mt-0.5"

  defp dept_size(:default), do: "text-xs mt-0.5"
  defp dept_size(:compact), do: "text-xs"
  defp dept_size(:horizontal), do: "text-xs mt-0.5"

  defp email_size(:default), do: "text-xs mt-1"
  defp email_size(:compact), do: "text-xs mt-0.5"
  defp email_size(:horizontal), do: "text-xs mt-0.5"
end
