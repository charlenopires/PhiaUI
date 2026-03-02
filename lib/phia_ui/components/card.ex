defmodule PhiaUi.Components.Card do
  @moduledoc """
  Composable Card component with 6 independent sub-components.

  Follows the shadcn/ui Card anatomy adapted for Phoenix LiveView.
  Each sub-component is independently usable and accepts `:class` for
  Tailwind overrides merged via `cn/1`.

  ## Sub-components

  | Function            | Element | Purpose                        |
  |---------------------|---------|--------------------------------|
  | `card/1`            | `<div>` | Outer container with surface   |
  | `card_header/1`     | `<div>` | Header layout (title + desc)   |
  | `card_title/1`      | `<h3>`  | Card heading                   |
  | `card_description/1`| `<p>`   | Subtitle / supporting text     |
  | `card_content/1`    | `<div>` | Primary content area           |
  | `card_footer/1`     | `<div>` | Footer row (actions, meta)     |

  ## Example — full composition

      <.card>
        <.card_header>
          <.card_title>Account Balance</.card_title>
          <.card_description>Your current balance</.card_description>
        </.card_header>
        <.card_content>
          <p class="text-2xl font-bold">$12,340.00</p>
        </.card_content>
        <.card_footer>
          <span class="text-sm text-muted-foreground">Last updated: today</span>
        </.card_footer>
      </.card>

  ## Example — class override

      <.card class="w-full max-w-sm">
        <.card_content>Compact card</.card_content>
      </.card>

  ## Example — @rest passthrough

      <.card data-testid="balance-card" aria-label="Account balance">
        …
      </.card>
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  # ---------------------------------------------------------------------------
  # card/1
  # ---------------------------------------------------------------------------

  attr :class, :string, default: nil, doc: "Additional CSS classes"
  attr :rest, :global, doc: "HTML attributes forwarded to the div element"
  slot :inner_block, required: true, doc: "Card content"

  @doc "Renders the outer Card container."
  def card(assigns) do
    ~H"""
    <div class={cn(["rounded-lg border bg-card text-card-foreground shadow", @class])} {@rest}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # card_header/1
  # ---------------------------------------------------------------------------

  attr :class, :string, default: nil, doc: "Additional CSS classes"
  attr :rest, :global, doc: "HTML attributes forwarded to the div element"
  slot :inner_block, required: true, doc: "Header content (title + description)"

  @doc "Renders the Card header layout area."
  def card_header(assigns) do
    ~H"""
    <div class={cn(["flex flex-col space-y-1.5 p-6", @class])} {@rest}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # card_title/1
  # ---------------------------------------------------------------------------

  attr :class, :string, default: nil, doc: "Additional CSS classes"
  attr :rest, :global, doc: "HTML attributes forwarded to the h3 element"
  slot :inner_block, required: true, doc: "Title text"

  @doc "Renders the Card title as an `<h3>`."
  def card_title(assigns) do
    ~H"""
    <h3 class={cn(["font-semibold leading-none tracking-tight", @class])} {@rest}>
      <%= render_slot(@inner_block) %>
    </h3>
    """
  end

  # ---------------------------------------------------------------------------
  # card_description/1
  # ---------------------------------------------------------------------------

  attr :class, :string, default: nil, doc: "Additional CSS classes"
  attr :rest, :global, doc: "HTML attributes forwarded to the p element"
  slot :inner_block, required: true, doc: "Description text"

  @doc "Renders the Card description as a `<p>`."
  def card_description(assigns) do
    ~H"""
    <p class={cn(["text-sm text-muted-foreground", @class])} {@rest}>
      <%= render_slot(@inner_block) %>
    </p>
    """
  end

  # ---------------------------------------------------------------------------
  # card_content/1
  # ---------------------------------------------------------------------------

  attr :class, :string, default: nil, doc: "Additional CSS classes"
  attr :rest, :global, doc: "HTML attributes forwarded to the div element"
  slot :inner_block, required: true, doc: "Primary content"

  @doc "Renders the Card content area."
  def card_content(assigns) do
    ~H"""
    <div class={cn(["p-6 pt-0", @class])} {@rest}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # card_footer/1
  # ---------------------------------------------------------------------------

  attr :class, :string, default: nil, doc: "Additional CSS classes"
  attr :rest, :global, doc: "HTML attributes forwarded to the div element"
  slot :inner_block, required: true, doc: "Footer content (actions, metadata)"

  @doc "Renders the Card footer row."
  def card_footer(assigns) do
    ~H"""
    <div class={cn(["flex items-center p-6 pt-0", @class])} {@rest}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end
end
