defmodule PhiaUi.ClassMerger.Groups do
  @moduledoc """
  Maps Tailwind CSS utility class tokens to their conflict group.

  Two classes in the same group target the same CSS property and therefore
  conflict — only the last one should be kept by `cn/1`.

  Returns `nil` for classes that don't belong to any known group
  (arbitrary / custom classes), in which case exact-match deduplication
  applies instead.
  """

  # ── Compile-time constants ───────────────────────────────────────────────────

  @text_sizes ~w(xs sm base lg xl 2xl 3xl 4xl 5xl 6xl 7xl 8xl 9xl)
  @font_weights ~w(thin extralight light normal medium semibold bold extrabold black)
  @font_families ~w(sans serif mono)

  # Pre-compute sets for O(1) exact membership tests
  @text_size_classes MapSet.new(Enum.map(@text_sizes, &"text-#{&1}"))
  @font_weight_classes MapSet.new(Enum.map(@font_weights, &"font-#{&1}"))
  @font_family_classes MapSet.new(Enum.map(@font_families, &"font-#{&1}"))

  @display_classes ~w(
    block inline inline-block flex inline-flex
    grid inline-grid table inline-table hidden
    table-row table-cell table-column
    table-caption table-row-group table-header-group
    table-footer-group table-column-group
    flow-root contents list-item
  )

  @position_classes ~w(static relative absolute fixed sticky)

  @border_width_classes ~w(border border-0 border-2 border-4 border-8)

  # Text-align classes — must be exact-matched before the text-* catch-all in special_group/1
  @text_align_classes ~w(text-left text-center text-right text-justify text-start text-end)

  # Compile-time exact-match map: class → group
  @exact_group_map Map.merge(
                     Map.merge(
                       Map.merge(
                         Map.from_keys(@display_classes, :display),
                         Map.from_keys(@position_classes, :position)
                       ),
                       Map.from_keys(@border_width_classes, :border_w)
                     ),
                     Map.from_keys(@text_align_classes, :text_align)
                   )

  # Prefix rules ordered longest-first to avoid false matches
  # (e.g., "px-" must be checked before "p-")
  @prefix_rules [
    {"gap-x-", :gap_x},
    {"gap-y-", :gap_y},
    {"gap-", :gap},
    {"min-w-", :min_w},
    {"max-w-", :max_w},
    {"min-h-", :min_h},
    {"max-h-", :max_h},
    {"size-", :size},
    {"bg-", :bg},
    {"px-", :px},
    {"py-", :py},
    {"pt-", :pt},
    {"pr-", :pr},
    {"pb-", :pb},
    {"pl-", :pl},
    {"ps-", :ps},
    {"pe-", :pe},
    {"p-", :p},
    {"mx-", :mx},
    {"my-", :my},
    {"mt-", :mt},
    {"mr-", :mr},
    {"mb-", :mb},
    {"ml-", :ml},
    {"ms-", :ms},
    {"me-", :me},
    {"m-", :m},
    {"w-", :w},
    {"h-", :h},
    {"z-", :z},
    {"opacity-", :opacity},
    {"overflow-", :overflow},
    {"cursor-", :cursor},
    {"leading-", :leading},
    {"tracking-", :tracking},
    {"decoration-", :decoration},
    {"shadow-", :shadow},
    {"rounded-", :rounded}
  ]

  # ── Public API ───────────────────────────────────────────────────────────────

  @doc """
  Returns the conflict group atom for `class`, or `nil` if unknown.

  ## Examples

      iex> PhiaUi.ClassMerger.Groups.group_for("bg-primary")
      :bg

      iex> PhiaUi.ClassMerger.Groups.group_for("text-sm")
      :text_size

      iex> PhiaUi.ClassMerger.Groups.group_for("text-red-500")
      :text_color

      iex> PhiaUi.ClassMerger.Groups.group_for("phia-custom")
      nil
  """
  @spec group_for(String.t()) :: atom() | nil
  def group_for(class) when is_binary(class) do
    exact_group(class) || special_group(class) || prefix_group(class) || standalone_group(class)
  end

  # ── Private helpers ──────────────────────────────────────────────────────────

  # O(1) map lookup for display, position, and border-width classes
  defp exact_group(class), do: Map.get(@exact_group_map, class)

  # Handles text-{size} vs text-{color} and font-{weight} vs font-{family}
  defp special_group(class) do
    cond do
      class in @text_size_classes -> :text_size
      String.starts_with?(class, "text-") -> :text_color
      class in @font_weight_classes -> :font_weight
      class in @font_family_classes -> :font_family
      true -> nil
    end
  end

  # Iterates the prefix table (longest-first) to find a match
  defp prefix_group(class) do
    Enum.find_value(@prefix_rules, fn {prefix, group} ->
      if String.starts_with?(class, prefix), do: group
    end)
  end

  # Standalone classes not covered above
  defp standalone_group(class) do
    flex_direction_group(class) || flex_wrap_group(class)
  end

  defp flex_direction_group(class) do
    if class in ~w(flex-row flex-col flex-row-reverse flex-col-reverse),
      do: :flex_direction
  end

  defp flex_wrap_group(class) do
    if class in ~w(flex-wrap flex-nowrap flex-wrap-reverse),
      do: :flex_wrap
  end
end
