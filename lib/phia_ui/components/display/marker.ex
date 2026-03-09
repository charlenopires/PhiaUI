defmodule PhiaUi.Components.Marker do
  @moduledoc """
  Point-of-interest indicator positioned absolutely on images or maps.

  Markers are placed inside a `relative` container and positioned via
  `:x` and `:y` percentage or pixel values. They support variants, sizes,
  pulse animation, optional icons, and a popover slot for details on
  hover/click.

  ## Examples

      <div class="relative">
        <img src="/images/floor-plan.png" alt="Floor plan" />
        <.marker x="25%" y="40%" label="Conference Room A" variant={:primary} />
        <.marker x="60%" y="70%" label="Kitchen" pulse={true} />
      </div>

  ## With popover

      <.marker x="50%" y="50%" variant={:primary}>
        <:popover>
          <p class="text-sm">Meeting at 3 PM</p>
        </:popover>
      </.marker>

  ## With icon

      <.marker x="30%" y="60%" icon="map-pin" variant={:destructive} size={:lg} />
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  attr(:x, :any, required: true, doc: "Horizontal position (e.g. \"50%\", \"120px\").")
  attr(:y, :any, required: true, doc: "Vertical position (e.g. \"50%\", \"120px\").")
  attr(:label, :string, default: nil, doc: "Accessible label / tooltip text.")

  attr(:variant, :atom,
    default: :default,
    values: [:default, :primary, :destructive, :success, :warning],
    doc: "Color variant."
  )

  attr(:size, :atom,
    default: :md,
    values: [:sm, :md, :lg],
    doc: "Marker size."
  )

  attr(:pulse, :boolean, default: false, doc: "Show ping animation.")
  attr(:icon, :string, default: nil, doc: "Optional icon name (Lucide).")
  attr(:on_click, :string, default: nil, doc: "phx-click event name.")
  attr(:class, :string, default: nil, doc: "Additional CSS classes.")
  attr(:rest, :global, doc: "HTML attributes forwarded to the root element.")

  slot(:inner_block, doc: "Custom content inside the marker.")
  slot(:popover, doc: "Content shown on hover/click.")

  @doc "Renders an absolutely-positioned marker indicator."
  def marker(assigns) do
    base_class =
      cn([
        "absolute -translate-x-1/2 -translate-y-1/2 rounded-full",
        "inline-flex items-center justify-center group",
        "transition-transform hover:scale-110 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring",
        size_class(assigns.size),
        variant_class(assigns.variant),
        assigns.class
      ])

    assigns = assign(assigns, :base_class, base_class)

    ~H"""
    <button
      :if={@on_click}
      type="button"
      class={@base_class}
      style={"left: #{@x}; top: #{@y}"}
      aria-label={@label}
      phx-click={@on_click}
      {@rest}
    >
      <span
        :if={@pulse}
        class={cn(["absolute inset-0 rounded-full animate-ping", variant_ping_class(@variant)])}
      />
      <span :if={@icon} class="relative z-10">
        <span class={cn(["block", icon_size_class(@size)])}>{@icon}</span>
      </span>
      <span :if={@inner_block != []} class="relative z-10">
        {render_slot(@inner_block)}
      </span>
      <div
        :if={@popover != []}
        class="absolute left-1/2 -translate-x-1/2 top-full mt-2 z-20 hidden group-hover:block"
      >
        <div class="rounded-md border bg-popover p-2 text-popover-foreground shadow-md text-xs whitespace-nowrap">
          {render_slot(@popover)}
        </div>
      </div>
    </button>
    <div
      :if={!@on_click}
      class={@base_class}
      style={"left: #{@x}; top: #{@y}"}
      aria-label={@label}
      {@rest}
    >
      <span
        :if={@pulse}
        class={cn(["absolute inset-0 rounded-full animate-ping", variant_ping_class(@variant)])}
      />
      <span :if={@icon} class="relative z-10">
        <span class={cn(["block", icon_size_class(@size)])}>{@icon}</span>
      </span>
      <span :if={@inner_block != []} class="relative z-10">
        {render_slot(@inner_block)}
      </span>
      <div
        :if={@popover != []}
        class="absolute left-1/2 -translate-x-1/2 top-full mt-2 z-20 hidden group-hover:block"
      >
        <div class="rounded-md border bg-popover p-2 text-popover-foreground shadow-md text-xs whitespace-nowrap">
          {render_slot(@popover)}
        </div>
      </div>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Helpers
  # ---------------------------------------------------------------------------

  defp size_class(:sm), do: "size-4"
  defp size_class(:md), do: "size-6"
  defp size_class(:lg), do: "size-8"

  defp icon_size_class(:sm), do: "size-2.5"
  defp icon_size_class(:md), do: "size-3.5"
  defp icon_size_class(:lg), do: "size-5"

  defp variant_class(:default), do: "bg-foreground text-background"
  defp variant_class(:primary), do: "bg-primary text-primary-foreground"
  defp variant_class(:destructive), do: "bg-destructive text-destructive-foreground"
  defp variant_class(:success), do: "bg-green-500 text-white"
  defp variant_class(:warning), do: "bg-yellow-500 text-white"

  defp variant_ping_class(:default), do: "bg-foreground/40"
  defp variant_ping_class(:primary), do: "bg-primary/40"
  defp variant_ping_class(:destructive), do: "bg-destructive/40"
  defp variant_ping_class(:success), do: "bg-green-500/40"
  defp variant_ping_class(:warning), do: "bg-yellow-500/40"
end
