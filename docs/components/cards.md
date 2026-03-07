# Cards

22 card components — base card, KPI metrics, article previews, profiles, pricing, products, receipts, and event/team cards.

**Module**: `PhiaUi.Components.Cards`

```elixir
import PhiaUi.Components.Cards
```

---

## Table of Contents

**Base**
- [card](#card)
- [selectable_card](#selectable_card)

**Analytics**
- [stat_card](#stat_card)
- [metric_grid](#metric_grid)
- [sparkline_card](#sparkline_card)
- [receipt_card](#receipt_card)

**Content Cards**
- [article_card](#article_card)
- [feature_card](#feature_card)
- [image_card](#image_card)
- [profile_card](#profile_card)
- [team_card](#team_card)
- [link_preview_card](#link_preview_card)

**E-Commerce**
- [product_card](#product_card)
- [pricing_card](#pricing_card)
- [color_swatch_card](#color_swatch_card)
- [cta_card](#cta_card)

**Status & Feedback**
- [testimonial_card](#testimonial_card)
- [progress_card](#progress_card)
- [notification_card](#notification_card)
- [file_card](#file_card)
- [event_card](#event_card)

---

## card

Base card container. Used by all card variants and as a standalone wrapper.

**Sub-components**: `card_header`, `card_title`, `card_description`, `card_content`, `card_footer`

```heex
<.card>
  <.card_header>
    <.card_title>Team members</.card_title>
    <.card_description>Invite and manage your team.</.card_description>
  </.card_header>
  <.card_content>
    <.table rows={@members}>…</.table>
  </.card_content>
  <.card_footer>
    <.button variant="outline">View all</.button>
  </.card_footer>
</.card>
```

---

## selectable_card

Card that toggles selected state — use for plan/option pickers.

```heex
<div class="grid grid-cols-3 gap-4">
  <%= for plan <- @plans do %>
    <.selectable_card
      value={plan.id}
      selected={@selected_plan == plan.id}
      phx-click="select_plan"
      phx-value-id={plan.id}
    >
      <.heading level={4}><%= plan.name %></.heading>
      <.display_text class="mt-1">$<%= plan.price %></.display_text>
      <ul class="mt-3 space-y-1 text-sm text-muted-foreground">
        <%= for feature <- plan.features do %>
          <li class="flex gap-2">
            <.icon name="check" size="sm" class="text-primary" />
            <%= feature %>
          </li>
        <% end %>
      </ul>
    </.selectable_card>
  <% end %>
</div>
```

---

## stat_card

KPI metric card with value, delta, sparkline, and optional link.

```heex
<.stat_card
  title="Monthly Revenue"
  value="$24,500"
  delta="+12.5%"
  delta_type={:increase}
  sparkline_data={[18000, 19500, 21000, 22500, 23000, 24500]}
  href="/analytics/revenue"
/>
```

**Attrs**: `title`, `value`, `delta`, `delta_type` (`:increase` | `:decrease` | `:neutral`), `sparkline_data` (list of numbers), `href`, `icon`

---

## metric_grid

Responsive grid of stat cards.

```heex
<.metric_grid>
  <.stat_card title="MRR" value="$24,500" delta="+12%" delta_type={:increase}
    sparkline_data={@mrr_data} />
  <.stat_card title="Active Users" value="18,423" delta="+5.2%" delta_type={:increase}
    sparkline_data={@user_data} />
  <.stat_card title="Churn Rate" value="2.1%" delta="-0.3%" delta_type={:decrease}
    sparkline_data={@churn_data} />
  <.stat_card title="NPS Score" value="72" delta="+4" delta_type={:increase} />
</.metric_grid>
```

**Attrs**: `cols` (integer, default 4), `class`

---

## sparkline_card

Small chart embedded inside a metric card.

```heex
<.sparkline_card
  title="API Requests"
  value="1.2M"
  data={[800, 950, 1100, 980, 1050, 1200]}
  trend={:up}
  animate={true}
/>
```

**Attrs**: `title`, `value`, `data` (list of numbers), `trend` (`:up` | `:down` | `:flat`), `animate`, `height`

---

## receipt_card

Financial receipt / invoice breakdown.

```heex
<.receipt_card
  title="Invoice #1042"
  date={~D[2025-03-01]}
  items={[
    %{label: "Pro plan (annual)", amount: "$290.00"},
    %{label: "Extra seats × 3", amount: "$90.00"}
  ]}
  subtotal="$380.00"
  tax="$34.20"
  total="$414.20"
  currency="USD"
/>
```

---

## article_card

Blog post / article preview card with cover image, category, meta, and excerpt.

```heex
<.article_card
  title={@post.title}
  excerpt={@post.excerpt}
  cover_src={@post.cover_url}
  category="Engineering"
  read_time="5 min read"
  date={@post.published_at}
  author_name={@post.author.name}
  author_avatar={@post.author.avatar_url}
  href={~p"/blog/#{@post.slug}"}
/>
```

---

## feature_card

Icon + title + description card for landing pages.

```heex
<.feature_card
  icon="zap"
  title="Fast by default"
  description="Server-rendered components with Tailwind JIT — no bundle overhead."
/>
```

---

## image_card

Image-first card with optional overlay text.

```heex
<.image_card
  src={@project.hero_url}
  alt={@project.title}
  title={@project.title}
  subtitle={@project.category}
  href={~p"/projects/#{@project.id}"}
/>
```

---

## profile_card

User profile summary card.

```heex
<.profile_card
  name={@user.name}
  title={@user.job_title}
  company={@user.company}
  avatar_src={@user.avatar_url}
  bio={@user.bio}
  location={@user.location}
  href={~p"/users/#{@user.id}"}
/>
```

---

## team_card

Team member card with avatar, role, and social links.

```heex
<.team_card
  name={@member.name}
  role={@member.role}
  avatar_src={@member.photo_url}
  twitter={@member.twitter}
  linkedin={@member.linkedin}
  github={@member.github}
/>
```

---

## link_preview_card

Open Graph link preview card.

```heex
<.link_preview_card
  url="https://hex.pm/packages/phia_ui"
  title="phia_ui"
  description="Enterprise-ready Phoenix LiveView component library."
  image_src="/og/phia_ui.png"
  site_name="Hex.pm"
/>
```

---

## product_card

E-commerce product listing card.

```heex
<.product_card
  name={product.name}
  price={product.price}
  compare_price={product.compare_price}
  image_src={product.image_url}
  badge="Sale"
  rating={product.avg_rating}
  review_count={product.review_count}
  on_add_to_cart="add_to_cart"
  product_id={product.id}
/>
```

---

## pricing_card

Subscription pricing card with features list.

```heex
<.pricing_card
  name="Pro"
  price="$29"
  period="/month"
  description="For growing teams."
  highlighted={true}
  badge="Most popular"
  features={["Unlimited projects", "20 team members", "Priority support", "Advanced analytics"]}
  cta_label="Start free trial"
  phx-click="select_pro"
/>
```

---

## color_swatch_card

Colour palette entry with hex value and copy button.

```heex
<.color_swatch_card
  name="Indigo 500"
  hex="#6366f1"
  rgb="99, 102, 241"
/>
```

---

## cta_card

Call-to-action card with title, description, and button.

```heex
<.cta_card
  title="Upgrade to Pro"
  description="Get unlimited access to all components and priority support."
  cta_label="Upgrade now"
  phx-click="start_upgrade"
  variant={:primary}
/>
```

---

## testimonial_card

Customer testimonial with quote, name, role, and avatar.

```heex
<.testimonial_card
  quote="PhiaUI cut our frontend development time in half."
  name="Sarah Johnson"
  role="CTO at Acme Corp"
  avatar_src="/testimonials/sarah.jpg"
  rating={5}
/>
```

---

## progress_card

Card with a progress bar showing task or goal completion.

```heex
<.progress_card
  title="Q1 Revenue Goal"
  value={73}
  label="$73K of $100K"
  target_date={~D[2025-03-31]}
  delta="+8% vs last quarter"
/>
```

---

## notification_card

Notification item as a standalone card.

```heex
<.notification_card
  icon="bell"
  title="New message"
  body="You have a new message from Alice."
  timestamp={DateTime.utc_now() |> DateTime.add(-300, :second)}
  read={false}
  phx-click="mark_read"
  phx-value-id={@notification.id}
/>
```

---

## file_card

File attachment preview card with icon, name, size, and download.

```heex
<.file_card
  filename="report-q1-2025.pdf"
  size="2.4 MB"
  mime="application/pdf"
  download_url={~p"/files/#{@file.id}/download"}
  uploaded_by={@file.uploader.name}
  uploaded_at={@file.inserted_at}
/>
```

---

## event_card

Event listing card with date, title, location, and RSVP.

```heex
<.event_card
  title="ElixirConf 2025"
  date={~D[2025-08-15]}
  location="Austin, TX"
  image_src="/events/elixirconf.jpg"
  attendee_count={450}
  href="https://elixirconf.com"
  status={:upcoming}
/>
```

---

## Real-world: Dashboard KPI section

```heex
<section class="space-y-6">
  <.page_header title="Overview" description="Key metrics for March 2025" />

  <.metric_grid>
    <.stat_card
      title="Monthly Revenue"
      value="$24,500"
      delta="+12.5%"
      delta_type={:increase}
      sparkline_data={@mrr_history}
      href="/revenue"
    />
    <.stat_card
      title="Active Users"
      value={number_format(@active_users, compact: true)}
      delta="+5.2%"
      delta_type={:increase}
      sparkline_data={@user_history}
    />
    <.stat_card
      title="Churn Rate"
      value="2.1%"
      delta="-0.3%"
      delta_type={:decrease}
      sparkline_data={@churn_history}
    />
    <.stat_card
      title="NPS Score"
      value="72"
      delta="+4"
      delta_type={:increase}
    />
  </.metric_grid>
</section>
```
