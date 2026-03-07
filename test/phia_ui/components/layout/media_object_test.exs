defmodule PhiaUi.Components.Layout.MediaObjectTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.Layout.MediaObject

    def render_media_object(assigns) do
      ~H"""
      <.media_object
        align={assigns[:align] || :start}
        gap={assigns[:gap] || 4}
        reversed={assigns[:reversed] || false}
        class={assigns[:class]}
      >
        <:media><img src="avatar.png" alt="" /></:media>
        <p>Body content</p>
      </.media_object>
      """
    end
  end

  defp render_media_object(attrs \\ %{}) do
    render_component(&H.render_media_object/1, attrs)
  end

  describe "media_object/1 default" do
    test "renders a div" do
      assert render_media_object() =~ "<div"
    end

    test "applies flex" do
      assert render_media_object() =~ "flex"
    end

    test "applies default gap-4" do
      assert render_media_object() =~ "gap-4"
    end

    test "renders media slot" do
      assert render_media_object() =~ "avatar.png"
    end

    test "renders body content" do
      assert render_media_object() =~ "Body content"
    end

    test "media has shrink-0" do
      assert render_media_object() =~ "shrink-0"
    end
  end

  describe "media_object/1 align" do
    test "align start" do
      assert render_media_object(%{align: :start}) =~ "items-start"
    end

    test "align center" do
      assert render_media_object(%{align: :center}) =~ "items-center"
    end

    test "align end" do
      assert render_media_object(%{align: :end}) =~ "items-end"
    end
  end

  describe "media_object/1 reversed" do
    test "reversed adds flex-row-reverse" do
      assert render_media_object(%{reversed: true}) =~ "flex-row-reverse"
    end

    test "not reversed has no flex-row-reverse" do
      refute render_media_object(%{reversed: false}) =~ "flex-row-reverse"
    end
  end

  describe "media_object/1 class forwarding" do
    test "forwards custom class" do
      assert render_media_object(%{class: "p-4"}) =~ "p-4"
    end
  end
end
