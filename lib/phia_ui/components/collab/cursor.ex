defmodule PhiaUi.Components.Collab.Cursor do
  @moduledoc """
  Collaborative cursor and selection components for real-time multiplayer UIs.

  Renders remote user cursors, text selections, and inline micro-chat bubbles
  over a shared editor or canvas area. The cursor overlay uses the
  `PhiaCollabCursors` JS hook for pointer tracking and idle detection, while
  the cursor chat uses `PhiaCollabCursorChat` for inline messaging.

  ## Components

  | Component                 | Purpose                                           |
  |---------------------------|---------------------------------------------------|
  | `collab_cursor/1`         | Single SVG cursor arrow with user name label      |
  | `collab_cursors_overlay/1`| Container positioning multiple cursors over content|
  | `collab_selection/1`      | Colored rectangle showing another user's selection |
  | `collab_cursor_chat/1`    | Cursor with Figma-style inline micro-chat bubble  |

  ## Cursor map shape

  The `collab_cursors_overlay` component accepts a list of cursor maps:

      %{
        id: "cursor-user-1",
        user_name: "Alice",
        color: "#3B82F6",
        x: 120,
        y: 340,
        idle: false
      }
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  # ---------------------------------------------------------------------------
  # collab_cursor/1
  # ---------------------------------------------------------------------------

  attr :id, :string, required: true
  attr :user_name, :string, required: true
  attr :color, :string, required: true
  attr :x, :any, default: 0
  attr :y, :any, default: 0
  attr :idle, :boolean, default: false
  attr :class, :string, default: nil

  @doc """
  Renders a single collaborative cursor with an SVG arrow and a name label.

  The cursor is absolutely positioned at the given `x`/`y` coordinates within
  its parent container. When `idle` is true, the cursor fades to reduced opacity.

  ## Example

      <.collab_cursor
        id="cursor-alice"
        user_name="Alice"
        color="#3B82F6"
        x={120}
        y={340}
      />
  """
  def collab_cursor(assigns) do
    ~H"""
    <div
      id={@id}
      data-cursor-id={@id}
      class={cn([
        "pointer-events-none absolute left-0 top-0 z-50 transition-opacity duration-300",
        if(@idle, do: "opacity-30", else: "opacity-100"),
        @class
      ])}
      style={"transform: translate(#{@x}px, #{@y}px)"}
      aria-hidden="true"
    >
      <svg
        width="16"
        height="20"
        viewBox="0 0 16 20"
        fill="none"
        xmlns="http://www.w3.org/2000/svg"
        class="drop-shadow-sm"
      >
        <path
          d="M0.928711 0.27832L15.0713 10.5547L7.58422 10.9365L3.97266 18.7949L0.928711 0.27832Z"
          fill={@color}
        />
        <path
          d="M0.928711 0.27832L15.0713 10.5547L7.58422 10.9365L3.97266 18.7949L0.928711 0.27832Z"
          stroke="white"
          stroke-width="1.2"
          stroke-linejoin="round"
        />
      </svg>
      <span
        class="ml-3 -mt-1 inline-block max-w-32 truncate rounded px-1.5 py-0.5 text-xs font-medium text-white shadow-sm"
        style={"background-color: #{@color}"}
      >
        {@user_name}
      </span>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # collab_cursors_overlay/1
  # ---------------------------------------------------------------------------

  attr :id, :string, required: true
  attr :cursors, :list, default: []
  attr :class, :string, default: nil

  @doc """
  Renders a transparent overlay container that positions multiple collaborative
  cursors over editor or canvas content.

  Uses the `PhiaCollabCursors` JS hook to track local pointer movements,
  push cursor positions to the server, and apply received remote cursor
  positions via DOM transforms.

  ## Example

      <.collab_cursors_overlay
        id="editor-cursors"
        cursors={@remote_cursors}
      >
        <div>Your editor content here</div>
      </.collab_cursors_overlay>
  """
  def collab_cursors_overlay(assigns) do
    ~H"""
    <div
      id={@id}
      phx-hook="PhiaCollabCursors"
      class={cn(["relative", @class])}
    >
      <div class="pointer-events-none absolute inset-0 z-40 overflow-hidden">
        <.collab_cursor
          :for={cursor <- @cursors}
          id={Map.get(cursor, :id, "cursor-unknown")}
          user_name={Map.get(cursor, :user_name, "Unknown")}
          color={Map.get(cursor, :color, "#6B7280")}
          x={Map.get(cursor, :x, 0)}
          y={Map.get(cursor, :y, 0)}
          idle={Map.get(cursor, :idle, false)}
        />
      </div>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # collab_selection/1
  # ---------------------------------------------------------------------------

  attr :id, :string, required: true
  attr :color, :string, required: true
  attr :user_name, :string, required: true
  attr :top, :any, default: 0
  attr :left, :any, default: 0
  attr :width, :any, default: 0
  attr :height, :any, default: 0
  attr :class, :string, default: nil

  @doc """
  Renders a semi-transparent colored rectangle representing another user's
  text selection in a collaborative editor.

  The selection is absolutely positioned within its parent container. A small
  user name label appears at the top-left corner of the selection region.

  ## Example

      <.collab_selection
        id="sel-alice"
        color="#3B82F6"
        user_name="Alice"
        top={80}
        left={24}
        width={200}
        height={20}
      />
  """
  def collab_selection(assigns) do
    ~H"""
    <div
      id={@id}
      class={cn([
        "pointer-events-none absolute z-30",
        @class
      ])}
      style={"top: #{@top}px; left: #{@left}px; width: #{@width}px; height: #{@height}px; background-color: #{@color}33;"}
      aria-hidden="true"
    >
      <span
        class="absolute -top-5 left-0 inline-block truncate rounded px-1 py-0.5 text-[10px] font-medium text-white shadow-sm"
        style={"background-color: #{@color}"}
      >
        {@user_name}
      </span>
      <div
        class="absolute left-0 top-0 h-full w-0.5"
        style={"background-color: #{@color}"}
      />
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # collab_cursor_chat/1
  # ---------------------------------------------------------------------------

  attr :id, :string, required: true
  attr :user_name, :string, required: true
  attr :color, :string, required: true
  attr :x, :any, default: 0
  attr :y, :any, default: 0
  attr :message, :string, default: nil
  attr :show_input, :boolean, default: false
  attr :class, :string, default: nil

  @doc """
  Renders a collaborative cursor with an optional Figma-style micro-chat bubble.

  When `message` is set, displays a chat bubble below the cursor with the
  message text. When `show_input` is true, renders a small text input for
  composing a micro-chat message. Uses the `PhiaCollabCursorChat` JS hook
  for keyboard shortcuts (/ to open, Enter to send, Escape to dismiss).

  ## Example

      <.collab_cursor_chat
        id="chat-cursor-alice"
        user_name="Alice"
        color="#3B82F6"
        x={200}
        y={150}
        message="Hey, check this out!"
      />
  """
  def collab_cursor_chat(assigns) do
    ~H"""
    <div
      id={@id}
      phx-hook="PhiaCollabCursorChat"
      class={cn([
        "pointer-events-none absolute left-0 top-0 z-50",
        @class
      ])}
      style={"transform: translate(#{@x}px, #{@y}px)"}
    >
      <svg
        width="16"
        height="20"
        viewBox="0 0 16 20"
        fill="none"
        xmlns="http://www.w3.org/2000/svg"
        class="drop-shadow-sm"
      >
        <path
          d="M0.928711 0.27832L15.0713 10.5547L7.58422 10.9365L3.97266 18.7949L0.928711 0.27832Z"
          fill={@color}
        />
        <path
          d="M0.928711 0.27832L15.0713 10.5547L7.58422 10.9365L3.97266 18.7949L0.928711 0.27832Z"
          stroke="white"
          stroke-width="1.2"
          stroke-linejoin="round"
        />
      </svg>

      <span
        class="ml-3 -mt-1 inline-block max-w-32 truncate rounded px-1.5 py-0.5 text-xs font-medium text-white shadow-sm"
        style={"background-color: #{@color}"}
      >
        {@user_name}
      </span>

      <div
        :if={@message}
        data-cursor-chat-message
        class="ml-4 mt-1 max-w-48 rounded-lg px-2.5 py-1.5 text-sm text-white shadow-md"
        style={"background-color: #{@color}"}
      >
        {@message}
      </div>

      <div
        :if={@show_input}
        class="pointer-events-auto ml-4 mt-1"
      >
        <input
          data-cursor-chat-input
          type="text"
          placeholder="Say something..."
          class="w-40 rounded-lg border-0 px-2.5 py-1.5 text-sm text-white placeholder-white/60 shadow-md outline-none focus:ring-2 focus:ring-white/40"
          style={"background-color: #{@color}"}
          autocomplete="off"
        />
      </div>
    </div>
    """
  end
end
