defmodule PhiaUi.Components.EditorHighlightPicker do
  @moduledoc """
  Editor highlight (realce) color picker with curated academic-friendly colors.

  Two variants:
  - `:full` — formatting toolbar: remove button + recent colors + 5x2 palette + academic hint
  - `:mini` — bubble menu: compact remove + 5x2 grid only

  ## Examples

      <.editor_highlight_picker id="toolbar-highlight" variant={:full} />
      <.editor_highlight_picker id="bubble-highlight" variant={:mini} />
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  @default_colors [
    %{name: "Sunflower", hex: "#FDE68A", purpose: "Main ideas"},
    %{name: "Mint", hex: "#A7F3D0", purpose: "Evidence"},
    %{name: "Sky", hex: "#BAE6FD", purpose: "Interesting"},
    %{name: "Orchid", hex: "#DDD6FE", purpose: "Definitions"},
    %{name: "Peach", hex: "#FED7AA", purpose: "Examples"},
    %{name: "Rose", hex: "#FECDD3", purpose: "Follow-up"},
    %{name: "Sage", hex: "#D9F99D", purpose: "Methodology"},
    %{name: "Lavender", hex: "#E9D5FF", purpose: "Quotes"},
    %{name: "Cream", hex: "#FEF3C7", purpose: "Secondary"},
    %{name: "Ice", hex: "#CFFAFE", purpose: "Cross-refs"}
  ]

  attr :id, :string, required: true, doc: "Unique DOM id"
  attr :colors, :list, default: nil, doc: "List of %{name, hex, purpose} maps. Defaults to 10 curated academic colors."
  attr :show_recent, :boolean, default: true, doc: "Show recent colors section (full variant only)"
  attr :show_labels, :boolean, default: false, doc: "Show semantic labels for ABNT mode"
  attr :variant, :atom, default: :full, values: [:full, :mini], doc: ":full for toolbar, :mini for bubble menu"
  attr :class, :string, default: nil
  attr :rest, :global

  def editor_highlight_picker(assigns) do
    assigns = assign(assigns, :colors, assigns.colors || @default_colors)

    case assigns.variant do
      :full -> full_picker(assigns)
      :mini -> mini_picker(assigns)
    end
  end

  defp full_picker(assigns) do
    ~H"""
    <div
      id={@id}
      phx-hook="PhiaEditorHighlightPicker"
      class={cn(["relative", @class])}
      {@rest}
    >
      <button
        type="button"
        data-highlight-trigger
        aria-expanded="false"
        aria-haspopup="true"
        aria-label="Highlight color"
        title="Highlight color (Ctrl+Shift+H)"
        class="flex h-7 w-7 flex-col items-center justify-center rounded hover:bg-gray-100"
      >
        <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
          <path d="m9 11-6 6v3h9l3-3" /><path d="m22 12-4.6 4.6a2 2 0 0 1-2.8 0l-5.2-5.2a2 2 0 0 1 0-2.8L14 4" />
        </svg>
        <div data-highlight-indicator class="mt-0.5 h-0.5 w-3.5 rounded-full" style="background-color: #FDE68A"></div>
      </button>

      <div
        data-highlight-panel
        role="dialog"
        aria-label="Highlight colors"
        class="hidden w-[240px] rounded-lg border border-gray-200 bg-white p-2 shadow-lg"
      >
        <%!-- No highlight --%>
        <button
          type="button"
          data-remove-highlight
          class="flex w-full items-center gap-2 rounded px-2 py-1.5 text-xs text-gray-700 hover:bg-gray-100"
        >
          <span class="flex h-4 w-4 items-center justify-center rounded border border-gray-300 bg-white text-[9px] text-gray-400">✕</span>
          <span>No highlight</span>
        </button>

        <%!-- Recent colors --%>
        <div :if={@show_recent} data-recent-section style="display:none" class="mt-1.5 border-t border-gray-100 pt-1.5">
          <div class="mb-1 px-1 text-[10px] font-medium text-gray-400 uppercase tracking-wider">Recent</div>
          <div data-recent-colors class="flex gap-1 px-1">
            <button
              :for={_ <- 1..5}
              type="button"
              data-recent-slot
              data-highlight-color=""
              style="display:none"
              class="h-5 w-5 rounded border border-gray-200 hover:scale-110 transition-transform focus:outline-none focus:ring-2 focus:ring-blue-400 focus:ring-offset-1"
              tabindex="0"
            />
          </div>
        </div>

        <%!-- Separator --%>
        <div class="my-1.5 border-t border-gray-100"></div>

        <%!-- 5×2 palette grid --%>
        <div class="grid grid-cols-5 gap-1 px-1">
          <button
            :for={color <- @colors}
            type="button"
            data-highlight-color={color.hex}
            title={"#{color.name} — #{color.purpose}"}
            aria-label={"Highlight #{color.name}: #{color.purpose}"}
            class="group relative h-6 w-full rounded border border-gray-200 hover:scale-110 transition-transform focus:outline-none focus:ring-2 focus:ring-blue-400 focus:ring-offset-1"
            style={"background-color: #{color.hex}"}
            tabindex="0"
          >
            <span
              :if={@show_labels}
              class="pointer-events-none absolute -bottom-4 left-1/2 -translate-x-1/2 whitespace-nowrap rounded bg-gray-800 px-1.5 py-0.5 text-[9px] text-white opacity-0 group-hover:opacity-100 transition-opacity"
            >
              {color.name}
            </span>
          </button>
        </div>

        <%!-- Academic hint --%>
        <div :if={@show_labels} class="mt-2 rounded bg-amber-50 px-2 py-1 text-[10px] text-amber-700">
          💡 Use highlights to organize your review — colors are not included in the final document.
        </div>
      </div>
    </div>
    """
  end

  defp mini_picker(assigns) do
    ~H"""
    <div
      id={@id}
      phx-hook="PhiaEditorHighlightPicker"
      class={cn(["relative", @class])}
      {@rest}
    >
      <button
        type="button"
        data-highlight-trigger
        aria-expanded="false"
        aria-haspopup="true"
        aria-label="Highlight color"
        title="Highlight"
        class="flex h-6 w-6 flex-col items-center justify-center rounded text-gray-600 hover:bg-gray-100"
      >
        <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
          <path d="m9 11-6 6v3h9l3-3" /><path d="m22 12-4.6 4.6a2 2 0 0 1-2.8 0l-5.2-5.2a2 2 0 0 1 0-2.8L14 4" />
        </svg>
        <div data-highlight-indicator class="mt-px h-0.5 w-3 rounded-full" style="background-color: #FDE68A"></div>
      </button>

      <div
        data-highlight-panel
        role="dialog"
        aria-label="Highlight colors"
        class="hidden w-[180px] rounded-lg border border-gray-200 bg-white p-2 shadow-lg"
      >
        <button
          type="button"
          data-remove-highlight
          class="flex w-full items-center gap-1.5 rounded px-1.5 py-1 text-[11px] text-gray-600 hover:bg-gray-100"
        >
          <span class="flex h-3.5 w-3.5 items-center justify-center rounded border border-gray-300 bg-white text-[8px] text-gray-400">✕</span>
          <span>No highlight</span>
        </button>
        <div class="my-1 border-t border-gray-100"></div>
        <div data-recent-colors class="hidden">
          <button :for={_ <- 1..5} type="button" data-recent-slot data-highlight-color="" style="display:none" class="hidden" />
        </div>
        <div class="grid grid-cols-5 gap-1">
          <button
            :for={color <- @colors}
            type="button"
            data-highlight-color={color.hex}
            title={"#{color.name}"}
            aria-label={"Highlight #{color.name}"}
            class="h-5 w-full rounded border border-gray-200 hover:scale-110 transition-transform focus:outline-none focus:ring-2 focus:ring-blue-400 focus:ring-offset-1"
            style={"background-color: #{color.hex}"}
            tabindex="0"
          />
        </div>
      </div>
    </div>
    """
  end
end
