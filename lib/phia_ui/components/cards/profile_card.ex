defmodule PhiaUi.Components.ProfileCard do
  @moduledoc """
  ProfileCard — a user profile display card with avatar, name, role, status, and slots.

  Supports two layout variants:
  - `:vertical` — centered flex-col layout (default)
  - `:horizontal` — flex-row layout with avatar on the left

  An optional status dot overlays the avatar to indicate online presence.

  ## Examples

      <.profile_card name="Alice Smith" role="Engineer" fallback="AS" status={:online} />

      <.profile_card name="Bob" fallback="B" variant={:horizontal}>
        <:bio>Loves Elixir.</:bio>
        <:tags><span>Elixir</span></:tags>
        <:actions><button>Follow</button></:actions>
      </.profile_card>
  """

  use Phoenix.Component

  import PhiaUi.Components.Card
  import PhiaUi.Components.Avatar
  import PhiaUi.ClassMerger, only: [cn: 1]

  attr :name, :string, required: true, doc: "Display name"
  attr :role, :string, default: nil, doc: "Job title or role"
  attr :src, :string, default: nil, doc: "Avatar image URL"
  attr :fallback, :string, default: nil, doc: "Initials for the avatar fallback"

  attr :status, :atom,
    default: nil,
    values: [nil, :online, :offline, :busy, :away],
    doc: "Online presence status"

  attr :variant, :atom,
    default: :vertical,
    values: [:vertical, :horizontal],
    doc: "Layout variant: :vertical (centered) or :horizontal (row)"

  attr :class, :string, default: nil, doc: "Additional CSS classes"
  attr :rest, :global, doc: "HTML attributes forwarded to the outer card"

  slot :bio, doc: "Short biography text"
  slot :tags, doc: "Tag chips or labels"
  slot :actions, doc: "Action buttons (follow, message, etc.)"

  @doc """
  Renders a profile card.
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
