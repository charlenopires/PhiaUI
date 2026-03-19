defmodule PhiaUi.Components.Editor.ContentBlocks do
  @moduledoc """
  Editor Content Block Components — 14 rich content blocks for embedding
  interactive and media elements inside a rich text editor.

  These components cover collapsible toggle lists, tabbed content, video/audio
  players, bookmark link previews, CTA buttons, progress indicators, labeled
  dividers, math blocks, social embeds, PDF viewers, and map embeds.

  All components render meaningful HTML without JavaScript (progressive
  enhancement) and support dark mode via Tailwind v4 design tokens.

  ## Components

  ### Interactive Blocks
  - `toggle_list/1`          — collapsible list container
  - `toggle_list_item/1`     — individual toggleable details/summary item
  - `tab_block/1`            — tabbed content sections with tab buttons
  - `tab_block_panel/1`      — individual tab panel (shows/hides by active tab)

  ### Media Blocks
  - `video_block/1`          — HTML5 video player with poster support
  - `audio_block/1`          — audio player with labeled header
  - `bookmark_card/1`        — URL preview card with favicon, image, and domain
  - `social_embed_block/1`   — rich social card with provider icon

  ### Content Widgets
  - `button_block/1`         — CTA button inside editor content
  - `progress_bar_block/1`   — inline progress indicator with label
  - `divider_with_label/1`   — HR with centered text label

  ### Specialized Blocks
  - `math_block/1`           — LaTeX block with input and preview area
  - `pdf_viewer_block/1`     — iframe PDF viewer with download link
  - `map_embed_block/1`      — iframe map embed with aspect-video container
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  # ============================================================================
  # 1. toggle_list/1
  # ============================================================================

  attr :id, :string, required: true, doc: "Unique identifier for the toggle list."
  attr :class, :string, default: nil, doc: "Additional CSS classes."

  slot :inner_block, required: true, doc: "Toggle list items."

  @doc """
  Renders a collapsible list container.

  Wraps toggle list items in a semantic `role="list"` container with
  `data-type="toggleList"` for editor integration.

  ## Example

      <.toggle_list id="my-toggles">
        <.toggle_list_item id="item-1" label="Section A" open={true}>
          Content for section A.
        </.toggle_list_item>
      </.toggle_list>
  """
  def toggle_list(assigns) do
    ~H"""
    <div
      id={@id}
      data-type="toggleList"
      role="list"
      class={cn(["space-y-1", @class])}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end

  # ============================================================================
  # 2. toggle_list_item/1
  # ============================================================================

  attr :id, :string, required: true, doc: "Unique identifier for the toggle item."
  attr :label, :string, required: true, doc: "Summary label text."
  attr :open, :boolean, default: false, doc: "Whether the item is initially expanded."
  attr :class, :string, default: nil, doc: "Additional CSS classes."

  slot :inner_block, required: true, doc: "Collapsible content."

  @doc """
  Renders an individual toggleable item using `<details>/<summary>`.

  The chevron icon rotates when the item is open. Uses native HTML disclosure
  so it works without JavaScript.

  ## Example

      <.toggle_list_item id="faq-1" label="What is PhiaUI?" open={true}>
        PhiaUI is a component library for Phoenix LiveView.
      </.toggle_list_item>
  """
  def toggle_list_item(assigns) do
    ~H"""
    <details
      id={@id}
      open={@open}
      role="listitem"
      class={cn([
        "group rounded-md border border-border bg-background",
        @class
      ])}
    >
      <summary class={cn([
        "flex cursor-pointer select-none items-center gap-2 px-3 py-2",
        "text-sm font-medium text-foreground",
        "hover:bg-accent/50 transition-colors",
        "[&::-webkit-details-marker]:hidden list-none"
      ])}>
        <svg
          xmlns="http://www.w3.org/2000/svg"
          width="14"
          height="14"
          viewBox="0 0 24 24"
          fill="none"
          stroke="currentColor"
          stroke-width="2"
          stroke-linecap="round"
          stroke-linejoin="round"
          aria-hidden="true"
          class="shrink-0 text-muted-foreground transition-transform duration-200 group-open:rotate-90"
        >
          <path d="m9 18 6-6-6-6" />
        </svg>
        <span>{@label}</span>
      </summary>
      <div class="px-3 pb-3 pt-1 text-sm leading-relaxed text-foreground">
        {render_slot(@inner_block)}
      </div>
    </details>
    """
  end

  # ============================================================================
  # 3. tab_block/1
  # ============================================================================

  attr :id, :string, required: true, doc: "Unique identifier for the tab block."

  attr :tabs, :list,
    default: [],
    doc: "List of maps with `:label` and `:id` keys representing each tab."

  attr :active_tab, :string, default: nil, doc: "The ID of the currently active tab."
  attr :class, :string, default: nil, doc: "Additional CSS classes."

  slot :inner_block, required: true, doc: "Tab panels (use tab_block_panel components)."

  @doc """
  Renders tabbed content sections with a tab button bar and bottom border indicator.

  The `active_tab` defaults to the first tab ID when not provided. Each tab button
  dispatches a `phx-click` event for server-side tab switching.

  ## Example

      <.tab_block
        id="code-tabs"
        tabs={[%{id: "elixir", label: "Elixir"}, %{id: "js", label: "JavaScript"}]}
        active_tab="elixir"
      >
        <.tab_block_panel id="panel-elixir" tab_id="elixir" active_tab="elixir">
          Elixir code here.
        </.tab_block_panel>
        <.tab_block_panel id="panel-js" tab_id="js" active_tab="elixir">
          JS code here.
        </.tab_block_panel>
      </.tab_block>
  """
  def tab_block(assigns) do
    active =
      assigns.active_tab ||
        case assigns.tabs do
          [first | _] -> Map.get(first, :id, "")
          _ -> ""
        end

    assigns = assign(assigns, :resolved_active, active)

    ~H"""
    <div
      id={@id}
      data-type="tabBlock"
      class={cn([
        "rounded-lg border border-border bg-background",
        @class
      ])}
    >
      <div role="tablist" aria-label="Content tabs" class="flex border-b border-border">
        <button
          :for={tab <- @tabs}
          type="button"
          role="tab"
          aria-selected={to_string(Map.get(tab, :id) == @resolved_active)}
          aria-controls={"#{@id}-panel-#{Map.get(tab, :id, "")}"}
          phx-click="tab_block:select"
          phx-value-tab-id={Map.get(tab, :id, "")}
          phx-value-block-id={@id}
          class={cn([
            "px-4 py-2 text-sm font-medium transition-colors",
            "hover:text-foreground",
            "focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring",
            Map.get(tab, :id) == @resolved_active && "border-b-2 border-primary text-foreground",
            Map.get(tab, :id) != @resolved_active && "text-muted-foreground"
          ])}
        >
          {Map.get(tab, :label, "")}
        </button>
      </div>
      <div class="p-4">
        {render_slot(@inner_block)}
      </div>
    </div>
    """
  end

  # ============================================================================
  # 4. tab_block_panel/1
  # ============================================================================

  attr :id, :string, required: true, doc: "Unique identifier for the tab panel."
  attr :tab_id, :string, required: true, doc: "The tab ID this panel belongs to."
  attr :active_tab, :string, default: nil, doc: "The currently active tab ID."
  attr :class, :string, default: nil, doc: "Additional CSS classes."

  slot :inner_block, required: true, doc: "Panel content."

  @doc """
  Renders an individual tab panel that shows or hides based on matching
  `tab_id` to `active_tab`.

  ## Example

      <.tab_block_panel id="panel-1" tab_id="overview" active_tab="overview">
        Overview content here.
      </.tab_block_panel>
  """
  def tab_block_panel(assigns) do
    ~H"""
    <div
      :if={@tab_id == @active_tab}
      id={@id}
      role="tabpanel"
      aria-labelledby={"tab-#{@tab_id}"}
      class={cn(["text-sm leading-relaxed text-foreground", @class])}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end

  # ============================================================================
  # 5. video_block/1
  # ============================================================================

  attr :id, :string, required: true, doc: "Unique identifier for the video block."
  attr :src, :string, required: true, doc: "URL of the video source."
  attr :poster, :string, default: nil, doc: "URL of the poster/thumbnail image."
  attr :controls, :boolean, default: true, doc: "Whether to show native video controls."
  attr :autoplay, :boolean, default: false, doc: "Whether to autoplay the video."
  attr :class, :string, default: nil, doc: "Additional CSS classes."

  @doc """
  Renders an HTML5 video player in a rounded container.

  Supports poster image, native controls, and autoplay (muted when autoplay
  is enabled for browser compatibility).

  ## Example

      <.video_block id="demo-vid" src="/videos/demo.mp4" poster="/images/poster.jpg" />
  """
  def video_block(assigns) do
    ~H"""
    <div
      id={@id}
      data-type="videoBlock"
      class={cn([
        "my-4 overflow-hidden rounded-lg border border-border bg-black",
        @class
      ])}
    >
      <video
        src={@src}
        poster={@poster}
        controls={@controls}
        autoplay={@autoplay}
        muted={@autoplay}
        playsinline
        preload="metadata"
        class="w-full"
        aria-label="Video player"
      >
        Your browser does not support the video element.
      </video>
    </div>
    """
  end

  # ============================================================================
  # 6. audio_block/1
  # ============================================================================

  attr :id, :string, required: true, doc: "Unique identifier for the audio block."
  attr :src, :string, required: true, doc: "URL of the audio source."
  attr :title, :string, default: nil, doc: "Optional title label for the audio."
  attr :class, :string, default: nil, doc: "Additional CSS classes."

  @doc """
  Renders an audio player with a labeled header.

  Uses native `<audio controls>` for maximum browser compatibility.

  ## Example

      <.audio_block id="podcast-1" src="/audio/episode.mp3" title="Episode 42" />
  """
  def audio_block(assigns) do
    ~H"""
    <div
      id={@id}
      data-type="audioBlock"
      class={cn([
        "my-4 rounded-lg border border-border bg-background p-3",
        @class
      ])}
    >
      <div :if={@title} class="mb-2 flex items-center gap-2">
        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true" class="shrink-0 text-muted-foreground">
          <path d="M9 18V5l12-2v13" />
          <circle cx="6" cy="18" r="3" />
          <circle cx="18" cy="16" r="3" />
        </svg>
        <span class="text-sm font-medium text-foreground">{@title}</span>
      </div>
      <audio
        src={@src}
        controls
        preload="metadata"
        class="w-full"
        aria-label={@title || "Audio player"}
      >
        Your browser does not support the audio element.
      </audio>
    </div>
    """
  end

  # ============================================================================
  # 7. bookmark_card/1
  # ============================================================================

  attr :id, :string, required: true, doc: "Unique identifier for the bookmark card."
  attr :url, :string, required: true, doc: "The bookmarked URL."
  attr :title, :string, default: nil, doc: "Title of the bookmarked page."
  attr :description, :string, default: nil, doc: "Description or excerpt."
  attr :favicon, :string, default: nil, doc: "URL of the site favicon."
  attr :image, :string, default: nil, doc: "URL of the preview image."
  attr :class, :string, default: nil, doc: "Additional CSS classes."

  @doc """
  Renders a URL preview card (bookmark) with optional image, title, description,
  favicon, and domain display.

  ## Example

      <.bookmark_card
        id="bm-1"
        url="https://example.com/article"
        title="Great Article"
        description="A summary of the article content."
        favicon="https://example.com/favicon.ico"
        image="https://example.com/og-image.jpg"
      />
  """
  def bookmark_card(assigns) do
    domain = extract_domain(assigns.url)
    assigns = assign(assigns, :domain, domain)

    ~H"""
    <a
      id={@id}
      href={@url}
      target="_blank"
      rel="noopener noreferrer"
      data-type="bookmarkCard"
      class={cn([
        "my-4 flex overflow-hidden rounded-lg border border-border bg-background",
        "transition-colors hover:bg-accent/30",
        "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring",
        @class
      ])}
    >
      <div class="flex min-w-0 flex-1 flex-col justify-between p-3">
        <div>
          <p :if={@title} class="text-sm font-medium text-foreground line-clamp-1">
            {@title}
          </p>
          <p :if={@description} class="mt-1 text-xs text-muted-foreground line-clamp-2">
            {@description}
          </p>
        </div>
        <div class="mt-2 flex items-center gap-1.5">
          <img
            :if={@favicon}
            src={@favicon}
            alt=""
            width="14"
            height="14"
            class="h-3.5 w-3.5 shrink-0 rounded-sm"
            loading="lazy"
          />
          <span class="truncate text-xs text-muted-foreground">{@domain}</span>
        </div>
      </div>
      <div :if={@image} class="hidden w-40 shrink-0 sm:block">
        <img
          src={@image}
          alt=""
          class="h-full w-full object-cover"
          loading="lazy"
        />
      </div>
    </a>
    """
  end

  defp extract_domain(url) do
    case URI.parse(url) do
      %URI{host: host} when is_binary(host) -> host
      _ -> url
    end
  end

  # ============================================================================
  # 8. button_block/1
  # ============================================================================

  attr :id, :string, default: nil, doc: "Optional identifier for the button."
  attr :label, :string, required: true, doc: "Button label text."
  attr :href, :string, default: nil, doc: "URL for anchor-style button."

  attr :variant, :atom,
    default: :primary,
    values: [:primary, :outline, :ghost],
    doc: "Visual variant of the button."

  attr :class, :string, default: nil, doc: "Additional CSS classes."
  attr :rest, :global, doc: "Additional HTML attributes."

  @doc """
  Renders a CTA button inside editor content.

  When `href` is provided, renders as an `<a>` tag. Otherwise renders as a
  `<button>`. Supports primary, outline, and ghost variants.

  ## Example

      <.button_block label="Get Started" href="/signup" variant={:primary} />
      <.button_block label="Learn More" variant={:outline} />
  """
  def button_block(assigns) do
    ~H"""
    <div class="my-4 flex justify-center" data-type="buttonBlock">
      <a
        :if={@href}
        id={@id}
        href={@href}
        class={cn([button_block_class(@variant), @class])}
        {@rest}
      >
        {@label}
      </a>
      <button
        :if={!@href}
        id={@id}
        type="button"
        class={cn([button_block_class(@variant), @class])}
        {@rest}
      >
        {@label}
      </button>
    </div>
    """
  end

  defp button_block_class(:primary) do
    cn([
      "inline-flex items-center justify-center rounded-md px-6 py-2.5",
      "text-sm font-medium",
      "bg-primary text-primary-foreground",
      "hover:bg-primary/90 transition-colors",
      "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2"
    ])
  end

  defp button_block_class(:outline) do
    cn([
      "inline-flex items-center justify-center rounded-md px-6 py-2.5",
      "text-sm font-medium",
      "border border-border bg-background text-foreground",
      "hover:bg-accent hover:text-accent-foreground transition-colors",
      "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2"
    ])
  end

  defp button_block_class(:ghost) do
    cn([
      "inline-flex items-center justify-center rounded-md px-6 py-2.5",
      "text-sm font-medium",
      "text-foreground",
      "hover:bg-accent hover:text-accent-foreground transition-colors",
      "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2"
    ])
  end

  # ============================================================================
  # 9. progress_bar_block/1
  # ============================================================================

  attr :id, :string, default: nil, doc: "Optional identifier for the progress block."
  attr :value, :integer, default: 0, doc: "Progress value between 0 and 100."
  attr :label, :string, default: nil, doc: "Optional label text above the bar."
  attr :class, :string, default: nil, doc: "Additional CSS classes."

  @doc """
  Renders an inline progress bar with optional label and percentage display.

  The bar width is set via inline style based on the `value` attribute (0-100).

  ## Example

      <.progress_bar_block value={75} label="Upload progress" />
      <.progress_bar_block id="proj-progress" value={42} />
  """
  def progress_bar_block(assigns) do
    clamped = max(0, min(100, assigns.value))
    assigns = assign(assigns, :clamped, clamped)

    ~H"""
    <div
      id={@id}
      data-type="progressBarBlock"
      class={cn(["my-4", @class])}
    >
      <div :if={@label || @clamped > 0} class="mb-1 flex items-center justify-between">
        <span :if={@label} class="text-xs font-medium text-foreground">{@label}</span>
        <span class="text-xs tabular-nums text-muted-foreground">{@clamped}%</span>
      </div>
      <div
        class="h-2 w-full overflow-hidden rounded-full bg-muted"
        role="progressbar"
        aria-valuenow={@clamped}
        aria-valuemin="0"
        aria-valuemax="100"
        aria-label={@label || "Progress"}
      >
        <div
          class="h-full rounded-full bg-primary transition-all duration-300"
          style={"width: #{@clamped}%"}
        />
      </div>
    </div>
    """
  end

  # ============================================================================
  # 10. divider_with_label/1
  # ============================================================================

  attr :label, :string, required: true, doc: "Text label displayed at the center of the divider."
  attr :class, :string, default: nil, doc: "Additional CSS classes."

  @doc """
  Renders a horizontal rule with a centered text label.

  Uses a flex container with two lines (pseudo-elements via bg-border spans)
  flanking the centered text.

  ## Example

      <.divider_with_label label="Section 2" />
      <.divider_with_label label="OR" />
  """
  def divider_with_label(assigns) do
    ~H"""
    <div
      role="separator"
      aria-label={@label}
      class={cn(["my-6 flex items-center gap-3", @class])}
    >
      <span class="h-px flex-1 bg-border" aria-hidden="true" />
      <span class="text-xs font-medium text-muted-foreground">{@label}</span>
      <span class="h-px flex-1 bg-border" aria-hidden="true" />
    </div>
    """
  end

  # ============================================================================
  # 11. math_block/1
  # ============================================================================

  attr :id, :string, required: true, doc: "Unique identifier for the math block."
  attr :value, :string, default: "", doc: "LaTeX source string."
  attr :class, :string, default: nil, doc: "Additional CSS classes."

  @doc """
  Renders a LaTeX math block with a textarea for input and a preview area.

  The preview area includes a `data-math-preview` attribute for client-side
  rendering via KaTeX or MathJax. Without JavaScript, the raw LaTeX source is
  displayed as a fallback.

  ## Example

      <.math_block id="eq-1" value="E = mc^2" />
      <.math_block id="eq-2" value="\\\\int_0^1 x^2 dx" />
  """
  def math_block(assigns) do
    ~H"""
    <div
      id={@id}
      data-type="mathBlock"
      class={cn([
        "my-4 rounded-lg border border-border bg-background",
        @class
      ])}
    >
      <div class="flex items-center gap-2 border-b border-border px-3 py-2">
        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true" class="shrink-0 text-muted-foreground">
          <path d="M4 20h4l6-14h-4" />
          <path d="M14 20h6" />
          <path d="M14 16l3 4 3-4" />
        </svg>
        <span class="text-xs font-medium text-muted-foreground">Math Block</span>
      </div>
      <div class="grid grid-cols-1 divide-y divide-border md:grid-cols-2 md:divide-x md:divide-y-0">
        <div class="p-3">
          <label for={"#{@id}-input"} class="mb-1 block text-xs font-medium text-muted-foreground">
            LaTeX Source
          </label>
          <textarea
            id={"#{@id}-input"}
            name={"#{@id}-math"}
            rows="3"
            placeholder="E = mc^2"
            class={cn([
              "w-full resize-none rounded-md border border-input bg-muted/30 px-3 py-2",
              "font-mono text-sm text-foreground",
              "placeholder:text-muted-foreground",
              "focus:outline-none focus:ring-2 focus:ring-ring"
            ])}
          >{@value}</textarea>
        </div>
        <div class="p-3">
          <span class="mb-1 block text-xs font-medium text-muted-foreground">Preview</span>
          <div
            data-math-preview
            aria-label="Math preview"
            class="flex min-h-[4.5rem] items-center justify-center rounded-md bg-muted/20 p-3 font-mono text-sm text-foreground"
          >
            {if @value != "" and @value != nil, do: @value, else: "No equation entered"}
          </div>
        </div>
      </div>
    </div>
    """
  end

  # ============================================================================
  # 12. social_embed_block/1
  # ============================================================================

  attr :id, :string, required: true, doc: "Unique identifier for the social embed."
  attr :url, :string, required: true, doc: "URL of the social post or content."

  attr :provider, :atom,
    default: :generic,
    values: [:twitter, :youtube, :instagram, :generic],
    doc: "Social media provider for icon display."

  attr :class, :string, default: nil, doc: "Additional CSS classes."

  @doc """
  Renders a rich social card with provider icon and a link to the content.

  The provider determines the icon and label. Links open in a new tab with
  `rel="noopener noreferrer"` for security.

  ## Example

      <.social_embed_block id="tweet-1" url="https://twitter.com/user/status/123" provider={:twitter} />
      <.social_embed_block id="yt-1" url="https://youtube.com/watch?v=abc" provider={:youtube} />
  """
  def social_embed_block(assigns) do
    ~H"""
    <div
      id={@id}
      data-type="socialEmbed"
      data-provider={@provider}
      class={cn([
        "my-4 flex items-center gap-3 rounded-lg border border-border bg-muted/30 p-4",
        "transition-colors hover:bg-accent/30",
        @class
      ])}
    >
      <div class="flex h-10 w-10 shrink-0 items-center justify-center rounded-lg bg-background">
        {provider_icon(assigns)}
      </div>
      <div class="min-w-0 flex-1">
        <a
          href={@url}
          target="_blank"
          rel="noopener noreferrer"
          class="block truncate text-sm font-medium text-foreground hover:text-primary hover:underline focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring"
        >
          {@url}
        </a>
        <span class="text-xs text-muted-foreground">{provider_label(@provider)}</span>
      </div>
      <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true" class="shrink-0 text-muted-foreground">
        <path d="M18 13v6a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h6" />
        <polyline points="15 3 21 3 21 9" />
        <line x1="10" y1="14" x2="21" y2="3" />
      </svg>
    </div>
    """
  end

  defp provider_icon(%{provider: :twitter} = assigns) do
    ~H"""
    <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true" class="text-foreground">
      <path d="M18.244 2.25h3.308l-7.227 8.26 8.502 11.24H16.17l-5.214-6.817L4.99 21.75H1.68l7.73-8.835L1.254 2.25H8.08l4.713 6.231zm-1.161 17.52h1.833L7.084 4.126H5.117z" />
    </svg>
    """
  end

  defp provider_icon(%{provider: :youtube} = assigns) do
    ~H"""
    <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true" class="text-red-600">
      <path d="M23.498 6.186a3.016 3.016 0 0 0-2.122-2.136C19.505 3.545 12 3.545 12 3.545s-7.505 0-9.377.505A3.017 3.017 0 0 0 .502 6.186C0 8.07 0 12 0 12s0 3.93.502 5.814a3.016 3.016 0 0 0 2.122 2.136c1.871.505 9.376.505 9.376.505s7.505 0 9.377-.505a3.015 3.015 0 0 0 2.122-2.136C24 15.93 24 12 24 12s0-3.93-.502-5.814zM9.545 15.568V8.432L15.818 12l-6.273 3.568z" />
    </svg>
    """
  end

  defp provider_icon(%{provider: :instagram} = assigns) do
    ~H"""
    <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true" class="text-pink-600">
      <rect width="20" height="20" x="2" y="2" rx="5" ry="5" />
      <path d="M16 11.37A4 4 0 1 1 12.63 8 4 4 0 0 1 16 11.37z" />
      <line x1="17.5" x2="17.51" y1="6.5" y2="6.5" />
    </svg>
    """
  end

  defp provider_icon(assigns) do
    ~H"""
    <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true" class="text-muted-foreground">
      <path d="M10 13a5 5 0 0 0 7.54.54l3-3a5 5 0 0 0-7.07-7.07l-1.72 1.71" />
      <path d="M14 11a5 5 0 0 0-7.54-.54l-3 3a5 5 0 0 0 7.07 7.07l1.71-1.71" />
    </svg>
    """
  end

  defp provider_label(:twitter), do: "View on X (Twitter)"
  defp provider_label(:youtube), do: "View on YouTube"
  defp provider_label(:instagram), do: "View on Instagram"
  defp provider_label(:generic), do: "View external content"

  # ============================================================================
  # 13. pdf_viewer_block/1
  # ============================================================================

  attr :id, :string, required: true, doc: "Unique identifier for the PDF viewer."
  attr :src, :string, required: true, doc: "URL of the PDF file."
  attr :class, :string, default: nil, doc: "Additional CSS classes."

  @doc """
  Renders an iframe-based PDF viewer with a header showing the filename and
  a download link.

  The iframe has `type="application/pdf"` and a minimum height of 500px for
  adequate viewing area.

  ## Example

      <.pdf_viewer_block id="report" src="/files/quarterly-report.pdf" />
  """
  def pdf_viewer_block(assigns) do
    filename = extract_filename(assigns.src)
    assigns = assign(assigns, :filename, filename)

    ~H"""
    <div
      id={@id}
      data-type="pdfViewer"
      class={cn([
        "my-4 overflow-hidden rounded-lg border border-border bg-background",
        @class
      ])}
    >
      <div class="flex items-center justify-between border-b border-border px-3 py-2">
        <div class="flex items-center gap-2 min-w-0">
          <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true" class="shrink-0 text-red-500">
            <path d="M15 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V7Z" />
            <path d="M14 2v4a2 2 0 0 0 2 2h4" />
            <path d="M10 12h4" />
            <path d="M10 16h4" />
          </svg>
          <span class="truncate text-xs font-medium text-foreground">{@filename}</span>
        </div>
        <a
          href={@src}
          download={@filename}
          aria-label={"Download #{@filename}"}
          class="inline-flex h-7 items-center gap-1 rounded-md px-2 text-xs text-muted-foreground transition-colors hover:bg-accent hover:text-foreground focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring"
        >
          <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
            <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4" />
            <polyline points="7 10 12 15 17 10" />
            <line x1="12" y1="15" x2="12" y2="3" />
          </svg>
          Download
        </a>
      </div>
      <iframe
        src={@src}
        type="application/pdf"
        title={"PDF: #{@filename}"}
        class="w-full"
        style="min-height: 500px"
        loading="lazy"
      />
    </div>
    """
  end

  defp extract_filename(src) do
    src
    |> URI.parse()
    |> Map.get(:path, src)
    |> String.split("/")
    |> List.last()
    |> Kernel.||("document.pdf")
  end

  # ============================================================================
  # 14. map_embed_block/1
  # ============================================================================

  attr :id, :string, required: true, doc: "Unique identifier for the map embed."
  attr :src, :string, required: true, doc: "URL of the map embed (e.g. Google Maps embed)."
  attr :title, :string, default: "Map", doc: "Accessible title for the map iframe."
  attr :class, :string, default: nil, doc: "Additional CSS classes."

  @doc """
  Renders a bordered container with an iframe map embed in an aspect-video
  aspect ratio.

  ## Example

      <.map_embed_block
        id="office-map"
        src="https://www.google.com/maps/embed?pb=..."
        title="Office Location"
      />
  """
  def map_embed_block(assigns) do
    ~H"""
    <div
      id={@id}
      data-type="mapEmbed"
      class={cn([
        "my-4 overflow-hidden rounded-lg border border-border bg-background",
        @class
      ])}
    >
      <div class="flex items-center gap-2 border-b border-border px-3 py-2">
        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true" class="shrink-0 text-muted-foreground">
          <path d="M20 10c0 6-8 12-8 12s-8-6-8-12a8 8 0 0 1 16 0Z" />
          <circle cx="12" cy="10" r="3" />
        </svg>
        <span class="text-xs font-medium text-muted-foreground">{@title}</span>
      </div>
      <div class="relative aspect-video w-full">
        <iframe
          src={@src}
          title={@title}
          frameborder="0"
          allowfullscreen
          loading="lazy"
          referrerpolicy="no-referrer-when-downgrade"
          class="absolute inset-0 h-full w-full"
        />
      </div>
    </div>
    """
  end
end
