defmodule PhiaUi.ClassMerger.Groups do
  @moduledoc """
  Maps Tailwind CSS utility class tokens to their conflict group.

  ## The Conflict Group Concept

  Two Tailwind classes "conflict" when they both set the same CSS property.
  For example, `px-2` and `px-4` both set `padding-inline-start` and
  `padding-inline-end`. Applying both classes to an element results in only
  one value being active (whichever appears last in the stylesheet), which
  makes the earlier class redundant and confusing.

  `cn/1` uses this module to detect and resolve such conflicts at merge time:
  only the **last** class in a conflict group is kept in the output.

  Each conflict group is identified by an atom (e.g. `:px`, `:bg`,
  `:text_size`). Two tokens with the same group atom conflict; two tokens
  with different group atoms are independent and both kept.

  ## Lookup Strategy

  `group_for/1` uses a four-step cascade to classify any token. Steps are
  ordered from most specific to least specific, and the first match wins:

  1. **`exact_group/1`** — O(1) compile-time map lookup. Handles classes that
     must be matched precisely to avoid false positives (e.g. `flex` matches
     both the display group and the `flex-*` prefix rule). Also handles
     `text-{align}` classes that must be separated from the `text-{color}`
     catch-all in step 2.

  2. **`special_group/1`** — Handles ambiguous `text-*` and `font-*` prefixes
     that cover multiple independent CSS properties:
     - `text-sm / text-lg` → `:text_size` (font-size)
     - `text-red-500 / text-primary` → `:text_color` (color)
     - `font-bold / font-semibold` → `:font_weight` (font-weight)
     - `font-sans / font-mono` → `:font_family` (font-family)

  3. **`prefix_group/1`** — Iterates the `@prefix_rules` table (ordered
     longest-first) and returns the group for the first matching prefix. This
     covers spacing, sizing, layout, and decoration utilities.

  4. **`standalone_group/1`** — Catches multi-word classes that share a prefix
     with an unrelated group (e.g. `flex-row` / `flex-col` for flex direction,
     which must not match the `flex-*` prefix in the display group).

  ## Why MapSet for Membership Tests?

  The compile-time constants (`@text_size_classes`, `@font_weight_classes`,
  `@font_family_classes`, `@display_classes`, etc.) are stored as `MapSet`
  values rather than plain lists. This gives O(1) average-case membership
  tests (`class in @text_size_classes`) instead of O(n) linear scans, which
  matters because `group_for/1` is called for every token in every `cn/1`
  call.

  MapSets are built at **compile time** using module attributes, so there is
  no runtime allocation cost — the set is baked into the BEAM bytecode as a
  literal.

  ## Why Prefix Rules Are Ordered Longest-First

  The prefix-rule table is scanned linearly from top to bottom; the first
  matching prefix wins. Ordering by descending prefix length prevents shorter
  prefixes from matching classes that belong to a more specific group.

  Example: `gap-x-4` must match `{"gap-x-", :gap_x}` before `{"gap-", :gap}`.
  If `"gap-"` appeared first, `gap-x-4` would be incorrectly assigned to the
  general `:gap` group instead of the axis-specific `:gap_x` group, causing
  `gap-x-4` and `gap-4` to be treated as conflicting (they are independent CSS
  properties: `column-gap` vs `gap`).

  Similarly, `px-4` must match `{"px-", :px}` before `{"p-", :p}` — they set
  different CSS properties (`padding-inline` vs all-sides `padding`).

  ## Returns

  Returns `nil` for classes that don't belong to any known group (arbitrary /
  custom classes), in which case exact-match deduplication applies instead.
  """

  # ── Compile-time constants ───────────────────────────────────────────────────

  # Tailwind font-size scale tokens (without the "text-" prefix).
  # Used to build @text_size_classes for the text-size vs text-color split.
  @text_sizes ~w(xs sm base lg xl 2xl 3xl 4xl 5xl 6xl 7xl 8xl 9xl)

  # Tailwind font-weight tokens (without the "font-" prefix).
  # Used to build @font_weight_classes for the font-weight vs font-family split.
  @font_weights ~w(thin extralight light normal medium semibold bold extrabold black)

  # Tailwind generic font-family tokens (without the "font-" prefix).
  @font_families ~w(sans serif mono)

  # Pre-compute sets for O(1) exact membership tests.
  # Built at compile time as module attributes so the MapSet is a literal in
  # the compiled bytecode — no runtime allocation on first use.
  @text_size_classes MapSet.new(Enum.map(@text_sizes, &"text-#{&1}"))
  @font_weight_classes MapSet.new(Enum.map(@font_weights, &"font-#{&1}"))
  @font_family_classes MapSet.new(Enum.map(@font_families, &"font-#{&1}"))

  # CSS `display` property values as Tailwind class names.
  # These are exact class names — no prefix to strip.
  @display_classes ~w(
    block inline inline-block flex inline-flex
    grid inline-grid table inline-table hidden
    table-row table-cell table-column
    table-caption table-row-group table-header-group
    table-footer-group table-column-group
    flow-root contents list-item
  )

  # CSS `position` property values as Tailwind class names.
  @position_classes ~w(static relative absolute fixed sticky)

  # Tailwind border-width utilities. These are exact-matched because the
  # "border" class (no suffix) would otherwise never match — it IS the group.
  @border_width_classes ~w(border border-0 border-2 border-4 border-8)

  # Text-align classes — must be exact-matched before `special_group/1`
  # handles the text-* catch-all. Without this, `text-center` would be
  # classified as `:text_color` (wrong) because it starts with "text-" and
  # is not in @text_size_classes.
  @text_align_classes ~w(text-left text-center text-right text-justify text-start text-end)

  # Compile-time exact-match map: class string → group atom.
  # Merging four sub-maps at compile time produces one flat map for O(1) lookup.
  # The merge order doesn't matter here because the key sets are disjoint.
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

  # Prefix rules ordered longest-first to prevent shorter prefixes from
  # matching before a more specific longer prefix gets a chance.
  #
  # Rule format: {"prefix-string-", :group_atom}
  #
  # Axis-specific gap must appear before the plain gap rule:
  #   gap-x-4 → :gap_x  (column-gap)
  #   gap-y-4 → :gap_y  (row-gap)
  #   gap-4   → :gap    (both axes, shorthand)
  #
  # Axis-constrained padding/margin must appear before the shorthand:
  #   px-4 → :px  (padding-inline), py-4 → :py (padding-block)
  #   pt-4 → :pt  (padding-top), etc.
  #   p-4  → :p   (all sides) — shortest, so last
  #
  # Logical properties (ps-/pe-/ms-/me-) are included for RTL support.
  @prefix_rules [
    # Gap utilities — axis-specific before shorthand
    {"gap-x-", :gap_x},
    {"gap-y-", :gap_y},
    {"gap-", :gap},
    # Sizing constraints — min/max before the plain w-/h-
    {"min-w-", :min_w},
    {"max-w-", :max_w},
    {"min-h-", :min_h},
    {"max-h-", :max_h},
    # Square sizing shorthand (sets both width and height)
    {"size-", :size},
    # Background colour/image — all bg-* classes share one property group
    {"bg-", :bg},
    # Padding — axis-specific and side-specific before all-sides shorthand
    {"px-", :px},
    {"py-", :py},
    {"pt-", :pt},
    {"pr-", :pr},
    {"pb-", :pb},
    {"pl-", :pl},
    {"ps-", :ps},
    {"pe-", :pe},
    {"p-", :p},
    # Margin — same ordering rationale as padding
    {"mx-", :mx},
    {"my-", :my},
    {"mt-", :mt},
    {"mr-", :mr},
    {"mb-", :mb},
    {"ml-", :ml},
    {"ms-", :ms},
    {"me-", :me},
    {"m-", :m},
    # Explicit width and height (without min/max — already handled above)
    {"w-", :w},
    {"h-", :h},
    # Stacking context
    {"z-", :z},
    # Visual effects
    {"opacity-", :opacity},
    {"overflow-", :overflow},
    {"cursor-", :cursor},
    # Typography — line-height, letter-spacing, text-decoration
    {"leading-", :leading},
    {"tracking-", :tracking},
    {"decoration-", :decoration},
    # Box shadow — all shadow-* variants share one CSS property
    {"shadow-", :shadow},
    # Border radius — all rounded-* variants share one CSS property
    {"rounded-", :rounded}
  ]

  # ── Public API ───────────────────────────────────────────────────────────────

  @doc """
  Returns the conflict group atom for `class`, or `nil` if unknown.

  The returned atom identifies the CSS property group that the class belongs
  to. Two classes with the same group atom conflict; only the last one is kept
  by `cn/1`. A `nil` return means the class is not in any known conflict group
  and will be deduplicated by exact string match instead.

  ## Examples

  Background colour group:

      iex> PhiaUi.ClassMerger.Groups.group_for("bg-primary")
      :bg

      iex> PhiaUi.ClassMerger.Groups.group_for("bg-red-500")
      :bg

  Text size (font-size) group:

      iex> PhiaUi.ClassMerger.Groups.group_for("text-sm")
      :text_size

      iex> PhiaUi.ClassMerger.Groups.group_for("text-2xl")
      :text_size

  Text colour — different group from text size:

      iex> PhiaUi.ClassMerger.Groups.group_for("text-red-500")
      :text_color

      iex> PhiaUi.ClassMerger.Groups.group_for("text-primary")
      :text_color

  Text alignment — exact-matched before the text-* catch-all:

      iex> PhiaUi.ClassMerger.Groups.group_for("text-center")
      :text_align

  Padding — axis-specific group:

      iex> PhiaUi.ClassMerger.Groups.group_for("px-4")
      :px

      iex> PhiaUi.ClassMerger.Groups.group_for("p-4")
      :p

  Display — exact match:

      iex> PhiaUi.ClassMerger.Groups.group_for("flex")
      :display

      iex> PhiaUi.ClassMerger.Groups.group_for("hidden")
      :display

  Unknown / custom class returns nil:

      iex> PhiaUi.ClassMerger.Groups.group_for("phia-custom")
      nil

      iex> PhiaUi.ClassMerger.Groups.group_for("my-custom-class")
      nil
  """
  @spec group_for(String.t()) :: atom() | nil
  def group_for(class) when is_binary(class) do
    # Four-step cascade, most specific first:
    # 1. Exact compile-time map lookup (display, position, border-width, text-align)
    # 2. Special ambiguous-prefix handling (text-*, font-*)
    # 3. Linear prefix scan (spacing, sizing, colours, etc.)
    # 4. Standalone multi-word classes not covered above (flex-direction, flex-wrap)
    exact_group(class) || special_group(class) || prefix_group(class) || standalone_group(class)
  end

  # ── Private helpers ──────────────────────────────────────────────────────────

  # Step 1 — O(1) map lookup for display, position, border-width, and
  # text-align classes. These are exact-matched to prevent the prefix rules
  # and special_group catch-alls from mis-classifying them.
  defp exact_group(class), do: Map.get(@exact_group_map, class)

  # Step 2 — Disambiguation for the "text-" and "font-" prefixes.
  #
  # The problem: both font-size and colour utilities start with "text-", and
  # both font-weight and font-family utilities start with "font-". A simple
  # prefix rule would lump them all into one group, incorrectly treating
  # `text-sm` and `text-red-500` as conflicting (they set different properties:
  # `font-size` vs `color`).
  #
  # The solution: check the @text_size_classes and @font_weight_classes
  # MapSets first (O(1) membership test). If the token is in the set, assign
  # the specific group. Otherwise fall through to the colour/family group.
  #
  # Note: text-align classes are already handled in exact_group/1 above, so
  # `text-center` will never reach this clause.
  defp special_group(class) do
    cond do
      class in @text_size_classes -> :text_size
      # Catch-all for any remaining "text-*" token: must be a colour utility.
      String.starts_with?(class, "text-") -> :text_color
      class in @font_weight_classes -> :font_weight
      class in @font_family_classes -> :font_family
      true -> nil
    end
  end

  # Step 3 — Linear scan of the prefix rules table.
  #
  # Enum.find_value/2 short-circuits on the first match, so the longest-first
  # ordering ensures we never mis-assign a class to a shorter-prefix group.
  # Returns the group atom when a match is found, or nil to fall through to
  # standalone_group/1.
  defp prefix_group(class) do
    Enum.find_value(@prefix_rules, fn {prefix, group} ->
      if String.starts_with?(class, prefix), do: group
    end)
  end

  # Step 4 — Catch-all for standalone classes not covered by the rules above.
  #
  # flex-row / flex-col / flex-row-reverse / flex-col-reverse all set the
  # `flex-direction` CSS property and must not be confused with the `flex`
  # display class (exact_group/1) or a hypothetical "flex-" prefix rule.
  #
  # flex-wrap / flex-nowrap / flex-wrap-reverse all set `flex-wrap` and are
  # likewise kept as a separate group.
  defp standalone_group(class) do
    flex_direction_group(class) || flex_wrap_group(class)
  end

  # Flex direction — sets the `flex-direction` CSS property.
  defp flex_direction_group(class) do
    if class in ~w(flex-row flex-col flex-row-reverse flex-col-reverse),
      do: :flex_direction
  end

  # Flex wrap — sets the `flex-wrap` CSS property.
  defp flex_wrap_group(class) do
    if class in ~w(flex-wrap flex-nowrap flex-wrap-reverse),
      do: :flex_wrap
  end
end
