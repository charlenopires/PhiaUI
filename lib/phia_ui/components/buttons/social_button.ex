defmodule PhiaUi.Components.SocialButton do
  @moduledoc """
  Platform-branded OAuth / social sign-in buttons.

  Provides `social_button/1` for individual providers and
  `social_button_group/1` for stacking multiple social buttons together.

  Brand colors are applied via inline `style` attributes to keep the CSS
  bundle minimal and to avoid Tailwind purging arbitrary color classes.

  ## Supported providers

  `:google`, `:github`, `:apple`, `:twitter`, `:facebook`, `:discord`,
  `:linkedin`, `:microsoft`, `:slack`, `:custom`

  For `:custom`, render your own icon via the `:icon` slot.

  ## Variants

  | Variant    | Appearance                                    |
  |------------|-----------------------------------------------|
  | `:branded` | Full brand color background + white text      |
  | `:outline` | Border with bg-background, no brand fill      |
  | `:ghost`   | Transparent, no border                        |

  ## Example

      <.social_button_group>
        <.social_button provider={:google} />
        <.social_button provider={:github} />
        <.social_button provider={:apple} />
      </.social_button_group>

      <.social_button provider={:google} label="Continue with Google" variant={:outline} />

      <.social_button provider={:github} icon_only={true} size={:lg} />

      <.social_button provider={:custom}>
        <:icon>
          <svg>...</svg>
        </:icon>
      </.social_button>
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  # ---------------------------------------------------------------------------
  # social_button/1
  # ---------------------------------------------------------------------------

  attr :provider, :atom,
    values: [:google, :github, :apple, :twitter, :facebook, :discord, :linkedin, :microsoft, :slack, :custom],
    required: true,
    doc: "OAuth provider — controls brand color and icon"

  attr :label, :string,
    default: nil,
    doc: "Override the default 'Sign in with X' label. Use nil for the default."

  attr :variant, :atom,
    values: [:branded, :outline, :ghost],
    default: :branded,
    doc: "Visual style — :branded fills with brand color"

  attr :size, :atom,
    values: [:sm, :default, :lg],
    default: :default,
    doc: "Button size"

  attr :icon_only, :boolean,
    default: false,
    doc: "When true, the text label is visually hidden (sr-only) but still accessible"

  attr :loading, :boolean, default: false
  attr :disabled, :boolean, default: false
  attr :class, :string, default: nil
  attr :rest, :global

  slot :icon, doc: "Custom icon slot — only used when provider={:custom}"

  @doc """
  Renders a platform-branded social sign-in button.

  Brand colors are applied via `style` to avoid Tailwind arbitrary color issues.
  The monochrome SVG icon inherits `color` from the button.
  """
  def social_button(assigns) do
    ~H"""
    <button
      type="button"
      class={cn([
        base_class(),
        variant_class(@variant),
        size_class(@size),
        (@variant == :branded and @provider == :google) && "border border-gray-300",
        (@disabled or @loading) && "pointer-events-none opacity-50",
        @class
      ])}
      style={if @variant == :branded, do: branded_style(@provider)}
      disabled={@disabled}
      aria-busy={@loading && "true"}
      {@rest}
    >
      <%!-- Icon area --%>
      <%= if @loading do %>
        <svg
          class={"animate-spin #{icon_size(@size)} shrink-0"}
          xmlns="http://www.w3.org/2000/svg"
          fill="none"
          viewBox="0 0 24 24"
          aria-hidden="true"
        >
          <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4" />
          <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z" />
        </svg>
      <% else %>
        <%= if @provider == :custom do %>
          <%= render_slot(@icon) %>
        <% else %>
          <svg
            class={"#{icon_size(@size)} shrink-0"}
            viewBox="0 0 24 24"
            xmlns="http://www.w3.org/2000/svg"
            aria-hidden="true"
            fill="currentColor"
          >
            <path d={provider_path(@provider)} />
          </svg>
        <% end %>
      <% end %>

      <%!-- Label area --%>
      <span class={cn(["text-sm font-medium", @icon_only && "sr-only"])}>
        {if @label, do: @label, else: provider_label(@provider)}
      </span>
    </button>
    """
  end

  # ---------------------------------------------------------------------------
  # social_button_group/1
  # ---------------------------------------------------------------------------

  attr :orientation, :atom,
    values: [:horizontal, :vertical],
    default: :vertical,
    doc: "Stack direction — :vertical (default) or :horizontal"

  attr :class, :string, default: nil
  attr :rest, :global

  slot :inner_block, required: true, doc: "social_button components"

  @doc """
  Renders a group of social sign-in buttons with consistent spacing.
  """
  def social_button_group(assigns) do
    ~H"""
    <div
      class={cn(["flex", orientation_class(@orientation), @class])}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  defp base_class do
    "inline-flex items-center justify-center gap-3 whitespace-nowrap rounded-md " <>
      "ring-offset-background transition-opacity " <>
      "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2"
  end

  defp variant_class(:branded), do: "font-medium"
  defp variant_class(:outline), do: "border border-input bg-background text-foreground hover:bg-accent hover:text-accent-foreground"
  defp variant_class(:ghost), do: "text-foreground hover:bg-accent hover:text-accent-foreground"

  defp size_class(:sm), do: "h-9 px-4 text-sm"
  defp size_class(:default), do: "h-10 px-5 text-sm"
  defp size_class(:lg), do: "h-12 px-6 text-base"

  defp icon_size(:sm), do: "h-4 w-4"
  defp icon_size(:default), do: "h-5 w-5"
  defp icon_size(:lg), do: "h-5 w-5"

  defp orientation_class(:horizontal), do: "flex-row gap-2"
  defp orientation_class(:vertical), do: "flex-col gap-2"

  # Brand background + text colors for :branded variant
  defp branded_style(:google), do: "background-color: #ffffff; color: #3c4043;"
  defp branded_style(:github), do: "background-color: #24292f; color: #ffffff;"
  defp branded_style(:apple), do: "background-color: #000000; color: #ffffff;"
  defp branded_style(:twitter), do: "background-color: #000000; color: #ffffff;"
  defp branded_style(:facebook), do: "background-color: #1877f2; color: #ffffff;"
  defp branded_style(:discord), do: "background-color: #5865f2; color: #ffffff;"
  defp branded_style(:linkedin), do: "background-color: #0a66c2; color: #ffffff;"
  defp branded_style(:microsoft), do: "background-color: #00a1f1; color: #ffffff;"
  defp branded_style(:slack), do: "background-color: #4a154b; color: #ffffff;"
  defp branded_style(:custom), do: nil

  # Default label per provider
  defp provider_label(:google), do: "Sign in with Google"
  defp provider_label(:github), do: "Sign in with GitHub"
  defp provider_label(:apple), do: "Sign in with Apple"
  defp provider_label(:twitter), do: "Sign in with X"
  defp provider_label(:facebook), do: "Sign in with Facebook"
  defp provider_label(:discord), do: "Sign in with Discord"
  defp provider_label(:linkedin), do: "Sign in with LinkedIn"
  defp provider_label(:microsoft), do: "Sign in with Microsoft"
  defp provider_label(:slack), do: "Sign in with Slack"
  defp provider_label(:custom), do: "Sign in"

  # SVG path data (monochrome, viewBox="0 0 24 24")
  defp provider_path(:google) do
    "M21.35 11.1H12.18V13.83h6.51c-.33 3.81-3.5 5.44-6.5 5.44C8.36 19.27 5 16.25 5 12c0-4.1 3.2-7.27 7.2-7.27 3.09 0 4.9 1.97 4.9 1.97L19 4.72S16.56 2 12.1 2C6.42 2 2.03 6.8 2.03 12c0 5.05 4.13 10 10.22 10 5.35 0 9.25-3.67 9.25-9.09 0-1.15-.15-1.81-.15-1.81z"
  end

  defp provider_path(:github) do
    "M12 .297c-6.63 0-12 5.373-12 12 0 5.303 3.438 9.8 8.205 11.385.6.113.82-.258.82-.577 0-.285-.01-1.04-.015-2.04-3.338.724-4.042-1.61-4.042-1.61C4.422 18.07 3.633 17.7 3.633 17.7c-1.087-.744.084-.729.084-.729 1.205.084 1.838 1.236 1.838 1.236 1.07 1.835 2.809 1.305 3.495.998.108-.776.417-1.305.76-1.605-2.665-.3-5.466-1.332-5.466-5.93 0-1.31.465-2.38 1.235-3.22-.135-.303-.54-1.523.105-3.176 0 0 1.005-.322 3.3 1.23.96-.267 1.98-.399 3-.405 1.02.006 2.04.138 3 .405 2.28-1.552 3.285-1.23 3.285-1.23.645 1.653.24 2.873.12 3.176.765.84 1.23 1.91 1.23 3.22 0 4.61-2.805 5.625-5.475 5.92.42.36.81 1.096.81 2.22 0 1.606-.015 2.896-.015 3.286 0 .315.21.69.825.57C20.565 22.092 24 17.592 24 12.297c0-6.627-5.373-12-12-12"
  end

  defp provider_path(:apple) do
    "M12.152 6.896c-.948 0-2.415-1.078-3.96-1.04-2.04.027-3.91 1.183-4.961 3.014-2.117 3.675-.546 9.103 1.519 12.09 1.013 1.454 2.208 3.09 3.792 3.039 1.52-.065 2.09-.987 3.935-.987 1.831 0 2.35.987 3.96.948 1.637-.026 2.676-1.48 3.676-2.948 1.156-1.688 1.636-3.325 1.662-3.415-.039-.013-3.182-1.221-3.22-4.857-.026-3.04 2.48-4.494 2.597-4.559-1.429-2.09-3.623-2.324-4.39-2.376-2-.156-3.675 1.09-4.61 1.09zM15.53 3.83c.843-1.012 1.4-2.427 1.245-3.83-1.207.052-2.662.805-3.532 1.818-.78.896-1.454 2.338-1.273 3.714 1.338.104 2.715-.688 3.559-1.701"
  end

  defp provider_path(:twitter) do
    "M18.901 1.153h3.68l-8.04 9.19L24 22.846h-7.406l-5.8-7.584-6.638 7.584H.474l8.6-9.83L0 1.154h7.594l5.243 6.932ZM17.61 20.644h2.039L6.486 3.24H4.298Z"
  end

  defp provider_path(:facebook) do
    "M24 12.073c0-6.627-5.373-12-12-12s-12 5.373-12 12c0 5.99 4.388 10.954 10.125 11.854v-8.385H7.078v-3.47h3.047V9.43c0-3.007 1.792-4.669 4.533-4.669 1.312 0 2.686.235 2.686.235v2.953H15.83c-1.491 0-1.956.925-1.956 1.874v2.25h3.328l-.532 3.47h-2.796v8.385C19.612 23.027 24 18.062 24 12.073z"
  end

  defp provider_path(:discord) do
    "M20.317 4.37a19.791 19.791 0 0 0-4.885-1.515.074.074 0 0 0-.079.037c-.21.375-.444.864-.608 1.25a18.27 18.27 0 0 0-5.487 0 12.64 12.64 0 0 0-.617-1.25.077.077 0 0 0-.079-.037A19.736 19.736 0 0 0 3.677 4.37a.07.07 0 0 0-.032.027C.533 9.046-.32 13.58.099 18.057a.082.082 0 0 0 .031.057 19.9 19.9 0 0 0 5.993 3.03.078.078 0 0 0 .084-.028c.462-.63.874-1.295 1.226-1.994a.076.076 0 0 0-.041-.106 13.107 13.107 0 0 1-1.872-.892.077.077 0 0 1-.008-.128 10.2 10.2 0 0 0 .372-.292.074.074 0 0 1 .077-.01c3.928 1.793 8.18 1.793 12.062 0a.074.074 0 0 1 .078.01c.12.098.246.198.373.292a.077.077 0 0 1-.006.127 12.299 12.299 0 0 1-1.873.892.077.077 0 0 0-.041.107c.36.698.772 1.362 1.225 1.993a.076.076 0 0 0 .084.028 19.839 19.839 0 0 0 6.002-3.03.077.077 0 0 0 .032-.054c.5-5.177-.838-9.674-3.549-13.66a.061.061 0 0 0-.031-.03zM8.02 15.33c-1.183 0-2.157-1.085-2.157-2.419 0-1.333.956-2.419 2.157-2.419 1.21 0 2.176 1.096 2.157 2.42 0 1.333-.956 2.418-2.157 2.418zm7.975 0c-1.183 0-2.157-1.085-2.157-2.419 0-1.333.955-2.419 2.157-2.419 1.21 0 2.176 1.096 2.157 2.42 0 1.333-.946 2.418-2.157 2.418z"
  end

  defp provider_path(:linkedin) do
    "M20.447 20.452h-3.554v-5.569c0-1.328-.027-3.037-1.852-3.037-1.853 0-2.136 1.445-2.136 2.939v5.667H9.351V9h3.414v1.561h.046c.477-.9 1.637-1.85 3.37-1.85 3.601 0 4.267 2.37 4.267 5.455v6.286zM5.337 7.433a2.062 2.062 0 0 1-2.063-2.065 2.064 2.064 0 1 1 2.063 2.065zm1.782 13.019H3.555V9h3.564v11.452zM22.225 0H1.771C.792 0 0 .774 0 1.729v20.542C0 23.227.792 24 1.771 24h20.451C23.2 24 24 23.227 24 22.271V1.729C24 .774 23.2 0 22.222 0h.003z"
  end

  defp provider_path(:microsoft) do
    "M11.4 24H0V12.6h11.4V24zM24 24H12.6V12.6H24V24zM11.4 11.4H0V0h11.4v11.4zM24 11.4H12.6V0H24v11.4z"
  end

  defp provider_path(:slack) do
    "M5.042 15.165a2.528 2.528 0 0 1-2.52 2.523A2.528 2.528 0 0 1 0 15.165a2.527 2.527 0 0 1 2.522-2.52h2.52v2.52zM6.313 15.165a2.527 2.527 0 0 1 2.521-2.52 2.527 2.527 0 0 1 2.521 2.52v6.313A2.528 2.528 0 0 1 8.834 24a2.528 2.528 0 0 1-2.521-2.522v-6.313zM8.834 5.042a2.528 2.528 0 0 1-2.521-2.52A2.528 2.528 0 0 1 8.834 0a2.528 2.528 0 0 1 2.521 2.522v2.52H8.834zM8.834 6.313a2.528 2.528 0 0 1 2.521 2.521 2.528 2.528 0 0 1-2.521 2.521H2.522A2.528 2.528 0 0 1 0 8.834a2.528 2.528 0 0 1 2.522-2.521h6.312zM18.956 8.834a2.528 2.528 0 0 1 2.522-2.521A2.528 2.528 0 0 1 24 8.834a2.528 2.528 0 0 1-2.522 2.521h-2.522V8.834zM17.688 8.834a2.528 2.528 0 0 1-2.523 2.521 2.527 2.527 0 0 1-2.52-2.521V2.522A2.527 2.527 0 0 1 15.165 0a2.528 2.528 0 0 1 2.523 2.522v6.312zM15.165 18.956a2.528 2.528 0 0 1 2.523 2.522A2.528 2.528 0 0 1 15.165 24a2.527 2.527 0 0 1-2.52-2.522v-2.522h2.52zM15.165 17.688a2.527 2.527 0 0 1-2.52-2.523 2.526 2.526 0 0 1 2.52-2.52h6.313A2.527 2.527 0 0 1 24 15.165a2.528 2.528 0 0 1-2.522 2.523h-6.313z"
  end

  defp provider_path(:custom), do: ""
end
