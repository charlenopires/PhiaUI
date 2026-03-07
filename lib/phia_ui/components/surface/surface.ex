defmodule PhiaUi.Components.Surface do
  @moduledoc """
  Surface primitives for PhiaUI — 5 components covering elevation, tonality,
  inset depth, scrollable containers, and tonal color layers.

  ## Components
  - `surface/1` — variant-based container with elevation control
  - `paper/1` — MUI-style paper with elevation 0-5
  - `inset_surface/1` — sunken / inset panel (Atlassian Sunken tier)
  - `scrollable_surface/1` — overflow-y container with optional edge fade
  - `tonal_surface/1` — semantic color tonal panel
  """

  use Phoenix.Component
  import PhiaUi.ClassMerger, only: [cn: 1]

  # ---------------------------------------------------------------------------
  # 1. surface/1
  # ---------------------------------------------------------------------------

  attr :variant, :string, values: ~w(flat raised floating overlay), default: "flat"
  attr :elevation, :any, default: nil
  attr :tonal, :boolean, default: false
  attr :outlined, :boolean, default: false
  attr :class, :string, default: nil
  attr :rest, :global

  slot :inner_block, required: true

  @doc """
  Generic surface container with variant and elevation support.

  ## Examples

      <.surface variant="raised">
        Content here
      </.surface>

      <.surface elevation="3" tonal outlined>
        Elevated tonal outlined surface
      </.surface>
  """
  def surface(assigns) do
    ~H"""
    <div
      class={cn([
        surface_variant_class(@variant),
        @elevation && elevation_class(@elevation),
        @tonal && "bg-primary/5 dark:bg-primary/10",
        @outlined && "border border-border",
        @class
      ])}
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end

  defp surface_variant_class("flat"),    do: "bg-card text-card-foreground rounded-lg"
  defp surface_variant_class("raised"),  do: "bg-card text-card-foreground rounded-lg shadow-md"
  defp surface_variant_class("floating"), do: "bg-card text-card-foreground rounded-xl shadow-xl"
  defp surface_variant_class("overlay"), do: "bg-popover text-popover-foreground rounded-xl shadow-xl"

  defp elevation_class("0"), do: "shadow-none"
  defp elevation_class("1"), do: "shadow-sm"
  defp elevation_class("2"), do: "shadow-md"
  defp elevation_class("3"), do: "shadow-lg"
  defp elevation_class("4"), do: "shadow-xl"
  defp elevation_class("5"), do: "shadow-2xl"

  # ---------------------------------------------------------------------------
  # 2. paper/1
  # ---------------------------------------------------------------------------

  attr :elevation, :string, values: ~w(0 1 2 3 4 5), default: "1"
  attr :variant, :string, values: ~w(elevation outlined), default: "elevation"
  attr :square, :boolean, default: false
  attr :class, :string, default: nil
  attr :rest, :global

  slot :inner_block, required: true

  @doc """
  MUI-style paper component with elevation 0-5 and optional outline.

  ## Examples

      <.paper elevation="2">
        Paper content
      </.paper>

      <.paper variant="outlined" square>
        Square outlined paper
      </.paper>
  """
  def paper(assigns) do
    ~H"""
    <div
      class={cn([
        "bg-card text-card-foreground",
        @square && "rounded-none" || "rounded-lg",
        @variant == "outlined" && "border border-border",
        @variant == "elevation" && elevation_class(@elevation),
        @class
      ])}
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # 3. inset_surface/1
  # ---------------------------------------------------------------------------

  attr :depth, :string, values: ~w(sm md lg), default: "md"
  attr :class, :string, default: nil
  attr :rest, :global

  slot :inner_block, required: true

  @doc """
  Sunken / inset panel — Atlassian Sunken elevation tier equivalent.

  ## Examples

      <.inset_surface depth="lg">
        Deeply inset content
      </.inset_surface>
  """
  def inset_surface(assigns) do
    ~H"""
    <div
      class={cn([inset_depth_class(@depth), @class])}
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end

  defp inset_depth_class("sm"), do: "bg-muted/50 rounded-md p-3 shadow-inner border border-border/50"
  defp inset_depth_class("md"), do: "bg-muted rounded-md p-4 shadow-inner border border-border"
  defp inset_depth_class("lg"), do: "bg-muted rounded-lg p-6 ring-1 ring-inset ring-border shadow-inner"

  # ---------------------------------------------------------------------------
  # 4. scrollable_surface/1
  # ---------------------------------------------------------------------------

  attr :max_height, :string, default: "20rem"
  attr :fade_edges, :boolean, default: false
  attr :class, :string, default: nil
  attr :rest, :global

  slot :inner_block, required: true

  @doc """
  Vertically scrollable container with optional top/bottom fade masks.

  ## Examples

      <.scrollable_surface max_height="30rem" fade_edges>
        Long list of items...
      </.scrollable_surface>
  """
  def scrollable_surface(assigns) do
    ~H"""
    <div
      class={cn([
        "overflow-y-auto bg-card rounded-lg",
        @fade_edges && "[mask-image:linear-gradient(to_bottom,transparent,black_10%,black_90%,transparent)]",
        @class
      ])}
      style={"max-height: #{@max_height}"}
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # 5. tonal_surface/1
  # ---------------------------------------------------------------------------

  attr :color, :string, values: ~w(primary secondary destructive muted accent), default: "primary"
  attr :class, :string, default: nil
  attr :rest, :global

  slot :inner_block, required: true

  @doc """
  Semantic color tonal panel using 10% opacity fills.

  ## Examples

      <.tonal_surface color="destructive">
        Warning area
      </.tonal_surface>
  """
  def tonal_surface(assigns) do
    ~H"""
    <div
      class={cn(["rounded-lg p-4", tonal_class(@color), @class])}
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end

  defp tonal_class("primary"),     do: "bg-primary/10 text-primary dark:bg-primary/15"
  defp tonal_class("secondary"),   do: "bg-secondary text-secondary-foreground"
  defp tonal_class("destructive"), do: "bg-destructive/10 text-destructive dark:bg-destructive/15"
  defp tonal_class("muted"),       do: "bg-muted text-muted-foreground"
  defp tonal_class("accent"),      do: "bg-accent text-accent-foreground"
end
