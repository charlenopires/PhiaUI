defmodule PhiaUi.Components.AdvancedChartsTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  # ── Test Helper Module ──────────────────────────────────────────────────

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.CandlestickChart
    import PhiaUi.Components.BoxPlot
    import PhiaUi.Components.ViolinPlot
    import PhiaUi.Components.SunburstChart
    import PhiaUi.Components.SankeyChart
    import PhiaUi.Components.ParetoChart
    import PhiaUi.Components.LollipopChart
    import PhiaUi.Components.DumbbellChart
    import PhiaUi.Components.WaffleChart
    import PhiaUi.Components.StreamChart
    import PhiaUi.Components.RidgelineChart
    import PhiaUi.Components.IcicleChart
    import PhiaUi.Components.CirclePackingChart
    import PhiaUi.Components.ChordChart
    import PhiaUi.Components.DotPlot
    import PhiaUi.Components.ArcDiagram
    import PhiaUi.Components.PictogramChart
    import PhiaUi.Components.ParliamentChart
    import PhiaUi.Components.WordCloudChart

    # ── Candlestick ───────────────────────────────────────────────────────

    def render_candlestick(assigns) do
      ~H"<.candlestick_chart data={@data} />"
    end

    def render_candlestick_opts(assigns) do
      ~H"<.candlestick_chart data={@data} title={@title} animate={false} />"
    end

    def render_candlestick_empty(assigns) do
      ~H"<.candlestick_chart data={[]} />"
    end

    # ── Box Plot ──────────────────────────────────────────────────────────

    def render_box_plot(assigns) do
      ~H"<.box_plot data={@data} />"
    end

    def render_box_plot_opts(assigns) do
      ~H"<.box_plot data={@data} title={@title} animate={false} />"
    end

    def render_box_plot_empty(assigns) do
      ~H"<.box_plot data={[]} />"
    end

    # ── Violin Plot ───────────────────────────────────────────────────────

    def render_violin(assigns) do
      ~H"<.violin_plot data={@data} />"
    end

    def render_violin_opts(assigns) do
      ~H"<.violin_plot data={@data} show_box={false} animate={false} />"
    end

    def render_violin_empty(assigns) do
      ~H"<.violin_plot data={[]} />"
    end

    # ── Sunburst ──────────────────────────────────────────────────────────

    def render_sunburst(assigns) do
      ~H"<.sunburst_chart data={@data} />"
    end

    def render_sunburst_opts(assigns) do
      ~H"<.sunburst_chart data={@data} title={@title} animate={false} />"
    end

    def render_sunburst_empty(assigns) do
      ~H"<.sunburst_chart data={[]} />"
    end

    # ── Sankey ────────────────────────────────────────────────────────────

    def render_sankey(assigns) do
      ~H"<.sankey_chart data={@data} />"
    end

    def render_sankey_opts(assigns) do
      ~H"<.sankey_chart data={@data} title={@title} animate={false} />"
    end

    def render_sankey_empty(assigns) do
      ~H"<.sankey_chart data={%{nodes: [], links: []}} />"
    end

    # ── Pareto ────────────────────────────────────────────────────────────

    def render_pareto(assigns) do
      ~H"<.pareto_chart data={@data} />"
    end

    def render_pareto_opts(assigns) do
      ~H"<.pareto_chart data={@data} title={@title} show_threshold={false} animate={false} />"
    end

    def render_pareto_empty(assigns) do
      ~H"<.pareto_chart data={[]} />"
    end

    # ── Lollipop ──────────────────────────────────────────────────────────

    def render_lollipop(assigns) do
      ~H"<.lollipop_chart data={@data} />"
    end

    def render_lollipop_opts(assigns) do
      ~H"<.lollipop_chart data={@data} variant={:horizontal} animate={false} />"
    end

    def render_lollipop_empty(assigns) do
      ~H"<.lollipop_chart data={[]} />"
    end

    # ── Dumbbell ──────────────────────────────────────────────────────────

    def render_dumbbell(assigns) do
      ~H"<.dumbbell_chart data={@data} />"
    end

    def render_dumbbell_opts(assigns) do
      ~H"<.dumbbell_chart data={@data} title={@title} animate={false} />"
    end

    def render_dumbbell_empty(assigns) do
      ~H"<.dumbbell_chart data={[]} />"
    end

    # ── Waffle ────────────────────────────────────────────────────────────

    def render_waffle(assigns) do
      ~H"<.waffle_chart data={@data} />"
    end

    def render_waffle_opts(assigns) do
      ~H"<.waffle_chart data={@data} title={@title} animate={false} />"
    end

    # ── Stream ────────────────────────────────────────────────────────────

    def render_stream(assigns) do
      ~H"<.stream_chart series={@series} />"
    end

    def render_stream_opts(assigns) do
      ~H"<.stream_chart series={@series} title={@title} animate={false} />"
    end

    # ── Ridgeline ─────────────────────────────────────────────────────────

    def render_ridgeline(assigns) do
      ~H"<.ridgeline_chart data={@data} />"
    end

    def render_ridgeline_opts(assigns) do
      ~H"<.ridgeline_chart data={@data} title={@title} animate={false} />"
    end

    def render_ridgeline_empty(assigns) do
      ~H"<.ridgeline_chart data={[]} />"
    end

    # ── Icicle ────────────────────────────────────────────────────────────

    def render_icicle(assigns) do
      ~H"<.icicle_chart data={@data} />"
    end

    def render_icicle_opts(assigns) do
      ~H"<.icicle_chart data={@data} title={@title} animate={false} />"
    end

    def render_icicle_empty(assigns) do
      ~H"<.icicle_chart data={[]} />"
    end

    # ── Circle Packing ────────────────────────────────────────────────────

    def render_circle_packing(assigns) do
      ~H"<.circle_packing_chart data={@data} />"
    end

    def render_circle_packing_opts(assigns) do
      ~H"<.circle_packing_chart data={@data} title={@title} animate={false} />"
    end

    def render_circle_packing_empty(assigns) do
      ~H"<.circle_packing_chart data={[]} />"
    end

    # ── Chord ─────────────────────────────────────────────────────────────

    def render_chord(assigns) do
      ~H"<.chord_chart matrix={@matrix} labels={@labels} />"
    end

    def render_chord_opts(assigns) do
      ~H"<.chord_chart matrix={@matrix} labels={@labels} title={@title} animate={false} />"
    end

    def render_chord_empty(assigns) do
      ~H"<.chord_chart matrix={[]} labels={[]} />"
    end

    # ── Dot Plot ──────────────────────────────────────────────────────────

    def render_dot_plot(assigns) do
      ~H"<.dot_plot data={@data} />"
    end

    def render_dot_plot_opts(assigns) do
      ~H"<.dot_plot data={@data} title={@title} animate={false} />"
    end

    def render_dot_plot_empty(assigns) do
      ~H"<.dot_plot data={[]} />"
    end

    # ── Arc Diagram ───────────────────────────────────────────────────────

    def render_arc_diagram(assigns) do
      ~H"<.arc_diagram nodes={@nodes} links={@links} />"
    end

    def render_arc_diagram_opts(assigns) do
      ~H"<.arc_diagram nodes={@nodes} links={@links} title={@title} animate={false} />"
    end

    def render_arc_diagram_empty(assigns) do
      ~H"<.arc_diagram nodes={[]} links={[]} />"
    end

    # ── Pictogram ─────────────────────────────────────────────────────────

    def render_pictogram(assigns) do
      ~H"<.pictogram_chart data={@data} />"
    end

    def render_pictogram_opts(assigns) do
      ~H"<.pictogram_chart data={@data} title={@title} animate={false} />"
    end

    def render_pictogram_empty(assigns) do
      ~H"<.pictogram_chart data={[]} />"
    end

    # ── Parliament ────────────────────────────────────────────────────────

    def render_parliament(assigns) do
      ~H"<.parliament_chart data={@data} />"
    end

    def render_parliament_opts(assigns) do
      ~H"<.parliament_chart data={@data} title={@title} animate={false} />"
    end

    def render_parliament_empty(assigns) do
      ~H"<.parliament_chart data={[]} />"
    end

    # ── Word Cloud ────────────────────────────────────────────────────────

    def render_word_cloud(assigns) do
      ~H"<.word_cloud_chart data={@data} />"
    end

    def render_word_cloud_opts(assigns) do
      ~H"<.word_cloud_chart data={@data} title={@title} animate={false} />"
    end

    def render_word_cloud_empty(assigns) do
      ~H"<.word_cloud_chart data={[]} />"
    end
  end

  # ── Test Data ───────────────────────────────────────────────────────────

  @ohlc_data [
    %{label: "Mon", open: 100, high: 120, low: 90, close: 115},
    %{label: "Tue", open: 115, high: 130, low: 105, close: 108},
    %{label: "Wed", open: 108, high: 125, low: 100, close: 122}
  ]

  @box_data [
    %{label: "Group A", values: [10, 20, 30, 40, 50, 60, 70]},
    %{label: "Group B", values: [15, 25, 35, 45, 55]}
  ]

  @violin_data [
    %{label: "Treatment", values: [10, 20, 20, 30, 30, 30, 40, 40, 50]},
    %{label: "Control", values: [15, 25, 25, 35, 35, 45]}
  ]

  @hierarchy_data [
    %{label: "Root", value: 100, children: [
      %{label: "A", value: 40, children: [
        %{label: "A1", value: 20, children: []},
        %{label: "A2", value: 20, children: []}
      ]},
      %{label: "B", value: 60, children: []}
    ]}
  ]

  @sankey_data %{
    nodes: [%{id: "a", label: "Source"}, %{id: "b", label: "Mid"}, %{id: "c", label: "Target"}],
    links: [%{source: "a", target: "b", value: 50}, %{source: "b", target: "c", value: 30}]
  }

  @simple_data [
    %{label: "A", value: 45},
    %{label: "B", value: 30},
    %{label: "C", value: 15},
    %{label: "D", value: 10}
  ]

  @dumbbell_data [
    %{label: "2023", start_value: 65, end_value: 85},
    %{label: "2024", start_value: 70, end_value: 92}
  ]

  @multi_series [
    %{name: "A", data: [%{label: "Q1", value: 10}, %{label: "Q2", value: 20}]},
    %{name: "B", data: [%{label: "Q1", value: 15}, %{label: "Q2", value: 25}]}
  ]

  @chord_matrix [[0, 10, 20], [10, 0, 15], [20, 15, 0]]
  @chord_labels ["X", "Y", "Z"]

  @arc_nodes ["A", "B", "C", "D"]
  @arc_links [%{source: "A", target: "B", value: 3}, %{source: "B", target: "C", value: 2}]

  @word_data [
    %{text: "Elixir", value: 100},
    %{text: "Phoenix", value: 80},
    %{text: "LiveView", value: 60},
    %{text: "OTP", value: 40}
  ]

  @parliament_data [
    %{label: "Party A", value: 120},
    %{label: "Party B", value: 80},
    %{label: "Party C", value: 50}
  ]

  # ── Candlestick Chart ──────────────────────────────────────────────────

  describe "candlestick_chart/1" do
    test "renders SVG with wicks and bodies" do
      html = render_component(&H.render_candlestick/1, %{data: @ohlc_data})
      assert html =~ "<svg"
      assert html =~ "viewBox="
      assert html =~ "<line"
      assert html =~ "<rect"
    end

    test "renders with title" do
      html = render_component(&H.render_candlestick_opts/1, %{data: @ohlc_data, title: "OHLC"})
      assert html =~ "OHLC"
    end

    test "renders with empty data" do
      html = render_component(&H.render_candlestick_empty/1, %{})
      assert html =~ "<svg"
    end

    test "renders candle labels" do
      html = render_component(&H.render_candlestick/1, %{data: @ohlc_data})
      assert html =~ "Mon"
      assert html =~ "Tue"
      assert html =~ "Wed"
    end
  end

  # ── Box Plot ────────────────────────────────────────────────────────────

  describe "box_plot/1" do
    test "renders SVG with box elements" do
      html = render_component(&H.render_box_plot/1, %{data: @box_data})
      assert html =~ "<svg"
      assert html =~ "<rect"
      assert html =~ "<line"
    end

    test "renders with title" do
      html = render_component(&H.render_box_plot_opts/1, %{data: @box_data, title: "Box"})
      assert html =~ "Box"
    end

    test "handles empty data" do
      html = render_component(&H.render_box_plot_empty/1, %{})
      assert html =~ "<svg"
    end

    test "renders group labels" do
      html = render_component(&H.render_box_plot/1, %{data: @box_data})
      assert html =~ "Group A"
      assert html =~ "Group B"
    end
  end

  # ── Violin Plot ─────────────────────────────────────────────────────────

  describe "violin_plot/1" do
    test "renders SVG with path elements" do
      html = render_component(&H.render_violin/1, %{data: @violin_data})
      assert html =~ "<svg"
      assert html =~ "<path"
    end

    test "renders without box overlay" do
      html = render_component(&H.render_violin_opts/1, %{data: @violin_data})
      assert html =~ "<svg"
    end

    test "handles empty data" do
      html = render_component(&H.render_violin_empty/1, %{})
      assert html =~ "<svg"
    end

    test "renders distribution labels" do
      html = render_component(&H.render_violin/1, %{data: @violin_data})
      assert html =~ "Treatment"
      assert html =~ "Control"
    end
  end

  # ── Sunburst Chart ─────────────────────────────────────────────────────

  describe "sunburst_chart/1" do
    test "renders SVG with arc paths" do
      html = render_component(&H.render_sunburst/1, %{data: @hierarchy_data})
      assert html =~ "<svg"
      assert html =~ "<path"
    end

    test "renders with title" do
      html = render_component(&H.render_sunburst_opts/1, %{data: @hierarchy_data, title: "Sunburst"})
      assert html =~ "Sunburst"
    end

    test "handles empty data" do
      html = render_component(&H.render_sunburst_empty/1, %{})
      assert html =~ "<svg"
    end
  end

  # ── Sankey Chart ────────────────────────────────────────────────────────

  describe "sankey_chart/1" do
    test "renders SVG with nodes and links" do
      html = render_component(&H.render_sankey/1, %{data: @sankey_data})
      assert html =~ "<svg"
      assert html =~ "<rect"
      assert html =~ "<path"
    end

    test "renders with title" do
      html = render_component(&H.render_sankey_opts/1, %{data: @sankey_data, title: "Flow"})
      assert html =~ "Flow"
    end

    test "renders node labels" do
      html = render_component(&H.render_sankey/1, %{data: @sankey_data})
      assert html =~ "Source"
      assert html =~ "Mid"
      assert html =~ "Target"
    end

    test "renders with empty data" do
      html = render_component(&H.render_sankey_empty/1, %{})
      assert html =~ "<svg"
    end
  end

  # ── Pareto Chart ────────────────────────────────────────────────────────

  describe "pareto_chart/1" do
    test "renders bars and cumulative line" do
      html = render_component(&H.render_pareto/1, %{data: @simple_data})
      assert html =~ "<svg"
      assert html =~ "<rect"
    end

    test "renders with title and without threshold" do
      html = render_component(&H.render_pareto_opts/1, %{data: @simple_data, title: "Pareto"})
      assert html =~ "Pareto"
    end

    test "handles empty data" do
      html = render_component(&H.render_pareto_empty/1, %{})
      assert html =~ "<svg"
    end

    test "renders data labels" do
      html = render_component(&H.render_pareto/1, %{data: @simple_data})
      assert html =~ "A"
      assert html =~ "B"
    end
  end

  # ── Lollipop Chart ─────────────────────────────────────────────────────

  describe "lollipop_chart/1" do
    test "renders stems and dots" do
      html = render_component(&H.render_lollipop/1, %{data: @simple_data})
      assert html =~ "<svg"
      assert html =~ "<line"
      assert html =~ "<circle"
    end

    test "renders horizontal variant" do
      html = render_component(&H.render_lollipop_opts/1, %{data: @simple_data})
      assert html =~ "<svg"
    end

    test "handles empty data" do
      html = render_component(&H.render_lollipop_empty/1, %{})
      assert html =~ "<svg"
    end

    test "renders category labels" do
      html = render_component(&H.render_lollipop/1, %{data: @simple_data})
      assert html =~ "A"
      assert html =~ "B"
    end
  end

  # ── Dumbbell Chart ─────────────────────────────────────────────────────

  describe "dumbbell_chart/1" do
    test "renders connecting bars and dots" do
      html = render_component(&H.render_dumbbell/1, %{data: @dumbbell_data})
      assert html =~ "<svg"
      assert html =~ "<line"
      assert html =~ "<circle"
    end

    test "renders with title" do
      html = render_component(&H.render_dumbbell_opts/1, %{data: @dumbbell_data, title: "Compare"})
      assert html =~ "Compare"
    end

    test "handles empty data" do
      html = render_component(&H.render_dumbbell_empty/1, %{})
      assert html =~ "<svg"
    end

    test "renders row labels" do
      html = render_component(&H.render_dumbbell/1, %{data: @dumbbell_data})
      assert html =~ "2023"
      assert html =~ "2024"
    end
  end

  # ── Waffle Chart ────────────────────────────────────────────────────────

  describe "waffle_chart/1" do
    test "renders grid of rects" do
      html = render_component(&H.render_waffle/1, %{data: @simple_data})
      assert html =~ "<svg"
      assert html =~ "<rect"
    end

    test "renders with title" do
      html = render_component(&H.render_waffle_opts/1, %{data: @simple_data, title: "Waffle"})
      assert html =~ "Waffle"
    end

    test "renders legend labels" do
      html = render_component(&H.render_waffle/1, %{data: @simple_data})
      assert html =~ "A"
      assert html =~ "B"
    end
  end

  # ── Stream Chart ────────────────────────────────────────────────────────

  describe "stream_chart/1" do
    test "renders flowing areas" do
      html = render_component(&H.render_stream/1, %{series: @multi_series})
      assert html =~ "<svg"
      assert html =~ "<path"
    end

    test "renders with title" do
      html = render_component(&H.render_stream_opts/1, %{series: @multi_series, title: "Stream"})
      assert html =~ "Stream"
    end

    test "renders series with viewBox" do
      html = render_component(&H.render_stream/1, %{series: @multi_series})
      assert html =~ "viewBox="
    end
  end

  # ── Ridgeline Chart ────────────────────────────────────────────────────

  describe "ridgeline_chart/1" do
    test "renders density distributions" do
      html = render_component(&H.render_ridgeline/1, %{data: @violin_data})
      assert html =~ "<svg"
      assert html =~ "<path"
    end

    test "renders with title" do
      html = render_component(&H.render_ridgeline_opts/1, %{data: @violin_data, title: "Ridge"})
      assert html =~ "Ridge"
    end

    test "handles empty data" do
      html = render_component(&H.render_ridgeline_empty/1, %{})
      assert html =~ "<svg"
    end

    test "renders row labels" do
      html = render_component(&H.render_ridgeline/1, %{data: @violin_data})
      assert html =~ "Treatment"
      assert html =~ "Control"
    end
  end

  # ── Icicle Chart ────────────────────────────────────────────────────────

  describe "icicle_chart/1" do
    test "renders hierarchical rects" do
      html = render_component(&H.render_icicle/1, %{data: @hierarchy_data})
      assert html =~ "<svg"
      assert html =~ "<rect"
    end

    test "renders with title" do
      html = render_component(&H.render_icicle_opts/1, %{data: @hierarchy_data, title: "Icicle"})
      assert html =~ "Icicle"
    end

    test "handles empty data" do
      html = render_component(&H.render_icicle_empty/1, %{})
      assert html =~ "<svg"
    end
  end

  # ── Circle Packing ─────────────────────────────────────────────────────

  describe "circle_packing_chart/1" do
    test "renders packed circles" do
      html = render_component(&H.render_circle_packing/1, %{data: @simple_data})
      assert html =~ "<svg"
      assert html =~ "<circle"
    end

    test "renders with title" do
      html = render_component(&H.render_circle_packing_opts/1, %{data: @simple_data, title: "Packing"})
      assert html =~ "Packing"
    end

    test "handles empty data" do
      html = render_component(&H.render_circle_packing_empty/1, %{})
      assert html =~ "<svg"
    end
  end

  # ── Chord Chart ─────────────────────────────────────────────────────────

  describe "chord_chart/1" do
    test "renders arcs and ribbons" do
      html = render_component(&H.render_chord/1, %{matrix: @chord_matrix, labels: @chord_labels})
      assert html =~ "<svg"
      assert html =~ "<path"
    end

    test "renders with title" do
      html = render_component(&H.render_chord_opts/1, %{matrix: @chord_matrix, labels: @chord_labels, title: "Chord"})
      assert html =~ "Chord"
    end

    test "renders label text" do
      html = render_component(&H.render_chord/1, %{matrix: @chord_matrix, labels: @chord_labels})
      assert html =~ "X"
      assert html =~ "Y"
      assert html =~ "Z"
    end

    test "handles empty matrix" do
      html = render_component(&H.render_chord_empty/1, %{})
      assert html =~ "<svg"
    end
  end

  # ── Dot Plot ────────────────────────────────────────────────────────────

  describe "dot_plot/1" do
    test "renders dots" do
      html = render_component(&H.render_dot_plot/1, %{data: @simple_data})
      assert html =~ "<svg"
      assert html =~ "<circle"
    end

    test "renders with title" do
      html = render_component(&H.render_dot_plot_opts/1, %{data: @simple_data, title: "Dots"})
      assert html =~ "Dots"
    end

    test "handles empty data" do
      html = render_component(&H.render_dot_plot_empty/1, %{})
      assert html =~ "<svg"
    end
  end

  # ── Arc Diagram ─────────────────────────────────────────────────────────

  describe "arc_diagram/1" do
    test "renders nodes and arcs" do
      html = render_component(&H.render_arc_diagram/1, %{nodes: @arc_nodes, links: @arc_links})
      assert html =~ "<svg"
      assert html =~ "<circle"
      assert html =~ "<path"
    end

    test "renders with title" do
      html = render_component(&H.render_arc_diagram_opts/1, %{nodes: @arc_nodes, links: @arc_links, title: "Arcs"})
      assert html =~ "Arcs"
    end

    test "renders node labels" do
      html = render_component(&H.render_arc_diagram/1, %{nodes: @arc_nodes, links: @arc_links})
      assert html =~ "A"
      assert html =~ "B"
      assert html =~ "C"
      assert html =~ "D"
    end

    test "handles empty data" do
      html = render_component(&H.render_arc_diagram_empty/1, %{})
      assert html =~ "<svg"
    end
  end

  # ── Pictogram Chart ────────────────────────────────────────────────────

  describe "pictogram_chart/1" do
    test "renders grid of symbols" do
      html = render_component(&H.render_pictogram/1, %{data: @simple_data})
      assert html =~ "<svg"
    end

    test "renders with title" do
      html = render_component(&H.render_pictogram_opts/1, %{data: @simple_data, title: "Pictogram"})
      assert html =~ "Pictogram"
    end

    test "handles empty data" do
      html = render_component(&H.render_pictogram_empty/1, %{})
      assert html =~ "<svg"
    end

    test "renders legend" do
      html = render_component(&H.render_pictogram/1, %{data: @simple_data})
      assert html =~ "A"
      assert html =~ "B"
    end
  end

  # ── Parliament Chart ───────────────────────────────────────────────────

  describe "parliament_chart/1" do
    test "renders semicircle of dots" do
      html = render_component(&H.render_parliament/1, %{data: @parliament_data})
      assert html =~ "<svg"
      assert html =~ "<circle"
    end

    test "renders with title and legend" do
      html = render_component(&H.render_parliament_opts/1, %{data: @parliament_data, title: "Parliament"})
      assert html =~ "Parliament"
    end

    test "renders party labels" do
      html = render_component(&H.render_parliament/1, %{data: @parliament_data})
      assert html =~ "Party A"
      assert html =~ "Party B"
      assert html =~ "Party C"
    end

    test "handles empty data" do
      html = render_component(&H.render_parliament_empty/1, %{})
      assert html =~ "<svg"
    end
  end

  # ── Word Cloud ──────────────────────────────────────────────────────────

  describe "word_cloud_chart/1" do
    test "renders text elements" do
      html = render_component(&H.render_word_cloud/1, %{data: @word_data})
      assert html =~ "<svg"
      assert html =~ "<text"
      assert html =~ "Elixir"
    end

    test "renders all words" do
      html = render_component(&H.render_word_cloud/1, %{data: @word_data})
      assert html =~ "Phoenix"
      assert html =~ "LiveView"
      assert html =~ "OTP"
    end

    test "renders with title" do
      html = render_component(&H.render_word_cloud_opts/1, %{data: @word_data, title: "Words"})
      assert html =~ "Words"
    end

    test "handles empty data" do
      html = render_component(&H.render_word_cloud_empty/1, %{})
      assert html =~ "<svg"
    end
  end
end
