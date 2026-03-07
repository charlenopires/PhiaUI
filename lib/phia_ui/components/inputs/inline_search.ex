defmodule PhiaUi.Components.InlineSearch do
  @moduledoc """
  Expandable search — collapses to an icon button, expands to a full input.

  Provides `inline_search/1` — an icon-button that reveals a text input when
  clicked (and collapses it back on Escape or blur). The expand/collapse is
  handled entirely by Phoenix LiveView JS — no server round-trip required.

  ## When to use

  Use `inline_search/1` in toolbars, navigation bars, or table headers where
  you need search functionality without always showing an open input field.
  It keeps the UI clean until the user actively needs search.

  ## Basic usage

      <%!-- Default inline search bar --%>
      <.inline_search
        name="q"
        value={@query}
        placeholder="Search..."
        phx-change="search"
        phx-debounce="300"
      />

      <%!-- In a page header toolbar --%>
      <div class="flex items-center gap-2">
        <h1 class="text-lg font-semibold">Products</h1>
        <.inline_search name="q" value={@q} phx-change="filter" phx-debounce="400" />
        <.button>New product</.button>
      </div>
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  alias Phoenix.LiveView.JS

  # ---------------------------------------------------------------------------
  # inline_search/1
  # ---------------------------------------------------------------------------

  attr(:id, :string,
    default: nil,
    doc: "Base id used for the toggle button and input. Auto-generated if nil."
  )

  attr(:name, :string,
    default: "search",
    doc: "HTML name forwarded to the `<input>` element."
  )

  attr(:value, :string,
    default: nil,
    doc: "Current search value."
  )

  attr(:placeholder, :string,
    default: "Search...",
    doc: "Placeholder text shown inside the expanded input."
  )

  attr(:expanded, :boolean,
    default: false,
    doc: "When true, renders the input in expanded state on initial render."
  )

  attr(:width, :string,
    default: "48",
    doc: "Tailwind width class suffix for the expanded input (e.g. `\"48\"` → `w-48`)."
  )

  attr(:class, :string,
    default: nil,
    doc: "Additional CSS classes on the outer wrapper."
  )

  attr(:rest, :global,
    include: ~w(phx-change phx-submit phx-debounce phx-keydown autocomplete),
    doc: "HTML attributes forwarded to the `<input>` element."
  )

  @doc """
  Renders a search icon button that expands to a text input on click.

  ## Behaviour

  1. Initially: shows a magnifier icon button.
  2. On click: the icon button hides and the input group slides in (JS).
  3. The × button inside the input collapses back to the icon.
  4. Pressing Escape from within the input also collapses it.

  The JS expand/collapse does not trigger a LiveView event — it is purely
  client-side via `Phoenix.LiveView.JS`.

  ## Example

      <.inline_search name="q" value={@q} phx-change="filter" phx-debounce="300" />
  """
  def inline_search(assigns) do
    id = assigns.id || "inline-search-#{:erlang.unique_integer([:positive])}"
    assigns = assign(assigns, :id, id)
    btn_id = id <> "-btn"
    input_id = id <> "-input"
    group_id = id <> "-group"

    assigns =
      assigns
      |> assign(:btn_id, btn_id)
      |> assign(:input_id, input_id)
      |> assign(:group_id, group_id)

    expand_js =
      JS.hide(to: "##{btn_id}")
      |> JS.show(to: "##{group_id}", transition: {"ease-out duration-150", "opacity-0 scale-95", "opacity-100 scale-100"})
      |> JS.focus(to: "##{input_id}")

    collapse_js =
      JS.hide(to: "##{group_id}")
      |> JS.show(to: "##{btn_id}")

    assigns =
      assigns
      |> assign(:expand_js, expand_js)
      |> assign(:collapse_js, collapse_js)

    ~H"""
    <div class={cn(["relative flex items-center", @class])}>
      <%!-- Collapsed: icon button --%>
      <button
        id={@btn_id}
        type="button"
        aria-label="Open search"
        class={cn(["flex h-9 w-9 items-center justify-center rounded-md text-muted-foreground transition-colors hover:bg-accent hover:text-foreground", @expanded && "hidden"])}
        phx-click={@expand_js}
      >
        <svg
          xmlns="http://www.w3.org/2000/svg"
          class="h-4 w-4"
          viewBox="0 0 24 24"
          fill="none"
          stroke="currentColor"
          stroke-width="2"
          stroke-linecap="round"
          stroke-linejoin="round"
          aria-hidden="true"
        >
          <circle cx="11" cy="11" r="8" /><path d="m21 21-4.35-4.35" />
        </svg>
      </button>

      <%!-- Expanded: search input group --%>
      <div
        id={@group_id}
        role="search"
        class={cn([
          "flex items-center h-9 rounded-md border border-input bg-background",
          "focus-within:ring-2 focus-within:ring-ring focus-within:ring-offset-2",
          !@expanded && "hidden"
        ])}
      >
        <span class="pl-2.5 text-muted-foreground pointer-events-none flex items-center">
          <svg
            xmlns="http://www.w3.org/2000/svg"
            class="h-4 w-4"
            viewBox="0 0 24 24"
            fill="none"
            stroke="currentColor"
            stroke-width="2"
            stroke-linecap="round"
            stroke-linejoin="round"
            aria-hidden="true"
          >
            <circle cx="11" cy="11" r="8" /><path d="m21 21-4.35-4.35" />
          </svg>
        </span>

        <input
          id={@input_id}
          type="search"
          name={@name}
          value={@value}
          placeholder={@placeholder}
          class={cn([
            "h-full bg-transparent pl-2 pr-2 text-sm placeholder:text-muted-foreground",
            "focus:outline-none [&::-webkit-search-cancel-button]:hidden",
            "w-#{@width}"
          ])}
          phx-keydown={@collapse_js}
          phx-key="Escape"
          {@rest}
        />

        <%!-- Collapse button --%>
        <button
          type="button"
          aria-label="Close search"
          class="flex h-full items-center px-2 text-muted-foreground transition-colors hover:text-foreground"
          phx-click={@collapse_js}
        >
          <svg
            xmlns="http://www.w3.org/2000/svg"
            class="h-3.5 w-3.5"
            viewBox="0 0 24 24"
            fill="none"
            stroke="currentColor"
            stroke-width="2"
            stroke-linecap="round"
            stroke-linejoin="round"
            aria-hidden="true"
          >
            <path d="M18 6 6 18M6 6l12 12" />
          </svg>
        </button>
      </div>
    </div>
    """
  end
end
