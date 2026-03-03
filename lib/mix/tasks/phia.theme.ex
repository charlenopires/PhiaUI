defmodule Mix.Tasks.Phia.Theme do
  @shortdoc "Manage PhiaUI themes — list, apply, export, import, install"

  @moduledoc """
  Manage PhiaUI themes via command-line.

  ## Usage

      mix phia.theme list
      mix phia.theme apply <theme_name>
      mix phia.theme export <theme_name> [--format css|json]
      mix phia.theme import <path_to_json>
      mix phia.theme install [--output PATH] [--themes a,b,c]

  ## Commands

  ### list

  Displays all available built-in theme presets with their primary OKLCH color:

      mix phia.theme list

  ### apply

  Applies a built-in preset by writing its CSS variables to the project's
  `assets/css/theme.css` (or `priv/templates/theme/theme.css` if not found).
  Creates the file if it does not exist.

      mix phia.theme apply zinc
      mix phia.theme apply blue
      mix phia.theme apply rose

  ### export

  Prints the JSON or CSS representation of a built-in theme to stdout.
  Use `--format json` (default) for JSON output or `--format css` for scoped
  CSS with `[data-phia-theme]` attribute selectors.

      mix phia.theme export zinc > my-theme.json
      mix phia.theme export blue --format css
      mix phia.theme export zinc --format json

  ### import

  Imports a custom theme from a JSON file and writes its CSS variables to
  `assets/css/theme.css`.

      mix phia.theme import ./my-theme.json

  ### install

  Generates a `phia-themes.css` file containing all (or selected) themes
  scoped to `[data-phia-theme]` attribute selectors, then injects an
  `@import` line into `assets/css/app.css` if it exists.

      mix phia.theme install
      mix phia.theme install --output assets/css/my-themes.css
      mix phia.theme install --themes zinc,blue,rose

  Options:

  - `--output` — output file path (default: `"assets/css/phia-themes.css"`)
  - `--themes` — comma-separated theme names (default: all built-in themes)
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
            "css" -> ThemeCSS.generate_for_selector(theme)
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

    inject_app_css_import(output)

    Mix.shell().info(
      "\nTip: Set data-phia-theme=\"blue\" on any ancestor element to activate a theme."
    )

    Mix.shell().info("     Use phx-hook=\"PhiaTheme\" on a button/select for runtime switching.")
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

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

  defp theme_css_path do
    candidates = [
      "assets/css/theme.css",
      "priv/static/theme.css"
    ]

    Enum.find(candidates, List.last(candidates), &File.exists?/1)
  end
end
