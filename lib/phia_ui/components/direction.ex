defmodule PhiaUi.Components.Direction do
  @moduledoc """
  Direction utility component for controlling text direction (LTR/RTL).

  Wraps children in a `<div>` with the HTML `dir` attribute set to either
  `"ltr"` (left-to-right) or `"rtl"` (right-to-left). Useful for
  multilingual applications with Arabic, Hebrew, or other RTL content.

  ## Examples

      <.direction dir="ltr">Hello World</.direction>

      <.direction dir="rtl">مرحبا بالعالم</.direction>

      <.direction dir="rtl" class="font-arabic text-lg">
        <p>نص عربي</p>
      </.direction>

      <.direction data-region="arabic-block">
        <.card>...</.card>
      </.direction>
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  attr(:dir, :string,
    default: "ltr",
    values: ~w(ltr rtl),
    doc: "Text direction: 'ltr' (left-to-right) or 'rtl' (right-to-left)"
  )

  attr(:class, :string,
    default: nil,
    doc: "Additional CSS classes applied to the wrapper div"
  )

  attr(:rest, :global, doc: "HTML attributes forwarded to the root div element")

  slot(:inner_block, required: true, doc: "Content inside the direction wrapper")

  @doc """
  Renders a `<div>` wrapper with the specified text direction.

  Sets the HTML `dir` attribute so that the browser renders all descendant
  text in the correct direction. When `dir="rtl"` is used, punctuation,
  inline elements, and text alignment all respond accordingly without
  requiring any additional CSS.
  """
  def direction(assigns) do
    ~H"""
    <div dir={@dir} class={cn([@class])} {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end
end
