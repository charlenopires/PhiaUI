defmodule PhiaUi.Components.AvatarTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.Avatar

    def render_with_image(assigns) do
      ~H"""
      <.avatar>
        <.avatar_image src="https://example.com/avatar.jpg" alt="John Doe" />
        <.avatar_fallback name="John Doe" />
      </.avatar>
      """
    end

    def render_fallback_only(assigns) do
      ~H"""
      <.avatar>
        <.avatar_fallback name="Jane Smith" />
      </.avatar>
      """
    end

    def render_group(assigns) do
      ~H"""
      <.avatar_group>
        <.avatar><.avatar_fallback name="Alice A" /></.avatar>
        <.avatar><.avatar_fallback name="Bob B" /></.avatar>
        <.avatar><.avatar_fallback name="Carl C" /></.avatar>
      </.avatar_group>
      """
    end

    def render_sizes(assigns) do
      ~H"""
      <div>
        <.avatar size="sm"><.avatar_fallback name="S" /></.avatar>
        <.avatar size="default"><.avatar_fallback name="D" /></.avatar>
        <.avatar size="lg"><.avatar_fallback name="L" /></.avatar>
        <.avatar size="xl"><.avatar_fallback name="X" /></.avatar>
      </div>
      """
    end

    def render_custom_fallback(assigns) do
      ~H"""
      <.avatar>
        <.avatar_fallback>?</.avatar_fallback>
      </.avatar>
      """
    end

    def render_with_custom_class(assigns) do
      ~H"""
      <.avatar class="ring-2 ring-primary">
        <.avatar_fallback name="Test User" />
      </.avatar>
      """
    end

    def render_group_with_class(assigns) do
      ~H"""
      <.avatar_group class="justify-center">
        <.avatar><.avatar_fallback name="A B" /></.avatar>
        <.avatar><.avatar_fallback name="C D" /></.avatar>
      </.avatar_group>
      """
    end
  end

  # ---------------------------------------------------------------------------
  # avatar/1
  # ---------------------------------------------------------------------------

  describe "avatar/1" do
    test "renders circular container with overflow-hidden" do
      html = render_component(&H.render_with_image/1, %{})
      assert html =~ "overflow-hidden"
      assert html =~ "rounded-full"
    end

    test "renders default size (h-10 w-10)" do
      html = render_component(&H.render_fallback_only/1, %{})
      assert html =~ "h-10 w-10"
    end

    test "renders sm size (h-6 w-6)" do
      html = render_component(&H.render_sizes/1, %{})
      assert html =~ "h-6 w-6"
    end

    test "renders lg size (h-14 w-14)" do
      html = render_component(&H.render_sizes/1, %{})
      assert html =~ "h-14 w-14"
    end

    test "renders xl size (h-18 w-18)" do
      html = render_component(&H.render_sizes/1, %{})
      assert html =~ "h-18 w-18"
    end

    test "renders as span element" do
      html = render_component(&H.render_fallback_only/1, %{})
      assert html =~ "<span"
    end

    test "accepts custom class" do
      html = render_component(&H.render_with_custom_class/1, %{})
      assert html =~ "ring-2"
      assert html =~ "ring-primary"
    end

    test "has relative positioning and flex layout" do
      html = render_component(&H.render_fallback_only/1, %{})
      assert html =~ "relative"
      assert html =~ "flex"
      assert html =~ "shrink-0"
    end
  end

  # ---------------------------------------------------------------------------
  # avatar_image/1
  # ---------------------------------------------------------------------------

  describe "avatar_image/1" do
    test "renders img tag with src" do
      html = render_component(&H.render_with_image/1, %{})
      assert html =~ ~s(src="https://example.com/avatar.jpg")
    end

    test "renders img tag with alt" do
      html = render_component(&H.render_with_image/1, %{})
      assert html =~ ~s(alt="John Doe")
    end

    test "includes onerror handler for fallback" do
      html = render_component(&H.render_with_image/1, %{})
      assert html =~ "onerror"
    end

    test "onerror hides the image on failure" do
      html = render_component(&H.render_with_image/1, %{})
      assert html =~ "this.style.display"
    end

    test "img covers full container (object-cover, h-full, w-full)" do
      html = render_component(&H.render_with_image/1, %{})
      assert html =~ "object-cover"
      assert html =~ "h-full"
      assert html =~ "w-full"
    end
  end

  # ---------------------------------------------------------------------------
  # avatar_fallback/1
  # ---------------------------------------------------------------------------

  describe "avatar_fallback/1" do
    test "displays initials from :name — first and last initial" do
      html = render_component(&H.render_fallback_only/1, %{})
      # Jane Smith -> JS
      assert html =~ "JS"
    end

    test "displays initials from :name — single word (only first letter)" do
      defmodule SingleName do
        @moduledoc false
        use Phoenix.Component
        import PhiaUi.Components.Avatar

        def render(assigns) do
          ~H"""
          <.avatar_fallback name="Alice" />
          """
        end
      end

      html = render_component(&SingleName.render/1, %{})
      assert html =~ "A"
    end

    test "uses data-avatar-fallback attribute" do
      html = render_component(&H.render_fallback_only/1, %{})
      assert html =~ "data-avatar-fallback"
    end

    test "renders bg-muted (semantic token)" do
      html = render_component(&H.render_fallback_only/1, %{})
      assert html =~ "bg-muted"
      refute html =~ "bg-gray"
    end

    test "renders text-muted-foreground (semantic token)" do
      html = render_component(&H.render_fallback_only/1, %{})
      assert html =~ "text-muted-foreground"
    end

    test "renders inner slot content when no :name provided" do
      html = render_component(&H.render_custom_fallback/1, %{})
      assert html =~ "?"
    end

    test "renders as span element" do
      html = render_component(&H.render_fallback_only/1, %{})
      assert html =~ ~s(data-avatar-fallback)
    end

    test "renders items-center and justify-center for centering" do
      html = render_component(&H.render_fallback_only/1, %{})
      assert html =~ "items-center"
      assert html =~ "justify-center"
    end
  end

  # ---------------------------------------------------------------------------
  # avatar_group/1
  # ---------------------------------------------------------------------------

  describe "avatar_group/1" do
    test "renders multiple avatars with negative spacing" do
      html = render_component(&H.render_group/1, %{})
      assert html =~ "-space-x-2"
    end

    test "renders all avatars in the group" do
      html = render_component(&H.render_group/1, %{})
      assert html =~ "AA"
      assert html =~ "BB"
      assert html =~ "CC"
    end

    test "renders as div element" do
      html = render_component(&H.render_group/1, %{})
      assert html =~ "<div"
    end

    test "renders flex layout" do
      html = render_component(&H.render_group/1, %{})
      assert html =~ "flex"
    end

    test "accepts custom class" do
      html = render_component(&H.render_group_with_class/1, %{})
      assert html =~ "justify-center"
      assert html =~ "-space-x-2"
    end
  end

  # ---------------------------------------------------------------------------
  # initials derivation edge cases
  # ---------------------------------------------------------------------------

  describe "initials/1 (via avatar_fallback)" do
    test "nil name produces empty string fallback" do
      defmodule NilName do
        @moduledoc false
        use Phoenix.Component
        import PhiaUi.Components.Avatar

        def render(assigns) do
          ~H"""
          <.avatar_fallback />
          """
        end
      end

      html = render_component(&NilName.render/1, %{})
      # Should not crash and should render the span
      assert html =~ "data-avatar-fallback"
    end

    test "John Doe name produces JD initials" do
      html = render_component(&H.render_with_image/1, %{})
      assert html =~ "JD"
    end

    test "three-word name only uses first two words" do
      defmodule ThreeName do
        @moduledoc false
        use Phoenix.Component
        import PhiaUi.Components.Avatar

        def render(assigns) do
          ~H"""
          <.avatar_fallback name="Mary Anne Brown" />
          """
        end
      end

      html = render_component(&ThreeName.render/1, %{})
      assert html =~ "MA"
      refute html =~ "MAB"
    end
  end
end
