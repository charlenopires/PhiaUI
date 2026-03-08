defmodule PhiaUi.Components.Data.ChartValueFormatterTest do
  use ExUnit.Case, async: true

  alias PhiaUi.Components.Data.ChartValueFormatter

  describe "default_formatter/0" do
    test "converts number to string" do
      f = ChartValueFormatter.default_formatter()
      assert f.(1234) == "1234"
      assert f.(0) == "0"
    end
  end

  describe "currency_formatter/1" do
    test "formats with dollar sign and commas" do
      f = ChartValueFormatter.currency_formatter()
      assert f.(1234567) == "$ 1,234,567"
    end

    test "formats with custom symbol" do
      f = ChartValueFormatter.currency_formatter("EUR")
      result = f.(1000)
      assert result =~ "EUR"
      assert result =~ "1,000"
    end
  end

  describe "percent_formatter/1" do
    test "formats as percentage" do
      f = ChartValueFormatter.percent_formatter()
      result = f.(0.756)
      assert result =~ "75.6"
      assert result =~ "%"
    end
  end

  describe "compact_formatter/0" do
    test "formats thousands as K" do
      f = ChartValueFormatter.compact_formatter()
      assert f.(1500) =~ "1.5K"
    end

    test "formats millions as M" do
      f = ChartValueFormatter.compact_formatter()
      assert f.(1_500_000) =~ "1.5M"
    end

    test "formats billions as B" do
      f = ChartValueFormatter.compact_formatter()
      assert f.(2_000_000_000) =~ "2.0B"
    end

    test "handles negative values" do
      f = ChartValueFormatter.compact_formatter()
      result = f.(-1500)
      assert result =~ "-"
      assert result =~ "1.5K"
    end
  end

  describe "format/2" do
    test "handles nil value" do
      assert ChartValueFormatter.format(nil, ChartValueFormatter.default_formatter()) == ""
    end

    test "handles nil formatter" do
      assert ChartValueFormatter.format(42, nil) == "42"
    end

    test "applies formatter to value" do
      f = ChartValueFormatter.currency_formatter()
      result = ChartValueFormatter.format(1234, f)
      assert result =~ "1,234"
    end
  end

  describe "for_type/1" do
    test "returns default formatter" do
      f = ChartValueFormatter.for_type(:default)
      assert is_function(f, 1)
      assert f.(42) == "42"
    end

    test "returns compact formatter" do
      f = ChartValueFormatter.for_type(:compact)
      assert is_function(f, 1)
      assert f.(1500) =~ "K"
    end

    test "returns default for unknown type" do
      f = ChartValueFormatter.for_type(:unknown)
      assert is_function(f, 1)
    end
  end
end
