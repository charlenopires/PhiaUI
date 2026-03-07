defmodule PhiaUi.Components.TypographyTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.Typography

    # heading helpers
    attr :level, :integer, default: 2
    attr :size, :atom, default: :auto
    attr :align, :atom, default: :start
    attr :tracking, :atom, default: :tight
    attr :class, :string, default: nil

    def render_heading(assigns) do
      ~H"""
      <.heading level={@level} size={@size} align={@align} tracking={@tracking} class={@class}>
        Title
      </.heading>
      """
    end

    # display helpers
    attr :size, :atom, default: :"5xl"
    attr :align, :atom, default: :start
    attr :weight, :atom, default: :semibold

    def render_display(assigns) do
      ~H"""
      <.display size={@size} align={@align} weight={@weight}>Hero</.display>
      """
    end

    # text helpers
    attr :as, :atom, default: :span
    attr :size, :atom, default: :sm
    attr :weight, :atom, default: :normal
    attr :color, :atom, default: :default
    attr :align, :atom, default: :start
    attr :truncate, :boolean, default: false
    attr :italic, :boolean, default: false
    attr :underline, :boolean, default: false
    attr :strikethrough, :boolean, default: false
    attr :class, :string, default: nil

    def render_text(assigns) do
      ~H"""
      <.text
        as={@as}
        size={@size}
        weight={@weight}
        color={@color}
        align={@align}
        truncate={@truncate}
        italic={@italic}
        underline={@underline}
        strikethrough={@strikethrough}
        class={@class}
      >
        Content
      </.text>
      """
    end

    # paragraph helpers
    attr :size, :atom, default: :base

    def render_paragraph(assigns) do
      ~H"""
      <.paragraph size={@size}>Body text.</.paragraph>
      """
    end

    # lead
    def render_lead(assigns) do
      ~H"""
      <.lead>Lead content.</.lead>
      """
    end

    # blockquote helpers
    attr :cite, :string, default: nil

    def render_blockquote(assigns) do
      ~H"""
      <.blockquote cite={@cite}>A quote.</.blockquote>
      """
    end

    # inline_code
    def render_inline_code(assigns) do
      ~H"""
      <.inline_code>mix phia.install</.inline_code>
      """
    end

    # code_block helpers
    attr :language, :string, default: nil

    def render_code_block(assigns) do
      ~H"""
      <.code_block language={@language}>def hello, do: :world</.code_block>
      """
    end

    # mark helpers
    attr :color, :atom, default: :default

    def render_mark(assigns) do
      ~H"""
      <.mark color={@color}>highlighted</.mark>
      """
    end

    # text_link helpers
    attr :href, :string, default: "/docs"
    attr :external, :boolean, default: false
    attr :variant, :atom, default: :default

    def render_text_link(assigns) do
      ~H"""
      <.text_link href={@href} external={@external} variant={@variant}>Link</.text_link>
      """
    end

    # overline
    def render_overline(assigns) do
      ~H"""
      <.overline>Category</.overline>
      """
    end

    # caption helpers
    attr :as, :atom, default: :figcaption

    def render_caption(assigns) do
      ~H"""
      <.caption as={@as}>Figure description.</.caption>
      """
    end

    # abbr helpers
    attr :title, :string, default: "HyperText Markup Language"

    def render_abbr(assigns) do
      ~H"""
      <.abbr title={@title}>HTML</.abbr>
      """
    end

    # prose_list helpers
    attr :variant, :atom, default: :disc
    attr :spacing, :atom, default: :base

    def render_prose_list(assigns) do
      ~H"""
      <.prose_list variant={@variant} spacing={@spacing}>
        <li>Item one</li>
        <li>Item two</li>
      </.prose_list>
      """
    end

    # ordered_list helpers
    attr :variant, :atom, default: :decimal
    attr :spacing, :atom, default: :base

    def render_ordered_list(assigns) do
      ~H"""
      <.ordered_list variant={@variant} spacing={@spacing}>
        <li>Step one</li>
        <li>Step two</li>
      </.ordered_list>
      """
    end

    # gradient_text helpers
    attr :from, :atom, default: :primary
    attr :to, :atom, default: :secondary
    attr :angle, :atom, default: :r

    def render_gradient_text(assigns) do
      ~H"""
      <.gradient_text from={@from} to={@to} angle={@angle}>Gradient</.gradient_text>
      """
    end

    # truncated_text helpers
    attr :lines, :integer, default: 2

    def render_truncated_text(assigns) do
      ~H"""
      <.truncated_text lines={@lines}>Long text content here.</.truncated_text>
      """
    end

    # prose helpers
    attr :size, :atom, default: :base
    attr :invert, :boolean, default: false

    def render_prose(assigns) do
      ~H"""
      <.prose size={@size} invert={@invert}>
        <h1>Title</h1>
        <p>Body</p>
      </.prose>
      """
    end
  end

  defp render_heading(attrs \\ %{}), do: render_component(&H.render_heading/1, attrs)
  defp render_display(attrs \\ %{}), do: render_component(&H.render_display/1, attrs)
  defp render_text(attrs \\ %{}), do: render_component(&H.render_text/1, attrs)
  defp render_paragraph(attrs \\ %{}), do: render_component(&H.render_paragraph/1, attrs)
  defp render_lead, do: render_component(&H.render_lead/1, %{})
  defp render_blockquote(attrs \\ %{}), do: render_component(&H.render_blockquote/1, attrs)
  defp render_inline_code, do: render_component(&H.render_inline_code/1, %{})
  defp render_code_block(attrs \\ %{}), do: render_component(&H.render_code_block/1, attrs)
  defp render_mark(attrs \\ %{}), do: render_component(&H.render_mark/1, attrs)
  defp render_text_link(attrs \\ %{}), do: render_component(&H.render_text_link/1, attrs)
  defp render_overline, do: render_component(&H.render_overline/1, %{})
  defp render_caption(attrs \\ %{}), do: render_component(&H.render_caption/1, attrs)
  defp render_abbr(attrs \\ %{}), do: render_component(&H.render_abbr/1, attrs)
  defp render_prose_list(attrs \\ %{}), do: render_component(&H.render_prose_list/1, attrs)
  defp render_ordered_list(attrs \\ %{}), do: render_component(&H.render_ordered_list/1, attrs)
  defp render_gradient_text(attrs \\ %{}), do: render_component(&H.render_gradient_text/1, attrs)
  defp render_truncated_text(attrs \\ %{}), do: render_component(&H.render_truncated_text/1, attrs)
  defp render_prose(attrs \\ %{}), do: render_component(&H.render_prose/1, attrs)

  # ===========================================================================
  # 1. heading/1
  # ===========================================================================

  describe "heading defaults (level 2, auto)" do
    test "renders h2 element" do
      assert render_heading() =~ "<h2"
    end

    test "scroll-m-20" do
      assert render_heading() =~ "scroll-m-20"
    end

    test "text-3xl" do
      assert render_heading() =~ "text-3xl"
    end

    test "font-semibold" do
      assert render_heading() =~ "font-semibold"
    end

    test "leading-tight" do
      assert render_heading() =~ "leading-tight"
    end

    test "border-b for h2" do
      assert render_heading() =~ "border-b"
    end

    test "tracking-tight default" do
      assert render_heading() =~ "tracking-tight"
    end

    test "text-left default align" do
      assert render_heading() =~ "text-left"
    end

    test "renders inner content" do
      assert render_heading() =~ "Title"
    end
  end

  describe "heading level 1" do
    test "renders h1 element" do
      assert render_heading(%{level: 1}) =~ "<h1"
    end

    test "text-4xl" do
      assert render_heading(%{level: 1}) =~ "text-4xl"
    end

    test "leading-none" do
      assert render_heading(%{level: 1}) =~ "leading-none"
    end
  end

  describe "heading level 3" do
    test "renders h3 element" do
      assert render_heading(%{level: 3}) =~ "<h3"
    end

    test "text-2xl" do
      assert render_heading(%{level: 3}) =~ "text-2xl"
    end
  end

  describe "heading level 4" do
    test "renders h4" do
      assert render_heading(%{level: 4}) =~ "<h4"
    end

    test "text-xl" do
      assert render_heading(%{level: 4}) =~ "text-xl"
    end
  end

  describe "heading level 5" do
    test "renders h5" do
      assert render_heading(%{level: 5}) =~ "<h5"
    end

    test "text-lg" do
      assert render_heading(%{level: 5}) =~ "text-lg"
    end
  end

  describe "heading level 6" do
    test "renders h6" do
      assert render_heading(%{level: 6}) =~ "<h6"
    end

    test "text-base" do
      assert render_heading(%{level: 6}) =~ "text-base"
    end
  end

  describe "heading size override" do
    test "size :xs overrides to text-xs" do
      assert render_heading(%{size: :xs}) =~ "text-xs"
    end

    test "size :4xl overrides to text-4xl" do
      assert render_heading(%{size: :"4xl"}) =~ "text-4xl"
    end
  end

  describe "heading align" do
    test "align :center renders text-center" do
      assert render_heading(%{align: :center}) =~ "text-center"
    end

    test "align :end renders text-right" do
      assert render_heading(%{align: :end}) =~ "text-right"
    end
  end

  describe "heading tracking" do
    test "tracking :normal renders tracking-normal" do
      assert render_heading(%{tracking: :normal}) =~ "tracking-normal"
    end

    test "tracking :wide renders tracking-wide" do
      assert render_heading(%{tracking: :wide}) =~ "tracking-wide"
    end
  end

  describe "heading class override" do
    test "custom class is rendered" do
      assert render_heading(%{class: "my-custom"}) =~ "my-custom"
    end
  end

  # ===========================================================================
  # 2. display/1
  # ===========================================================================

  describe "display defaults" do
    test "renders p element" do
      assert render_display() =~ "<p"
    end

    test "text-5xl default" do
      assert render_display() =~ "text-5xl"
    end

    test "leading-none" do
      assert render_display() =~ "leading-none"
    end

    test "tracking-tight" do
      assert render_display() =~ "tracking-tight"
    end

    test "font-semibold default weight" do
      assert render_display() =~ "font-semibold"
    end

    test "renders content" do
      assert render_display() =~ "Hero"
    end
  end

  describe "display sizes" do
    test "size 6xl" do
      assert render_display(%{size: :"6xl"}) =~ "text-6xl"
    end

    test "size 7xl" do
      assert render_display(%{size: :"7xl"}) =~ "text-7xl"
    end
  end

  describe "display weight" do
    test "weight :normal" do
      assert render_display(%{weight: :normal}) =~ "font-normal"
    end

    test "weight :medium" do
      assert render_display(%{weight: :medium}) =~ "font-medium"
    end
  end

  describe "display align" do
    test "align :center" do
      assert render_display(%{align: :center}) =~ "text-center"
    end
  end

  # ===========================================================================
  # 3. text/1
  # ===========================================================================

  describe "text defaults (span)" do
    test "renders span element" do
      assert render_text() =~ "<span"
    end

    test "text-sm default size" do
      assert render_text() =~ "text-sm"
    end

    test "font-normal default weight" do
      assert render_text() =~ "font-normal"
    end

    test "text-foreground default color" do
      assert render_text() =~ "text-foreground"
    end

    test "renders content" do
      assert render_text() =~ "Content"
    end
  end

  describe "text :as variants" do
    test "as :p renders p element" do
      assert render_text(%{as: :p}) =~ "<p"
    end

    test "as :div renders div element" do
      assert render_text(%{as: :div}) =~ "<div"
    end

    test "as :label renders label element" do
      assert render_text(%{as: :label}) =~ "<label"
    end
  end

  describe "text size variants" do
    test "size :xs" do
      assert render_text(%{size: :xs}) =~ "text-xs"
    end

    test "size :base" do
      assert render_text(%{size: :base}) =~ "text-base"
    end

    test "size :lg" do
      assert render_text(%{size: :lg}) =~ "text-lg"
    end

    test "size :xl" do
      assert render_text(%{size: :xl}) =~ "text-xl"
    end
  end

  describe "text weight variants" do
    test "weight :medium" do
      assert render_text(%{weight: :medium}) =~ "font-medium"
    end

    test "weight :semibold" do
      assert render_text(%{weight: :semibold}) =~ "font-semibold"
    end
  end

  describe "text color variants" do
    test "color :muted" do
      assert render_text(%{color: :muted}) =~ "text-muted-foreground"
    end

    test "color :primary" do
      assert render_text(%{color: :primary}) =~ "text-primary"
    end

    test "color :destructive" do
      assert render_text(%{color: :destructive}) =~ "text-destructive"
    end
  end

  describe "text modifiers" do
    test "truncate adds truncate class" do
      assert render_text(%{truncate: true}) =~ "truncate"
    end

    test "italic adds italic class" do
      assert render_text(%{italic: true}) =~ "italic"
    end

    test "underline adds underline class" do
      assert render_text(%{underline: true}) =~ "underline"
    end

    test "strikethrough adds line-through class" do
      assert render_text(%{strikethrough: true}) =~ "line-through"
    end
  end

  describe "text align" do
    test "align :center" do
      assert render_text(%{align: :center}) =~ "text-center"
    end

    test "align :end" do
      assert render_text(%{align: :end}) =~ "text-right"
    end
  end

  describe "text class override" do
    test "custom class is rendered" do
      assert render_text(%{class: "custom-class"}) =~ "custom-class"
    end
  end

  # ===========================================================================
  # 4. paragraph/1
  # ===========================================================================

  describe "paragraph defaults" do
    test "renders p element" do
      assert render_paragraph() =~ "<p"
    end

    test "leading-7" do
      assert render_paragraph() =~ "leading-7"
    end

    test "mt-6 for non-first-child" do
      assert render_paragraph() =~ "not(:first-child"
    end

    test "text-base default" do
      assert render_paragraph() =~ "text-base"
    end

    test "renders content" do
      assert render_paragraph() =~ "Body text."
    end
  end

  describe "paragraph size variants" do
    test "size :sm" do
      assert render_paragraph(%{size: :sm}) =~ "text-sm"
    end

    test "size :lg" do
      assert render_paragraph(%{size: :lg}) =~ "text-lg"
    end
  end

  # ===========================================================================
  # 5. lead/1
  # ===========================================================================

  describe "lead" do
    test "renders p element" do
      assert render_lead() =~ "<p"
    end

    test "text-xl" do
      assert render_lead() =~ "text-xl"
    end

    test "text-muted-foreground" do
      assert render_lead() =~ "text-muted-foreground"
    end

    test "leading-relaxed" do
      assert render_lead() =~ "leading-relaxed"
    end

    test "renders content" do
      assert render_lead() =~ "Lead content."
    end
  end

  # ===========================================================================
  # 6. blockquote/1
  # ===========================================================================

  describe "blockquote defaults" do
    test "renders blockquote element" do
      assert render_blockquote() =~ "<blockquote"
    end

    test "border-l-4" do
      assert render_blockquote() =~ "border-l-4"
    end

    test "border-border" do
      assert render_blockquote() =~ "border-border"
    end

    test "pl-6" do
      assert render_blockquote() =~ "pl-6"
    end

    test "italic" do
      assert render_blockquote() =~ "italic"
    end

    test "text-muted-foreground" do
      assert render_blockquote() =~ "text-muted-foreground"
    end

    test "no cite footer by default" do
      refute render_blockquote() =~ "<cite"
    end

    test "renders inner content" do
      assert render_blockquote() =~ "A quote."
    end
  end

  describe "blockquote with cite" do
    test "renders cite element" do
      assert render_blockquote(%{cite: "Shakespeare"}) =~ "<cite"
    end

    test "renders cite text" do
      assert render_blockquote(%{cite: "Shakespeare"}) =~ "Shakespeare"
    end

    test "renders footer" do
      assert render_blockquote(%{cite: "Shakespeare"}) =~ "<footer"
    end
  end

  # ===========================================================================
  # 7. inline_code/1
  # ===========================================================================

  describe "inline_code" do
    test "renders code element" do
      assert render_inline_code() =~ "<code"
    end

    test "bg-muted" do
      assert render_inline_code() =~ "bg-muted"
    end

    test "font-mono" do
      assert render_inline_code() =~ "font-mono"
    end

    test "font-semibold" do
      assert render_inline_code() =~ "font-semibold"
    end

    test "rounded-sm" do
      assert render_inline_code() =~ "rounded-sm"
    end

    test "renders content" do
      assert render_inline_code() =~ "mix phia.install"
    end
  end

  # ===========================================================================
  # 8. code_block/1
  # ===========================================================================

  describe "code_block defaults" do
    test "renders pre element" do
      assert render_code_block() =~ "<pre"
    end

    test "renders code element inside" do
      assert render_code_block() =~ "<code"
    end

    test "overflow-x-auto" do
      assert render_code_block() =~ "overflow-x-auto"
    end

    test "rounded-lg" do
      assert render_code_block() =~ "rounded-lg"
    end

    test "bg-muted" do
      assert render_code_block() =~ "bg-muted"
    end

    test "font-mono" do
      assert render_code_block() =~ "font-mono"
    end

    test "no language badge by default" do
      refute render_code_block() =~ "elixir"
    end

    test "renders inner content" do
      assert render_code_block() =~ "def hello"
    end
  end

  describe "code_block with language" do
    test "renders language label" do
      assert render_code_block(%{language: "elixir"}) =~ "elixir"
    end
  end

  # ===========================================================================
  # 9. mark/1
  # ===========================================================================

  describe "mark defaults" do
    test "renders mark element" do
      assert render_mark() =~ "<mark"
    end

    test "rounded-sm" do
      assert render_mark() =~ "rounded-sm"
    end

    test "text-foreground" do
      assert render_mark() =~ "text-foreground"
    end

    test "bg-primary/20 default color" do
      assert render_mark() =~ "bg-primary/20"
    end

    test "renders content" do
      assert render_mark() =~ "highlighted"
    end
  end

  describe "mark color variants" do
    test "color :yellow" do
      assert render_mark(%{color: :yellow}) =~ "bg-yellow-200/80"
    end

    test "color :green" do
      assert render_mark(%{color: :green}) =~ "bg-green-200/80"
    end

    test "color :blue" do
      assert render_mark(%{color: :blue}) =~ "bg-blue-200/80"
    end

    test "color :red" do
      assert render_mark(%{color: :red}) =~ "bg-destructive/20"
    end
  end

  # ===========================================================================
  # 10. text_link/1
  # ===========================================================================

  describe "text_link defaults" do
    test "renders a element" do
      assert render_text_link() =~ "<a"
    end

    test "href attribute" do
      assert render_text_link() =~ ~s(href="/docs")
    end

    test "text-primary" do
      assert render_text_link() =~ "text-primary"
    end

    test "underline-offset-4" do
      assert render_text_link() =~ "underline-offset-4"
    end

    test "hover:underline" do
      assert render_text_link() =~ "hover:underline"
    end

    test "no target by default" do
      refute render_text_link() =~ "target="
    end

    test "renders content" do
      assert render_text_link() =~ "Link"
    end
  end

  describe "text_link external" do
    test "adds target=_blank" do
      assert render_text_link(%{external: true}) =~ ~s(target="_blank")
    end

    test "adds rel=noopener noreferrer" do
      assert render_text_link(%{external: true}) =~ "noopener noreferrer"
    end
  end

  describe "text_link variant :muted" do
    test "text-muted-foreground" do
      assert render_text_link(%{variant: :muted}) =~ "text-muted-foreground"
    end

    test "hover:text-foreground" do
      assert render_text_link(%{variant: :muted}) =~ "hover:text-foreground"
    end

    test "no text-primary" do
      refute render_text_link(%{variant: :muted}) =~ "text-primary"
    end
  end

  # ===========================================================================
  # 11. overline/1
  # ===========================================================================

  describe "overline" do
    test "renders span element" do
      assert render_overline() =~ "<span"
    end

    test "text-xs" do
      assert render_overline() =~ "text-xs"
    end

    test "uppercase" do
      assert render_overline() =~ "uppercase"
    end

    test "tracking-widest" do
      assert render_overline() =~ "tracking-widest"
    end

    test "text-muted-foreground" do
      assert render_overline() =~ "text-muted-foreground"
    end

    test "font-semibold" do
      assert render_overline() =~ "font-semibold"
    end

    test "renders content" do
      assert render_overline() =~ "Category"
    end
  end

  # ===========================================================================
  # 12. caption/1
  # ===========================================================================

  describe "caption defaults (figcaption)" do
    test "renders figcaption element" do
      assert render_caption() =~ "<figcaption"
    end

    test "text-sm" do
      assert render_caption() =~ "text-sm"
    end

    test "text-muted-foreground" do
      assert render_caption() =~ "text-muted-foreground"
    end

    test "leading-normal" do
      assert render_caption() =~ "leading-normal"
    end

    test "renders content" do
      assert render_caption() =~ "Figure description."
    end
  end

  describe "caption :as variants" do
    test "as :span renders span" do
      assert render_caption(%{as: :span}) =~ "<span"
    end

    test "as :p renders p" do
      assert render_caption(%{as: :p}) =~ "<p"
    end
  end

  # ===========================================================================
  # 13. abbr/1
  # ===========================================================================

  describe "abbr" do
    test "renders abbr element" do
      assert render_abbr() =~ "<abbr"
    end

    test "title attribute is set" do
      assert render_abbr() =~ ~s(title="HyperText Markup Language")
    end

    test "cursor-help" do
      assert render_abbr() =~ "cursor-help"
    end

    test "border-b for underline effect" do
      assert render_abbr() =~ "border-b"
    end

    test "border-dotted" do
      assert render_abbr() =~ "border-dotted"
    end

    test "border-muted-foreground" do
      assert render_abbr() =~ "border-muted-foreground"
    end

    test "renders content" do
      assert render_abbr() =~ "HTML"
    end
  end

  # ===========================================================================
  # 14. prose_list/1
  # ===========================================================================

  describe "prose_list defaults" do
    test "renders ul element" do
      assert render_prose_list() =~ "<ul"
    end

    test "list-disc default" do
      assert render_prose_list() =~ "list-disc"
    end

    test "my-6 base spacing" do
      assert render_prose_list() =~ "my-6"
    end

    test "ml-6 base spacing" do
      assert render_prose_list() =~ "ml-6"
    end

    test "renders list items" do
      html = render_prose_list()
      assert html =~ "Item one"
      assert html =~ "Item two"
    end
  end

  describe "prose_list variant :circle" do
    test "list-[circle]" do
      assert render_prose_list(%{variant: :circle}) =~ "list-[circle]"
    end
  end

  describe "prose_list variant :none" do
    test "list-none" do
      assert render_prose_list(%{variant: :none}) =~ "list-none"
    end
  end

  describe "prose_list spacing :sm" do
    test "my-2" do
      assert render_prose_list(%{spacing: :sm}) =~ "my-2"
    end

    test "ml-4" do
      assert render_prose_list(%{spacing: :sm}) =~ "ml-4"
    end
  end

  # ===========================================================================
  # 15. ordered_list/1
  # ===========================================================================

  describe "ordered_list defaults" do
    test "renders ol element" do
      assert render_ordered_list() =~ "<ol"
    end

    test "list-decimal default" do
      assert render_ordered_list() =~ "list-decimal"
    end

    test "my-6 base spacing" do
      assert render_ordered_list() =~ "my-6"
    end

    test "renders list items" do
      html = render_ordered_list()
      assert html =~ "Step one"
      assert html =~ "Step two"
    end
  end

  describe "ordered_list variant :alpha" do
    test "list-[lower-alpha]" do
      assert render_ordered_list(%{variant: :alpha}) =~ "list-[lower-alpha]"
    end
  end

  describe "ordered_list variant :roman" do
    test "list-[lower-roman]" do
      assert render_ordered_list(%{variant: :roman}) =~ "list-[lower-roman]"
    end
  end

  describe "ordered_list spacing :sm" do
    test "my-2" do
      assert render_ordered_list(%{spacing: :sm}) =~ "my-2"
    end

    test "ml-4" do
      assert render_ordered_list(%{spacing: :sm}) =~ "ml-4"
    end
  end

  # ===========================================================================
  # 16. gradient_text/1
  # ===========================================================================

  describe "gradient_text defaults" do
    test "renders span element" do
      assert render_gradient_text() =~ "<span"
    end

    test "bg-clip-text" do
      assert render_gradient_text() =~ "bg-clip-text"
    end

    test "text-transparent" do
      assert render_gradient_text() =~ "text-transparent"
    end

    test "bg-gradient-to-r default angle" do
      assert render_gradient_text() =~ "bg-gradient-to-r"
    end

    test "from-primary/90 default from" do
      assert render_gradient_text() =~ "from-primary/90"
    end

    test "to-secondary/90 default to" do
      assert render_gradient_text() =~ "to-secondary/90"
    end

    test "renders content" do
      assert render_gradient_text() =~ "Gradient"
    end
  end

  describe "gradient_text from variants" do
    test "from :secondary" do
      assert render_gradient_text(%{from: :secondary}) =~ "from-secondary/90"
    end

    test "from :destructive" do
      assert render_gradient_text(%{from: :destructive}) =~ "from-destructive/90"
    end

    test "from :muted" do
      assert render_gradient_text(%{from: :muted}) =~ "from-muted-foreground/90"
    end
  end

  describe "gradient_text to variants" do
    test "to :primary" do
      assert render_gradient_text(%{to: :primary}) =~ "to-primary/90"
    end

    test "to :destructive" do
      assert render_gradient_text(%{to: :destructive}) =~ "to-destructive/90"
    end
  end

  describe "gradient_text angle variants" do
    test "angle :l" do
      assert render_gradient_text(%{angle: :l}) =~ "bg-gradient-to-l"
    end

    test "angle :t" do
      assert render_gradient_text(%{angle: :t}) =~ "bg-gradient-to-t"
    end

    test "angle :b" do
      assert render_gradient_text(%{angle: :b}) =~ "bg-gradient-to-b"
    end

    test "angle :tr" do
      assert render_gradient_text(%{angle: :tr}) =~ "bg-gradient-to-tr"
    end

    test "angle :tl" do
      assert render_gradient_text(%{angle: :tl}) =~ "bg-gradient-to-tl"
    end

    test "angle :br" do
      assert render_gradient_text(%{angle: :br}) =~ "bg-gradient-to-br"
    end

    test "angle :bl" do
      assert render_gradient_text(%{angle: :bl}) =~ "bg-gradient-to-bl"
    end
  end

  # ===========================================================================
  # 17. truncated_text/1
  # ===========================================================================

  describe "truncated_text defaults" do
    test "renders p element" do
      assert render_truncated_text() =~ "<p"
    end

    test "overflow-hidden" do
      assert render_truncated_text() =~ "overflow-hidden"
    end

    test "line-clamp-2 default" do
      assert render_truncated_text() =~ "line-clamp-2"
    end

    test "renders content" do
      assert render_truncated_text() =~ "Long text content here."
    end
  end

  describe "truncated_text lines variants" do
    test "lines 1" do
      assert render_truncated_text(%{lines: 1}) =~ "line-clamp-1"
    end

    test "lines 3" do
      assert render_truncated_text(%{lines: 3}) =~ "line-clamp-3"
    end

    test "lines 4" do
      assert render_truncated_text(%{lines: 4}) =~ "line-clamp-4"
    end

    test "lines 5" do
      assert render_truncated_text(%{lines: 5}) =~ "line-clamp-5"
    end

    test "lines 6" do
      assert render_truncated_text(%{lines: 6}) =~ "line-clamp-6"
    end
  end

  # ===========================================================================
  # 18. prose/1
  # ===========================================================================

  describe "prose defaults" do
    test "renders div element" do
      assert render_prose() =~ "<div"
    end

    test "text-foreground" do
      assert render_prose() =~ "text-foreground"
    end

    test "max-w-none" do
      assert render_prose() =~ "max-w-none"
    end

    test "text-base default size" do
      assert render_prose() =~ "text-base"
    end

    test "child h1 selectors" do
      # & is HTML-escaped to &amp; inside a class attribute
      assert render_prose() =~ "[&amp;_h1]"
    end

    test "child p selectors" do
      assert render_prose() =~ "[&amp;_p]"
    end

    test "child ul selectors" do
      assert render_prose() =~ "[&amp;_ul]"
    end

    test "child code selectors" do
      assert render_prose() =~ "[&amp;_code]"
    end

    test "renders inner content" do
      html = render_prose()
      assert html =~ "Title"
      assert html =~ "Body"
    end
  end

  describe "prose size variants" do
    test "size :sm" do
      assert render_prose(%{size: :sm}) =~ "text-sm"
    end

    test "size :lg" do
      assert render_prose(%{size: :lg}) =~ "text-lg"
    end

    test "size :xl" do
      assert render_prose(%{size: :xl}) =~ "text-xl"
    end
  end

  describe "prose invert" do
    test "invert adds text-foreground/80" do
      assert render_prose(%{invert: true}) =~ "text-foreground/80"
    end

    test "no invert class by default" do
      refute render_prose() =~ "text-foreground/80"
    end
  end
end
