defmodule PhiaUi.ResponsiveHelpers do
  @moduledoc """
  Shared helpers for converting per-breakpoint responsive maps into Tailwind
  CSS class strings.

  All layout attributes in PhiaUI accept either a plain value (backward
  compatible) or a responsive map like `%{base: :col, md: :row}`. This module
  provides the conversion from those maps to prefixed Tailwind classes.

  ## Responsive Map Convention

  A responsive map can contain any combination of these keys:

  - `:base` — no breakpoint prefix (mobile-first default)
  - `:sm` — `sm:` breakpoint (≥640px)
  - `:md` — `md:` breakpoint (≥768px)
  - `:lg` — `lg:` breakpoint (≥1024px)
  - `:xl` — `xl:` breakpoint (≥1280px)
  - `:"2xl"` — `2xl:` breakpoint (≥1536px)

  ## Examples

      iex> PhiaUi.ResponsiveHelpers.resolve_responsive(:row, &"flex-\#{&1}")
      ["flex-row"]

      iex> PhiaUi.ResponsiveHelpers.resolve_responsive(%{base: :col, md: :row}, &"flex-\#{&1}")
      ["flex-col", "md:flex-row"]

      iex> PhiaUi.ResponsiveHelpers.resolve_responsive(nil, &"flex-\#{&1}")
      [nil]
  """

  @breakpoints [:sm, :md, :lg, :xl, :"2xl"]

  @doc """
  Resolves a value or responsive map into a list of Tailwind classes.

  The `mapper` function receives a plain value and returns a class string.
  When `value` is a map, the mapper is called for each breakpoint entry and
  the result is prefixed with the breakpoint name.

  Returns a list suitable for inclusion in a `cn/1` call.
  """
  @spec resolve_responsive(any(), (any() -> String.t() | nil)) :: [String.t() | nil]
  def resolve_responsive(value, mapper)

  def resolve_responsive(nil, _mapper), do: [nil]

  def resolve_responsive(value, mapper) when is_map(value) do
    responsive_classes(value, mapper)
  end

  def resolve_responsive(value, mapper), do: [mapper.(value)]

  @doc """
  Converts a responsive breakpoint map into a list of prefixed Tailwind classes.

  ## Examples

      iex> PhiaUi.ResponsiveHelpers.responsive_classes(%{base: 4, lg: 8}, &"gap-\#{&1}")
      ["gap-4", "lg:gap-8"]
  """
  @spec responsive_classes(map(), (any() -> String.t() | nil)) :: [String.t() | nil]
  def responsive_classes(bp_map, mapper) do
    base = if val = bp_map[:base], do: mapper.(val)

    bps =
      for bp <- @breakpoints,
          val = bp_map[bp],
          val != nil,
          cls = mapper.(val),
          cls != nil do
        "#{bp}:#{cls}"
      end

    [base | bps]
  end

  @doc """
  Converts a responsive breakpoint map into container query classes (`@sm:`, `@md:`, etc).

  ## Examples

      iex> PhiaUi.ResponsiveHelpers.container_classes(%{base: 1, md: 2}, &"grid-cols-\#{&1}")
      ["grid-cols-1", "@md:grid-cols-2"]
  """
  @spec container_classes(map(), (any() -> String.t() | nil)) :: [String.t() | nil]
  def container_classes(bp_map, mapper) do
    base = if val = bp_map[:base], do: mapper.(val)

    bps =
      for bp <- @breakpoints,
          val = bp_map[bp],
          val != nil,
          cls = mapper.(val),
          cls != nil do
        "@#{bp}:#{cls}"
      end

    [base | bps]
  end
end
