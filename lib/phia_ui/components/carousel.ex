defmodule PhiaUi.Components.Carousel do
  @moduledoc """
  Carousel component with touch swipe, button navigation, and keyboard support.

  Follows the shadcn/ui Carousel anatomy adapted for Phoenix LiveView.
  The `PhiaCarousel` vanilla JS hook manages CSS transform-based sliding,
  touch swipe detection, keyboard navigation, and loop behaviour.

  ## Sub-components

  | Function             | Element  | Purpose                                    |
  |----------------------|----------|--------------------------------------------|
  | `carousel/1`         | `div`    | Root container — mounts PhiaCarousel hook  |
  | `carousel_content/1` | `div`    | Flex track that holds all slides           |
  | `carousel_item/1`    | `div`    | Individual slide (100% width)              |
  | `carousel_previous/1`| `button` | Navigate to the previous slide             |
  | `carousel_next/1`    | `button` | Navigate to the next slide                 |

  ## Example — horizontal with navigation

      <.carousel id="hero">
        <.carousel_content>
          <.carousel_item>Slide 1</.carousel_item>
          <.carousel_item>Slide 2</.carousel_item>
          <.carousel_item>Slide 3</.carousel_item>
        </.carousel_content>
        <.carousel_previous />
        <.carousel_next />
      </.carousel>

  ## Example — looping vertical carousel

      <.carousel id="vert" orientation="vertical" loop={true}>
        <.carousel_content>
          <.carousel_item>Top</.carousel_item>
          <.carousel_item>Bottom</.carousel_item>
        </.carousel_content>
        <.carousel_previous />
        <.carousel_next />
      </.carousel>

  ## Example — with dot indicators

      <.carousel id="dots">
        <.carousel_content>
          <.carousel_item>Slide 1</.carousel_item>
          <.carousel_item>Slide 2</.carousel_item>
        </.carousel_content>
        <:indicators>
          <button class="h-2 w-2 rounded-full bg-primary"></button>
          <button class="h-2 w-2 rounded-full bg-muted"></button>
        </:indicators>
      </.carousel>

  ## Hook setup

  Copy `priv/templates/js/hooks/carousel.js` to your project via:

      mix phia.add carousel

  Then register in your `app.js`:

      import PhiaCarousel from "./hooks/carousel"
      let liveSocket = new LiveSocket("/live", Socket, {
        hooks: { PhiaCarousel }
      })

  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  # ---------------------------------------------------------------------------
  # carousel/1
  # ---------------------------------------------------------------------------

  attr(:id, :string, default: "carousel", doc: "Unique carousel ID used by the hook")

  attr(:orientation, :string,
    default: "horizontal",
    values: ~w(horizontal vertical),
    doc: "Carousel orientation — controls transform axis and swipe direction"
  )

  attr(:loop, :boolean,
    default: false,
    doc: "When true, navigating past the last slide wraps around to the first"
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:rest, :global, doc: "HTML attributes forwarded to the root div")

  slot(:inner_block, required: true, doc: "carousel_content and navigation sub-components")

  slot(:indicators,
    doc: "Optional dot indicators rendered at the bottom of the carousel"
  )

  @doc """
  Renders the carousel root container.

  Mounts the `PhiaCarousel` hook and passes orientation/loop configuration
  via `data-*` attributes. The root is focusable (`tabindex="0"`) so
  keyboard arrow keys can control the carousel.
  """
  def carousel(assigns) do
    ~H"""
    <div
      id={@id}
      role="region"
      aria-label="carousel"
      phx-hook="PhiaCarousel"
      data-orientation={@orientation}
      data-loop={to_string(@loop)}
      tabindex="0"
      class={cn(["relative overflow-hidden", @class])}
      {@rest}
    >
      {render_slot(@inner_block)}
      <%= if @indicators != [] do %>
        <div class="absolute bottom-2 left-0 right-0 flex justify-center gap-1">
          {render_slot(@indicators)}
        </div>
      <% end %>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # carousel_content/1
  # ---------------------------------------------------------------------------

  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:rest, :global, doc: "HTML attributes forwarded to the track div")

  slot(:inner_block, required: true, doc: "carousel_item sub-components")

  @doc """
  Renders the carousel track container.

  The flex layout places all slides side by side. The PhiaCarousel hook
  updates `transform: translateX/Y(n%)` on this element to switch slides.
  The `transition-transform duration-300` classes provide smooth animation.
  """
  def carousel_content(assigns) do
    ~H"""
    <div
      data-carousel-track
      class={cn(["flex transition-transform duration-300 ease-in-out", @class])}
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # carousel_item/1
  # ---------------------------------------------------------------------------

  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:rest, :global, doc: "HTML attributes forwarded to the slide div")

  slot(:inner_block, required: true, doc: "Slide content")

  @doc """
  Renders an individual carousel slide.

  Each slide has `role="group"` and `aria-roledescription="slide"` for
  screen reader announcements. The `min-w-full shrink-0` classes ensure
  each slide occupies exactly the full width of the track.
  """
  def carousel_item(assigns) do
    ~H"""
    <div
      role="group"
      aria-roledescription="slide"
      class={cn(["min-w-full shrink-0", @class])}
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # carousel_previous/1
  # ---------------------------------------------------------------------------

  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:rest, :global, doc: "HTML attributes forwarded to the button element")

  slot(:inner_block, doc: "Button content — defaults to a left arrow ‹ character")

  @doc """
  Renders the previous slide navigation button.

  The `data-carousel-prev` marker is used by the PhiaCarousel hook to
  attach a click handler and manage the `disabled` state. When `:loop`
  is false and the carousel is at the first slide, the button is disabled.
  """
  def carousel_previous(assigns) do
    ~H"""
    <button
      type="button"
      data-carousel-prev
      aria-label="Previous slide"
      class={cn([
        "absolute left-2 top-1/2 -translate-y-1/2 z-10",
        "inline-flex items-center justify-center rounded-full",
        "h-8 w-8 bg-background/80 shadow-md border border-border",
        "hover:bg-background transition-colors",
        "disabled:opacity-50 disabled:pointer-events-none",
        @class
      ])}
      {@rest}
    >
      <%= if @inner_block != [] do %>
        {render_slot(@inner_block)}
      <% else %>
        ‹
      <% end %>
    </button>
    """
  end

  # ---------------------------------------------------------------------------
  # carousel_next/1
  # ---------------------------------------------------------------------------

  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:rest, :global, doc: "HTML attributes forwarded to the button element")

  slot(:inner_block, doc: "Button content — defaults to a right arrow › character")

  @doc """
  Renders the next slide navigation button.

  The `data-carousel-next` marker is used by the PhiaCarousel hook to
  attach a click handler and manage the `disabled` state. When `:loop`
  is false and the carousel is at the last slide, the button is disabled.
  """
  def carousel_next(assigns) do
    ~H"""
    <button
      type="button"
      data-carousel-next
      aria-label="Next slide"
      class={cn([
        "absolute right-2 top-1/2 -translate-y-1/2 z-10",
        "inline-flex items-center justify-center rounded-full",
        "h-8 w-8 bg-background/80 shadow-md border border-border",
        "hover:bg-background transition-colors",
        "disabled:opacity-50 disabled:pointer-events-none",
        @class
      ])}
      {@rest}
    >
      <%= if @inner_block != [] do %>
        {render_slot(@inner_block)}
      <% else %>
        ›
      <% end %>
    </button>
    """
  end
end
