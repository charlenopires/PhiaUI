defmodule PhiaUi.Components.Carousel do
  @moduledoc """
  Carousel component with touch swipe, button navigation, and keyboard support.

  Follows the shadcn/ui Carousel anatomy adapted for Phoenix LiveView.
  The `PhiaCarousel` vanilla-JS hook manages CSS `transform`-based sliding,
  touch/swipe detection, keyboard navigation (arrow keys), and optional loop
  behaviour. Zero npm dependencies.

  ## When to use

  - Hero banner with rotating promotional images
  - Product image gallery (multiple photos of the same item)
  - Onboarding walkthrough (step-by-step screens)
  - Testimonial rotator
  - Vertical announcement ticker

  ## Anatomy

  | Component             | Element  | Purpose                                        |
  |-----------------------|----------|------------------------------------------------|
  | `carousel/1`          | `div`    | Root container — mounts the `PhiaCarousel` hook|
  | `carousel_content/1`  | `div`    | Flex track that holds all slides side-by-side  |
  | `carousel_item/1`     | `div`    | Individual slide (`min-w-full shrink-0`)        |
  | `carousel_previous/1` | `button` | Navigate to the previous slide                 |
  | `carousel_next/1`     | `button` | Navigate to the next slide                     |

  ## Basic horizontal carousel

      <.carousel id="hero-banner">
        <.carousel_content>
          <.carousel_item>
            <img src="/images/promo-1.jpg" alt="Summer sale" class="w-full object-cover" />
          </.carousel_item>
          <.carousel_item>
            <img src="/images/promo-2.jpg" alt="New arrivals" class="w-full object-cover" />
          </.carousel_item>
          <.carousel_item>
            <img src="/images/promo-3.jpg" alt="Free shipping" class="w-full object-cover" />
          </.carousel_item>
        </.carousel_content>
        <.carousel_previous />
        <.carousel_next />
      </.carousel>

  ## Looping vertical carousel

      <.carousel id="announcements" orientation="vertical" loop={true}>
        <.carousel_content>
          <.carousel_item class="h-12 flex items-center">
            Maintenance window scheduled for Sunday 2 AM UTC
          </.carousel_item>
          <.carousel_item class="h-12 flex items-center">
            v2.4.0 released — see the changelog
          </.carousel_item>
        </.carousel_content>
        <.carousel_previous />
        <.carousel_next />
      </.carousel>

  ## Carousel with dot indicator slot

      <.carousel id="product-gallery">
        <.carousel_content>
          <.carousel_item :for={img <- @product_images}>
            <img src={img.url} alt={img.alt} class="w-full rounded-lg object-cover" />
          </.carousel_item>
        </.carousel_content>
        <.carousel_previous />
        <.carousel_next />
        <:indicators>
          <button
            :for={{_img, i} <- Enum.with_index(@product_images)}
            data-index={i}
            class="h-2 w-2 rounded-full bg-muted data-[active]:bg-primary"
          />
        </:indicators>
      </.carousel>

  ## Accessibility

  - The root element has `role="region"` and `aria-label="carousel"`
  - Each slide has `role="group"` and `aria-roledescription="slide"`
  - Navigation buttons have `aria-label="Previous slide"` / `"Next slide"`
  - The root is focusable (`tabindex="0"`) so arrow-key navigation works
    without a mouse

  ## Hook setup

      mix phia.add carousel   # copies hooks/carousel.js to your project

      # app.js
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

  attr(:id, :string,
    default: "carousel",
    doc: """
    Unique carousel ID. The `PhiaCarousel` hook uses this to identify the
    instance and store its current slide index in hook state.
    """
  )

  attr(:orientation, :string,
    default: "horizontal",
    values: ~w(horizontal vertical),
    doc: """
    Carousel slide direction:
    - `"horizontal"` — slides left/right (default, most common)
    - `"vertical"`   — slides up/down (e.g. announcement ticker)
    The hook reads `data-orientation` to set the correct transform axis.
    """
  )

  attr(:loop, :boolean,
    default: false,
    doc: """
    When `true`, navigating past the last slide wraps to the first (and
    navigating before the first wraps to the last). The hook reads `data-loop`.
    """
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes for the root div")

  attr(:rest, :global, doc: "HTML attributes forwarded to the root div")

  slot(:inner_block,
    required: true,
    doc: "`carousel_content/1` and navigation sub-components"
  )

  slot(:indicators,
    doc: """
    Optional dot indicator buttons rendered at the bottom of the carousel.
    The `PhiaCarousel` hook can toggle a `data-active` attribute on the active
    indicator. Use `data-[active]:bg-primary` Tailwind variant to style it.
    """
  )

  @doc """
  Renders the carousel root container.

  Mounts the `PhiaCarousel` hook and communicates configuration via `data-*`
  attributes. The root is focusable (`tabindex="0"`) so keyboard users can
  navigate slides with arrow keys without any additional setup.

  `role="region"` + `aria-label="carousel"` ensures the landmark is announced
  correctly by screen readers.
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
      <%!-- Dot indicators — absolutely positioned at the bottom of the root --%>
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

  attr(:class, :string, default: nil, doc: "Additional CSS classes for the track div")

  attr(:rest, :global,
    doc: "HTML attributes forwarded to the track div (the element that receives `transform`)"
  )

  slot(:inner_block, required: true, doc: "`carousel_item/1` slide children")

  @doc """
  Renders the carousel track container.

  The `data-carousel-track` attribute is used by the `PhiaCarousel` hook to
  locate and animate this element. The hook updates `style.transform` on this
  element directly to translate between slides.

  `transition-transform duration-300 ease-in-out` provides the slide animation.
  Do not remove these classes unless you want an instant snap transition.
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

  attr(:class, :string, default: nil, doc: "Additional CSS classes for the slide div")

  attr(:rest, :global, doc: "HTML attributes forwarded to the slide div")

  slot(:inner_block, required: true, doc: "Slide content — images, cards, text, etc.")

  @doc """
  Renders an individual carousel slide.

  `min-w-full shrink-0` ensures each slide occupies exactly 100% of the track
  width (or height for vertical carousels), preventing any bleeding between
  slides.

  `role="group"` and `aria-roledescription="slide"` allow screen readers to
  announce "Slide 1 of 3" when the user navigates via keyboard.
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

  attr(:class, :string, default: nil, doc: "Additional CSS classes for the button element")

  attr(:rest, :global, doc: "HTML attributes forwarded to the `<button>` element")

  slot(:inner_block,
    doc: "Button content — defaults to the left-pointing single-guillemet character `‹`"
  )

  @doc """
  Renders the previous-slide navigation button.

  The `data-carousel-prev` attribute is used by the `PhiaCarousel` hook to
  attach a click listener and manage the `disabled` attribute. When `loop`
  is `false` and the carousel is at the first slide, the hook sets
  `disabled` on this button to prevent backward navigation.

  Override the default `‹` icon by placing content in the `:inner_block` slot.
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

  attr(:class, :string, default: nil, doc: "Additional CSS classes for the button element")

  attr(:rest, :global, doc: "HTML attributes forwarded to the `<button>` element")

  slot(:inner_block,
    doc: "Button content — defaults to the right-pointing single-guillemet character `›`"
  )

  @doc """
  Renders the next-slide navigation button.

  The `data-carousel-next` attribute is used by the `PhiaCarousel` hook to
  attach a click listener and manage the `disabled` attribute. When `loop`
  is `false` and the carousel is at the last slide, the hook sets `disabled`
  on this button to prevent forward navigation.

  Override the default `›` icon by placing content in the `:inner_block` slot.
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
