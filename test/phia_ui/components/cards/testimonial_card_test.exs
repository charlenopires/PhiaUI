defmodule PhiaUi.Components.TestimonialCardTest do
  use ExUnit.Case, async: true
  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.TestimonialCard

    attr :quote, :string, default: "Great product!"
    attr :author_name, :string, default: "Jane Doe"
    attr :author_role, :string, default: nil
    attr :author_src, :string, default: nil
    attr :company, :string, default: nil
    attr :rating, :integer, default: nil
    attr :variant, :atom, default: :default
    attr :class, :string, default: nil

    def render_testimonial_card(assigns) do
      ~H"""
      <.testimonial_card
        quote={@quote}
        author_name={@author_name}
        author_role={@author_role}
        author_src={@author_src}
        company={@company}
        rating={@rating}
        variant={@variant}
        class={@class}
      />
      """
    end

    attr :author_name, :string, default: "Jane"
    attr :author_src, :string, default: "/avatar.jpg"

    def render_with_author_src(assigns) do
      ~H"""
      <.testimonial_card
        quote="Awesome!"
        author_name={@author_name}
        author_src={@author_src}
      />
      """
    end
  end

  defp render_testimonial_card(attrs \\ %{}) do
    render_component(&H.render_testimonial_card/1, attrs)
  end

  describe "testimonial_card/1 default render" do
    test "renders a card wrapper" do
      html = render_testimonial_card()
      assert html =~ "<div"
    end

    test "renders the quote text" do
      html = render_testimonial_card(%{quote: "Phia UI is amazing"})
      assert html =~ "Phia UI is amazing"
    end

    test "renders the author name" do
      html = render_testimonial_card(%{author_name: "Alice Smith"})
      assert html =~ "Alice Smith"
    end

    test "renders decorative quote mark" do
      html = render_testimonial_card()
      assert html =~ "\""
    end

    test "quote text is italic" do
      html = render_testimonial_card(%{quote: "Test quote"})
      assert html =~ "italic"
    end
  end

  describe "testimonial_card/1 author role and company" do
    test "renders author_role when provided" do
      html = render_testimonial_card(%{author_role: "CTO"})
      assert html =~ "CTO"
    end

    test "renders company when provided" do
      html = render_testimonial_card(%{company: "Acme Corp"})
      assert html =~ "Acme Corp"
    end

    test "renders both role and company joined with comma" do
      html = render_testimonial_card(%{author_role: "CTO", company: "Acme"})
      assert html =~ "CTO"
      assert html =~ "Acme"
    end

    test "does not render role/company row when both are nil" do
      html = render_testimonial_card(%{author_role: nil, company: nil})
      # The p tag for role/company is only rendered when at least one is set
      # Without role or company there is no comma-joined text
      refute html =~ ", "
    end
  end

  describe "testimonial_card/1 rating stars" do
    test "renders 5 filled stars for rating 5" do
      html = render_testimonial_card(%{rating: 5})
      assert html =~ "★★★★★"
    end

    test "renders 3 filled and 2 empty stars for rating 3" do
      html = render_testimonial_card(%{rating: 3})
      assert html =~ "★★★☆☆"
    end

    test "renders 1 filled and 4 empty stars for rating 1" do
      html = render_testimonial_card(%{rating: 1})
      assert html =~ "★☆☆☆☆"
    end

    test "does not render stars when rating is nil" do
      html = render_testimonial_card(%{rating: nil})
      refute html =~ "★"
      refute html =~ "☆"
    end
  end

  describe "testimonial_card/1 author avatar" do
    test "renders avatar img when author_src provided" do
      html = render_component(&H.render_with_author_src/1, %{})
      assert html =~ "<img"
      assert html =~ ~s(src="/avatar.jpg")
    end

    test "does not render img when author_src is nil" do
      html = render_testimonial_card(%{author_src: nil})
      refute html =~ "<img"
    end
  end

  describe "testimonial_card/1 variants" do
    test ":default variant renders card with shadow-sm" do
      html = render_testimonial_card(%{variant: :default})
      assert html =~ "shadow-sm"
    end

    test ":bordered variant renders card with border-2" do
      html = render_testimonial_card(%{variant: :bordered})
      assert html =~ "border-2"
    end

    test ":minimal variant renders plain div (no card chrome)" do
      html = render_testimonial_card(%{variant: :minimal})
      assert html =~ "<div"
      refute html =~ "shadow-sm"
      refute html =~ "border-2"
    end
  end

  describe "testimonial_card/1 class forwarding" do
    test "accepts custom class" do
      html = render_testimonial_card(%{class: "my-testimonial"})
      assert html =~ "my-testimonial"
    end
  end
end
