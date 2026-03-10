defmodule PhiaUiDesign.Mcp.Server do
  @moduledoc """
  MCP (Model Context Protocol) server for Claude Code integration.

  Implements a JSON-RPC 2.0 server over stdio transport. Claude Code
  connects to this server to manipulate PhiaUI designs programmatically.

  ## Protocol

  The server supports:

  - `initialize` — handshake with protocol version and capabilities
  - `notifications/initialized` — client confirmation
  - `tools/list` — enumerate all available design tools
  - `tools/call` — execute a tool by name with arguments

  ## Usage

  Started via `mix phia.design.mcp`. Configure in `.mcp.json`:

      {
        "mcpServers": {
          "phiaui-design": {
            "command": "mix",
            "args": ["phia.design.mcp"],
            "env": {"MIX_ENV": "dev"}
          }
        }
      }
  """

  alias PhiaUiDesign.Canvas.Scene
  alias PhiaUiDesign.Mcp.{ToolRegistry, Tools}

  @protocol_version "2024-11-05"
  @server_name "phiaui-design"
  @server_version "0.1.16"

  @doc """
  Run the MCP server. Blocks indefinitely reading from stdin.
  """
  def run(opts \\ []) do
    # Ensure application dependencies are started
    Application.ensure_all_started(:phoenix)
    Application.ensure_all_started(:phoenix_live_view)
    Application.ensure_all_started(:phia_ui)

    # Start the catalog server for component introspection
    start_catalog()

    # Create a fresh scene
    scene = Scene.new()

    state = %{
      scene: scene,
      initialized: false,
      theme: :zinc,
      project_path: Keyword.get(opts, :project_path)
    }

    # Redirect Elixir/Erlang log output to stderr so stdout stays clean
    :logger.set_primary_config(:level, :warning)

    loop(state)
  end

  # ---------------------------------------------------------------------------
  # Message loop
  # ---------------------------------------------------------------------------

  defp loop(state) do
    case IO.gets("") do
      :eof ->
        :ok

      {:error, _} ->
        :ok

      line ->
        line = String.trim(line)

        state =
          if line != "" do
            case Jason.decode(line) do
              {:ok, message} ->
                {state, response} = process(message, state)
                if response, do: write_response(response)
                state

              {:error, _} ->
                state
            end
          else
            state
          end

        loop(state)
    end
  end

  defp write_response(response) do
    json = Jason.encode!(response)
    IO.write(:stdio, json <> "\n")
  end

  # ---------------------------------------------------------------------------
  # JSON-RPC message processing
  # ---------------------------------------------------------------------------

  defp process(%{"method" => "initialize", "id" => id}, state) do
    result = %{
      "protocolVersion" => @protocol_version,
      "capabilities" => %{
        "tools" => %{}
      },
      "serverInfo" => %{
        "name" => @server_name,
        "version" => @server_version
      }
    }

    {%{state | initialized: true}, jsonrpc_result(id, result)}
  end

  defp process(%{"method" => "notifications/initialized"}, state) do
    {state, nil}
  end

  defp process(%{"method" => "tools/list", "id" => id}, state) do
    result = %{"tools" => ToolRegistry.all_tools()}
    {state, jsonrpc_result(id, result)}
  end

  defp process(%{"method" => "tools/call", "id" => id, "params" => params}, state) do
    tool_name = params["name"]
    arguments = params["arguments"] || %{}

    {result, state} = Tools.execute(tool_name, arguments, state)
    {state, jsonrpc_result(id, result)}
  end

  # Ping / unknown method with id
  defp process(%{"method" => "ping", "id" => id}, state) do
    {state, jsonrpc_result(id, %{})}
  end

  defp process(%{"id" => id}, state) do
    {state, jsonrpc_error(id, -32601, "Method not found")}
  end

  # Notifications without id
  defp process(_message, state) do
    {state, nil}
  end

  # ---------------------------------------------------------------------------
  # JSON-RPC helpers
  # ---------------------------------------------------------------------------

  defp jsonrpc_result(id, result) do
    %{"jsonrpc" => "2.0", "id" => id, "result" => result}
  end

  defp jsonrpc_error(id, code, message) do
    %{
      "jsonrpc" => "2.0",
      "id" => id,
      "error" => %{"code" => code, "message" => message}
    }
  end

  # ---------------------------------------------------------------------------
  # Setup
  # ---------------------------------------------------------------------------

  defp start_catalog do
    case PhiaUiDesign.Catalog.CatalogServer.start_link() do
      {:ok, _} -> :ok
      {:error, {:already_started, _}} -> :ok
    end
  end
end
