defmodule PhiaUi.Components.Item do
  @moduledoc """
  Versatile list item component with media, title, description, and trailing actions.

  Provides a consistent layout for list items across the application —
  settings rows, contact lists, notification items, file browsers, and more.
  Pure HEEx, no JavaScript required.

  ## Components

  | Function            | Element | Purpose                                    |
  |---------------------|---------|--------------------------------------------|
  | `item/1`            | `div`/`a` | Container with media, content, actions   |
  | `item_title/1`      | `p`     | Primary text, `font-medium`                |
  | `item_description/1`| `p`     | Secondary text, `text-muted-foreground`    |

  ## Variants

  | Variant    | Style                                              |
  |------------|----------------------------------------------------|
  | `"default"`| Transparent background, hover accent                |
  | `"outline"`| Border with `border-border`                         |
  | `"muted"`  | `bg-muted/50` background                            |

  ## Basic example

      <.item>
        <:media><.avatar src="/avatar.jpg" fallback="JD" /></:media>
        <.item_title>John Doe</.item_title>
        <.item_description>Software Engineer</.item_description>
        <:trailing>
          <.badge>Admin</.badge>
        </:trailing>
      </.item>

  ## As a link

      <.item navigate={~p"/users/42"}>
        <.item_title>View Profile</.item_title>
        <.item_description>Click to open</.item_description>
      </.item>
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  # ---------------------------------------------------------------------------
  # item/1
  # ---------------------------------------------------------------------------

  attr :variant, :atom,
    values: [:default, :outline, :muted],
    default: :default,
    doc: "Visual variant."

  attr :href, :string, default: nil, doc: "Renders as an `<a>` tag."
  attr :navigate, :string, default: nil, doc: "LiveView `navigate`."
  attr :patch, :string, default: nil, doc: "LiveView `patch`."
  attr :class, :string, default: nil, doc: "Additional CSS classes."
  attr :rest, :global, doc: "Additional HTML attributes."

  slot :media, doc: "Leading avatar, icon, or thumbnail."
  slot :inner_block, required: true, doc: "Main content area."
  slot :trailing, doc: "Trailing metadata or actions."

  @doc """
  Renders a versatile list item with optional media, content, and trailing actions.

  ## Examples

      <.item>
        <.item_title>Settings</.item_title>
        <.item_description>Manage your account</.item_description>
      </.item>

      <.item variant="outline" navigate={~p"/profile"}>
        <:media><.icon name="user" /></:media>
        <.item_title>Profile</.item_title>
        <:trailing><.icon name="chevron-right" size={:sm} /></:trailing>
      </.item>
  """
  def item(assigns) do
    ~H"""
    <%= if @href do %>
      <a
        href={@href}
        class={item_class(@variant, true, @class)}
        {@rest}
      >
        <div :if={@media != []} class="flex-shrink-0">{render_slot(@media)}</div>
        <div class="flex-1 min-w-0">{render_slot(@inner_block)}</div>
        <div :if={@trailing != []} class="flex-shrink-0">{render_slot(@trailing)}</div>
      </a>
    <% else %>
      <%= if @navigate do %>
        <.link
          navigate={@navigate}
          class={item_class(@variant, true, @class)}
          {@rest}
        >
          <div :if={@media != []} class="flex-shrink-0">{render_slot(@media)}</div>
          <div class="flex-1 min-w-0">{render_slot(@inner_block)}</div>
          <div :if={@trailing != []} class="flex-shrink-0">{render_slot(@trailing)}</div>
        </.link>
      <% else %>
        <%= if @patch do %>
          <.link
            patch={@patch}
            class={item_class(@variant, true, @class)}
            {@rest}
          >
            <div :if={@media != []} class="flex-shrink-0">{render_slot(@media)}</div>
            <div class="flex-1 min-w-0">{render_slot(@inner_block)}</div>
            <div :if={@trailing != []} class="flex-shrink-0">{render_slot(@trailing)}</div>
          </.link>
        <% else %>
          <div
            class={item_class(@variant, false, @class)}
            {@rest}
          >
            <div :if={@media != []} class="flex-shrink-0">{render_slot(@media)}</div>
            <div class="flex-1 min-w-0">{render_slot(@inner_block)}</div>
            <div :if={@trailing != []} class="flex-shrink-0">{render_slot(@trailing)}</div>
          </div>
        <% end %>
      <% end %>
    <% end %>
    """
  end

  # ---------------------------------------------------------------------------
  # item_title/1
  # ---------------------------------------------------------------------------

  attr :class, :string, default: nil, doc: "Additional CSS classes."
  attr :rest, :global
  slot :inner_block, required: true

  @doc "Renders the primary title text inside an `item/1`."
  def item_title(assigns) do
    ~H"""
    <p class={cn(["text-sm font-medium leading-none", @class])} {@rest}>
      {render_slot(@inner_block)}
    </p>
    """
  end

  # ---------------------------------------------------------------------------
  # item_description/1
  # ---------------------------------------------------------------------------

  attr :class, :string, default: nil, doc: "Additional CSS classes."
  attr :rest, :global
  slot :inner_block, required: true

  @doc "Renders secondary description text inside an `item/1`."
  def item_description(assigns) do
    ~H"""
    <p class={cn(["text-sm text-muted-foreground line-clamp-1 mt-1", @class])} {@rest}>
      {render_slot(@inner_block)}
    </p>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  defp item_class(variant, clickable?, extra_class) do
    cn([
      "flex items-center gap-3 px-3 py-2 rounded-md",
      variant_class(variant),
      clickable? && "hover:bg-accent cursor-pointer transition-colors",
      extra_class
    ])
  end

  defp variant_class(:default), do: nil
  defp variant_class(:outline), do: "border border-border"
  defp variant_class(:muted), do: "bg-muted/50"
end
