defmodule PhiaUi.Components.ArticleCard do
  @moduledoc """
  ArticleCard — a blog post / article preview card.

  Supports an optional cover image, category badge, meta row (date · read time),
  title with optional link, excerpt, and author row.

  ## Examples

      <.article_card
        title="Getting Started with Elixir"
        category="Tutorial"
        date="Mar 6, 2026"
        read_time="5 min read"
        excerpt="Learn the basics of Elixir in this hands-on guide."
        author_name="Alice"
        href="/posts/getting-started"
      />

      <.article_card title="News" cover_src="/img/news.jpg" cover_alt="Newsroom" />
  """

  use Phoenix.Component

  import PhiaUi.Components.Card
  import PhiaUi.Components.Badge, only: [badge: 1]
  import PhiaUi.Components.Avatar
  import PhiaUi.ClassMerger, only: [cn: 1]

  attr :title, :string, required: true, doc: "Article title"
  attr :href, :string, default: nil, doc: "Optional URL — wraps the title in a link"
  attr :cover_src, :string, default: nil, doc: "Cover image URL"
  attr :cover_alt, :string, default: "", doc: "Cover image alt text"
  attr :category, :string, default: nil, doc: "Category label shown as a badge"
  attr :date, :string, default: nil, doc: "Publication date string"
  attr :read_time, :string, default: nil, doc: "Estimated read time (e.g. '5 min read')"
  attr :excerpt, :string, default: nil, doc: "Short preview text (line-clamped)"
  attr :author_name, :string, default: nil, doc: "Author display name"
  attr :author_src, :string, default: nil, doc: "Author avatar image URL"
  attr :class, :string, default: nil, doc: "Additional CSS classes"
  attr :rest, :global, doc: "HTML attributes forwarded to the outer card"

  @doc """
  Renders an article preview card.
  """
  def article_card(assigns) do
    ~H"""
    <.card class={cn(["overflow-hidden", @class])} {@rest}>
      <%!-- Cover image --%>
      <img
        :if={@cover_src}
        src={@cover_src}
        alt={@cover_alt}
        class="w-full aspect-video object-cover"
      />

      <.card_content class={cn(["flex flex-col gap-3", @cover_src && "pt-4"])}>
        <%!-- Category badge --%>
        <div :if={@category}>
          <.badge variant={:secondary}>{@category}</.badge>
        </div>

        <%!-- Meta row: date · read_time --%>
        <div :if={@date || @read_time} class="flex items-center gap-1 text-xs text-muted-foreground">
          <span :if={@date}>{@date}</span>
          <span :if={@date && @read_time}>&middot;</span>
          <span :if={@read_time}>{@read_time}</span>
        </div>

        <%!-- Title --%>
        <h2 class="text-xl font-bold leading-tight">
          <a :if={@href} href={@href} class="hover:underline">{@title}</a>
          <span :if={!@href}>{@title}</span>
        </h2>

        <%!-- Excerpt --%>
        <p :if={@excerpt} class="text-sm text-muted-foreground line-clamp-3">
          {@excerpt}
        </p>

        <%!-- Author row --%>
        <div :if={@author_name} class="flex items-center gap-2 mt-1">
          <.avatar :if={@author_src} size="sm">
            <.avatar_image src={@author_src} alt={@author_name} />
            <.avatar_fallback name={@author_name} />
          </.avatar>
          <span class="text-sm font-medium">{@author_name}</span>
        </div>
      </.card_content>
    </.card>
    """
  end
end
