defmodule PhiaUiDesign.Web.Endpoint do
  @moduledoc """
  Phoenix Endpoint for the PhiaUI Design tool.

  Runs on a dedicated port (default 4200), completely independent of the
  host application's endpoint. All configuration is programmatic — no
  config files are required.

  ## Static assets

  Three Plug.Static mounts serve the required JavaScript:

  1. `/assets` — the design tool's own JS (hooks, bootstrap).
  2. `/assets/vendor/phoenix` — the pre-built Phoenix channel client
     from the `phoenix` dependency.
  3. `/assets/vendor/phoenix_live_view` — the pre-built LiveView client
     from the `phoenix_live_view` dependency.

  This avoids any build step or bundler while still getting correct
  LiveView WebSocket transport.
  """

  use Phoenix.Endpoint, otp_app: :phia_ui

  @session_options [
    store: :cookie,
    key: "_phiaui_design_key",
    signing_salt: "phiaui_design_salt",
    same_site: "Lax"
  ]

  socket "/live", Phoenix.LiveView.Socket,
    websocket: [connect_info: [session: @session_options]],
    longpoll: false

  # Design tool's own static assets (app.js, etc.)
  plug Plug.Static,
    at: "/assets",
    from: {:phia_ui, "priv/phiaui_design/static"},
    gzip: false

  # Serve the pre-built Phoenix JS client from the dependency
  plug Plug.Static,
    at: "/assets/vendor/phoenix",
    from: {:phoenix, "priv/static"},
    gzip: false

  # Serve the pre-built LiveView JS client from the dependency
  plug Plug.Static,
    at: "/assets/vendor/phoenix_live_view",
    from: {:phoenix_live_view, "priv/static"},
    gzip: false

  plug Plug.RequestId

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Jason

  plug Plug.MethodOverride
  plug Plug.Head
  plug Plug.Session, @session_options
  plug PhiaUiDesign.Web.Router
end
