defmodule Mix.Tasks.Phia.Icons do
  @moduledoc """
  Generates the Lucide SVG sprite used by `PhiaUi.Components.Icon`.

  Reads individual SVG files from the `lucide-static` npm package and
  combines them into a single sprite at `priv/static/icons/lucide-sprite.svg`.

  ## Usage

      mix phia.icons

  Run from the root of your Phoenix project after installing lucide-static:

      cd assets && npm install lucide-static

  ## Options

      --source   Path to the directory containing Lucide SVG files.
                 Defaults to `assets/node_modules/lucide-static/icons`.

      --output   Destination path for the generated sprite.
                 Defaults to `priv/static/icons/lucide-sprite.svg`.

      --help     Print this help message.

  ## Custom source

      mix phia.icons --source assets/node_modules/lucide-static/icons

  ## Minimum icon set

  The following icons are always included when present in the source directory:

      menu, chevron-down, chevron-right, check, x, plus, search, pencil,
      trash-2, upload-cloud, image, bold, italic, underline, heading, list,
      list-ordered, quote, code-2, link, trending-up, trending-down, minus,
      eye, eye-off, calendar, tag, loader-circle
  """

  use Mix.Task

  @shortdoc "Generates the Lucide SVG sprite at priv/static/icons/lucide-sprite.svg"

  @minimum_icons ~w(
    menu chevron-down chevron-right check x plus search pencil
    trash-2 upload-cloud image bold italic underline heading list
    list-ordered quote code-2 link trending-up trending-down minus
    eye eye-off calendar tag loader-circle
  )

  @default_source "assets/node_modules/lucide-static/icons"
  @default_output "priv/static/icons/lucide-sprite.svg"

  @impl Mix.Task
  def run(["--help"]) do
    Mix.shell().info(@moduledoc)
  end

  def run(args) do
    {opts, _, _} = OptionParser.parse(args, switches: [source: :string, output: :string])
    source = Keyword.get(opts, :source, @default_source)
    output = Keyword.get(opts, :output, @default_output)

    source_dir = Path.expand(source)

    unless File.dir?(source_dir) do
      Mix.raise("""
      Lucide icons not found at: #{source_dir}

      Install lucide-static in your assets/ directory:

          cd assets && npm install lucide-static

      Then run:

          mix phia.icons
      """)
    end

    generate(source_dir, output)

    Mix.shell().info([:green, "* create ", :reset, output])
  end

  @doc """
  Generates the SVG sprite from `source_dir` and writes it to `output_path`.

  Reads each icon in `@minimum_icons` from `source_dir/{name}.svg`, strips the
  outer `<svg>` wrapper, wraps the inner elements in a `<symbol>` with the
  correct id, and writes the combined sprite to `output_path`.

  Missing icon files are skipped with a warning.
  """
  @spec generate(Path.t(), Path.t()) :: :ok
  def generate(source_dir, output_path) do
    symbols =
      @minimum_icons
      |> Enum.flat_map(fn name ->
        path = Path.join(source_dir, "#{name}.svg")

        case File.read(path) do
          {:ok, content} ->
            [build_symbol(name, content)]

          {:error, _} ->
            Mix.shell().info([:yellow, "* skip    ", :reset, "#{name}.svg not found"])
            []
        end
      end)

    sprite = build_sprite(symbols)

    File.mkdir_p!(Path.dirname(output_path))
    File.write!(output_path, sprite)

    :ok
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  defp build_symbol(name, svg_content) do
    inner = extract_inner(svg_content)

    "  <symbol id=\"icon-#{name}\" viewBox=\"0 0 24 24\" fill=\"none\" stroke=\"currentColor\" stroke-width=\"2\" stroke-linecap=\"round\" stroke-linejoin=\"round\">\n" <>
      inner <>
      "\n  </symbol>"
  end

  defp extract_inner(svg_content) do
    svg_content
    |> String.replace(~r/<svg[^>]*>/s, "", global: false)
    |> String.replace("</svg>", "")
    |> String.trim()
  end

  defp build_sprite(symbols) do
    body = Enum.join(symbols, "\n")

    """
    <svg xmlns="http://www.w3.org/2000/svg" style="display:none">
    #{body}
    </svg>
    """
  end
end
