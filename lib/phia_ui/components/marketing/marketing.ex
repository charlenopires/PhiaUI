defmodule PhiaUi.Components.Marketing do
  @moduledoc """
  Marketing page section components.

  Provides reusable marketing page building blocks:

  - `pricing_table/1` — Tier comparison with optional billing toggle
  - `cta_section/1` — Full-width call-to-action banner
  - `newsletter_cta/1` — Email subscribe section
  - `logo_cloud/1` — Partner/client logo strip
  - `site_footer/1` — Website footer with link columns
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  # ---------------------------------------------------------------------------
  # 1. pricing_table/1
  # ---------------------------------------------------------------------------

  attr :title, :string, default: nil
  attr :description, :string, default: nil
  attr :columns, :integer, default: 3
  attr :class, :string, default: nil
  attr :rest, :global

  slot :toggle, doc: "Billing toggle (monthly/yearly switch)"
  slot :inner_block, required: true, doc: "Pricing tier cards"
  slot :footer, doc: "Footer content below tiers"

  @doc """
  Renders a pricing tier comparison layout.

  ## Examples

      <.pricing_table title="Pricing" description="Choose a plan." columns={3}>
        <div>Free Tier</div>
        <div>Pro Tier</div>
        <div>Enterprise Tier</div>
      </.pricing_table>
  """
  def pricing_table(assigns) do
    ~H"""
    <section class={cn(["w-full", @class])} {@rest}>
      <%= if @title || @description do %>
        <div class="mx-auto mb-10 max-w-2xl text-center">
          <%= if @title do %>
            <h2 class="text-3xl font-bold tracking-tight text-foreground sm:text-4xl">{@title}</h2>
          <% end %>
          <%= if @description do %>
            <p class="mt-4 text-lg text-muted-foreground">{@description}</p>
          <% end %>
        </div>
      <% end %>

      <%= for toggle <- @toggle do %>
        <div class="mb-8 flex justify-center">
          {render_slot(toggle)}
        </div>
      <% end %>

      <div class={cn(["grid gap-8 items-start", pricing_columns(@columns)])}>
        {render_slot(@inner_block)}
      </div>

      <%= for footer <- @footer do %>
        <div class="mt-12 text-center">
          {render_slot(footer)}
        </div>
      <% end %>
    </section>
    """
  end

  defp pricing_columns(1), do: "grid-cols-1 max-w-md mx-auto"
  defp pricing_columns(2), do: "grid-cols-1 md:grid-cols-2 max-w-4xl mx-auto"
  defp pricing_columns(3), do: "grid-cols-1 md:grid-cols-2 lg:grid-cols-3"
  defp pricing_columns(4), do: "grid-cols-1 md:grid-cols-2 lg:grid-cols-4"
  defp pricing_columns(_), do: "grid-cols-1 md:grid-cols-2 lg:grid-cols-3"

  # ---------------------------------------------------------------------------
  # 2. cta_section/1
  # ---------------------------------------------------------------------------

  attr :title, :string, required: true
  attr :description, :string, default: nil
  attr :variant, :atom, values: [:default, :filled, :gradient], default: :default
  attr :align, :atom, values: [:center, :start, :split], default: :center
  attr :class, :string, default: nil
  attr :rest, :global

  slot :actions, doc: "CTA buttons"
  slot :media, doc: "Optional media content (for split layout)"

  @doc """
  Renders a full-width call-to-action banner.

  ## Examples

      <.cta_section title="Ready to get started?">
        <:actions>
          <button>Sign Up Free</button>
        </:actions>
      </.cta_section>

      <.cta_section title="Join us" variant={:filled} description="Start today.">
        <:actions>
          <button>Get Started</button>
        </:actions>
      </.cta_section>
  """
  def cta_section(assigns) do
    ~H"""
    <section
      class={cn([
        "w-full rounded-xl px-6 py-16 sm:px-12 sm:py-20",
        cta_variant(@variant),
        @align == :split && "grid items-center gap-8 lg:grid-cols-2",
        @align != :split && "text-center",
        @class
      ])}
      {@rest}
    >
      <div class={cn([
        @align == :center && "mx-auto max-w-2xl",
        @align == :start && "max-w-xl"
      ])}>
        <h2 class={cn(["text-3xl font-bold tracking-tight sm:text-4xl", cta_text(@variant)])}>
          {@title}
        </h2>
        <%= if @description do %>
          <p class={cn(["mt-4 text-lg", cta_desc(@variant)])}>
            {@description}
          </p>
        <% end %>

        <%= for actions <- @actions do %>
          <div class={cn(["mt-8 flex flex-wrap gap-3", @align == :center && "justify-center"])}>
            {render_slot(actions)}
          </div>
        <% end %>
      </div>

      <%= for media <- @media do %>
        <div class="w-full">
          {render_slot(media)}
        </div>
      <% end %>
    </section>
    """
  end

  defp cta_variant(:default), do: "border border-border bg-card"
  defp cta_variant(:filled), do: "bg-primary"
  defp cta_variant(:gradient), do: "bg-gradient-to-br from-primary to-primary/60"

  defp cta_text(:default), do: "text-foreground"
  defp cta_text(:filled), do: "text-primary-foreground"
  defp cta_text(:gradient), do: "text-primary-foreground"

  defp cta_desc(:default), do: "text-muted-foreground"
  defp cta_desc(:filled), do: "text-primary-foreground/80"
  defp cta_desc(:gradient), do: "text-primary-foreground/80"

  # ---------------------------------------------------------------------------
  # 3. newsletter_cta/1
  # ---------------------------------------------------------------------------

  attr :title, :string, default: nil
  attr :description, :string, default: nil
  attr :placeholder, :string, default: "Enter your email"
  attr :button_label, :string, default: "Subscribe"
  attr :on_submit, :string, required: true, doc: "Phoenix event name for form submit"
  attr :input_name, :string, default: "email"
  attr :layout, :atom, values: [:stacked, :inline], default: :inline
  attr :class, :string, default: nil
  attr :rest, :global

  slot :disclaimer, doc: "Legal text below the form"

  @doc """
  Renders an email subscribe section with input and button.

  ## Examples

      <.newsletter_cta
        title="Stay updated"
        description="Get the latest news."
        on_submit="subscribe"
      />
  """
  def newsletter_cta(assigns) do
    ~H"""
    <section class={cn(["w-full", @class])} {@rest}>
      <%= if @title do %>
        <h3 class="text-2xl font-bold text-foreground">{@title}</h3>
      <% end %>
      <%= if @description do %>
        <p class="mt-2 text-muted-foreground">{@description}</p>
      <% end %>

      <form
        phx-submit={@on_submit}
        class={cn([
          "mt-4",
          @layout == :inline && "flex gap-2",
          @layout == :stacked && "flex flex-col gap-3 max-w-sm"
        ])}
      >
        <input
          type="email"
          name={@input_name}
          placeholder={@placeholder}
          required
          class={cn([
            "flex-1 rounded-md border border-input bg-background px-3 py-2 text-sm",
            "placeholder:text-muted-foreground",
            "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring"
          ])}
        />
        <button
          type="submit"
          class={cn([
            "shrink-0 rounded-md bg-primary px-4 py-2 text-sm font-medium text-primary-foreground",
            "hover:bg-primary/90 transition-colors",
            "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring"
          ])}
        >
          {@button_label}
        </button>
      </form>

      <%= for disclaimer <- @disclaimer do %>
        <p class="mt-3 text-xs text-muted-foreground">
          {render_slot(disclaimer)}
        </p>
      <% end %>
    </section>
    """
  end

  # ---------------------------------------------------------------------------
  # 4. logo_cloud/1
  # ---------------------------------------------------------------------------

  attr :title, :string, default: nil
  attr :layout, :atom, values: [:grid, :inline], default: :inline
  attr :columns, :integer, default: 5
  attr :grayscale, :boolean, default: false
  attr :class, :string, default: nil
  attr :rest, :global

  slot :inner_block, required: true, doc: "Logo images"

  @doc """
  Renders a partner/client logo strip.

  ## Examples

      <.logo_cloud title="Trusted by">
        <img src="/logos/acme.svg" alt="Acme" class="h-8" />
        <img src="/logos/globex.svg" alt="Globex" class="h-8" />
      </.logo_cloud>

      <.logo_cloud layout={:grid} columns={4} grayscale>
        <img src="/logos/a.svg" alt="A" />
        <img src="/logos/b.svg" alt="B" />
      </.logo_cloud>
  """
  def logo_cloud(assigns) do
    ~H"""
    <section class={cn(["w-full", @class])} {@rest}>
      <%= if @title do %>
        <p class="mb-8 text-center text-sm font-medium text-muted-foreground">{@title}</p>
      <% end %>

      <div class={cn([
        @layout == :inline && "flex flex-wrap items-center justify-center gap-8 sm:gap-12",
        @layout == :grid && "grid items-center justify-items-center gap-8 #{logo_columns(@columns)}",
        @grayscale && "grayscale opacity-60 hover:[&>*]:grayscale-0 hover:[&>*]:opacity-100 [&>*]:transition-all"
      ])}>
        {render_slot(@inner_block)}
      </div>
    </section>
    """
  end

  defp logo_columns(2), do: "grid-cols-2"
  defp logo_columns(3), do: "grid-cols-2 md:grid-cols-3"
  defp logo_columns(4), do: "grid-cols-2 md:grid-cols-4"
  defp logo_columns(5), do: "grid-cols-2 sm:grid-cols-3 md:grid-cols-5"
  defp logo_columns(6), do: "grid-cols-2 sm:grid-cols-3 md:grid-cols-6"
  defp logo_columns(_), do: "grid-cols-2 sm:grid-cols-3 md:grid-cols-5"

  # ---------------------------------------------------------------------------
  # 5. site_footer/1
  # ---------------------------------------------------------------------------

  attr :class, :string, default: nil
  attr :rest, :global

  slot :logo, doc: "Logo/brand area"

  slot :columns, doc: "Link columns" do
    attr :title, :string, required: true
  end

  slot :bottom, doc: "Bottom bar (copyright, legal links)"
  slot :social, doc: "Social media icons"

  @doc """
  Renders a website footer with link columns, logo, copyright, and social icons.

  ## Examples

      <.site_footer>
        <:logo>
          <img src="/logo.svg" alt="Acme" class="h-8" />
        </:logo>
        <:columns title="Product">
          <a href="/features">Features</a>
          <a href="/pricing">Pricing</a>
        </:columns>
        <:columns title="Company">
          <a href="/about">About</a>
          <a href="/blog">Blog</a>
        </:columns>
        <:social>
          <a href="https://twitter.com">Twitter</a>
        </:social>
        <:bottom>
          <p>2026 Acme Inc. All rights reserved.</p>
        </:bottom>
      </.site_footer>
  """
  def site_footer(assigns) do
    ~H"""
    <footer class={cn(["w-full border-t border-border", @class])} {@rest}>
      <div class="py-12">
        <div class="grid gap-8 lg:grid-cols-[1fr_2fr]">
          <%!-- Brand column --%>
          <div class="flex flex-col gap-4">
            <%= for logo <- @logo do %>
              <div>{render_slot(logo)}</div>
            <% end %>
            <%= for social <- @social do %>
              <div class="flex items-center gap-3">
                {render_slot(social)}
              </div>
            <% end %>
          </div>

          <%!-- Link columns --%>
          <%= if @columns != [] do %>
            <div class={cn(["grid gap-8", footer_columns(length(@columns))])}>
              <%= for col <- @columns do %>
                <div>
                  <h4 class="text-sm font-semibold text-foreground">{col.title}</h4>
                  <div class="mt-4 flex flex-col gap-3 text-sm text-muted-foreground">
                    {render_slot(col)}
                  </div>
                </div>
              <% end %>
            </div>
          <% end %>
        </div>
      </div>

      <%!-- Bottom bar --%>
      <%= for bottom <- @bottom do %>
        <div class="border-t border-border py-6 text-sm text-muted-foreground">
          {render_slot(bottom)}
        </div>
      <% end %>
    </footer>
    """
  end

  defp footer_columns(1), do: "grid-cols-1"
  defp footer_columns(2), do: "grid-cols-2"
  defp footer_columns(3), do: "grid-cols-2 md:grid-cols-3"
  defp footer_columns(4), do: "grid-cols-2 md:grid-cols-4"
  defp footer_columns(5), do: "grid-cols-2 md:grid-cols-3 lg:grid-cols-5"
  defp footer_columns(_), do: "grid-cols-2 md:grid-cols-3"
end
