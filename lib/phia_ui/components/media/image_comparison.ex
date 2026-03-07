defmodule PhiaUi.Components.ImageComparison do
  @moduledoc """
  Image comparison slider — drag to reveal before/after images.

  Inspired by PrimeReact `Compare`, shadcn custom implementations, Cloudinary widget.
  Requires the `PhiaImageComparison` JS hook.

  The before-image is revealed via `clip-path: inset(...)` controlled by the hook.
  The divider handle is absolutely positioned and draggable (mouse + touch).

  ## Setup

  Add the hook to your `app.js` (after `mix phia.install`):

      import PhiaImageComparison from "./hooks/image_comparison.js"
      let liveSocket = new LiveSocket("/live", Socket, {
        hooks: { PhiaImageComparison, ... }
      })

  ## Example

      <.image_comparison
        id="product-compare"
        before_src="/images/before.jpg"
        after_src="/images/after.jpg"
        before_label="Before"
        after_label="After"
        initial_position={40}
      />
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  attr(:id, :string, required: true, doc: "Unique element ID — required for the JS hook.")

  attr(:before_src, :string, required: true, doc: "URL for the \"before\" image.")
  attr(:after_src, :string, required: true, doc: "URL for the \"after\" image.")

  attr(:before_label, :string, default: "Before", doc: "Label overlaid on the before image.")
  attr(:after_label, :string, default: "After", doc: "Label overlaid on the after image.")

  attr(:initial_position, :integer,
    default: 50,
    doc: "Initial divider position (0-100, percent from left)."
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes for the root element.")
  attr(:rest, :global, doc: "HTML attributes forwarded to the root `<div>`.")

  def image_comparison(assigns) do
    initial = assigns.initial_position

    assigns =
      assigns
      |> assign(:before_clip, "inset(0 #{100 - initial}% 0 0)")
      |> assign(:divider_left, "#{initial}%")

    ~H"""
    <div
      id={@id}
      phx-hook="PhiaImageComparison"
      data-initial-position={@initial_position}
      class={cn(["relative overflow-hidden select-none rounded-lg", @class])}
      {@rest}
    >
      <%!-- After image (full width, base layer) --%>
      <img src={@after_src} alt={@after_label} class="block w-full h-auto" draggable="false" />

      <%!-- Before image (clipped to left portion) --%>
      <div
        data-before-container
        class="absolute inset-0"
        style={"clip-path: #{@before_clip}"}
      >
        <img src={@before_src} alt={@before_label} class="block w-full h-auto" draggable="false" />
      </div>

      <%!-- Divider handle --%>
      <div
        data-divider
        class="absolute inset-y-0 z-10 flex flex-col items-center cursor-ew-resize"
        style={"left: #{@divider_left}; transform: translateX(-50%)"}
      >
        <%!-- Vertical line --%>
        <div class="w-0.5 flex-1 bg-white shadow-md" />
        <%!-- Circle handle --%>
        <div class="absolute top-1/2 -translate-y-1/2 flex h-8 w-8 items-center justify-center rounded-full bg-white shadow-lg">
          <svg
            xmlns="http://www.w3.org/2000/svg"
            class="h-4 w-4 text-gray-600"
            fill="none"
            viewBox="0 0 24 24"
            stroke="currentColor"
            stroke-width="2"
            aria-hidden="true"
          >
            <path stroke-linecap="round" stroke-linejoin="round" d="M8 9l-4 3 4 3M16 9l4 3-4 3" />
          </svg>
        </div>
      </div>

      <%!-- Labels --%>
      <span class="absolute bottom-2 left-2 rounded-md bg-black/50 px-2 py-0.5 text-xs text-white">
        {@before_label}
      </span>
      <span class="absolute bottom-2 right-2 rounded-md bg-black/50 px-2 py-0.5 text-xs text-white">
        {@after_label}
      </span>
    </div>
    """
  end
end
