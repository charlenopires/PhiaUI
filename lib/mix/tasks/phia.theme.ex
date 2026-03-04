defmodule Mix.Tasks.Phia.Theme do
  @shortdoc "Manage PhiaUI themes — list, apply, export, import, install"

  @moduledoc """
  Manage PhiaUI color theme presets from the command line.

  PhiaUI ships with 8 built-in color presets (zinc, slate, blue, rose, orange,
  green, violet, neutral). This task lets you list them, apply one as your
  project's active theme, export/import themes as JSON, and generate a
  static multi-theme CSS file for runtime color switching.

  ## Commands at a glance

      mix phia.theme list
      mix phia.theme apply <theme_name>
      mix phia.theme export <theme_name> [--format css|json]
      mix phia.theme import <path_to_json>
      mix phia.theme install [--output PATH] [--themes a,b,c]

  ---

  ## list

  Displays all available built-in presets with their primary OKLCH color value.

      $ mix phia.theme list

      PhiaUI — Available Themes

        NAME         LABEL                PRIMARY (light)
        --------------------------------------------------------
        blue         Blue                 oklch(0.546 0.245 262.881)
        green        Green                oklch(0.527 0.154 150.069)
        neutral      Neutral              oklch(0.205 0 0)
        orange       Orange               oklch(0.645 0.246 37.304)
        rose         Rose                 oklch(0.592 0.241 349.615)
        slate        Slate                oklch(0.208 0.042 265.755)
        violet       Violet               oklch(0.541 0.281 293.009)
        zinc         Zinc                 oklch(0.211 0.005 285.82)

  ---

  ## apply

  Applies a built-in preset by writing its CSS variables to the project's
  `assets/css/theme.css` (falls back to `priv/static/theme.css` if the assets
  path does not exist). Creates the file if it does not exist.

  Use this command when you want a single, fixed theme for your project.

      $ mix phia.theme apply zinc
      Applied theme 'zinc' to assets/css/theme.css

      $ mix phia.theme apply blue
      $ mix phia.theme apply rose

  After applying, refresh your browser or restart the Phoenix server to see the
  new colors.

  ---

  ## export

  Prints the JSON or CSS representation of a built-in theme to stdout.
  Redirect to a file to save it.

  Use `--format json` (default) for a portable JSON representation that can
  later be re-imported or shared with a designer. Use `--format css` to get
  the scoped CSS blocks ready for manual inclusion.

      $ mix phia.theme export zinc > my-brand.json
      $ mix phia.theme export blue --format css
      $ mix phia.theme export zinc --format json

  The CSS output uses `[data-phia-theme="<name>"]` attribute selectors and is
  identical to what `mix phia.theme install` generates for each theme.

  ---

  ## import

  Imports a custom theme from a JSON file and writes its CSS variables to
  `assets/css/theme.css`. The JSON must follow the same schema produced by
  `export --format json`.

      $ mix phia.theme import ./my-brand.json
      Imported theme 'my-brand' to assets/css/theme.css

  Typical workflow for a custom brand theme:

      # 1. Export an existing theme as a starting point
      $ mix phia.theme export zinc > my-brand.json

      # 2. Edit my-brand.json to adjust colors, radius, etc.

      # 3. Import it back
      $ mix phia.theme import my-brand.json

  ---

  ## install

  Generates a `phia-themes.css` file containing all (or a selected subset of)
  themes, each scoped to `[data-phia-theme="<name>"]` attribute selectors.
  Also injects an `@import` into `assets/css/app.css` so TailwindCSS v4 picks
  up the file.

  This is the command to use when you want **runtime color switching** — users
  can switch between themes without a page reload by changing the
  `data-phia-theme` attribute on `<html>` (handled automatically by the
  `PhiaTheme` JavaScript hook).

      $ mix phia.theme install
      Generated assets/css/phia-themes.css with 8 theme(s)
      Injected @import into assets/css/app.css

      # Write to a custom path
      $ mix phia.theme install --output assets/css/my-themes.css

      # Only include a subset of presets
      $ mix phia.theme install --themes zinc,blue,rose

  ### Options

  - `--output PATH` — output file path (default: `"assets/css/phia-themes.css"`)
  - `--themes LIST` — comma-separated preset names (default: all 8 built-in themes)

  ### Using the generated file

  Once installed, activate a theme by setting the `data-phia-theme` attribute:

      <!-- In your root layout -->
      <html data-phia-theme="blue" class="dark">

  Or use the `PhiaTheme` JavaScript hook for interactive runtime switching:

      <button phx-hook="PhiaTheme" data-theme="rose">Switch to Rose</button>
      <select phx-hook="PhiaTheme">
        <option value="zinc">Zinc</option>
        <option value="blue">Blue</option>
      </select>

  The hook reads the selected value and writes it to `localStorage` under the
  key `phia-color-theme`, then sets `data-phia-theme` on `<html>`.
  """

  use Mix.Task

  alias PhiaUi.{Theme, ThemeCSS}

  @requirements ["app.start"]

  @impl Mix.Task
  def run(args) do
    {opts, positional, _invalid} =
      OptionParser.parse(args,
        strict: [output: :string, themes: :string, format: :string]
      )

    case positional do
      ["list"] -> run_list()
      ["apply", name] -> run_apply(name)
      ["export", name] -> run_export(name, opts)
      ["import", path] -> run_import(path)
      ["install"] -> run_install(opts)
      _ -> print_usage()
    end
  end

  # ---------------------------------------------------------------------------
  # Subcommands
  # ---------------------------------------------------------------------------

  defp run_list do
    Mix.shell().info("\nPhiaUI — Available Themes\n")

    Mix.shell().info(
      "  #{String.pad_trailing("NAME", 12)} #{String.pad_trailing("LABEL", 20)} PRIMARY (light)"
    )

    Mix.shell().info("  #{String.duplicate("-", 56)}")

    Theme.list()
    |> Enum.sort()
    |> Enum.each(fn key ->
      {:ok, theme} = Theme.get(key)
      name_col = String.pad_trailing(to_string(key), 12)
      label_col = String.pad_trailing(theme.label, 20)
      primary = Map.get(theme.colors.light, :primary, "—")
      Mix.shell().info("  #{name_col} #{label_col} #{primary}")
    end)

    Mix.shell().info("")
  end

  defp run_apply(name) do
    atom = String.to_existing_atom(name)

    case Theme.get(atom) do
      {:ok, theme} ->
        css = ThemeCSS.generate(theme)
        path = theme_css_path()
        File.mkdir_p!(Path.dirname(path))
        File.write!(path, css)
        Mix.shell().info("Applied theme '#{name}' to #{path}")

        Mix.shell().info(
          "\nTip: Run `mix phia.theme install` to generate scoped multi-theme CSS."
        )

      {:error, :not_found} ->
        Mix.shell().error(
          "Unknown theme: #{inspect(name)}. Run `mix phia.theme list` to see available themes."
        )
    end
  rescue
    ArgumentError ->
      Mix.shell().error(
        "Unknown theme: #{inspect(name)}. Run `mix phia.theme list` to see available themes."
      )
  end

  defp run_export(name, opts) do
    format = Keyword.get(opts, :format, "json")
    atom = String.to_existing_atom(name)

    case Theme.get(atom) do
      {:ok, theme} ->
        output =
          case format do
            # CSS output uses [data-phia-theme] selectors — same format as install.
            "css" -> ThemeCSS.generate_for_selector(theme)
            # JSON output is the portable, importable representation.
            _ -> ThemeCSS.to_json(theme)
          end

        Mix.shell().info(output)

      {:error, :not_found} ->
        Mix.shell().error("Unknown theme: #{inspect(name)}.")
    end
  rescue
    ArgumentError ->
      Mix.shell().error("Unknown theme: #{inspect(name)}.")
  end

  defp run_import(file_path) do
    case File.read(file_path) do
      {:ok, json} ->
        theme = ThemeCSS.from_json(json)
        css = ThemeCSS.generate(theme)
        path = theme_css_path()
        File.mkdir_p!(Path.dirname(path))
        File.write!(path, css)
        Mix.shell().info("Imported theme '#{theme.name}' to #{path}")

      {:error, reason} ->
        Mix.shell().error("Could not read #{file_path}: #{:file.format_error(reason)}")
    end
  end

  defp run_install(opts) do
    output = Keyword.get(opts, :output, "assets/css/phia-themes.css")

    # Resolve the list of theme keys to include. When --themes is omitted all
    # built-in presets are included; otherwise parse the comma-separated list.
    theme_keys =
      case Keyword.get(opts, :themes) do
        nil ->
          Theme.list()

        themes_str ->
          themes_str
          |> String.split(",")
          |> Enum.map(&String.trim/1)
          |> Enum.map(&String.to_existing_atom/1)
      end

    css = ThemeCSS.generate_all(theme_keys)
    File.mkdir_p!(Path.dirname(output))
    File.write!(output, css)
    Mix.shell().info("Generated #{output} with #{length(theme_keys)} theme(s)")

    # Idempotently prepend an @import into app.css so TailwindCSS v4 sees the
    # generated file without requiring a manual edit.
    inject_app_css_import(output)

    Mix.shell().info(
      "\nTip: Set data-phia-theme=\"blue\" on any ancestor element to activate a theme."
    )

    Mix.shell().info("     Use phx-hook=\"PhiaTheme\" on a button/select for runtime switching.")
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  # Prepends an @import line for `output_path` into assets/css/app.css.
  # Checks for the filename (not the full path) to handle relative/absolute
  # path variations. Skips if the import is already present (idempotent).
  defp inject_app_css_import(output_path) do
    app_css = "assets/css/app.css"
    import_filename = Path.basename(output_path)
    import_line = ~s(@import "./#{import_filename}";\n)

    if File.exists?(app_css) do
      content = File.read!(app_css)

      if String.contains?(content, import_filename) do
        Mix.shell().info("#{app_css} already imports #{import_filename} (skipped)")
      else
        File.write!(app_css, import_line <> content)
        Mix.shell().info("Injected @import into #{app_css}")
      end
    else
      Mix.shell().info(
        ~s(Tip: Add `@import "./#{import_filename}";` to your app.css if not done automatically.)
      )
    end
  end

  defp print_usage do
    Mix.shell().info(@moduledoc)
  end

  # Resolves the path to write theme CSS when using `apply` or `import`.
  # Prefers `assets/css/theme.css` in a standard Phoenix project layout and
  # falls back to `priv/static/theme.css` (used during phia_ui development).
  defp theme_css_path do
    candidates = [
      "assets/css/theme.css",
      "priv/static/theme.css"
    ]

    Enum.find(candidates, List.last(candidates), &File.exists?/1)
  end
end
