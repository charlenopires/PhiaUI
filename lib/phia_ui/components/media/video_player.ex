defmodule PhiaUi.Components.VideoPlayer do
  @moduledoc """
  HTML5 video player with custom controls and aspect ratio support.

  Uses the `PhiaVideoPlayer` JS hook for play/pause, progress bar, volume,
  fullscreen, and time display. Pattern follows `audio_player.ex`.

  ## Aspect ratios

  | Ratio       | CSS class            |
  |-------------|----------------------|
  | `:video`    | `aspect-video` (16:9)|
  | `:square`   | `aspect-square`      |
  | `:portrait` | `aspect-[9/16]`      |
  | `:auto`     | none (intrinsic)     |

  ## Examples

      <.video_player id="demo" src="/videos/demo.mp4" />
      <.video_player id="hero" src="/videos/hero.mp4" poster="/images/poster.jpg" aspect_ratio={:video} />
      <.video_player id="reel" src="/videos/reel.mp4" aspect_ratio={:portrait} muted autoplay loop />
  """

  use Phoenix.Component
  import PhiaUi.ClassMerger, only: [cn: 1]

  attr :id, :string, required: true, doc: "Unique HTML id required by the JS hook"
  attr :src, :string, required: true, doc: "Video source URL"
  attr :poster, :string, default: nil, doc: "Poster image URL"
  attr :type, :string, default: "video/mp4", doc: "Video MIME type"
  attr :aspect_ratio, :atom, values: [:video, :square, :portrait, :auto], default: :video
  attr :controls, :boolean, default: true, doc: "Show custom controls"
  attr :autoplay, :boolean, default: false
  attr :muted, :boolean, default: false
  attr :loop, :boolean, default: false
  attr :preload, :atom, values: [:none, :metadata, :auto], default: :metadata
  attr :class, :string, default: nil
  attr :rest, :global

  @doc """
  Renders a video player component.

  The component is wired to the `PhiaVideoPlayer` LiveView hook via `phx-hook`.
  The hook manages play/pause toggling, progress seeking, volume control,
  fullscreen, and timestamp display.

  ## Examples

      <.video_player id="demo" src="/videos/demo.mp4" />

      <.video_player
        id="hero"
        src="/videos/hero.mp4"
        poster="/images/poster.jpg"
        aspect_ratio={:video}
      />
  """
  def video_player(assigns) do
    ~H"""
    <div
      id={@id}
      phx-hook="PhiaVideoPlayer"
      class={cn([
        "group relative overflow-hidden rounded-lg bg-black",
        aspect_class(@aspect_ratio),
        @class
      ])}
      data-autoplay={to_string(@autoplay)}
      data-muted={to_string(@muted)}
      {@rest}
    >
      <video
        data-video
        class="h-full w-full object-contain"
        poster={@poster}
        preload={to_string(@preload)}
        loop={@loop}
        muted={@muted}
        playsinline
      >
        <source src={@src} type={@type} />
      </video>

      <%= if @controls do %>
        <%!-- Play overlay (center) --%>
        <button
          type="button"
          data-play-overlay
          aria-label="Play video"
          class={cn([
            "absolute inset-0 flex items-center justify-center",
            "bg-black/30 transition-opacity",
            "group-[.playing]:opacity-0 group-[.playing]:pointer-events-none"
          ])}
        >
          <span class="flex h-16 w-16 items-center justify-center rounded-full bg-white/90 text-foreground shadow-lg transition-transform hover:scale-110">
            <svg class="h-6 w-6 ml-1" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">
              <path d="M8 5v14l11-7z" />
            </svg>
          </span>
        </button>

        <%!-- Bottom controls bar --%>
        <div
          data-controls
          class={cn([
            "absolute inset-x-0 bottom-0 flex items-center gap-2 bg-gradient-to-t from-black/60 to-transparent px-3 pb-3 pt-8",
            "transition-opacity",
            "group-[.playing]:opacity-0 group-[.playing]:hover:opacity-100"
          ])}
        >
          <%!-- Play/Pause --%>
          <button type="button" data-play-btn aria-label="Play" class="shrink-0 text-white hover:text-white/80 transition-colors">
            <svg data-icon-play class="h-5 w-5" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">
              <path d="M8 5v14l11-7z" />
            </svg>
            <svg data-icon-pause class="hidden h-5 w-5" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">
              <path d="M6 4h4v16H6V4zm8 0h4v16h-4V4z" />
            </svg>
          </button>

          <%!-- Time --%>
          <span data-time class="shrink-0 text-xs font-mono text-white/80">0:00</span>

          <%!-- Progress --%>
          <div data-progress-bar class="relative flex-1 cursor-pointer group/progress">
            <div class="h-1 rounded-full bg-white/30">
              <div data-progress-fill class="h-full rounded-full bg-white transition-all" style="width: 0%" />
            </div>
          </div>

          <%!-- Duration --%>
          <span data-duration class="shrink-0 text-xs font-mono text-white/80">0:00</span>

          <%!-- Volume --%>
          <button type="button" data-mute-btn aria-label="Mute" class="shrink-0 text-white hover:text-white/80 transition-colors">
            <svg data-icon-volume class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true">
              <polygon points="11 5 6 9 2 9 2 15 6 15 11 19 11 5" />
              <path d="M15.54 8.46a5 5 0 0 1 0 7.07" />
              <path d="M19.07 4.93a10 10 0 0 1 0 14.14" />
            </svg>
            <svg data-icon-muted class="hidden h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true">
              <polygon points="11 5 6 9 2 9 2 15 6 15 11 19 11 5" />
              <line x1="23" y1="9" x2="17" y2="15" />
              <line x1="17" y1="9" x2="23" y2="15" />
            </svg>
          </button>

          <%!-- Fullscreen --%>
          <button type="button" data-fullscreen-btn aria-label="Fullscreen" class="shrink-0 text-white hover:text-white/80 transition-colors">
            <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true">
              <path d="M8 3H5a2 2 0 00-2 2v3m18 0V5a2 2 0 00-2-2h-3m0 18h3a2 2 0 002-2v-3M3 16v3a2 2 0 002 2h3" />
            </svg>
          </button>
        </div>
      <% end %>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  defp aspect_class(:video), do: "aspect-video"
  defp aspect_class(:square), do: "aspect-square"
  defp aspect_class(:portrait), do: "aspect-[9/16]"
  defp aspect_class(:auto), do: nil
end
