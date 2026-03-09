defmodule PhiaUi.Components.AppStoreButton do
  @moduledoc """
  Apple App Store and Google Play Store badge buttons.

  Renders store-branded download buttons with inline SVG icons.
  Follows the `social_button.ex` pattern — no external icon dependencies.

  ## Examples

      <.app_store_button store={:apple} href="https://apps.apple.com/..." />
      <.app_store_button store={:google} href="https://play.google.com/..." />
      <.app_store_button store={:apple} variant={:outline} size={:lg} />
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  attr :store, :atom, values: [:apple, :google], required: true, doc: "App store platform"
  attr :href, :string, default: nil, doc: "Store listing URL"
  attr :variant, :atom, values: [:default, :outline], default: :default
  attr :size, :atom, values: [:sm, :default, :lg], default: :default
  attr :class, :string, default: nil
  attr :rest, :global

  @doc """
  Renders a store-branded download badge button with an inline SVG icon.
  """
  def app_store_button(assigns) do
    ~H"""
    <a
      href={@href}
      target="_blank"
      rel="noopener noreferrer"
      role="button"
      class={cn([
        base_class(),
        variant_class(@variant),
        size_class(@size),
        @class
      ])}
      {@rest}
    >
      <svg
        class={icon_size(@size)}
        viewBox="0 0 24 24"
        xmlns="http://www.w3.org/2000/svg"
        fill="currentColor"
        aria-hidden="true"
      >
        <path d={store_path(@store)} />
      </svg>
      <span class="flex flex-col text-left leading-tight">
        <span class={cn(["font-normal", subtext_size(@size)])}>
          {store_subtext(@store)}
        </span>
        <span class={cn(["font-semibold", label_size(@size)])}>
          {store_label(@store)}
        </span>
      </span>
    </a>
    """
  end

  defp base_class do
    "inline-flex items-center gap-2.5 rounded-lg transition-colors " <>
      "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2"
  end

  defp variant_class(:default), do: "bg-foreground text-background hover:bg-foreground/90"
  defp variant_class(:outline), do: "border border-border bg-background text-foreground hover:bg-accent"

  defp size_class(:sm), do: "h-10 px-3.5"
  defp size_class(:default), do: "h-12 px-4"
  defp size_class(:lg), do: "h-14 px-5"

  defp icon_size(:sm), do: "h-5 w-5 shrink-0"
  defp icon_size(:default), do: "h-6 w-6 shrink-0"
  defp icon_size(:lg), do: "h-7 w-7 shrink-0"

  defp subtext_size(:sm), do: "text-[9px]"
  defp subtext_size(:default), do: "text-[10px]"
  defp subtext_size(:lg), do: "text-xs"

  defp label_size(:sm), do: "text-sm"
  defp label_size(:default), do: "text-base"
  defp label_size(:lg), do: "text-lg"

  defp store_subtext(:apple), do: "Download on the"
  defp store_subtext(:google), do: "Get it on"

  defp store_label(:apple), do: "App Store"
  defp store_label(:google), do: "Google Play"

  # Apple logo - simple apple SVG path
  defp store_path(:apple) do
    "M18.71 19.5c-.83 1.24-1.71 2.45-3.05 2.47-1.34.03-1.77-.79-3.29-.79-1.53 0-2 .77-3.27.81-1.31.05-2.3-1.32-3.14-2.53C4.25 17 2.94 12.45 4.7 9.39c.87-1.52 2.43-2.48 4.12-2.51 1.28-.02 2.5.87 3.29.87.78 0 2.26-1.07 3.8-.91.65.03 2.47.26 3.64 1.98-.09.06-2.17 1.28-2.15 3.81.03 3.02 2.65 4.03 2.68 4.04-.03.07-.42 1.44-1.38 2.83M13 3.5c.73-.83 1.94-1.46 2.94-1.5.13 1.17-.34 2.35-1.04 3.19-.69.85-1.83 1.51-2.95 1.42-.15-1.15.41-2.35 1.05-3.11"
  end

  # Google Play triangle logo
  defp store_path(:google) do
    "M3.609 1.814L13.792 12 3.61 22.186a.996.996 0 01-.61-.92V2.734a1 1 0 01.609-.92zm10.89 10.893l2.302 2.302-10.937 6.333 8.635-8.635zm3.199-1.04l2.603 1.508a1 1 0 010 1.65l-2.603 1.508-2.557-2.557 2.557-2.11zM5.864 2.658L16.801 8.99l-2.302 2.302-8.635-8.634z"
  end
end
