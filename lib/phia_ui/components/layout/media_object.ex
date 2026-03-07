defmodule PhiaUi.Components.Layout.MediaObject do
  @moduledoc """
  Classic media-object layout: a fixed media element (image/icon/avatar)
  alongside a flexible body content block.

  Used for comment threads, notification items, user rows, and product cards.

  ## Examples

      <%!-- Comment row --%>
      <.media_object>
        <:media>
          <.avatar src={@user.avatar} fallback={@user.initials} />
        </:media>
        <div>
          <p class="font-semibold">{@user.name}</p>
          <p class="text-sm text-muted-foreground">{@comment.body}</p>
        </div>
      </.media_object>

      <%!-- Reversed (media on the right) --%>
      <.media_object reversed>
        <:media><.icon name="hero-bell" class="h-6 w-6" /></:media>
        <p>Notification text</p>
      </.media_object>

      <%!-- Centered alignment --%>
      <.media_object align={:center} gap={3}>
        <:media><.avatar fallback="JD" /></:media>
        <span>Jane Doe</span>
      </.media_object>
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  attr(:align, :atom,
    default: :start,
    values: [:start, :center, :end],
    doc: "Vertical alignment between media and body."
  )

  attr(:gap, :integer, default: 4, doc: "Gap between media and body (0–12) → `gap-N`.")

  attr(:reversed, :boolean, default: false, doc: "Places media to the right of the body.")

  attr(:class, :string, default: nil, doc: "Additional CSS classes merged via cn/1.")

  attr(:rest, :global, doc: "HTML attributes forwarded to the root element.")

  slot(:media, required: true, doc: "Media element: image, icon, or avatar.")
  slot(:inner_block, required: true, doc: "Body content alongside the media.")

  @doc "Renders a media object layout."
  def media_object(assigns) do
    ~H"""
    <div
      class={cn([
        "flex",
        "gap-#{@gap}",
        align_class(@align),
        @reversed && "flex-row-reverse",
        @class
      ])}
      {@rest}
    >
      <div class="shrink-0">
        <%= render_slot(@media) %>
      </div>
      <div class="min-w-0 flex-1">
        <%= render_slot(@inner_block) %>
      </div>
    </div>
    """
  end

  defp align_class(:start), do: "items-start"
  defp align_class(:center), do: "items-center"
  defp align_class(:end), do: "items-end"
end
