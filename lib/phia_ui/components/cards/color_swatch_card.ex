defmodule PhiaUi.Components.ColorSwatchCard do
  @moduledoc "Color block + name + hex value + optional copy button."

  use Phoenix.Component

  import PhiaUi.Components.CopyButton
  import PhiaUi.ClassMerger, only: [cn: 1]

  attr :name, :string, required: true, doc: "Color name (e.g. 'Ocean Blue')"
  attr :hex, :string, required: true, doc: "Hex color value (e.g. '#1E90FF')"
  attr :rgb, :string, default: nil, doc: "Optional RGB representation (e.g. 'rgb(30, 144, 255)')"
  attr :hsl, :string, default: nil, doc: "Optional HSL representation (e.g. 'hsl(210, 100%, 56%)')"
  attr :copyable, :boolean, default: true, doc: "Whether to show a copy button for the hex value"
  attr :size, :atom, default: :md, values: [:sm, :md, :lg], doc: "Size variant controlling swatch height"
  attr :class, :string, default: nil, doc: "Additional CSS classes"
  attr :rest, :global, doc: "HTML attributes forwarded to the wrapper element"

  slot :tags, doc: "Optional tags to display below the color info"

  @doc """
  Renders a color swatch card displaying a color block with its name and hex value.

  ## Sizes

  - `:sm` — h-16 color block
  - `:md` — h-24 color block
  - `:lg` — h-32 color block

  ## Examples

      <.color_swatch_card name="Ocean Blue" hex="#1E90FF" />

      <.color_swatch_card name="Sunset" hex="#FF6B35" rgb="rgb(255, 107, 53)" size={:lg} />

      <.color_swatch_card name="Forest" hex="#228B22" copyable={false}>
        <:tags><span class="badge">nature</span></:tags>
      </.color_swatch_card>
  """
  def color_swatch_card(assigns) do
    ~H"""
    <div class={cn(["rounded-lg border overflow-hidden", @class])} {@rest}>
      <%!-- Color swatch block --%>
      <div class={cn([swatch_height(@size), "w-full"])} style={"background-color: #{@hex}"}></div>
      <%!-- Color info --%>
      <div class="p-3 space-y-1">
        <p class="text-sm font-medium">{@name}</p>
        <div class="flex items-center justify-between gap-2">
          <span class="text-xs text-muted-foreground font-mono">{@hex}</span>
          <.copy_button :if={@copyable} id={"copy-#{String.replace(@name, ~r/\s+/, "-") |> String.downcase()}-hex"} value={@hex} />
        </div>
        <p :if={@rgb} class="text-xs text-muted-foreground">{@rgb}</p>
        <p :if={@hsl} class="text-xs text-muted-foreground">{@hsl}</p>
        <div :if={@tags != []}>
          {render_slot(@tags)}
        </div>
      </div>
    </div>
    """
  end

  defp swatch_height(:sm), do: "h-16"
  defp swatch_height(:md), do: "h-24"
  defp swatch_height(:lg), do: "h-32"
end
