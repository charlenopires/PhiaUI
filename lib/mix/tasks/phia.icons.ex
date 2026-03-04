defmodule Mix.Tasks.Phia.Icons do
  @moduledoc """
  Generates the Lucide SVG sprite used by `PhiaUi.Components.Icon`.

  PhiaUI's `<.icon>` component renders icons by referencing symbols inside an
  inline SVG sprite. This task reads individual SVG files from the
  `lucide-static` npm package and combines them into a single sprite file at
  `priv/static/icons/lucide-sprite.svg`.

  The sprite uses `<symbol>` elements with `id="icon-{name}"` so that icons
  can be rendered with `<use href="#icon-chevron-down" />` without any extra
  HTTP requests.

  ## Prerequisites

  Install the `lucide-static` package in your `assets/` directory:

      cd assets && npm install lucide-static

  ## Usage

      mix phia.icons

  Run this command from the root of your Phoenix project. The generated sprite
  is written to `priv/static/icons/lucide-sprite.svg` by default.

  ## Options

      --source PATH   Directory containing Lucide SVG source files.
                      Defaults to `assets/node_modules/lucide-static/icons`.

      --output PATH   Destination path for the generated sprite file.
                      Defaults to `priv/static/icons/lucide-sprite.svg`.

      --help          Print this help message.

  ## Examples

      # Default: read from node_modules, write to priv/static/icons/
      $ mix phia.icons

      # Custom source and output paths
      $ mix phia.icons --source assets/node_modules/lucide-static/icons \\
                       --output priv/static/icons/lucide-sprite.svg

  ## Included icons

  The following icons are always included when present in the source directory.
  These are the icons used internally by PhiaUI components:

      menu, chevron-down, chevron-right, check, x, plus, search, pencil,
      trash-2, upload-cloud, image, bold, italic, underline, heading, list,
      list-ordered, quote, code-2, link, trending-up, trending-down, minus,
      eye, eye-off, calendar, tag, loader-circle

  Missing icon files are skipped with a warning rather than failing the task,
  so a partial icon set is still functional.

  ## Sprite format

  The generated file is a hidden SVG container (`style="display:none"`) with
  each icon wrapped in a `<symbol>` element:

  ```xml
  <svg xmlns="http://www.w3.org/2000/svg" style="display:none">
    <symbol id="icon-check" viewBox="0 0 24 24" fill="none"
            stroke="currentColor" stroke-width="2"
            stroke-linecap="round" stroke-linejoin="round">
      <polyline points="20 6 9 12 4 9"/>
    </symbol>
    ...
  </svg>
  ```

  Include the sprite once in your root layout (e.g., `root.html.heex`) before
  any icon references, or serve it as a static asset and reference it with an
  external `href`.
  """

  use Mix.Task

  @shortdoc "Generates the Lucide SVG sprite at priv/static/icons/lucide-sprite.svg"

  # The set of Lucide icon names that PhiaUI components reference internally.
  # These must be present in the generated sprite for built-in components to
  # render correctly. Additional icons can be added by forking this task or
  # by manually appending <symbol> entries to the sprite file.
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

  Iterates over each icon name in `@minimum_icons`, reads the corresponding
  `.svg` file from `source_dir`, strips the outer `<svg>` wrapper, and wraps
  the inner elements in a `<symbol>` with a namespaced `id="icon-{name}"`.

  All symbols are combined into a single hidden SVG container and written to
  `output_path`. Intermediate directories are created if they do not exist.

  Missing icon files produce a yellow warning and are skipped — the task does
  not fail for partial icon sets.

  ## Example

      iex> Mix.Tasks.Phia.Icons.generate(
      ...>   "assets/node_modules/lucide-static/icons",
      ...>   "priv/static/icons/lucide-sprite.svg"
      ...> )
      :ok
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

  # Wraps the inner SVG elements of a single icon in a <symbol> element.
  #
  # The id is prefixed with "icon-" to avoid clashes with other ids on the
  # page. Stroke attributes are set on the <symbol> itself so they can be
  # overridden by the `color` CSS property on the referencing element.
  defp build_symbol(name, svg_content) do
    inner = extract_inner(svg_content)

    "  <symbol id=\"icon-#{name}\" viewBox=\"0 0 24 24\" fill=\"none\" stroke=\"currentColor\" stroke-width=\"2\" stroke-linecap=\"round\" stroke-linejoin=\"round\">\n" <>
      inner <>
      "\n  </symbol>"
  end

  # Strips the outer <svg ...> opening tag and the closing </svg> tag, leaving
  # only the inner path/polyline/circle elements.
  #
  # Uses a non-greedy regex with the `s` flag to handle multi-line opening
  # tags (Lucide SVGs sometimes have attributes on separate lines).
  defp extract_inner(svg_content) do
    svg_content
    |> String.replace(~r/<svg[^>]*>/s, "", global: false)
    |> String.replace("</svg>", "")
    |> String.trim()
  end

  # Wraps all <symbol> elements in a hidden SVG container.
  #
  # The container uses `style="display:none"` rather than `hidden` or
  # `aria-hidden="true"` to ensure maximum browser compatibility. The sprite
  # must be placed in the DOM before any <use> references to it.
  defp build_sprite(symbols) do
    body = Enum.join(symbols, "\n")

    """
    <svg xmlns="http://www.w3.org/2000/svg" style="display:none">
    #{body}
    </svg>
    """
  end
end
