defmodule PhiaUi.Editor.OtEngine do
  @moduledoc """
  Pure Elixir Operational Transform (OT) engine for collaborative text editing.

  Implements the core OT algorithms for plain-text documents using a delta-based
  format compatible with Quill Delta / ShareDB. Each delta is a list of operations
  that describe a document transformation:

    - `%{retain: n}` — skip forward `n` characters (keep them unchanged)
    - `%{insert: text}` — insert `text` at the current position
    - `%{delete: n}` — delete `n` characters at the current position

  ## Core Functions

    - `apply/2` — apply a delta to a document string
    - `transform/3` — transform concurrent deltas (OT core)
    - `compose/2` — merge two sequential deltas into one
    - `invert/2` — produce an undo delta from the original document

  ## Example

      iex> doc = "Hello World"
      iex> delta = [%{retain: 5}, %{insert: ","}, %{retain: 6}]
      iex> {:ok, result} = PhiaUi.Editor.OtEngine.apply(doc, delta)
      iex> result
      "Hello, World"

  ## Transform Example

      iex> # User A inserts "X" at position 0, User B inserts "Y" at position 0
      iex> op_a = [%{insert: "X"}]
      iex> op_b = [%{insert: "Y"}]
      iex> {:ok, b_prime} = PhiaUi.Editor.OtEngine.transform(op_a, op_b, :left)
      iex> b_prime
      [%{retain: 1}, %{insert: "Y"}]
  """

  # ==========================================================================
  # Constructors
  # ==========================================================================

  @doc "Create a retain operation."
  @spec retain(pos_integer()) :: %{retain: pos_integer()}
  def retain(n) when is_integer(n) and n > 0, do: %{retain: n}

  @doc "Create an insert operation."
  @spec insert(String.t()) :: %{insert: String.t()}
  def insert(text) when is_binary(text) and byte_size(text) > 0, do: %{insert: text}

  @doc "Create a delete operation."
  @spec delete(pos_integer()) :: %{delete: pos_integer()}
  def delete(n) when is_integer(n) and n > 0, do: %{delete: n}

  # ==========================================================================
  # Length
  # ==========================================================================

  @doc """
  Compute the input length a delta operates on (sum of retain + delete).

  Insert operations do not consume input characters, so they are excluded.

  ## Example

      iex> PhiaUi.Editor.OtEngine.length([%{retain: 5}, %{insert: "hi"}, %{delete: 3}])
      8
  """
  @spec length(list()) :: non_neg_integer()
  def length(delta) when is_list(delta) do
    Enum.reduce(delta, 0, fn
      %{retain: n}, acc -> acc + n
      %{delete: n}, acc -> acc + n
      %{insert: _}, acc -> acc
    end)
  end

  # ==========================================================================
  # Apply
  # ==========================================================================

  @doc """
  Apply a delta to a document string, producing the transformed document.

  Returns `{:ok, new_string}` on success, or `{:error, reason}` if the delta
  does not match the document length.

  ## Example

      iex> PhiaUi.Editor.OtEngine.apply("abcdef", [%{retain: 3}, %{delete: 2}, %{insert: "XY"}, %{retain: 1}])
      {:ok, "abcXYf"}
  """
  @spec apply(String.t(), list()) :: {:ok, String.t()} | {:error, String.t()}
  def apply(doc, delta) when is_binary(doc) and is_list(delta) do
    case apply_ops(delta, doc, []) do
      {:ok, parts} -> {:ok, IO.iodata_to_binary(parts)}
      {:error, _} = err -> err
    end
  end

  defp apply_ops([], remaining, acc) do
    # Any remaining document chars are implicitly retained
    {:ok, Enum.reverse([remaining | acc])}
  end

  defp apply_ops([%{retain: n} | rest], doc, acc) do
    doc_len = String.length(doc)

    if n > doc_len do
      {:error, "retain #{n} exceeds remaining document length #{doc_len}"}
    else
      {kept, remaining} = String.split_at(doc, n)
      apply_ops(rest, remaining, [kept | acc])
    end
  end

  defp apply_ops([%{insert: text} | rest], doc, acc) do
    apply_ops(rest, doc, [text | acc])
  end

  defp apply_ops([%{delete: n} | rest], doc, acc) do
    doc_len = String.length(doc)

    if n > doc_len do
      {:error, "delete #{n} exceeds remaining document length #{doc_len}"}
    else
      {_deleted, remaining} = String.split_at(doc, n)
      apply_ops(rest, remaining, acc)
    end
  end

  defp apply_ops([op | _rest], _doc, _acc) do
    {:error, "unknown operation: #{inspect(op)}"}
  end

  # ==========================================================================
  # Transform
  # ==========================================================================

  @doc """
  Transform delta B against delta A so that B can be applied after A.

  Given two concurrent operations A and B (both based on the same document),
  `transform(A, B, priority)` produces B' such that:

      apply(apply(doc, A), B') == apply(apply(doc, B), A')

  The `priority` parameter (`:left` or `:right`) resolves ties when both
  operations insert at the same position:
    - `:left` — A's insert goes first (B' gets a retain to skip over A's insert)
    - `:right` — B's insert goes first

  Returns `{:ok, transformed_b}`.

  ## Example

      iex> op_a = [%{retain: 3}, %{insert: "X"}]
      iex> op_b = [%{retain: 3}, %{insert: "Y"}]
      iex> {:ok, b_prime} = PhiaUi.Editor.OtEngine.transform(op_a, op_b, :left)
      iex> b_prime
      [%{retain: 4}, %{insert: "Y"}]
  """
  @spec transform(list(), list(), :left | :right) :: {:ok, list()}
  def transform(op_a, op_b, priority) when is_list(op_a) and is_list(op_b) and priority in [:left, :right] do
    result = transform_walk(op_a, op_b, priority, [])
    {:ok, compact(result)}
  end

  # Both exhausted
  defp transform_walk([], [], _priority, acc), do: Enum.reverse(acc)

  # A exhausted, remaining B ops pass through
  defp transform_walk([], [%{insert: _} = op | rest_b], priority, acc) do
    transform_walk([], rest_b, priority, [op | acc])
  end

  defp transform_walk([], [%{retain: _} = op | rest_b], priority, acc) do
    transform_walk([], rest_b, priority, [op | acc])
  end

  defp transform_walk([], [%{delete: _} = op | rest_b], priority, acc) do
    transform_walk([], rest_b, priority, [op | acc])
  end

  # B exhausted, remaining A ops: inserts in A add retains in B'
  defp transform_walk([%{insert: text} | rest_a], [], priority, acc) do
    transform_walk(rest_a, [], priority, [%{retain: String.length(text)} | acc])
  end

  defp transform_walk([%{retain: _} | rest_a], [], priority, acc) do
    transform_walk(rest_a, [], priority, acc)
  end

  defp transform_walk([%{delete: _} | rest_a], [], priority, acc) do
    transform_walk(rest_a, [], priority, acc)
  end

  # Both insert: priority decides who goes first
  defp transform_walk([%{insert: text_a} | rest_a], [%{insert: _} | _] = ops_b, :left, acc) do
    # A goes first: B' retains over A's insert
    transform_walk(rest_a, ops_b, :left, [%{retain: String.length(text_a)} | acc])
  end

  defp transform_walk([%{insert: _} | _] = ops_a, [%{insert: _} = op_b | rest_b], :right, acc) do
    # B goes first: B' keeps its insert
    transform_walk(ops_a, rest_b, :right, [op_b | acc])
  end

  # A inserts, B does something else: B' retains over A's insert
  defp transform_walk([%{insert: text_a} | rest_a], ops_b, priority, acc) do
    transform_walk(rest_a, ops_b, priority, [%{retain: String.length(text_a)} | acc])
  end

  # B inserts, A does something else: B' keeps its insert
  defp transform_walk(ops_a, [%{insert: _} = op_b | rest_b], priority, acc) do
    transform_walk(ops_a, rest_b, priority, [op_b | acc])
  end

  # Both retain
  defp transform_walk([%{retain: n_a} | rest_a], [%{retain: n_b} | rest_b], priority, acc) do
    min = min(n_a, n_b)

    new_a = if n_a > min, do: [%{retain: n_a - min} | rest_a], else: rest_a
    new_b = if n_b > min, do: [%{retain: n_b - min} | rest_b], else: rest_b

    transform_walk(new_a, new_b, priority, [%{retain: min} | acc])
  end

  # A deletes, B retains
  defp transform_walk([%{delete: n_a} | rest_a], [%{retain: n_b} | rest_b], priority, acc) do
    min = min(n_a, n_b)

    new_a = if n_a > min, do: [%{delete: n_a - min} | rest_a], else: rest_a
    new_b = if n_b > min, do: [%{retain: n_b - min} | rest_b], else: rest_b

    # A already deleted this range, so B' skips it (no retain needed)
    transform_walk(new_a, new_b, priority, acc)
  end

  # A retains, B deletes
  defp transform_walk([%{retain: n_a} | rest_a], [%{delete: n_b} | rest_b], priority, acc) do
    min = min(n_a, n_b)

    new_a = if n_a > min, do: [%{retain: n_a - min} | rest_a], else: rest_a
    new_b = if n_b > min, do: [%{delete: n_b - min} | rest_b], else: rest_b

    transform_walk(new_a, new_b, priority, [%{delete: min} | acc])
  end

  # Both delete the same range
  defp transform_walk([%{delete: n_a} | rest_a], [%{delete: n_b} | rest_b], priority, acc) do
    min = min(n_a, n_b)

    new_a = if n_a > min, do: [%{delete: n_a - min} | rest_a], else: rest_a
    new_b = if n_b > min, do: [%{delete: n_b - min} | rest_b], else: rest_b

    # Both deleted the same text, so B' does nothing for this range
    transform_walk(new_a, new_b, priority, acc)
  end

  # ==========================================================================
  # Compose
  # ==========================================================================

  @doc """
  Compose two sequential deltas into a single equivalent delta.

  If delta A transforms document D into D', and delta B transforms D' into D'',
  then `compose(A, B)` produces a delta C that transforms D directly into D''.

  Returns `{:ok, composed}`.

  ## Example

      iex> a = [%{insert: "abc"}]
      iex> b = [%{retain: 1}, %{delete: 1}, %{retain: 1}]
      iex> {:ok, composed} = PhiaUi.Editor.OtEngine.compose(a, b)
      iex> composed
      [%{insert: "ac"}]
  """
  @spec compose(list(), list()) :: {:ok, list()}
  def compose(delta_a, delta_b) when is_list(delta_a) and is_list(delta_b) do
    result = compose_walk(delta_a, delta_b, [])
    {:ok, compact(result)}
  end

  # Both exhausted
  defp compose_walk([], [], acc), do: Enum.reverse(acc)

  # A exhausted, remaining B ops pass through
  defp compose_walk([], [op | rest_b], acc) do
    compose_walk([], rest_b, [op | acc])
  end

  # B exhausted, remaining A ops pass through
  defp compose_walk([op | rest_a], [], acc) do
    compose_walk(rest_a, [], [op | acc])
  end

  # A inserts, B deletes: cancel out
  defp compose_walk([%{insert: text_a} | rest_a], [%{delete: n_b} | rest_b], acc) do
    len_a = String.length(text_a)

    cond do
      len_a > n_b ->
        # A's insert is longer; keep the remaining insert
        {_deleted, kept} = String.split_at(text_a, n_b)
        compose_walk([%{insert: kept} | rest_a], rest_b, acc)

      len_a < n_b ->
        # B deletes more than A inserted; delete the excess from original doc
        compose_walk(rest_a, [%{delete: n_b - len_a} | rest_b], acc)

      true ->
        # Exact cancel
        compose_walk(rest_a, rest_b, acc)
    end
  end

  # A inserts, B retains: emit (partial) insert
  defp compose_walk([%{insert: text_a} | rest_a], [%{retain: n_b} | rest_b], acc) do
    len_a = String.length(text_a)

    cond do
      len_a > n_b ->
        {kept, remaining} = String.split_at(text_a, n_b)
        compose_walk([%{insert: remaining} | rest_a], rest_b, [%{insert: kept} | acc])

      len_a < n_b ->
        compose_walk(rest_a, [%{retain: n_b - len_a} | rest_b], [%{insert: text_a} | acc])

      true ->
        compose_walk(rest_a, rest_b, [%{insert: text_a} | acc])
    end
  end

  # B inserts: always emit directly (independent of A)
  defp compose_walk(ops_a, [%{insert: _} = op_b | rest_b], acc) do
    compose_walk(ops_a, rest_b, [op_b | acc])
  end

  # A retains, B retains: emit retain of min
  defp compose_walk([%{retain: n_a} | rest_a], [%{retain: n_b} | rest_b], acc) do
    min = min(n_a, n_b)

    new_a = if n_a > min, do: [%{retain: n_a - min} | rest_a], else: rest_a
    new_b = if n_b > min, do: [%{retain: n_b - min} | rest_b], else: rest_b

    compose_walk(new_a, new_b, [%{retain: min} | acc])
  end

  # A retains, B deletes: emit delete of min
  defp compose_walk([%{retain: n_a} | rest_a], [%{delete: n_b} | rest_b], acc) do
    min = min(n_a, n_b)

    new_a = if n_a > min, do: [%{retain: n_a - min} | rest_a], else: rest_a
    new_b = if n_b > min, do: [%{delete: n_b - min} | rest_b], else: rest_b

    compose_walk(new_a, new_b, [%{delete: min} | acc])
  end

  # A deletes, B anything that consumes A's output: A's delete passes through
  defp compose_walk([%{delete: n_a} | rest_a], ops_b, acc) do
    compose_walk(rest_a, ops_b, [%{delete: n_a} | acc])
  end

  # ==========================================================================
  # Invert
  # ==========================================================================

  @doc """
  Produce an inverted delta that undoes the given delta when applied to the
  document that results from applying the original delta.

  Given `{:ok, new_doc} = apply(doc, delta)`, then
  `{:ok, inverted} = invert(delta, doc)` satisfies
  `apply(new_doc, inverted) == {:ok, doc}`.

  Returns `{:ok, inverted_delta}`.

  ## Example

      iex> doc = "Hello"
      iex> delta = [%{delete: 5}, %{insert: "Bye"}]
      iex> {:ok, inverted} = PhiaUi.Editor.OtEngine.invert(delta, doc)
      iex> inverted
      [%{delete: 3}, %{insert: "Hello"}]
  """
  @spec invert(list(), String.t()) :: {:ok, list()}
  def invert(delta, doc) when is_list(delta) and is_binary(doc) do
    result = invert_walk(delta, doc, [])
    {:ok, compact(result)}
  end

  defp invert_walk([], _doc, acc), do: Enum.reverse(acc)

  defp invert_walk([%{retain: n} | rest], doc, acc) do
    {_skipped, remaining} = String.split_at(doc, n)
    invert_walk(rest, remaining, [%{retain: n} | acc])
  end

  defp invert_walk([%{insert: text} | rest], doc, acc) do
    # To undo an insert, delete the same number of characters
    invert_walk(rest, doc, [%{delete: String.length(text)} | acc])
  end

  defp invert_walk([%{delete: n} | rest], doc, acc) do
    # To undo a delete, re-insert the deleted text
    {deleted_text, remaining} = String.split_at(doc, n)
    invert_walk(rest, remaining, [%{insert: deleted_text} | acc])
  end

  # ==========================================================================
  # Compact (normalize/trim trailing retains/merge adjacent same-type ops)
  # ==========================================================================

  @doc false
  @spec compact(list()) :: list()
  def compact(ops) when is_list(ops) do
    ops
    |> Enum.reduce([], fn op, acc -> merge_op(op, acc) end)
    |> Enum.reverse()
    |> trim_trailing_retains()
  end

  # Merge adjacent retain ops
  defp merge_op(%{retain: n}, [%{retain: m} | rest]), do: [%{retain: m + n} | rest]
  # Merge adjacent delete ops
  defp merge_op(%{delete: n}, [%{delete: m} | rest]), do: [%{delete: m + n} | rest]
  # Merge adjacent insert ops
  defp merge_op(%{insert: t}, [%{insert: s} | rest]), do: [%{insert: s <> t} | rest]
  # Skip zero-length ops
  defp merge_op(%{retain: 0}, acc), do: acc
  defp merge_op(%{delete: 0}, acc), do: acc
  defp merge_op(%{insert: ""}, acc), do: acc
  # Default: push
  defp merge_op(op, acc), do: [op | acc]

  # Remove trailing retain ops (they are implicit)
  defp trim_trailing_retains(ops) do
    ops
    |> Enum.reverse()
    |> Enum.drop_while(fn
      %{retain: _} -> true
      _ -> false
    end)
    |> Enum.reverse()
  end
end
