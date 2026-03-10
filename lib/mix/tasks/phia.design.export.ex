defmodule Mix.Tasks.Phia.Design.Export do
  @moduledoc """
  Export a saved PhiaUI design to HEEx or LiveView source files.

  ## Usage

      mix phia.design.export my_design.phia.json
      mix phia.design.export my_design.phia.json --format liveview --output lib/my_app_web/live/page_live.ex
      mix phia.design.export my_design.phia.json --format heex --output lib/my_app_web/templates/page.html.heex

  ## Options

  - `--format` — Output format: `heex` (default) or `liveview`
  - `--output` — Output file path (prints to stdout if omitted)
  - `--module` — Module name for LiveView format (default: `MyAppWeb.DesignedLive`)
  - `--web-module` — Phoenix web module (default: `MyAppWeb`)
  """

  @shortdoc "Export a .phia.json design to HEEx or LiveView code"

  use Mix.Task

  alias PhiaUiDesign.Canvas.Persistence
  alias PhiaUiDesign.Codegen.{HeexEmitter, LiveviewEmitter}

  @impl Mix.Task
  def run(args) do
    {opts, positional, _} =
      OptionParser.parse(args,
        strict: [
          format: :string,
          output: :string,
          module: :string,
          web_module: :string,
          help: :boolean
        ],
        aliases: [f: :format, o: :output, m: :module, h: :help]
      )

    if opts[:help] || positional == [] do
      Mix.shell().info(@moduledoc)
      return_or_halt()
    end

    Application.ensure_all_started(:phia_ui)

    [input_path | _] = positional
    format = Keyword.get(opts, :format, "heex")
    output_path = opts[:output]
    module_name = Keyword.get(opts, :module, "MyAppWeb.DesignedLive")
    web_module = Keyword.get(opts, :web_module, "MyAppWeb")

    unless File.exists?(input_path) do
      Mix.raise("File not found: #{input_path}")
    end

    case Persistence.load(input_path) do
      {:ok, scene, metadata} ->
        Mix.shell().info("Loaded design '#{metadata.name}' from #{input_path}")

        code =
          case format do
            "liveview" ->
              LiveviewEmitter.emit(scene, module_name, web_module: web_module)

            _ ->
              HeexEmitter.emit(scene)
          end

        if output_path do
          File.mkdir_p!(Path.dirname(output_path))
          File.write!(output_path, code)
          Mix.shell().info("Exported #{format} to #{output_path}")
        else
          Mix.shell().info(code)
        end

      {:error, reason} ->
        Mix.raise("Failed to load #{input_path}: #{inspect(reason)}")
    end
  end

  defp return_or_halt do
    if function_exported?(System, :halt, 1), do: System.halt(0)
  end
end
