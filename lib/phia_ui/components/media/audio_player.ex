defmodule PhiaUi.Components.AudioPlayer do
  @moduledoc """
  AudioPlayer component for playing audio with play/pause, progress bar and timestamp.

  Used for voice notes, audio messages, and media playback. The `PhiaAudioPlayer`
  JS hook handles all playback logic — the component renders a static, accessible
  shell that is enhanced client-side.

  ## Variants

  | Variant     | Description                               |
  |-------------|-------------------------------------------|
  | `:default`  | Full-width player with waveform track     |
  | `:compact`  | Condensed single-line layout              |

  ## Examples

      <%!-- Basic player --%>
      <.audio_player id="vn-1" src="/uploads/voice.mp3" />

      <%!-- With known duration --%>
      <.audio_player id="vn-2" src="/uploads/voice.mp3" duration={45} />

      <%!-- Compact variant --%>
      <.audio_player id="vn-3" src="/uploads/voice.mp3" variant={:compact} />

      <%!-- With label --%>
      <.audio_player id="vn-4" src="/uploads/voice.mp3" label="Voice note" />
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  attr(:id, :string, required: true, doc: "Unique HTML id — required by the JS hook")

  attr(:src, :string, required: true, doc: "URL of the audio file")

  attr(:duration, :integer,
    default: 0,
    doc: "Known duration in seconds. Displayed as MM:SS before playback starts."
  )

  attr(:variant, :atom,
    values: [:default, :compact],
    default: :default,
    doc: "Visual style — :default (full) or :compact (single-line)"
  )

  attr(:label, :string, default: nil, doc: "Optional label rendered above the player")

  attr(:autoplay, :boolean, default: false, doc: "Auto-start playback on mount")

  attr(:class, :string, default: nil, doc: "Additional CSS classes merged via cn/1")

  attr(:rest, :global, doc: "HTML attributes forwarded to the root element")

  @doc """
  Renders an audio player component.

  The component is wired to the `PhiaAudioPlayer` LiveView hook via `phx-hook`.
  The hook manages play/pause toggling, progress updates, and timestamp display.

  ## Examples

      <.audio_player id="msg-audio" src={@message.audio_url} duration={@message.duration} />

      <.audio_player
        id="voice-note"
        src="/uploads/note.mp3"
        variant={:compact}
        label="Recording 1"
      />
  """
  def audio_player(assigns) do
    ~H"""
    <div
      id={@id}
      phx-hook="PhiaAudioPlayer"
      data-src={@src}
      data-duration={@duration}
      data-autoplay={to_string(@autoplay)}
      class={cn([
        "flex flex-col gap-2",
        @variant == :compact && "compact",
        @class
      ])}
      {@rest}
    >
      <%= if @label do %>
        <span class="text-sm font-medium text-foreground">{@label}</span>
      <% end %>

      <div class={cn([
        "flex items-center gap-3",
        "rounded-lg border border-border bg-card p-3",
        @variant == :compact && "p-2"
      ])}>
        <%!-- Play / Pause button --%>
        <button
          type="button"
          data-play-btn
          aria-label="Play"
          class={cn([
            "shrink-0 flex items-center justify-center rounded-full",
            "bg-primary text-primary-foreground",
            "transition-colors hover:bg-primary/90",
            "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring",
            @variant == :compact && "h-8 w-8",
            @variant == :default && "h-10 w-10"
          ])}
        >
          <%!-- Play icon (shown by default) --%>
          <svg
            data-icon-play
            xmlns="http://www.w3.org/2000/svg"
            class="h-4 w-4"
            viewBox="0 0 24 24"
            fill="currentColor"
            aria-hidden="true"
          >
            <polygon points="5,3 19,12 5,21" />
          </svg>
          <%!-- Pause icon (hidden by default, shown when playing) --%>
          <svg
            data-icon-pause
            xmlns="http://www.w3.org/2000/svg"
            class="h-4 w-4 hidden"
            viewBox="0 0 24 24"
            fill="currentColor"
            aria-hidden="true"
          >
            <rect x="6" y="4" width="4" height="16" /><rect x="14" y="4" width="4" height="16" />
          </svg>
        </button>

        <%!-- Progress track + timestamp --%>
        <div class="flex-1 flex flex-col gap-1">
          <%!-- Track --%>
          <div
            data-track
            class="relative h-1.5 w-full rounded-full bg-secondary cursor-pointer"
          >
            <div
              data-progress
              class="absolute inset-y-0 left-0 rounded-full bg-primary transition-all"
              style="width: 0%"
            />
          </div>
          <%!-- Timestamp --%>
          <div class="flex justify-between">
            <span
              data-timestamp
              class="text-xs text-muted-foreground tabular-nums"
            >
              0:00
            </span>
            <span
              data-duration-display
              class="text-xs text-muted-foreground tabular-nums"
            >
              {format_duration(@duration)}
            </span>
          </div>
        </div>
      </div>

      <%!-- Native audio element (visually hidden, used by hook) --%>
      <audio
        data-audio
        src={@src}
        class="sr-only"
        preload="metadata"
      />
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  defp format_duration(0), do: "0:00"

  defp format_duration(seconds) when is_integer(seconds) and seconds > 0 do
    minutes = div(seconds, 60)
    secs = rem(seconds, 60)
    "#{minutes}:#{String.pad_leading(Integer.to_string(secs), 2, "0")}"
  end

  defp format_duration(_), do: "0:00"
end
