defmodule PhiaUi.Components.Article do
  @moduledoc """
  Semantic article component with structured title, meta, lead, body, and footer.

  Encodes a common content pattern for blog posts, documentation pages,
  news articles, and any long-form content with a consistent typographic
  hierarchy.

  ## Examples

      <.article>
        <:title>Getting Started with PhiaUI</:title>
        <:meta>Published on March 9, 2026 · 5 min read</:meta>
        <:lead>A quick introduction to the PhiaUI component library.</:lead>
        <p>PhiaUI provides over 600 components...</p>
        <:footer>
          <span>Tags: elixir, phoenix, ui</span>
        </:footer>
      </.article>

  ## Slots

  | Slot           | Required | Purpose                                    |
  |----------------|----------|--------------------------------------------|
  | `:title`       | yes      | Article heading (`<h1>`)                   |
  | `:meta`        | no       | Author, date, reading time                 |
  | `:lead`        | no       | Intro paragraph (larger, muted)            |
  | `:inner_block` | yes      | Body content                               |
  | `:footer`      | no       | Tags, share buttons, related links         |
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  attr(:class, :string, default: nil, doc: "Additional CSS classes.")

  attr(:rest, :global, doc: "HTML attributes forwarded to the `<article>` element.")

  slot(:title, required: true, doc: "Article heading rendered inside an `<h1>`.")
  slot(:meta, doc: "Metadata row (author, date, reading time).")
  slot(:lead, doc: "Introductory paragraph with larger, muted text.")
  slot(:inner_block, required: true, doc: "Article body content.")
  slot(:footer, doc: "Footer area with border-top separator.")

  @doc "Renders a semantic `<article>` with structured typography."
  def article(assigns) do
    ~H"""
    <article class={cn(["space-y-4", @class])} {@rest}>
      <header class="space-y-2">
        <h1 class="text-3xl font-bold tracking-tight">{render_slot(@title)}</h1>
        <p :if={@meta != []} class="text-sm text-muted-foreground">
          {render_slot(@meta)}
        </p>
      </header>
      <p :if={@lead != []} class="text-lg/relaxed text-muted-foreground">
        {render_slot(@lead)}
      </p>
      <div class="prose dark:prose-invert max-w-none">
        {render_slot(@inner_block)}
      </div>
      <footer :if={@footer != []} class="border-t pt-6 mt-8 text-sm text-muted-foreground">
        {render_slot(@footer)}
      </footer>
    </article>
    """
  end
end
