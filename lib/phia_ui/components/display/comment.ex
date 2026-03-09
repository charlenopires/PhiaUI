defmodule PhiaUi.Components.Comment do
  @moduledoc """
  Blog-style comment with avatar, author, date, body, actions, and nested replies.

  Supports threaded conversations with configurable nesting depth via the
  `:depth` attribute. Indentation is capped at `:max_depth` to prevent
  deeply-nested threads from becoming unreadable.

  ## Examples

      <.comment_list>
        <.comment author="Jane" date="2 hours ago">
          Great article! Really enjoyed it.
          <:actions>
            <button>Reply</button>
            <button>Like</button>
          </:actions>
          <:replies>
            <.comment author="John" date="1 hour ago" depth={1}>
              Thanks! Glad you liked it.
            </.comment>
          </:replies>
        </.comment>
      </.comment_list>

  ## With avatar

      <.comment author="Alice" avatar_src="/images/alice.jpg" avatar_fallback="A" date="Just now">
        Hello world!
      </.comment>

  ## Nesting

  Each level of `:depth` adds left padding and a border-left indicator.
  Depths beyond `:max_depth` (default 4) are clamped to prevent excessive
  indentation.
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  # ---------------------------------------------------------------------------
  # comment/1
  # ---------------------------------------------------------------------------

  attr(:author, :string, required: true, doc: "Author display name.")
  attr(:avatar_src, :string, default: nil, doc: "Avatar image URL.")
  attr(:avatar_fallback, :string, default: nil, doc: "Fallback initials when no avatar image.")
  attr(:date, :string, default: nil, doc: "Human-readable date string.")
  attr(:depth, :integer, default: 0, doc: "Nesting depth (controls left indent).")
  attr(:max_depth, :integer, default: 4, doc: "Maximum indent depth.")
  attr(:class, :string, default: nil, doc: "Additional CSS classes.")
  attr(:rest, :global, doc: "HTML attributes forwarded to the root element.")

  slot(:inner_block, required: true, doc: "Comment body content.")
  slot(:actions, doc: "Reply, like, report buttons.")
  slot(:replies, doc: "Nested child comments.")
  slot(:header_extra, doc: "Badges, edited indicator, etc.")

  @doc "Renders a single comment with optional avatar, actions, and nested replies."
  def comment(assigns) do
    assigns = assign(assigns, :clamped_depth, min(assigns.depth, assigns.max_depth))

    ~H"""
    <div class={cn(["group", indent_class(@clamped_depth), @class])} {@rest}>
      <div class={cn(["flex gap-3", if(@clamped_depth > 0, do: "border-l-2 border-border pl-4")])}>
        <div class="shrink-0 mt-1">
          <div :if={@avatar_src} class="size-8 rounded-full overflow-hidden bg-muted">
            <img src={@avatar_src} alt={@author} class="size-full object-cover" />
          </div>
          <div
            :if={!@avatar_src}
            class="size-8 rounded-full bg-muted flex items-center justify-center text-xs font-medium text-muted-foreground"
          >
            {avatar_text(@avatar_fallback, @author)}
          </div>
        </div>
        <div class="flex-1 min-w-0 space-y-1">
          <div class="flex items-center gap-2 text-sm">
            <span class="font-semibold">{@author}</span>
            <span :if={@date} class="text-muted-foreground">{@date}</span>
            {render_slot(@header_extra)}
          </div>
          <div class="text-sm leading-relaxed">
            {render_slot(@inner_block)}
          </div>
          <div :if={@actions != []} class="flex items-center gap-3 pt-1 text-xs text-muted-foreground">
            {render_slot(@actions)}
          </div>
        </div>
      </div>
      <div :if={@replies != []} class="mt-4">
        {render_slot(@replies)}
      </div>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # comment_list/1
  # ---------------------------------------------------------------------------

  attr(:class, :string, default: nil, doc: "Additional CSS classes.")
  attr(:rest, :global, doc: "HTML attributes forwarded to the container.")

  slot(:inner_block, required: true, doc: "Comment children.")

  @doc "Renders a container for a list of threaded comments."
  def comment_list(assigns) do
    ~H"""
    <div class={cn(["space-y-6", @class])} {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Helpers
  # ---------------------------------------------------------------------------

  defp indent_class(0), do: nil
  defp indent_class(1), do: "pl-4"
  defp indent_class(2), do: "pl-8"
  defp indent_class(3), do: "pl-12"
  defp indent_class(_), do: "pl-16"

  defp avatar_text(nil, author), do: String.first(author || "?")
  defp avatar_text(fallback, _author), do: fallback
end
