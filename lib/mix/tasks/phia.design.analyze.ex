defmodule Mix.Tasks.Phia.Design.Analyze do
  @moduledoc """
  Analyze a saved PhiaUI design file.

  Reports component usage, required JS hooks, install commands,
  and potential issues. Useful for CI pipelines or pre-deploy checks.

  ## Usage

      mix phia.design.analyze my_design.phia.json
      mix phia.design.analyze my_design.phia.json --json

  ## Options

  - `--json` (`-j`) — Output as JSON instead of human-readable text

  ## Output

  The analysis includes:

  - **File metadata** — name, theme, node count
  - **Components used** — sorted list of unique component names
  - **JS hooks required** — hooks that must be registered in your app.js
  - **Install commands** — `mix phia.add` commands to install needed components

  ## Examples

      # Human-readable report
      mix phia.design.analyze dashboard.phia.json

      # JSON for scripting
      mix phia.design.analyze dashboard.phia.json --json | jq '.js_hooks_required'

  ## Related Tasks

  - `mix phia.design` — visual editor
  - `mix phia.design.export` — export designs to code
  - `mix phia.design.mcp` — MCP server for Claude Code
  """

  @shortdoc "Analyze a .phia.json design file"

  use Mix.Task

  alias PhiaUiDesign.Canvas.{Persistence, Scene}
  alias PhiaUiDesign.Codegen.LiveviewEmitter

  @impl Mix.Task
  def run(args) do
    {opts, positional, _} =
      OptionParser.parse(args,
        strict: [json: :boolean, help: :boolean],
        aliases: [j: :json, h: :help]
      )

    if opts[:help] || positional == [] do
      Mix.shell().info(@moduledoc)
      return_or_halt()
    end

    Application.ensure_all_started(:phia_ui)

    [input_path | _] = positional

    unless File.exists?(input_path) do
      Mix.raise("File not found: #{input_path}")
    end

    case Persistence.load(input_path) do
      {:ok, scene, metadata} ->
        analysis = analyze(scene, metadata, input_path)

        if opts[:json] do
          Mix.shell().info(Jason.encode!(analysis, pretty: true))
        else
          print_analysis(analysis)
        end

      {:error, reason} ->
        Mix.raise("Failed to load #{input_path}: #{inspect(reason)}")
    end
  end

  defp analyze(scene, metadata, path) do
    components = Scene.components_used(scene)
    hooks = Scene.hooks_needed(scene)
    total_nodes = Scene.count(scene)
    add_commands = LiveviewEmitter.required_add_commands(components)

    %{
      "file" => path,
      "name" => metadata.name,
      "theme" => to_string(metadata.theme),
      "total_nodes" => total_nodes,
      "components_used" => Enum.map(components, &to_string/1) |> Enum.sort(),
      "unique_components" => length(components),
      "js_hooks_required" => hooks,
      "install_commands" => add_commands
    }
  end

  defp print_analysis(analysis) do
    Mix.shell().info("""

    PhiaUI Design Analysis
    ======================
    File:   #{analysis["file"]}
    Name:   #{analysis["name"]}
    Theme:  #{analysis["theme"]}
    Nodes:  #{analysis["total_nodes"]}
    Unique components: #{analysis["unique_components"]}

    Components used:
    #{analysis["components_used"] |> Enum.map(&"  - #{&1}") |> Enum.join("\n")}

    JS hooks required:
    #{format_list(analysis["js_hooks_required"])}

    Install commands:
    #{format_list(analysis["install_commands"])}
    """)
  end

  defp format_list([]), do: "  (none)"
  defp format_list(items), do: Enum.map(items, &"  #{&1}") |> Enum.join("\n")

  defp return_or_halt do
    if function_exported?(System, :halt, 1), do: System.halt(0)
  end
end
