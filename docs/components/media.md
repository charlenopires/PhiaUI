# Media

Audio playback, image carousels, and server-side QR code generation.

## Table of Contents

- [audio_player](#audio_player)
- [carousel](#carousel)
- [qr_code](#qr_code)

---

## audio_player

HTML5 audio player with play/pause, scrubber, time display, and volume control. All state is managed by the `PhiaAudioPlayer` hook.

**Hook**: `PhiaAudioPlayer`
**Attrs**: `id`, `src` (audio URL), `title`, `cover_url`

```heex
<%!-- Basic audio player --%>
<.audio_player
  id="podcast-player"
  src={@episode.audio_url}
  title={@episode.title}
/>

<%!-- With cover art --%>
<.audio_player
  id="track-player"
  src={@track.url}
  title={@track.name}
  cover_url={@track.cover_art}
/>

<%!-- Playlist of audio players --%>
<div class="space-y-3">
  <.audio_player
    :for={ep <- @episodes}
    id={"episode-#{ep.id}"}
    src={ep.audio_url}
    title={ep.title}
    cover_url={ep.cover_url}
  />
</div>
```

```javascript
// app.js
import PhiaAudioPlayer from "./phia_hooks/audio_player"
// hooks: { PhiaAudioPlayer }
```

### Use cases

- Podcast episode lists
- Music streaming interfaces
- Audio message playback in chat
- Voice memo previews

---

## carousel

Touch-swipe, keyboard-navigable, looping image/content carousel.

**Hook**: `PhiaCarousel`
**Sub-components**: `carousel_content/1`, `carousel_item/1`, `carousel_previous/1`, `carousel_next/1`
**Attrs**: `id`, `loop` (bool), `orientation` (horizontal/vertical)

```heex
<%!-- Image carousel --%>
<.carousel id="product-images" loop={true}>
  <.carousel_content>
    <.carousel_item :for={img <- @product_images}>
      <.aspect_ratio ratio="4/3" class="overflow-hidden rounded-lg">
        <img src={img.url} alt={img.alt} class="object-cover w-full h-full" />
      </.aspect_ratio>
    </.carousel_item>
  </.carousel_content>
  <.carousel_previous />
  <.carousel_next />
</.carousel>

<%!-- Card carousel --%>
<.carousel id="featured-posts" class="w-full">
  <.carousel_content class="-ml-4">
    <.carousel_item :for={post <- @featured_posts} class="pl-4 basis-1/3">
      <.card>
        <.card_header>
          <.card_title><%= post.title %></.card_title>
        </.card_header>
        <.card_content>
          <p class="text-sm text-muted-foreground"><%= post.excerpt %></p>
        </.card_content>
      </.card>
    </.carousel_item>
  </.carousel_content>
  <.carousel_previous />
  <.carousel_next />
</.carousel>

<%!-- Testimonials --%>
<.carousel id="testimonials" loop={true} class="max-w-2xl mx-auto">
  <.carousel_content>
    <.carousel_item :for={t <- @testimonials}>
      <.card class="text-center p-8">
        <blockquote class="text-lg italic">"<%= t.quote %>"</blockquote>
        <div class="mt-4 flex items-center justify-center gap-3">
          <.avatar size="sm"><.avatar_fallback name={t.author} /></.avatar>
          <div>
            <p class="font-medium text-sm"><%= t.author %></p>
            <p class="text-xs text-muted-foreground"><%= t.role %></p>
          </div>
        </div>
      </.card>
    </.carousel_item>
  </.carousel_content>
  <.carousel_previous />
  <.carousel_next />
</.carousel>
```

```javascript
// app.js
import PhiaCarousel from "./phia_hooks/carousel"
// hooks: { PhiaCarousel }
```

---

## qr_code

Server-side SVG QR code generation using `eqrcode`. No JavaScript required.

**Attrs**: `value` (string to encode), `size` (pixel width, default 200), `class`

> **Dependency**: `eqrcode` is included as a transitive dependency via PhiaUI. No extra setup needed.

```heex
<%!-- URL QR code --%>
<.qr_code value="https://phiaui.dev" />

<%!-- Custom size --%>
<.qr_code value={@share_url} size={300} class="mx-auto" />

<%!-- With label --%>
<div class="flex flex-col items-center gap-2">
  <.qr_code value={@wifi_password} size={180} />
  <p class="text-xs text-muted-foreground">Scan to connect to WiFi</p>
</div>

<%!-- In a modal for sharing --%>
<.dialog id="share-qr">
  <:trigger>
    <.button variant="outline" size="sm">
      <.icon name="qr-code" size="sm" /> Share via QR
    </.button>
  </:trigger>
  <.dialog_content>
    <.dialog_header>
      <.dialog_title>Scan to Share</.dialog_title>
    </.dialog_header>
    <div class="flex justify-center py-4">
      <.qr_code value={@current_url} size={240} />
    </div>
  </.dialog_content>
</.dialog>

<%!-- For payment or crypto --%>
<.card class="w-fit mx-auto">
  <.card_header>
    <.card_title>Pay with Bitcoin</.card_title>
  </.card_header>
  <.card_content class="flex flex-col items-center gap-3">
    <.qr_code value={@btc_address} size={200} />
    <div class="flex items-center gap-2">
      <code class="text-xs bg-muted px-2 py-1 rounded truncate max-w-48"><%= @btc_address %></code>
      <.copy_button value={@btc_address} />
    </div>
  </.card_content>
</.card>
```

### Use cases

- WiFi credentials sharing
- Payment addresses (crypto, Pix, etc.)
- Contact cards / vCards
- Event check-in codes
- Share URLs on mobile
- 2FA enrollment (TOTP secrets)

← [Back to README](../../README.md)
