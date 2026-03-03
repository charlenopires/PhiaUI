defmodule PhiaUi.ClassMerger.PropertyTest do
  use ExUnit.Case, async: true
  use ExUnitProperties

  alias PhiaUi.ClassMerger

  # ---------------------------------------------------------------------------
  # Generators
  # ---------------------------------------------------------------------------

  # Simple alphanumeric tokens — Groups.group_for/1 returns nil for these,
  # so they dedup by exact-match only, making membership assertions safe.
  defp simple_token do
    gen all prefix <- string(:alphanumeric, min_length: 2, max_length: 4),
            suffix <- string(:alphanumeric, min_length: 1, max_length: 4) do
      "#{prefix}-#{suffix}"
    end
  end

  # A single class list entry: a token string, nil, or false
  defp class_entry do
    one_of([simple_token(), constant(nil), constant(false)])
  end

  defp class_list do
    list_of(class_entry(), min_length: 0, max_length: 10)
  end

  # ---------------------------------------------------------------------------
  # Properties
  # ---------------------------------------------------------------------------

  property "output has no leading or trailing whitespace" do
    check all classes <- class_list() do
      result = ClassMerger.cn(classes)
      assert result == String.trim(result)
    end
  end

  property "output has no consecutive whitespace" do
    check all classes <- class_list() do
      result = ClassMerger.cn(classes)
      refute result =~ ~r/\s{2,}/
    end
  end

  property "nil and false entries do not affect the result" do
    check all classes <- class_list() do
      base = ClassMerger.cn(classes)
      assert ClassMerger.cn([nil | classes]) == base
      assert ClassMerger.cn([false | classes]) == base
      assert ClassMerger.cn(classes ++ [nil]) == base
      assert ClassMerger.cn(classes ++ [false]) == base
    end
  end

  property "cn is idempotent: cn([cn(classes)]) == cn(classes)" do
    check all classes <- class_list() do
      result = ClassMerger.cn(classes)
      assert ClassMerger.cn([result]) == result
    end
  end

  property "all unique tokens from the input appear in the result" do
    check all tokens <- uniq_list_of(simple_token(), min_length: 1, max_length: 6) do
      result = ClassMerger.cn(tokens)

      Enum.each(tokens, fn token ->
        assert result =~ token,
               "Expected #{inspect(result)} to contain token #{inspect(token)}"
      end)
    end
  end

  property "output is a subset of input tokens (no tokens invented)" do
    check all classes <- class_list() do
      result = ClassMerger.cn(classes)

      input_tokens =
        classes
        |> Enum.reject(&(!&1))
        |> Enum.flat_map(&String.split(&1, ~r/\s+/, trim: true))
        |> MapSet.new()

      result_tokens =
        result
        |> String.split(~r/\s+/, trim: true)
        |> MapSet.new()

      assert MapSet.subset?(result_tokens, input_tokens),
             "Output #{inspect(result)} contains tokens not in input #{inspect(classes)}"
    end
  end
end
