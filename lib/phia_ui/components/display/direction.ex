defmodule PhiaUi.Components.Direction do
  @moduledoc """
  Text direction utility component for LTR and RTL content.

  Wraps children in a `<div>` with the HTML `dir` attribute set to either
  `"ltr"` (left-to-right) or `"rtl"` (right-to-left). When `dir="rtl"` is
  applied, the browser automatically mirrors:
  - Text alignment (right-aligned by default for RTL scripts).
  - Inline element flow (right-to-left).
  - Punctuation placement.
  - Bi-directional text rendering (Unicode BiDi algorithm).

  No CSS, no JavaScript — purely the standard HTML `dir` attribute.

  ## When to use

  Use `direction/1` when:
  - Displaying user-generated content that may be in an RTL language
    (Arabic, Hebrew, Farsi, Urdu, etc.).
  - Building internationalised UI where a section must switch direction
    independently of the page-level direction.
  - Isolating RTL content inside an otherwise LTR page.

  For full-page RTL support, set `dir` on the `<html>` element instead.

  ## Examples

  ### Basic LTR (default)

      <.direction dir="ltr">Hello World</.direction>

  ### Arabic RTL text

      <.direction dir="rtl">مرحبا بالعالم</.direction>

  ### Hebrew with custom font

      <.direction dir="rtl" class="font-serif text-lg">
        <p>שלום עולם</p>
      </.direction>

  ### Conditional direction based on locale

      <.direction dir={if @locale in ~w(ar he fa ur), do: "rtl", else: "ltr"}>
        <.card>
          <.card_content>{@content}</.card_content>
        </.card>
      </.direction>

  ### Multilingual chat message

      <%!-- In a chat app, each message detects its own direction --%>
      <%= for message <- @messages do %>
        <.direction dir={message.direction} class="mb-2">
          <div class="rounded-lg bg-muted px-4 py-2 text-sm">
            {message.body}
          </div>
        </.direction>
      <% end %>

  ### RTL navigation sidebar

      <.direction dir="rtl">
        <nav class="flex flex-col gap-1 p-4">
          <.navigation_menu_link href="/ar/home">الصفحة الرئيسية</.navigation_menu_link>
          <.navigation_menu_link href="/ar/about">من نحن</.navigation_menu_link>
        </nav>
      </.direction>

  ## Accessibility notes

  Setting `dir` on a container element is the W3C-recommended approach for
  marking bidirectional text regions. Screen readers and braille displays
  use this attribute to determine reading order and text pronunciation
  direction for languages such as Arabic and Hebrew.
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  attr(:dir, :string,
    default: "ltr",
    values: ~w(ltr rtl),
    doc:
      "Text direction. `\"ltr\"` (default) for left-to-right languages (English, French, etc.). `\"rtl\"` for right-to-left languages (Arabic, Hebrew, Farsi, Urdu)."
  )

  attr(:class, :string,
    default: nil,
    doc: "Additional CSS classes applied to the wrapper `<div>`."
  )

  attr(:rest, :global,
    doc: "HTML attributes forwarded to the root `<div>` element (e.g. `lang`, `data-*`)."
  )

  slot(:inner_block,
    required: true,
    doc:
      "Content inside the direction wrapper. All descendant text and inline elements respect the `dir` attribute."
  )

  @doc """
  Renders a `<div>` wrapper with the specified text direction.

  Sets the HTML `dir` attribute so the browser renders all descendant text
  in the correct direction. Punctuation, inline elements, and implicit text
  alignment all respond accordingly without requiring additional CSS.

  ## Example

      <.direction dir="rtl" class="text-lg">
        <p>مرحبا بالعالم</p>
      </.direction>
  """
  def direction(assigns) do
    ~H"""
    <div dir={@dir} class={cn([@class])} {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end
end
