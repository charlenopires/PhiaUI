defmodule PhiaUi.Components.Data.ChartSymbols do
  @moduledoc false
  # SVG path generators for 7 Recharts-style symbol shapes.
  # Each path is centered at (0, 0) — use SVG transform="translate(cx, cy)" to position.
  # Not registered in ComponentRegistry — internal only.

  @supported_types [:circle, :cross, :diamond, :square, :star, :triangle, :wye]

  @doc "Returns the list of supported symbol type atoms."
  def types, do: @supported_types

  @doc "Returns true if the given symbol type is supported."
  def supported?(type), do: type in @supported_types

  @doc """
  Generates an SVG path `d` string for the given symbol type centered at (0, 0).

  ## Parameters
  - `type` — one of `:circle`, `:cross`, `:diamond`, `:square`, `:star`, `:triangle`, `:wye`
  - `size` — symbol size in pixels (radius for circle, half-side for others)
  """
  def path(:circle, size) do
    r = size * 1.0
    # Arc-based circle: two semicircular arcs
    "M #{f(-r)} 0 A #{f(r)} #{f(r)} 0 1 1 #{f(r)} 0 A #{f(r)} #{f(r)} 0 1 1 #{f(-r)} 0 Z"
  end

  def path(:cross, size) do
    s = size * 1.0
    t = s / 3
    # Plus sign shape
    "M #{f(-t)} #{f(-s)} L #{f(t)} #{f(-s)} L #{f(t)} #{f(-t)} " <>
      "L #{f(s)} #{f(-t)} L #{f(s)} #{f(t)} L #{f(t)} #{f(t)} " <>
      "L #{f(t)} #{f(s)} L #{f(-t)} #{f(s)} L #{f(-t)} #{f(t)} " <>
      "L #{f(-s)} #{f(t)} L #{f(-s)} #{f(-t)} L #{f(-t)} #{f(-t)} Z"
  end

  def path(:diamond, size) do
    s = size * 1.0
    "M 0 #{f(-s)} L #{f(s)} 0 L 0 #{f(s)} L #{f(-s)} 0 Z"
  end

  def path(:square, size) do
    s = size * 1.0
    "M #{f(-s)} #{f(-s)} L #{f(s)} #{f(-s)} L #{f(s)} #{f(s)} L #{f(-s)} #{f(s)} Z"
  end

  def path(:star, size) do
    # 5-pointed star with inner/outer ratio 0.382 (golden ratio)
    outer = size * 1.0
    inner = outer * 0.382
    points = for i <- 0..9 do
      angle = i * :math.pi() / 5 - :math.pi() / 2
      r = if rem(i, 2) == 0, do: outer, else: inner
      {f(r * :math.cos(angle)), f(r * :math.sin(angle))}
    end

    [{x0, y0} | rest] = points
    move = "M #{x0} #{y0}"
    lines = Enum.map_join(rest, " ", fn {x, y} -> "L #{x} #{y}" end)
    "#{move} #{lines} Z"
  end

  def path(:triangle, size) do
    # Equilateral triangle centered at origin
    s = size * 1.0
    h = s * :math.sqrt(3) / 2
    "M 0 #{f(-h * 2 / 3)} L #{f(s)} #{f(h / 3)} L #{f(-s)} #{f(h / 3)} Z"
  end

  def path(:wye, size) do
    # Y-shape: 3 arms at 120-degree intervals
    s = size * 1.0
    w = s * 0.3
    arm_len = s

    arms =
      for i <- 0..2 do
        angle = i * 2 * :math.pi() / 3 - :math.pi() / 2
        perp = angle + :math.pi() / 2

        # Tip of arm
        tx = arm_len * :math.cos(angle)
        ty = arm_len * :math.sin(angle)

        # Sides of arm at base (near center)
        bx1 = w * :math.cos(perp)
        by1 = w * :math.sin(perp)

        # Sides of arm at tip
        tx1 = tx + w * :math.cos(perp)
        ty1 = ty + w * :math.sin(perp)
        tx2 = tx - w * :math.cos(perp)
        ty2 = ty - w * :math.sin(perp)

        # Base sides
        bx2 = -w * :math.cos(perp)
        by2 = -w * :math.sin(perp)

        [{f(bx1), f(by1)}, {f(tx1), f(ty1)}, {f(tx2), f(ty2)}, {f(bx2), f(by2)}]
      end

    # Build path: start from first arm's first point, go through all arm vertices
    all_points = List.flatten(arms)
    [{x0, y0} | rest] = all_points
    move = "M #{x0} #{y0}"
    lines = Enum.map_join(rest, " ", fn {x, y} -> "L #{x} #{y}" end)
    "#{move} #{lines} Z"
  end

  defp f(v), do: Float.round(v * 1.0, 2)
end
