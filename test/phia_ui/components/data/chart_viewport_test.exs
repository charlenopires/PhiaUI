defmodule PhiaUi.Components.Data.ChartViewportTest do
  use ExUnit.Case, async: true

  alias PhiaUi.Components.Data.ChartViewport

  describe "default_xy/0" do
    test "returns standard viewport dimensions" do
      vp = ChartViewport.default_xy()
      assert vp.vw == 400
      assert vp.vh == 300
      assert vp.pl == 44
      assert vp.pr == 16
      assert vp.pt == 16
      assert vp.pb == 40
      assert vp.cw == 340
      assert vp.ch == 244
    end

    test "cw equals vw - pl - pr" do
      vp = ChartViewport.default_xy()
      assert vp.cw == vp.vw - vp.pl - vp.pr
    end

    test "ch equals vh - pt - pb" do
      vp = ChartViewport.default_xy()
      assert vp.ch == vp.vh - vp.pt - vp.pb
    end
  end

  describe "default_polar/1" do
    test "returns standard polar dimensions" do
      vp = ChartViewport.default_polar()
      assert vp.vw == 300
      assert vp.vh == 220
      assert vp.cx == 110
      assert vp.cy == 110
      assert vp.r == 90
    end

    test "accepts overrides" do
      vp = ChartViewport.default_polar(vw: 400, r: 100)
      assert vp.vw == 400
      assert vp.r == 100
      assert vp.vh == 220
    end
  end

  describe "build/1" do
    test "returns default viewport with no overrides" do
      vp = ChartViewport.build()
      assert vp == ChartViewport.default_xy()
    end

    test "returns default viewport with empty list" do
      vp = ChartViewport.build([])
      assert vp == ChartViewport.default_xy()
    end

    test "overrides individual dimensions" do
      vp = ChartViewport.build(vw: 500, pl: 50)
      assert vp.vw == 500
      assert vp.pl == 50
      assert vp.vh == 300
    end

    test "recomputes cw when vw or pl or pr changes" do
      vp = ChartViewport.build(vw: 500, pl: 50, pr: 20)
      assert vp.cw == 500 - 50 - 20
    end

    test "recomputes ch when vh or pt or pb changes" do
      vp = ChartViewport.build(vh: 400, pt: 20, pb: 50)
      assert vp.ch == 400 - 20 - 50
    end

    test "preserves other defaults when overriding one field" do
      vp = ChartViewport.build(vw: 420)
      assert vp.vh == 300
      assert vp.pl == 44
      assert vp.pr == 16
      assert vp.pt == 16
      assert vp.pb == 40
    end
  end

  describe "viewbox/1" do
    test "formats viewBox string from viewport" do
      vp = ChartViewport.default_xy()
      assert ChartViewport.viewbox(vp) == "0 0 400 300"
    end

    test "uses custom dimensions" do
      vp = ChartViewport.build(vw: 500, vh: 400)
      assert ChartViewport.viewbox(vp) == "0 0 500 400"
    end
  end
end
