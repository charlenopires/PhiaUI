defmodule PhiaUi.Components.Marketing.FeatureSection do
  @moduledoc """
  Grid section for displaying feature cards with heading and description.

  Provides a responsive grid layout with an optional title and description
  header. Use as a container for feature cards, benefit blocks, or any
  repeated content that benefits from a grid layout.

  ## Examples

      <.feature_section title="Features" description="Everything you need." columns={3}>
        <div>Feature 1</div>
        <div>Feature 2</div>
        <div>Feature 3</div>
      </.feature_section>

      <.feature_section columns={2} align={:start}>
        <div>Left-aligned feature grid</div>
        <div>With two columns</div>
      </.feature_section>
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  attr :title, :string, default: nil
  attr :description, :string, default: nil
  attr :columns, :integer, default: 3
  attr :align, :atom, values: [:center, :start], default: :center
  attr :class, :string, default: nil
  attr :rest, :global

  slot :inner_block, required: true, doc: "Feature card children"

  @doc "Renders a responsive feature grid section with optional heading and description."
  def feature_section(assigns) do
    ~H"""
    <section class={cn(["w-full", @class])} {@rest}>
      <%= if @title || @description do %>
        <div class={cn(["mb-12", align_class(@align)])}>
          <%= if @title do %>
            <h2 class="text-3xl font-bold tracking-tight text-foreground sm:text-4xl">
              {@title}
            </h2>
          <% end %>
          <%= if @description do %>
            <p class="mt-4 max-w-2xl text-lg text-muted-foreground">
              {@description}
            </p>
          <% end %>
        </div>
      <% end %>

      <div class={cn(["grid gap-8", columns_class(@columns)])}>
        {render_slot(@inner_block)}
      </div>
    </section>
    """
  end

  defp align_class(:center), do: "text-center mx-auto"
  defp align_class(:start), do: "text-left"

  defp columns_class(1), do: "grid-cols-1"
  defp columns_class(2), do: "grid-cols-1 md:grid-cols-2"
  defp columns_class(3), do: "grid-cols-1 md:grid-cols-2 lg:grid-cols-3"
  defp columns_class(4), do: "grid-cols-1 md:grid-cols-2 lg:grid-cols-4"
  defp columns_class(_), do: "grid-cols-1 md:grid-cols-2 lg:grid-cols-3"
end
