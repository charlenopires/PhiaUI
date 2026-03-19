defmodule PhiaUi.Components.Editor.References do
  @moduledoc """
  Editor References Suite — 8 components for footnotes, citations, bookmarks,
  cross-references, bibliographies, and abbreviations.

  Provides all the building blocks for academic and technical writing reference
  management within the PhiaUI rich text editor.

  ## Components

  ### Inline References
  - `footnote/1`          — superscript footnote link with note text
  - `endnote/1`           — superscript endnote link for end-of-document references
  - `bookmark_anchor/1`   — invisible anchor `<span>` for in-document linking
  - `cross_reference/1`   — `<a>` link to a bookmark or heading within the document
  - `citation_mark/1`     — inline "(Author, Year)" citation link
  - `abbreviation_mark/1` — `<abbr>` with dotted underline and tooltip

  ### Block References
  - `bibliography/1`      — ordered list of formatted references (APA, MLA, Chicago, etc.)
  - `citation_dialog/1`   — form dialog for inserting/editing a citation entry
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  # ============================================================================
  # 1. footnote/1
  # ============================================================================

  attr :number, :integer, required: true
  attr :text, :string, default: ""
  attr :class, :string, default: nil
  attr :rest, :global

  @doc """
  Renders an inline superscript footnote marker with associated note text.

  The superscript number links to the footnote, and the text is rendered
  as a `<small>` block below.

  ## Example

      <.footnote number={1} text="See the original paper for details." />
  """
  def footnote(assigns) do
    ~H"""
    <span class={cn(["inline", @class])} {@rest}>
      <sup>
        <a
          href={"#fn-#{@number}"}
          id={"fnref-#{@number}"}
          role="doc-noteref"
          class="text-primary hover:underline focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring"
        >
          {@number}
        </a>
      </sup>
      <small
        :if={@text != ""}
        id={"fn-#{@number}"}
        role="doc-footnote"
        class="block text-xs text-muted-foreground mt-0.5"
      >
        <a href={"#fnref-#{@number}"} class="mr-1 text-primary no-underline" aria-label={"Back to reference #{@number}"}>
          &uarr;
        </a>
        {@text}
      </small>
    </span>
    """
  end

  # ============================================================================
  # 2. endnote/1
  # ============================================================================

  attr :number, :integer, required: true
  attr :text, :string, default: ""
  attr :class, :string, default: nil
  attr :rest, :global

  @doc """
  Renders an inline superscript endnote marker for end-of-document references.

  Visually identical to `footnote/1`, but uses `endnote-` ID prefixes and
  `doc-endnote` ARIA roles to distinguish semantically.

  ## Example

      <.endnote number={3} text="Full data available in Appendix B." />
  """
  def endnote(assigns) do
    ~H"""
    <span class={cn(["inline", @class])} {@rest}>
      <sup>
        <a
          href={"#en-#{@number}"}
          id={"enref-#{@number}"}
          role="doc-noteref"
          class="text-primary hover:underline focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring"
        >
          {@number}
        </a>
      </sup>
      <small
        :if={@text != ""}
        id={"en-#{@number}"}
        role="doc-endnote"
        class="block text-xs text-muted-foreground mt-0.5"
      >
        <a href={"#enref-#{@number}"} class="mr-1 text-primary no-underline" aria-label={"Back to reference #{@number}"}>
          &uarr;
        </a>
        {@text}
      </small>
    </span>
    """
  end

  # ============================================================================
  # 3. bookmark_anchor/1
  # ============================================================================

  attr :id, :string, required: true
  attr :name, :string, required: true
  attr :class, :string, default: nil
  attr :rest, :global

  @doc """
  Renders an invisible anchor `<span>` for in-document bookmarking.

  Other components (like `cross_reference/1`) can link to this anchor via
  its `id`. The element is visually hidden but present in the DOM.

  ## Example

      <.bookmark_anchor id="section-intro" name="Introduction" />
  """
  def bookmark_anchor(assigns) do
    ~H"""
    <span
      id={@id}
      data-bookmark-name={@name}
      aria-hidden="true"
      class={cn(["absolute", @class])}
      {@rest}
    />
    """
  end

  # ============================================================================
  # 4. cross_reference/1
  # ============================================================================

  attr :target, :string, required: true
  attr :label, :string, default: nil
  attr :class, :string, default: nil
  attr :rest, :global

  @doc """
  Renders an `<a>` link that points to a bookmark or heading within the document.

  When no label is provided, the target ID is displayed.

  ## Example

      <.cross_reference target="section-intro" label="see Introduction" />
  """
  def cross_reference(assigns) do
    ~H"""
    <a
      href={"##{@target}"}
      class={cn([
        "text-primary underline decoration-dotted underline-offset-2",
        "hover:decoration-solid",
        "focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring",
        @class
      ])}
      {@rest}
    >
      {@label || @target}
    </a>
    """
  end

  # ============================================================================
  # 5. citation_mark/1
  # ============================================================================

  attr :id, :string, required: true
  attr :key, :string, required: true
  attr :author, :string, default: ""
  attr :year, :string, default: ""
  attr :class, :string, default: nil
  attr :rest, :global

  @doc """
  Renders an inline "(Author, Year)" citation link.

  Links to the corresponding bibliography entry via `#bib-{key}`.

  ## Example

      <.citation_mark id="cite-1" key="smith2024" author="Smith" year="2024" />
  """
  def citation_mark(assigns) do
    ~H"""
    <a
      id={@id}
      href={"#bib-#{@key}"}
      data-citation-key={@key}
      class={cn([
        "inline text-primary hover:underline",
        "focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring",
        @class
      ])}
      {@rest}
    >
      ({@author}{if @year != "", do: ", #{@year}", else: ""})
    </a>
    """
  end

  # ============================================================================
  # 6. bibliography/1
  # ============================================================================

  attr :id, :string, required: true
  attr :entries, :list, default: []
  attr :style, :atom, default: :apa
  attr :class, :string, default: nil
  attr :rest, :global

  @doc """
  Renders an ordered list of formatted bibliography entries.

  Each entry is a map with keys: `:author`, `:title`, `:year`, `:source`, `:url`,
  `:volume`, `:pages`, and `:key`. Formatting follows the selected citation style.

  ## Example

      <.bibliography
        id="refs"
        style={:apa}
        entries={[
          %{key: "smith2024", author: "Smith, J.", title: "Example", year: "2024", source: "Nature"}
        ]}
      />
  """
  def bibliography(assigns) do
    formatted =
      assigns.entries
      |> Enum.with_index(1)
      |> Enum.map(fn {entry, idx} ->
        %{
          index: idx,
          key: Map.get(entry, :key, "ref-#{idx}"),
          text: format_entry(entry, assigns.style)
        }
      end)

    assigns = assign(assigns, :formatted, formatted)

    ~H"""
    <section id={@id} role="doc-bibliography" aria-label="Bibliography" class={cn(["mt-8", @class])} {@rest}>
      <h2 class="text-lg font-semibold text-foreground mb-3">References</h2>
      <ol class="list-none space-y-2 text-sm text-foreground">
        <li
          :for={ref <- @formatted}
          id={"bib-#{ref.key}"}
          class="pl-8 -indent-8"
        >
          <span class="text-muted-foreground mr-1">[{ref.index}]</span>
          {ref.text}
        </li>
      </ol>
    </section>
    """
  end

  defp format_entry(entry, style) do
    author = Map.get(entry, :author, "")
    title = Map.get(entry, :title, "")
    year = Map.get(entry, :year, "")
    source = Map.get(entry, :source, "")

    case style do
      :mla ->
        ~s[#{author}. "#{title}." #{source}, #{year}.]

      :chicago ->
        ~s[#{author}. "#{title}." #{source} (#{year}).]

      :harvard ->
        ~s[#{author} (#{year}) '#{title}', #{source}.]

      :ieee ->
        ~s[#{author}, "#{title}," #{source}, #{year}.]

      :abnt ->
        ~s[#{String.upcase(author)}. #{title}. #{source}, #{year}.]

      _ ->
        # APA (default)
        ~s[#{author} (#{year}). #{title}. #{source}.]
    end
  end

  # ============================================================================
  # 7. citation_dialog/1
  # ============================================================================

  attr :id, :string, required: true
  attr :visible, :boolean, default: false
  attr :citation, :map, default: %{}
  attr :class, :string, default: nil
  attr :rest, :global

  @doc """
  Renders a form dialog for inserting or editing a citation entry.

  Contains fields for author, title, year, source, URL, volume, and pages.
  Hidden when `visible` is false.

  ## Example

      <.citation_dialog id="cite-dialog" visible={@show_citation_form} citation={@editing_citation} />
  """
  def citation_dialog(assigns) do
    assigns =
      assigns
      |> assign(:author, Map.get(assigns.citation, :author, ""))
      |> assign(:title, Map.get(assigns.citation, :title, ""))
      |> assign(:year, Map.get(assigns.citation, :year, ""))
      |> assign(:source, Map.get(assigns.citation, :source, ""))
      |> assign(:url, Map.get(assigns.citation, :url, ""))
      |> assign(:volume, Map.get(assigns.citation, :volume, ""))
      |> assign(:pages, Map.get(assigns.citation, :pages, ""))

    ~H"""
    <div
      :if={@visible}
      id={@id}
      role="dialog"
      aria-label="Insert citation"
      class={cn([
        "rounded-lg border border-border bg-popover p-4 shadow-lg",
        "animate-[phia-bubble-in_150ms_ease-out]",
        @class
      ])}
      {@rest}
    >
      <h3 class="text-sm font-semibold text-foreground mb-3">Insert Citation</h3>
      <form phx-submit="citation:insert" class="space-y-2">
        <div class="grid grid-cols-2 gap-2">
          <div>
            <label for={"#{@id}-author"} class="block text-xs font-medium text-muted-foreground mb-0.5">Author</label>
            <input
              id={"#{@id}-author"}
              name="author"
              type="text"
              value={@author}
              placeholder="Author name"
              class="h-8 w-full rounded border border-border bg-background px-2 text-sm text-foreground focus:outline-none focus:ring-1 focus:ring-ring"
            />
          </div>
          <div>
            <label for={"#{@id}-year"} class="block text-xs font-medium text-muted-foreground mb-0.5">Year</label>
            <input
              id={"#{@id}-year"}
              name="year"
              type="text"
              value={@year}
              placeholder="2024"
              class="h-8 w-full rounded border border-border bg-background px-2 text-sm text-foreground focus:outline-none focus:ring-1 focus:ring-ring"
            />
          </div>
        </div>
        <div>
          <label for={"#{@id}-title"} class="block text-xs font-medium text-muted-foreground mb-0.5">Title</label>
          <input
            id={"#{@id}-title"}
            name="title"
            type="text"
            value={@title}
            placeholder="Work title"
            class="h-8 w-full rounded border border-border bg-background px-2 text-sm text-foreground focus:outline-none focus:ring-1 focus:ring-ring"
          />
        </div>
        <div>
          <label for={"#{@id}-source"} class="block text-xs font-medium text-muted-foreground mb-0.5">Source / Journal</label>
          <input
            id={"#{@id}-source"}
            name="source"
            type="text"
            value={@source}
            placeholder="Journal or publisher"
            class="h-8 w-full rounded border border-border bg-background px-2 text-sm text-foreground focus:outline-none focus:ring-1 focus:ring-ring"
          />
        </div>
        <div class="grid grid-cols-3 gap-2">
          <div>
            <label for={"#{@id}-url"} class="block text-xs font-medium text-muted-foreground mb-0.5">URL</label>
            <input
              id={"#{@id}-url"}
              name="url"
              type="url"
              value={@url}
              placeholder="https://..."
              class="h-8 w-full rounded border border-border bg-background px-2 text-sm text-foreground focus:outline-none focus:ring-1 focus:ring-ring"
            />
          </div>
          <div>
            <label for={"#{@id}-volume"} class="block text-xs font-medium text-muted-foreground mb-0.5">Volume</label>
            <input
              id={"#{@id}-volume"}
              name="volume"
              type="text"
              value={@volume}
              placeholder="Vol."
              class="h-8 w-full rounded border border-border bg-background px-2 text-sm text-foreground focus:outline-none focus:ring-1 focus:ring-ring"
            />
          </div>
          <div>
            <label for={"#{@id}-pages"} class="block text-xs font-medium text-muted-foreground mb-0.5">Pages</label>
            <input
              id={"#{@id}-pages"}
              name="pages"
              type="text"
              value={@pages}
              placeholder="1-20"
              class="h-8 w-full rounded border border-border bg-background px-2 text-sm text-foreground focus:outline-none focus:ring-1 focus:ring-ring"
            />
          </div>
        </div>
        <div class="flex items-center justify-end gap-2 pt-2">
          <button
            type="button"
            phx-click="citation:cancel"
            class="h-8 rounded border border-border px-3 text-xs text-muted-foreground hover:bg-muted transition-colors"
          >
            Cancel
          </button>
          <button
            type="submit"
            class="h-8 rounded bg-primary px-3 text-xs text-primary-foreground hover:bg-primary/90 transition-colors"
          >
            Insert
          </button>
        </div>
      </form>
    </div>
    """
  end

  # ============================================================================
  # 8. abbreviation_mark/1
  # ============================================================================

  attr :short, :string, required: true
  attr :full, :string, required: true
  attr :class, :string, default: nil
  attr :rest, :global

  @doc """
  Renders an `<abbr>` element with a dotted underline and tooltip showing the
  full term.

  ## Example

      <.abbreviation_mark short="HTML" full="HyperText Markup Language" />
  """
  def abbreviation_mark(assigns) do
    ~H"""
    <abbr
      title={@full}
      class={cn([
        "cursor-help border-b border-dotted border-muted-foreground no-underline",
        @class
      ])}
      {@rest}
    >
      {@short}
    </abbr>
    """
  end
end
