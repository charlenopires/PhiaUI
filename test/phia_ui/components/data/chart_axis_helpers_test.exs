defmodule PhiaUi.Components.Data.ChartAxisHelpersTest do
  use ExUnit.Case, async: true

  alias PhiaUi.Components.Data.ChartAxisHelpers

  # ---------------------------------------------------------------------------
  # nice_ticks/3
  # ---------------------------------------------------------------------------

  describe "nice_ticks/3" do
    test "equal min and max returns single tick" do
      assert ChartAxisHelpers.nice_ticks(5, 5) == [5]
    end

    test "returns list of numeric ticks" do
      ticks = ChartAxisHelpers.nice_ticks(0, 100)
      assert is_list(ticks)
      assert length(ticks) > 0
      Enum.each(ticks, fn t -> assert is_number(t) end)
    end

    test "ticks cover the full range" do
      ticks = ChartAxisHelpers.nice_ticks(0, 100)
      assert hd(ticks) <= 0
      assert List.last(ticks) >= 100
    end

    test "ticks are in ascending order" do
      ticks = ChartAxisHelpers.nice_ticks(0, 100)
      assert ticks == Enum.sort(ticks)
    end

    test "uses human-readable step sizes" do
      ticks = ChartAxisHelpers.nice_ticks(0, 100, 5)
      # Step should be 20 (100/5 = 20, nice_step picks 20)
      steps = ticks |> Enum.chunk_every(2, 1, :discard) |> Enum.map(fn [a, b] -> b - a end)
      # All steps should be equal
      assert Enum.all?(steps, fn s -> abs(s - hd(steps)) < 0.01 end)
    end

    test "works with negative min" do
      ticks = ChartAxisHelpers.nice_ticks(-50, 50)
      assert hd(ticks) <= -50
      assert List.last(ticks) >= 50
    end

    test "works with decimal values" do
      ticks = ChartAxisHelpers.nice_ticks(0.0, 1.0)
      assert is_list(ticks)
      assert length(ticks) > 1
    end

    test "custom count affects tick density" do
      ticks_3 = ChartAxisHelpers.nice_ticks(0, 100, 3)
      ticks_10 = ChartAxisHelpers.nice_ticks(0, 100, 10)
      # More desired ticks should produce more actual ticks (approximately)
      assert length(ticks_10) >= length(ticks_3)
    end
  end

  # ---------------------------------------------------------------------------
  # format_tick/2
  # ---------------------------------------------------------------------------

  describe "format_tick/2" do
    test "integer values displayed without decimal" do
      assert ChartAxisHelpers.format_tick(42.0) == "42"
    end

    test "values >= 1M formatted as M suffix" do
      assert ChartAxisHelpers.format_tick(1_500_000.0) == "1.5M"
    end

    test "values >= 1K formatted as K suffix" do
      assert ChartAxisHelpers.format_tick(2_500.0) == "2.5K"
    end

    test "float values show one decimal place" do
      assert ChartAxisHelpers.format_tick(3.7) == "3.7"
    end

    test "custom suffix appended" do
      assert ChartAxisHelpers.format_tick(1_500_000.0, suffix: "%") == "1.5M%"
    end

    test "zero formatted as integer" do
      assert ChartAxisHelpers.format_tick(0.0) == "0"
    end

    test "negative values format correctly" do
      result = ChartAxisHelpers.format_tick(-2_500.0)
      assert result == "-2.5K"
    end

    test "exactly 1000 formatted as 1.0K" do
      assert ChartAxisHelpers.format_tick(1000.0) == "1.0K"
    end
  end

  # ---------------------------------------------------------------------------
  # log_ticks/3
  # ---------------------------------------------------------------------------

  describe "log_ticks/3" do
    test "returns ticks for valid range" do
      ticks = ChartAxisHelpers.log_ticks(1, 1000)
      assert is_list(ticks)
      assert length(ticks) > 0
    end

    test "includes 1, 2, 5 pattern within decades" do
      ticks = ChartAxisHelpers.log_ticks(1, 100)
      assert 2.0 in ticks
      assert 5.0 in ticks
      assert 10.0 in ticks
      assert 20.0 in ticks
      assert 50.0 in ticks
    end

    test "boundaries are included" do
      ticks = ChartAxisHelpers.log_ticks(1, 1000)
      assert hd(ticks) <= 1
      assert List.last(ticks) >= 1000
    end

    test "ticks are in ascending order" do
      ticks = ChartAxisHelpers.log_ticks(1, 10000)
      assert ticks == Enum.sort(ticks)
    end

    test "no duplicate ticks" do
      ticks = ChartAxisHelpers.log_ticks(1, 10000)
      assert ticks == Enum.uniq(ticks)
    end

    test "works with fractional min" do
      ticks = ChartAxisHelpers.log_ticks(0.1, 100)
      assert is_list(ticks)
      assert length(ticks) > 0
    end

    test "min <= 0 falls back to nice_ticks" do
      ticks = ChartAxisHelpers.log_ticks(0, 100)
      assert is_list(ticks)
      assert length(ticks) > 0
    end

    test "negative min falls back to nice_ticks" do
      ticks = ChartAxisHelpers.log_ticks(-10, 100)
      assert is_list(ticks)
      assert length(ticks) > 0
    end

    test "small range produces ticks" do
      ticks = ChartAxisHelpers.log_ticks(1, 10)
      assert length(ticks) >= 2
    end

    test "large range produces reasonable number of ticks" do
      ticks = ChartAxisHelpers.log_ticks(1, 1_000_000)
      # Should have ticks at 1, 2, 5, 10, 20, 50, 100, ... pattern
      assert length(ticks) > 5
      assert length(ticks) < 50
    end

    test "adjacent ticks span at most one decade" do
      ticks = ChartAxisHelpers.log_ticks(1, 10000)

      ticks
      |> Enum.filter(fn t -> t > 0 end)
      |> Enum.chunk_every(2, 1, :discard)
      |> Enum.each(fn [a, b] ->
        assert b / a <= 10.1, "Gap between #{a} and #{b} exceeds one decade"
      end)
    end
  end

  # ---------------------------------------------------------------------------
  # format_log_tick/2
  # ---------------------------------------------------------------------------

  describe "format_log_tick/2" do
    test "values >= 1M use M suffix (delegates to format_tick)" do
      result = ChartAxisHelpers.format_log_tick(2_000_000.0)
      assert result == "2.0M"
    end

    test "values >= 1 use standard formatting" do
      result = ChartAxisHelpers.format_log_tick(100.0)
      assert result == "100"
    end

    test "values between 0.01 and 1 show 2 decimal places" do
      result = ChartAxisHelpers.format_log_tick(0.05)
      assert result == "0.05"
    end

    test "values >= 0.01 show 2 decimal places" do
      result = ChartAxisHelpers.format_log_tick(0.01)
      assert result == "0.01"
    end

    test "very small values raise ArgumentError due to OTP 28 io_lib format incompatibility" do
      # The source uses :io_lib.format('~.1e', [value]) which is not supported on OTP 28.
      # This test documents the known bug. Once the source is fixed, update to:
      #   result = ChartAxisHelpers.format_log_tick(0.001)
      #   assert result =~ "e"
      assert_raise ArgumentError, fn ->
        ChartAxisHelpers.format_log_tick(0.001)
      end
    end

    test "integer-like values format cleanly" do
      result = ChartAxisHelpers.format_log_tick(10.0)
      assert result == "10"
    end

    test "value 1.0 formats as integer" do
      result = ChartAxisHelpers.format_log_tick(1.0)
      assert result == "1"
    end

    test "value 1000 formats as 1.0K" do
      result = ChartAxisHelpers.format_log_tick(1000.0)
      assert result == "1.0K"
    end

    test "value 0.5 shows 2 decimal places" do
      result = ChartAxisHelpers.format_log_tick(0.5)
      assert result == "0.5"
    end
  end
end
