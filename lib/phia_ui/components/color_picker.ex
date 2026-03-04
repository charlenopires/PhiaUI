defmodule PhiaUi.Components.ColorPicker do
  @moduledoc """
  Color picker component with native `<input type="color">`, optional swatches,
  and a live value display.

  Wires up to the `PhiaColorPicker` JavaScript hook which:
    - Syncs the value display span in real time as the user drags the color wheel.
    - Fires a `pushEvent` to the parent LiveView whenever the selected colour
      changes (both from the native input and from swatch clicks).
    - Handles swatch clicks by updating the colour input and firing the event.

  Pure HEEx structure — the JS hook is the only dynamic layer.

  ## Examples

      <%!-- Basic colour picker --%>
      <.color_picker id="theme-color" value={@color} on_change="update_color" />

      <%!-- With swatches and hex format --%>
      <.color_picker
        id="brand-color"
        value={@color}
        format={:hex}
        swatches={["#FF5733", "#4CAF50", "#2196F3"]}
        on_change="pick_color"
      />

  ## LiveView event handler

  The hook pushes `{value: "#rrggbb"}` to the server:

      def handle_event("update_color", %{"value" => color}, socket) do
        {:noreply, assign(socket, color: color)}
      end

  ## Accessibility

  Each swatch button carries an `aria-label` identifying the colour value so
  that screen-reader users can distinguish them.
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  attr(:id, :string,
    required: true,
    doc: "Unique DOM id for the component root and used to derive the input id."
  )

  attr(:value, :string,
    default: "#000000",
    doc: "Initial/current hex colour string, e.g. \"#FF5733\"."
  )

  attr(:on_change, :string,
    default: nil,
    doc: "LiveView event name pushed to the server when the colour changes."
  )

  attr(:format, :atom,
    values: [:hex, :rgb],
    default: :hex,
    doc: "Colour format. Currently stored for future server-side conversion; default is `:hex`."
  )

  attr(:swatches, :list,
    default: [],
    doc: "List of hex colour strings rendered as quick-pick swatch buttons."
  )

  attr(:class, :string,
    default: nil,
    doc: "Additional CSS classes merged via `cn/1`."
  )

  attr(:rest, :global,
    doc: "HTML attributes forwarded to the root container `<div>`."
  )

  @doc """
  Renders a colour picker with a native colour input, a live hex value display,
  and optional colour swatches.

  ## Example

      <.color_picker
        id="accent-color"
        value={@accent}
        swatches={["#6366F1", "#EC4899", "#10B981"]}
        on_change="set_accent"
      />
  """
  def color_picker(assigns) do
    ~H"""
    <div
      id={@id}
      phx-hook="PhiaColorPicker"
      data-on-change={@on_change}
      class={cn(["inline-flex flex-col gap-3", @class])}
      {@rest}
    >
      <%!-- Native colour input + live value display --%>
      <div class="flex items-center gap-3">
        <input
          type="color"
          id={"#{@id}-input"}
          value={@value}
          class="h-10 w-16 cursor-pointer rounded-md border border-border bg-background p-1"
          data-color-input
        />
        <span class="text-sm font-mono text-foreground" data-color-value>{@value}</span>
      </div>

      <%!-- Swatches row — only rendered when at least one swatch is provided --%>
      <div :if={length(@swatches) > 0} class="flex flex-wrap gap-2" data-swatches>
        <button
          :for={swatch <- @swatches}
          type="button"
          class="h-6 w-6 rounded-full border-2 border-transparent hover:border-ring focus-visible:ring-2 focus-visible:ring-ring focus-visible:outline-none"
          style={"background-color: #{swatch}"}
          data-swatch-value={swatch}
          aria-label={"Select color #{swatch}"}
        >
        </button>
      </div>
    </div>
    """
  end
end
