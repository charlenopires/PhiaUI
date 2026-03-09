defmodule PhiaUi.Components.CodeSnippet do
  @moduledoc """
  Code display card with filename header, language badge, copy button, and line numbers.

  Uses `PhiaCodeSnippet` JS hook for copy-to-clipboard with "Copied!" feedback.
  No syntax highlighting is included — the component renders raw code in a
  `<pre><code>` block. Syntax highlighting can be added via external libraries.

  ## Examples

      <.code_snippet id="ex1" code="defmodule Hello, do: def world, do: :ok" language="elixir" />

      <.code_snippet
        id="ex2"
        code={@snippet}
        filename="app.js"
        language="javascript"
        show_line_numbers
      />

      <.code_snippet id="ex3" code={@long_code} max_height="300px" />
  """

  use Phoenix.Component
  import PhiaUi.ClassMerger, only: [cn: 1]

  attr :id, :string, required: true, doc: "Unique id required by the JS hook"
  attr :code, :string, required: true, doc: "Code string to display"
  attr :language, :string, default: nil, doc: "Language name shown as badge"
  attr :filename, :string, default: nil, doc: "Filename shown in header"
  attr :show_line_numbers, :boolean, default: false, doc: "Show line numbers"
  attr :highlight_lines, :list, default: [], doc: "Line numbers to highlight"
  attr :max_height, :string, default: nil, doc: "Max height for scrollable code area (CSS value)"
  attr :class, :string, default: nil
  attr :rest, :global

  def code_snippet(assigns) do
    lines = String.split(assigns.code, "\n")
    assigns = assign(assigns, :lines, lines)

    ~H"""
    <div
      id={@id}
      phx-hook="PhiaCodeSnippet"
      class={cn([
        "overflow-hidden rounded-lg border border-border bg-card",
        @class
      ])}
      {@rest}
    >
      <%!-- Header bar --%>
      <%= if @filename || @language do %>
        <div class="flex items-center justify-between border-b border-border bg-muted/50 px-4 py-2">
          <div class="flex items-center gap-2 min-w-0">
            <%!-- Terminal dots --%>
            <div class="flex items-center gap-1.5">
              <span class="h-3 w-3 rounded-full bg-red-400" />
              <span class="h-3 w-3 rounded-full bg-yellow-400" />
              <span class="h-3 w-3 rounded-full bg-green-400" />
            </div>
            <%= if @filename do %>
              <span class="truncate text-sm font-medium text-foreground">{@filename}</span>
            <% end %>
          </div>
          <div class="flex items-center gap-2 shrink-0">
            <%= if @language do %>
              <span class="rounded bg-muted px-2 py-0.5 text-xs font-medium text-muted-foreground">
                {@language}
              </span>
            <% end %>
            <button
              type="button"
              data-copy-btn
              data-code={@code}
              aria-label="Copy code"
              class="inline-flex items-center justify-center rounded-md p-1.5 text-muted-foreground transition-colors hover:bg-muted hover:text-foreground"
            >
              <svg data-icon-copy class="h-4 w-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
                <rect x="9" y="9" width="13" height="13" rx="2" ry="2" /><path d="M5 15H4a2 2 0 01-2-2V4a2 2 0 012-2h9a2 2 0 012 2v1" />
              </svg>
              <svg data-icon-check class="hidden h-4 w-4 text-green-500" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
                <polyline points="20 6 9 17 4 12" />
              </svg>
            </button>
          </div>
        </div>
      <% end %>

      <%!-- No header — just show copy button --%>
      <%= if is_nil(@filename) and is_nil(@language) do %>
        <div class="flex justify-end border-b border-border bg-muted/50 px-2 py-1.5">
          <button
            type="button"
            data-copy-btn
            data-code={@code}
            aria-label="Copy code"
            class="inline-flex items-center justify-center rounded-md p-1.5 text-muted-foreground transition-colors hover:bg-muted hover:text-foreground"
          >
            <svg data-icon-copy class="h-4 w-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
              <rect x="9" y="9" width="13" height="13" rx="2" ry="2" /><path d="M5 15H4a2 2 0 01-2-2V4a2 2 0 012-2h9a2 2 0 012 2v1" />
            </svg>
            <svg data-icon-check class="hidden h-4 w-4 text-green-500" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
              <polyline points="20 6 9 17 4 12" />
            </svg>
          </button>
        </div>
      <% end %>

      <%!-- Code block --%>
      <div class="overflow-x-auto" style={if @max_height, do: "max-height: #{@max_height}; overflow-y: auto;"}>
        <pre class="p-4 text-sm leading-relaxed"><code class="font-mono text-foreground"><%= if @show_line_numbers do %><table class="border-collapse"><tbody><%= for {line, idx} <- Enum.with_index(@lines, 1) do %><tr class={if idx in @highlight_lines, do: "bg-primary/10"}><td class="select-none pr-4 text-right text-muted-foreground/50 align-top">{idx}</td><td class="whitespace-pre">{line}</td></tr><% end %></tbody></table><% else %>{@code}<% end %></code></pre>
      </div>
    </div>
    """
  end
end
