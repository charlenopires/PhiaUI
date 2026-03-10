defmodule Mix.Tasks.Phia.Design do
  @moduledoc """
  Starts the PhiaUI Design tool — a visual component editor.

  ## Usage

      mix phia.design              # Start on port 4200
      mix phia.design --port 4201  # Custom port
      mix phia.design --no-open    # Don't auto-open browser

  The design tool runs alongside your existing Phoenix application.
  It starts its own HTTP server on a separate port (default: 4200)
  using Bandit, with its own Endpoint, Router, and LiveView.

  ## Features

  - **Component browser** — search and insert any of 623 PhiaUI components
  - **Live canvas** — real component rendering (not placeholders)
  - **Properties panel** — edit attributes and slots visually
  - **Code panel** — live HEEx preview of your design
  - **Page templates** — start from 9 pre-built layouts (dashboard, auth, landing, etc.)
  - **Responsive preview** — desktop, tablet, and mobile viewports
  - **Save/load** — persist designs as `.phia.json` files

  ## Claude Code Integration

  For AI-assisted design, use the MCP server instead:

      mix phia.design.mcp

  See `Mix.Tasks.Phia.Design.Mcp` for setup instructions, or the
  [PhiaUI Design tutorial](docs/guides/tutorial-design.md) for a full walkthrough.

  ## Related Tasks

  - `mix phia.design.mcp` — MCP server for Claude Code integration
  - `mix phia.design.export` — export designs to HEEx/LiveView code
  - `mix phia.design.analyze` — analyze designs for dependencies

  ## Requirements

  - Bandit (`{:bandit, "~> 1.6"}`) must be in your deps.
  - The `:phia_ui` application must be startable (it is started
    automatically by this task).
  """

  @shortdoc "Starts the PhiaUI Design visual editor"

  use Mix.Task

  @impl Mix.Task
  def run(args) do
    {opts, _, _} =
      OptionParser.parse(args,
        strict: [port: :integer, open: :boolean, help: :boolean],
        aliases: [p: :port, h: :help]
      )

    if opts[:help] do
      Mix.shell().info(@moduledoc)
      return_or_halt()
    end

    port = Keyword.get(opts, :port, 4200)
    open? = Keyword.get(opts, :open, true)

    unless Code.ensure_loaded?(Bandit) do
      Mix.raise("""
      Bandit is required to run PhiaUI Design.

      Add {:bandit, "~> 1.6"} to your deps in mix.exs and run:
        mix deps.get
      """)
    end

    Mix.shell().info("Starting PhiaUI Design on http://localhost:#{port}")

    # Ensure the application and its dependencies are started
    Application.ensure_all_started(:phoenix)
    Application.ensure_all_started(:phoenix_live_view)
    Application.ensure_all_started(:phia_ui)

    # Generate a stable-for-this-session secret key base
    secret_key_base =
      :crypto.strong_rand_bytes(64)
      |> Base.url_encode64()
      |> binary_part(0, 64)

    # Configure the endpoint programmatically
    design_config = [
      http: [port: port],
      server: true,
      secret_key_base: secret_key_base,
      live_view: [signing_salt: "phiaui_design_lv"],
      pubsub_server: PhiaUiDesign.PubSub,
      adapter: Bandit.PhoenixAdapter
    ]

    Application.put_env(:phia_ui, PhiaUiDesign.Web.Endpoint, design_config)

    # Start supporting processes under a dedicated supervisor
    children = [
      {Phoenix.PubSub, name: PhiaUiDesign.PubSub},
      PhiaUiDesign.Catalog.CatalogServer
    ]

    {:ok, _} =
      Supervisor.start_link(children,
        strategy: :one_for_one,
        name: PhiaUiDesign.Supervisor
      )

    # Start the endpoint (HTTP server + LiveView socket)
    {:ok, _} = PhiaUiDesign.Web.Endpoint.start_link()

    Mix.shell().info("""

    PhiaUI Design is running!

      Open: http://localhost:#{port}

    Press Ctrl+C to stop.
    """)

    if open? do
      open_browser("http://localhost:#{port}")
    end

    # Keep the task alive
    Process.sleep(:infinity)
  end

  defp open_browser(url) do
    Task.start(fn ->
      Process.sleep(500)

      case :os.type() do
        {:unix, :darwin} -> System.cmd("open", [url])
        {:unix, _} -> System.cmd("xdg-open", [url])
        {:win32, _} -> System.cmd("cmd", ["/c", "start", url])
      end
    end)
  end

  defp return_or_halt do
    if function_exported?(System, :halt, 1) do
      System.halt(0)
    end
  end
end
