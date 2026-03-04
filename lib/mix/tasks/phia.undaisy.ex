defmodule Mix.Tasks.Phia.Undaisy do
  @moduledoc """
  Removes all DaisyUI references from a Phoenix LiveView project.

  Automates DaisyUI cleanup so you can adopt PhiaUI cleanly. Targets
  configuration files and reports template files that need manual attention.

  ## What gets changed automatically

  - `assets/package.json` — removes `"daisyui"` from dependencies
  - `assets/css/*.css` — removes `@plugin`, `@import`, and `@source` DaisyUI lines
  - `assets/tailwind.config.js` — removes `require("daisyui")` and `daisyui:` block

  ## What requires manual migration

  DaisyUI CSS classes in `.heex`/`.ex` template files (e.g., `btn-primary`,
  `card-body`, `modal-box`) must be replaced manually. PhiaUI uses function
  components — not utility classes — for the same UI primitives:

      <%!-- DaisyUI --%>
      <button class="btn btn-primary">Save</button>

      <%!-- PhiaUI --%>
      <.button variant="default">Save</.button>

  This task scans your templates and reports every file that contains
  DaisyUI-specific class names so you know exactly what needs updating.

  ## Usage

      mix phia.undaisy

  ## Options

      --dry-run   Show planned changes without modifying any files
      --help      Print this message

  ## After running

  1. Remove the DaisyUI package from your assets directory:

         cd assets && npm uninstall daisyui
         # or: bun remove daisyui / yarn remove daisyui / pnpm remove daisyui

  2. Set up PhiaUI:

         mix phia.install

  3. Migrate any listed template files from DaisyUI classes to PhiaUI components.

  """

  use Mix.Task

  @shortdoc "Removes DaisyUI from a Phoenix LiveView project"

  # CSS directives to remove (Tailwind v4 @plugin, legacy @import, @source paths)
  @css_patterns [
    # @plugin "daisyui"; or @plugin "daisyui/full";
    ~r/^[^\S\n]*@plugin\s+["']daisyui(?:\/[^"']*)?["']\s*;\n?/m,
    # @plugin "daisyui" { ... } (block form with options)
    ~r/^[^\S\n]*@plugin\s+["']daisyui(?:\/[^"']*)?["'][^\n{]*\{[^}]*\}\n?/ms,
    # @import "daisyui" or @import 'daisyui'
    ~r/^[^\S\n]*@import\s+["']daisyui(?:\/[^"']*)?["']\s*;\n?/m,
    # @source "node_modules/daisyui/..."
    ~r/^[^\S\n]*@source\s+["'][^"']*node_modules\/daisyui[^"']*["']\s*;\n?/m
  ]

  # DaisyUI-specific component class identifiers.
  # These are suffixed or compound names that only appear in DaisyUI projects,
  # minimising false positives against plain Tailwind or PhiaUI class names.
  @daisy_classes ~w(
    btn-primary btn-secondary btn-accent btn-ghost btn-link
    btn-info btn-success btn-warning btn-error btn-outline
    btn-active btn-disabled btn-glass btn-wide btn-block
    btn-circle btn-square
    card-body card-title card-actions card-compact card-side
    modal-box modal-action modal-backdrop
    navbar-start navbar-center navbar-end
    drawer-side drawer-overlay drawer-content drawer-toggle drawer-button
    menu-title menu-horizontal
    tabs-lifted tabs-bordered tabs-boxed tab-active tab-content
    collapse-arrow collapse-plus
    join-item
    chat-bubble chat-start chat-end
    hero-content hero-overlay
    indicator-item
    stat-title stat-value stat-desc
    swap-on swap-off swap-rotate swap-flip
    loading-spinner loading-dots loading-ring
    mockup-code mockup-browser mockup-phone
    badge-primary badge-secondary badge-accent
    alert-info alert-success alert-warning alert-error
    toast-start toast-center toast-end
    mask-squircle mask-heart mask-hexagon
    radial-progress artboard countdown diff-item
  )

  @impl Mix.Task
  def run(["--help"]), do: Mix.shell().info(@moduledoc)

  def run(args) do
    dry_run? = "--dry-run" in args
    root = File.cwd!()

    if dry_run? do
      Mix.shell().info("PhiaUI undaisy — dry-run (no files will be changed)\n")
    else
      Mix.shell().info("PhiaUI — Removing DaisyUI\n")
    end

    config_results =
      [
        process_file(Path.join([root, "assets", "package.json"]), &clean_package_json/1, dry_run?),
        process_file(
          Path.join([root, "assets", "tailwind.config.js"]),
          &clean_tailwind_config/1,
          dry_run?
        )
      ] ++ process_css_dir(root, dry_run?)

    template_hits = scan_templates(root)

    print_config_results(config_results)
    print_template_report(template_hits)
    print_next_steps(config_results, template_hits, dry_run?)
  end

  # ---------------------------------------------------------------------------
  # Public pure transformers (exposed for testing)
  # ---------------------------------------------------------------------------

  @doc """
  Removes the `"daisyui"` key from a package.json string.

  Handles both `"dependencies"` and `"devDependencies"` sections.
  Uses `Jason` when available (standard in Phoenix projects) for clean
  round-trip encoding; falls back to regex otherwise.

  Returns `{:changed, new_content}` or `{:unchanged, original}`.
  """
  @spec clean_package_json(String.t()) :: {:changed, String.t()} | {:unchanged, String.t()}
  def clean_package_json(content) do
    if String.contains?(content, "\"daisyui\"") do
      {:changed, do_clean_package_json(content)}
    else
      {:unchanged, content}
    end
  end

  @doc """
  Removes DaisyUI `@plugin`, `@import`, and `@source` directives from a CSS string.

  Returns `{:changed, new_content}` or `{:unchanged, original}`.
  """
  @spec clean_css(String.t()) :: {:changed, String.t()} | {:unchanged, String.t()}
  def clean_css(content) do
    new_content = Enum.reduce(@css_patterns, content, &String.replace(&2, &1, ""))
    if new_content == content, do: {:unchanged, content}, else: {:changed, new_content}
  end

  @doc """
  Removes `require("daisyui")` and the `daisyui:` config block from a
  tailwind.config.js string.

  Returns `{:changed, new_content}` or `{:unchanged, original}`.
  """
  @spec clean_tailwind_config(String.t()) :: {:changed, String.t()} | {:unchanged, String.t()}
  def clean_tailwind_config(content) do
    new_content =
      content
      |> remove_require_daisyui()
      |> remove_daisyui_config_block()

    if new_content == content, do: {:unchanged, content}, else: {:changed, new_content}
  end

  @doc """
  Scans a string for DaisyUI-specific component class names.

  Returns the list of matched class identifiers found in `content`.
  """
  @spec find_daisy_classes(String.t()) :: [String.t()]
  def find_daisy_classes(content) do
    Enum.filter(@daisy_classes, &String.contains?(content, &1))
  end

  # ---------------------------------------------------------------------------
  # Private: file processors
  # ---------------------------------------------------------------------------

  defp process_css_dir(root, dry_run?) do
    css_dir = Path.join([root, "assets", "css"])

    case File.ls(css_dir) do
      {:ok, files} ->
        files
        |> Enum.filter(&String.ends_with?(&1, ".css"))
        |> Enum.map(&process_file(Path.join(css_dir, &1), fn c -> clean_css(c) end, dry_run?))

      {:error, _} ->
        []
    end
  end

  defp process_file(path, cleaner, dry_run?) do
    if File.exists?(path) do
      content = File.read!(path)

      case cleaner.(content) do
        {:changed, new_content} ->
          unless dry_run?, do: File.write!(path, new_content)
          {path, if(dry_run?, do: :would_change, else: :changed)}

        {:unchanged, _} ->
          {path, :unchanged}
      end
    else
      {path, :not_found}
    end
  end

  # ---------------------------------------------------------------------------
  # Private: template scanner
  # ---------------------------------------------------------------------------

  defp scan_templates(root) do
    lib_dir = Path.join(root, "lib")

    if File.exists?(lib_dir) do
      lib_dir
      |> collect_template_files()
      |> Enum.flat_map(fn path ->
        classes = path |> File.read!() |> find_daisy_classes()
        if classes == [], do: [], else: [{path, classes}]
      end)
    else
      []
    end
  end

  defp collect_template_files(dir) do
    dir
    |> File.ls!()
    |> Enum.flat_map(fn entry ->
      path = Path.join(dir, entry)

      cond do
        File.dir?(path) -> collect_template_files(path)
        template_file?(path) -> [path]
        true -> []
      end
    end)
  end

  defp template_file?(path) do
    String.ends_with?(path, ".heex") or
      String.ends_with?(path, ".html.eex") or
      String.ends_with?(path, ".ex")
  end

  # ---------------------------------------------------------------------------
  # Private: string transformers
  # ---------------------------------------------------------------------------

  defp do_clean_package_json(content) do
    with {:module, _} <- Code.ensure_loaded(Jason),
         {:ok, json} <- Jason.decode(content) do
      cleaned =
        json
        |> drop_json_key("dependencies", "daisyui")
        |> drop_json_key("devDependencies", "daisyui")

      Jason.encode!(cleaned, pretty: true) <> "\n"
    else
      _ -> clean_package_json_regex(content)
    end
  end

  defp drop_json_key(json, section, key) do
    case json[section] do
      nil -> json
      deps -> Map.put(json, section, Map.delete(deps, key))
    end
  end

  # Regex fallback when Jason is unavailable (e.g. tests in isolation).
  defp clean_package_json_regex(content) do
    content
    # Remove ",\n  "daisyui": "..."" (last item in object)
    |> String.replace(~r/,\s*\n\s*"daisyui":\s*"[^"]*"/, "")
    # Remove '"daisyui": "...",\n  ' (first item in object)
    |> String.replace(~r/\n\s*"daisyui":\s*"[^"]*",/, "")
    # Remove sole item '"daisyui": "..."'
    |> String.replace(~r/"daisyui":\s*"[^"]*"/, "")
  end

  defp remove_require_daisyui(content) do
    content
    # "..., require('daisyui')" — last or middle item
    |> String.replace(~r/,\s*require\(["']daisyui["']\)/, "")
    # "require('daisyui'), ..." — first item
    |> String.replace(~r/require\(["']daisyui["']\),\s*/, "")
    # "require('daisyui')" — sole item
    |> String.replace(~r/require\(["']daisyui["']\)/, "")
  end

  defp remove_daisyui_config_block(content) do
    # Matches: daisyui: { ... }, — single-level config object (most common)
    String.replace(content, ~r/,?\s*daisyui:\s*\{[^}]*\}/s, "")
  end

  # ---------------------------------------------------------------------------
  # Private: output helpers
  # ---------------------------------------------------------------------------

  defp print_config_results(results) do
    Enum.each(results, fn {path, status} ->
      short = Path.relative_to_cwd(path)

      case status do
        :changed ->
          Mix.shell().info([:green, "* remove  ", :reset, short])

        :would_change ->
          Mix.shell().info([:cyan, "* would   ", :reset, short])

        :unchanged ->
          Mix.shell().info([:light_black, "* skip    ", :reset, short, " (no DaisyUI found)"])

        :not_found ->
          Mix.shell().info([:light_black, "* skip    ", :reset, short, " (not found)"])
      end
    end)

    Mix.shell().info("")
  end

  defp print_template_report([]) do
    Mix.shell().info([:green, "✓ No DaisyUI class names found in templates.\n", :reset])
  end

  defp print_template_report(hits) do
    Mix.shell().info([
      :yellow,
      "⚠  #{length(hits)} file(s) contain DaisyUI class names — manual migration required:\n",
      :reset
    ])

    Enum.each(hits, fn {path, classes} ->
      short = Path.relative_to_cwd(path)
      Mix.shell().info(["   ", :bright, short, :reset])
      Mix.shell().info([:light_black, "     classes: ", :reset, Enum.join(classes, ", ")])
    end)

    Mix.shell().info("")
  end

  defp print_next_steps(results, template_hits, dry_run?) do
    anything_changed? = Enum.any?(results, fn {_, s} -> s in [:changed, :would_change] end)

    cond do
      dry_run? and anything_changed? ->
        Mix.shell().info("Run `mix phia.undaisy` (without --dry-run) to apply these changes.")

      dry_run? ->
        Mix.shell().info("Nothing to change — no DaisyUI detected in config files.")

      anything_changed? or template_hits != [] ->
        Mix.shell().info("""
        Next steps:

          1. Uninstall the DaisyUI npm package:
               cd assets && npm uninstall daisyui
               # or: bun remove daisyui

          2. Set up PhiaUI:
               mix phia.install

          3. Replace DaisyUI classes in the template files listed above with
             PhiaUI function components.
        """)

      true ->
        Mix.shell().info("Nothing changed — no DaisyUI detected in this project.")
    end
  end
end
