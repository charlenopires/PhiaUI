defmodule PhiaUi.Components.Marketing.FeatureSectionTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.Marketing.FeatureSection

    def render_feature_section(assigns) do
      ~H"""
      <.feature_section
        title={assigns[:title]}
        description={assigns[:description]}
        columns={assigns[:columns] || 3}
        align={assigns[:align] || :center}
        class={assigns[:class]}
      >
        {assigns[:content] || "Feature cards here"}
      </.feature_section>
      """
    end
  end

  defp render_feature_section(attrs \\ %{}), do: render_component(&H.render_feature_section/1, attrs)

  describe "feature_section/1" do
    test "renders inner_block content" do
      html = render_feature_section(%{content: "Card A"})
      assert html =~ "Card A"
    end

    test "renders title when provided" do
      html = render_feature_section(%{title: "Our Features"})
      assert html =~ "Our Features"
      assert html =~ "<h2"
    end

    test "renders description when provided" do
      html = render_feature_section(%{description: "Everything you need."})
      assert html =~ "Everything you need."
      assert html =~ "text-muted-foreground"
    end

    test "does not render header when no title or description" do
      html = render_feature_section(%{title: nil, description: nil})
      refute html =~ "mb-12"
    end

    test "default 3 columns renders lg:grid-cols-3" do
      assert render_feature_section() =~ "lg:grid-cols-3"
    end

    test "2 columns renders md:grid-cols-2 without lg:grid-cols-3" do
      html = render_feature_section(%{columns: 2})
      assert html =~ "md:grid-cols-2"
      refute html =~ "lg:grid-cols-3"
    end

    test "4 columns renders lg:grid-cols-4" do
      assert render_feature_section(%{columns: 4}) =~ "lg:grid-cols-4"
    end

    test "1 column renders grid-cols-1 only" do
      html = render_feature_section(%{columns: 1})
      assert html =~ "grid-cols-1"
      refute html =~ "md:grid-cols"
    end

    test "center align renders text-center" do
      assert render_feature_section(%{align: :center, title: "Features"}) =~ "text-center"
    end

    test "start align renders text-left" do
      assert render_feature_section(%{align: :start, title: "Features"}) =~ "text-left"
    end

    test "custom class is applied" do
      assert render_feature_section(%{class: "my-features"}) =~ "my-features"
    end

    test "renders section element" do
      assert render_feature_section() =~ "<section"
    end

    test "grid container has gap-8" do
      assert render_feature_section() =~ "gap-8"
    end
  end
end
