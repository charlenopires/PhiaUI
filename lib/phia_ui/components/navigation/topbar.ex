defmodule PhiaUi.Components.Topbar do
  @moduledoc """
  Standalone sticky top navigation bar (h-14, border-b, bg-background).

  This component is useful when building a topbar-only layout (no sidebar), or
  when you need to render a topbar outside of a `shell/1`. When using `shell/1`,
  prefer the `:topbar` slot directly — it renders the same markup internally.

  ## Example

      <.topbar>
        <a href="/" class="font-semibold text-foreground">Acme</a>
        <nav class="ml-6 flex gap-4 text-sm text-muted-foreground">
          <a href="/docs">Docs</a>
          <a href="/pricing">Pricing</a>
        </nav>
        <div class="ml-auto">
          <.dark_mode_toggle id="topbar-dm" />
        </div>
      </.topbar>
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  # ---------------------------------------------------------------------------
  # topbar/1
  # ---------------------------------------------------------------------------

  attr(:class, :string, default: nil, doc: "Additional CSS classes for the header element")
  attr(:rest, :global)

  slot(:inner_block, required: true, doc: "Topbar content — brand, search, actions, user avatar")

  @doc """
  Standalone sticky top navigation bar (h-14, border-b, bg-background).

  ## Example

      <.topbar>
        <a href="/" class="font-semibold text-foreground">Acme</a>
        <div class="ml-auto">
          <.dark_mode_toggle id="topbar-dm" />
        </div>
      </.topbar>
  """
  def topbar(assigns) do
    ~H"""
    <header class={cn(["flex h-14 items-center border-b bg-(--background) px-4", @class])} {@rest}>
      <%= render_slot(@inner_block) %>
    </header>
    """
  end
end
