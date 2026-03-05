defmodule PhiaUi.Components.WheelPickerTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.WheelPicker

    def render_single_col(assigns) do
      ~H"""
      <.wheel_picker columns={[
        %{
          name: "month",
          items: ~w(January February March April May June July August September October November December),
          selected: "October"
        }
      ]} />
      """
    end

    def render_three_cols(assigns) do
      ~H"""
      <.wheel_picker columns={[
        %{name: "month", items: ~w(January February March April May June July August September October November December), selected: "September"},
        %{name: "day",   items: ~w(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31), selected: "1"},
        %{name: "year",  items: ~w(1990 1991 1992 1993 1994 1995 1996 1997 1998 1999 2000), selected: "1995"}
      ]} />
      """
    end

    def render_with_on_change(assigns) do
      ~H"""
      <.wheel_picker
        columns={[
          %{
            name: "month",
            items: ~w(January February March April May June July August September October November December),
            selected: "October"
          }
        ]}
        on_change="col_changed"
      />
      """
    end

    def render_with_class(assigns) do
      ~H"""
      <.wheel_picker
        columns={[
          %{
            name: "month",
            items: ~w(January February March April May June July August September October November December),
            selected: "October"
          }
        ]}
        class="my-wheel"
      />
      """
    end

    def render_no_sep(assigns) do
      ~H"""
      <.wheel_picker
        columns={[
          %{
            name: "month",
            items: ~w(January February March April May June July August September October November December),
            selected: "October"
          }
        ]}
        separator={false}
      />
      """
    end
  end

  describe "wheel_picker/1" do
    # 1. selected item has font-bold
    test "renders selected item (October) with font-bold" do
      html = render_component(&H.render_single_col/1, %{})
      assert html =~ "font-bold"
      assert html =~ "October"
    end

    # 2. renders item before selected (September)
    test "renders item before selected (September)" do
      html = render_component(&H.render_single_col/1, %{})
      assert html =~ "September"
    end

    # 3. renders item after selected (November)
    test "renders item after selected (November)" do
      html = render_component(&H.render_single_col/1, %{})
      assert html =~ "November"
    end

    # 4. renders gradient-to-b overlay (top gradient)
    test "renders gradient-to-b overlay (top gradient)" do
      html = render_component(&H.render_single_col/1, %{})
      assert html =~ "gradient-to-b"
    end

    # 5. renders gradient-to-t overlay (bottom gradient)
    test "renders gradient-to-t overlay (bottom gradient)" do
      html = render_component(&H.render_single_col/1, %{})
      assert html =~ "gradient-to-t"
    end

    # 6. selected item has no phx-value-value pointing to itself (offset=0 — no click)
    test "selected item has no phx-value-value pointing to itself" do
      html = render_component(&H.render_with_on_change/1, %{})
      refute html =~ ~s(phx-value-value="October")
    end

    # 7. adjacent items have phx-click when on_change set
    test "adjacent items have phx-click when on_change set" do
      html = render_component(&H.render_with_on_change/1, %{})
      assert html =~ ~s(phx-click="col_changed")
    end

    # 8. phx-value-column set to column name
    test "phx-value-column set to column name" do
      html = render_component(&H.render_with_on_change/1, %{})
      assert html =~ ~s(phx-value-column="month")
    end

    # 9. phx-value-value set to adjacent item value
    test "phx-value-value set to adjacent item value (September)" do
      html = render_component(&H.render_with_on_change/1, %{})
      assert html =~ ~s(phx-value-value="September")
    end

    # 10. no phx-click when on_change not set
    test "no phx-click when on_change not set" do
      html = render_component(&H.render_single_col/1, %{})
      refute html =~ "phx-click"
    end

    # 11. three columns renders all three selected values
    test "three columns renders all three selected values" do
      html = render_component(&H.render_three_cols/1, %{})
      assert html =~ "September"
      assert html =~ "1995"
    end

    # 12. three columns renders September, 1, and 1995
    test "three columns renders September, 1, and 1995 as center items" do
      html = render_component(&H.render_three_cols/1, %{})
      assert html =~ "September"
      # "1" appears as an item value (selected day); whitespace-insensitive check
      assert html =~ ~r/>\s*1\s*</
      assert html =~ "1995"
    end

    # 13. center highlight bg-muted present
    test "center highlight bar has bg-muted class" do
      html = render_component(&H.render_single_col/1, %{})
      assert html =~ "bg-muted"
    end

    # 14. adjacent items have opacity-70 class
    test "adjacent items have opacity-70 class" do
      html = render_component(&H.render_single_col/1, %{})
      assert html =~ "opacity-70"
    end

    # 15. far items have opacity-40
    test "far items have opacity-40 class" do
      html = render_component(&H.render_single_col/1, %{})
      assert html =~ "opacity-40"
    end

    # 16. custom class applied
    test "custom class is applied to wrapper" do
      html = render_component(&H.render_with_class/1, %{})
      assert html =~ "my-wheel"
    end

    # 17. renders border on wrapper
    test "renders border on wrapper element" do
      html = render_component(&H.render_single_col/1, %{})
      assert html =~ "border"
    end

    # 18. adjacent item (offset=-1) has text-sm
    test "adjacent item (offset -1 or +1) has text-sm class" do
      html = render_component(&H.render_single_col/1, %{})
      assert html =~ "text-sm"
    end

    # 19. far item (offset=-2) has text-xs
    test "far item (offset -2 or +2) has text-xs class" do
      html = render_component(&H.render_single_col/1, %{})
      assert html =~ "text-xs"
    end

    # 20. selected item has text-lg
    test "selected item has text-lg class" do
      html = render_component(&H.render_single_col/1, %{})
      assert html =~ "text-lg"
    end

    # 21. wrapper has rounded-xl
    test "wrapper has rounded-xl class" do
      html = render_component(&H.render_single_col/1, %{})
      assert html =~ "rounded-xl"
    end

    # 22. renders 5 visible items per column (offsets -2..+2)
    test "renders 5 visible items for a single column" do
      html = render_component(&H.render_single_col/1, %{})
      # August(-2), September(-1), October(0), November(+1), December(+2)
      assert html =~ "August"
      assert html =~ "September"
      assert html =~ "October"
      assert html =~ "November"
      assert html =~ "December"
    end

    # 23. separator: wrapper uses divide-x by default
    test "wrapper uses divide-x class for column separation by default" do
      html = render_component(&H.render_single_col/1, %{})
      assert html =~ "divide-x"
    end

    # 24. separator={false} omits divide-x
    test "separator={false} omits divide-x class" do
      html = render_component(&H.render_no_sep/1, %{})
      refute html =~ "divide-x"
    end

    # 25. wrapper has overflow-hidden
    test "wrapper has overflow-hidden class" do
      html = render_component(&H.render_single_col/1, %{})
      assert html =~ "overflow-hidden"
    end
  end
end
