defmodule PhiaUi.Components.LinkPreviewCard do
  @moduledoc """
  Card component for displaying a link preview with title, description,
  image, favicon, site name, and domain. Supports :default, :compact,
  and :minimal variants.
  """

  use Phoenix.Component

  import PhiaUi.Components.Card
  import PhiaUi.Components.Icon, only: [icon: 1]
  import PhiaUi.ClassMerger, only: [cn: 1]

  attr(:url, :string, required: true, doc: "The URL being previewed")

  attr(:title, :string, required: true, doc: "Link title text")

  attr(:description, :string, default: nil, doc: "Optional link description")

  attr(:image_src, :string, default: nil, doc: "Optional preview image URL")

  attr(:favicon_src, :string, default: nil, doc: "Optional favicon image URL")

  attr(:site_name, :string, default: nil, doc: "Optional site name label")

  attr(:variant, :atom,
    default: :default,
    values: [:default, :compact, :minimal],
    doc: "Layout variant: :default (full), :compact (horizontal), :minimal (borderless)"
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes")

  attr(:rest, :global, doc: "HTML attributes forwarded to the root element")

  @doc """
  Renders a link preview card.

  ## Examples

      <.link_preview_card
        url="https://elixir-lang.org"
        title="Elixir Programming Language"
        description="A dynamic, functional language for building scalable applications."
        site_name="elixir-lang.org"
        image_src="/og/elixir.png"
      />

      <.link_preview_card
        url="https://hexdocs.pm/phoenix"
        title="Phoenix Framework"
        variant={:compact}
      />
  """
  def link_preview_card(assigns) do
    assigns = assign(assigns, :domain, extract_domain(assigns.url))

    ~H"""
    <%= render_variant(assigns) %>
    """
  end

  # ---------------------------------------------------------------------------
  # Variant renderers — delegated from main function via pattern matching
  # ---------------------------------------------------------------------------

  defp render_variant(%{variant: :default} = assigns) do
    ~H"""
    <.card class={cn(["overflow-hidden", @class])} {@rest}>
      <%!-- Preview image --%>
      <div :if={@image_src} class="aspect-video overflow-hidden">
        <img src={@image_src} alt={@title} class="w-full h-full object-cover" />
      </div>
      <.card_content class={cn(["p-4", if(@image_src, do: "", else: "pt-4")])}>
        <%!-- Favicon + site name row --%>
        <div :if={@favicon_src || @site_name} class="flex items-center gap-1.5 mb-2">
          <img :if={@favicon_src} src={@favicon_src} alt="" class="w-4 h-4 object-contain" />
          <span :if={@site_name} class="text-xs text-muted-foreground">{@site_name}</span>
        </div>
        <%!-- Title row with external link icon --%>
        <div class="flex items-start justify-between gap-2">
          <a href={@url} target="_blank" rel="noopener noreferrer" class="text-sm font-semibold hover:underline flex-1">
            {@title}
          </a>
          <.icon name="external-link" size={:xs} class="text-muted-foreground shrink-0 mt-0.5" />
        </div>
        <%!-- Description --%>
        <p :if={@description} class="mt-1 text-xs text-muted-foreground line-clamp-2">
          {@description}
        </p>
        <%!-- Domain --%>
        <p class="mt-1 text-xs text-muted-foreground">{@domain}</p>
      </.card_content>
    </.card>
    """
  end

  defp render_variant(%{variant: :compact} = assigns) do
    ~H"""
    <.card class={cn(["", @class])} {@rest}>
      <.card_content class="p-3">
        <div class="flex items-center gap-2">
          <%!-- Favicon --%>
          <img :if={@favicon_src} src={@favicon_src} alt="" class="w-4 h-4 object-contain shrink-0" />
          <%!-- Title --%>
          <a href={@url} target="_blank" rel="noopener noreferrer" class="text-sm font-medium hover:underline flex-1 truncate">
            {@title}
          </a>
          <%!-- Domain + external link icon --%>
          <div class="flex items-center gap-1 shrink-0">
            <span class="text-xs text-muted-foreground">{@domain}</span>
            <.icon name="external-link" size={:xs} class="text-muted-foreground" />
          </div>
        </div>
      </.card_content>
    </.card>
    """
  end

  defp render_variant(%{variant: :minimal} = assigns) do
    ~H"""
    <div class={cn(["", @class])} {@rest}>
      <a href={@url} target="_blank" rel="noopener noreferrer" class="text-sm font-medium hover:underline">
        {@title}
      </a>
      <p class="text-xs text-muted-foreground">{@domain}</p>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers — pattern matching only, no case/cond
  # ---------------------------------------------------------------------------

  defp extract_domain(url) do
    case URI.parse(url) do
      %URI{host: host} when is_binary(host) -> host
      _ -> url
    end
  end
end
