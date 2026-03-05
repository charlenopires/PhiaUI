defmodule Mix.Tasks.Phia.Add do
  @moduledoc """
  Ejects a PhiaUI component into the current Phoenix project as an editable
  source file.

  When you run `mix phia.add`, PhiaUI renders an EEx template and writes the
  result to `lib/{app_web}/components/ui/{component}.ex`. From that point on,
  the file belongs to your project — edit it freely. This is the same
  "copy-paste ownership" model popularised by shadcn/ui.

  ## Usage

      mix phia.add <component>

  ## Available components

      button    badge    card    table    dialog

  ## What gets created

  Running `mix phia.add button` in a project called `my_app` creates:

      lib/my_app_web/components/ui/button.ex
      lib/my_app_web/class_merger.ex          (shared dependency, skipped if exists)
      lib/my_app_web/class_merger/cache.ex    (shared dependency, skipped if exists)
      lib/my_app_web/class_merger/groups.ex   (shared dependency, skipped if exists)
      assets/js/phia_hooks/{component}.js     (only for components that need a hook)

  The web module namespace (e.g., `MyAppWeb`) is derived automatically from the
  `:app` key in `mix.exs`.

  ## Behaviour

  - Derives the web module name from `Mix.Project.config()[:app]`
    (e.g., `:my_app` → `MyAppWeb`).
  - Renders the EEx template from PhiaUI's `priv/templates/components/`.
  - Writes the file with `Mix.Generator.create_file/3` (conflict-aware).
  - **Idempotent**: if the file already exists the user is prompted before
    any overwrite.
  - The `ClassMerger` utility (required by every component) is ejected
    automatically and skipped if already present.
  - Prints a confirmation message via `Mix.shell().info/1`.

  ## Next steps after ejecting

  1. Run `mix phia.install` once (if you haven't already) to inject PhiaUI
     theme tokens into `assets/css/app.css`.
  2. Add `ClassMerger.Cache` to your supervision tree:
       children = [MyAppWeb.ClassMerger.Cache, ...]
  3. Import the component in any LiveView or layout:
       import MyAppWeb.Components.UI.Button

  ## Options

      --help    Print this help message

  ## Examples

      $ mix phia.add button
      * create lib/my_app_web/components/ui/button.ex

      $ mix phia.add dialog
      * create lib/my_app_web/components/ui/dialog.ex
      * create assets/js/phia_hooks/dialog.js
  """

  use Mix.Task

  @shortdoc "Ejects a PhiaUI component into your project"

  @known_components ~w(button badge card table dialog)

  @impl Mix.Task
  def run(["--help"]) do
    Mix.shell().info(@moduledoc)
  end

  def run([component | _]) do
    root = File.cwd!()

    case eject_component(component, root) do
      :ok ->
        target = component_path(root, component)
        Mix.shell().info([:green, "* create ", :reset, target])

      :already_exists ->
        target = component_path(root, component)
        Mix.shell().info([:yellow, "* exists  ", :reset, target])

      {:error, reason} ->
        Mix.shell().error(reason)
    end
  end

  def run([]) do
    Mix.shell().error("""
    Usage: mix phia.add <component>

    Available components: #{Enum.join(@known_components, ", ")}
    """)
  end

  @doc """
  Derives the host project's web module name from the current Mix project.

  The web module name is the camelized app name suffixed with `"Web"`. For
  example, a project with `app: :my_app` returns `"MyAppWeb"`.

  ## Example

      iex> Mix.Tasks.Phia.Add.app_web_name()
      "PhiaUiWeb"
  """
  @spec app_web_name() :: String.t()
  def app_web_name do
    app = Mix.Project.config()[:app]
    app |> to_string() |> Macro.camelize() |> then(&"#{&1}Web")
  end

  @doc """
  Builds the absolute target file path for a component under `root`.

  The path follows the Phoenix convention of placing UI components under
  `lib/{app_web_dir}/components/ui/`.

  ## Example

      iex> Mix.Tasks.Phia.Add.component_path("/project", "button")
      "/project/lib/phia_ui_web/components/ui/button.ex"
  """
  @spec component_path(Path.t(), String.t()) :: Path.t()
  def component_path(root, component_name) do
    app_web_dir = app_web_name() |> Macro.underscore()
    Path.join([root, "lib", app_web_dir, "components", "ui", "#{component_name}.ex"])
  end

  @doc """
  Ejects a component from PhiaUI's templates into `root`.

  This is the main entry point called by `run/1`. It runs a pipeline of
  steps: validate → resolve_target → render_content → write_file.

  Also automatically ejects the `ClassMerger` utility (a required dependency
  shared by all components) unless it is already present.

  ## Return values

  - `:ok` — component was created successfully.
  - `:already_exists` — file already existed; user was prompted.
  - `{:error, reason}` — component name is not in the known components list.

  ## Example

      iex> Mix.Tasks.Phia.Add.eject_component("button", "/tmp/my_project")
      :ok
  """
  @spec eject_component(String.t(), Path.t()) :: :ok | :already_exists | {:error, String.t()}
  def eject_component(component_name, root \\ File.cwd!()) do
    %{component: component_name, root: root}
    |> validate()
    |> resolve_target()
    |> render_content()
    |> write_file()
  end

  @doc """
  Ejects the ClassMerger dependency files into `root`.

  `ClassMerger` is a Tailwind CSS class conflict resolver (similar to
  `tailwind-merge`) implemented in pure Elixir. Every PhiaUI component imports
  the `cn/1` helper it provides, so it must be present in the host project.

  Creates three files relative to `lib/{app_web_dir}/`:

  - `class_merger.ex` — main `cn/1` function
  - `class_merger/cache.ex` — ETS-backed GenServer cache
  - `class_merger/groups.ex` — Tailwind conflict group mappings

  Skips any file that already exists, making this function safe to call
  repeatedly.
  """
  @spec eject_class_merger(Path.t()) :: :ok
  def eject_class_merger(root) do
    app_web_dir = app_web_name() |> Macro.underscore()
    module = app_web_name()

    class_merger_files()
    |> Enum.each(fn {tpl_file, target_rel} ->
      target = Path.join([root, "lib", app_web_dir, target_rel])

      unless File.exists?(target) do
        tpl = class_merger_template_path(tpl_file)
        content = render_template(tpl, module)
        File.mkdir_p!(Path.dirname(target))
        File.write!(target, content)
      end
    end)

    :ok
  end

  @doc """
  Copies the JS hook file for `component_name` into `root/assets/js/phia_hooks/`
  if a corresponding hook template exists at `priv/templates/js/hooks/{component}.js`.

  Components such as Dialog, DropdownMenu, and Toast require a client-side
  JavaScript hook for browser interactions (focus trapping, keyboard handling,
  etc.). This function handles that copy automatically during ejection.

  No-op (returns `:ok`) when no hook template is found for the given component.
  Idempotent: skips the copy if the target hook file already exists.
  """
  @spec eject_js_hooks(String.t(), Path.t()) :: :ok
  def eject_js_hooks(component_name, root) do
    case js_hook_template_path(component_name) do
      {:ok, template} ->
        hook_dir = Path.join([root, "assets", "js", "phia_hooks"])
        target = Path.join(hook_dir, "#{component_name}.js")

        unless File.exists?(target) do
          File.mkdir_p!(hook_dir)
          File.cp!(template, target)
        end

        :ok

      :not_found ->
        :ok
    end
  end

  @doc """
  Returns a next-steps message to display after ejecting `component_name`.

  This message reminds the developer to run `mix phia.install`, add
  `ClassMerger.Cache` to their supervision tree, and import the component.
  """
  @spec next_steps_message(String.t()) :: String.t()
  def next_steps_message(component_name) do
    app_web = app_web_name()

    """
    Next steps for #{component_name}:

    1. Run `mix phia.install` to inject the PhiaUI theme tokens into app.css
       (if you haven't already).

    2. Add ClassMerger to your supervision tree in application.ex:
         children = [#{app_web}.ClassMerger.Cache, ...]

    3. Import the component where needed:
         import #{app_web}.Components.UI.#{Macro.camelize(component_name)}
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  # Renders an EEx template with `module_name` and `app_web` assigns.
  #
  # Templates use `<%%= %>` for HEEx markers so that EEx passes them through
  # as literal `<%= %>` in the generated output file. This prevents EEx from
  # trying to evaluate HEEx expressions during the ejection step.
  defp render_template(path, module_name) do
    EEx.eval_file(path, assigns: [module_name: module_name, app_web: module_name])
  end

  # Returns [{template_filename, target_relative_path}, ...] for the three
  # ClassMerger source files that must be co-located with components.
  defp class_merger_files do
    [
      {"class_merger.ex.eex", "class_merger.ex"},
      {"cache.ex.eex", "class_merger/cache.ex"},
      {"groups.ex.eex", "class_merger/groups.ex"}
    ]
  end

  defp class_merger_template_path(filename) do
    local = Path.join([File.cwd!(), "priv/templates/class_merger", filename])

    if File.exists?(local) do
      local
    else
      Application.app_dir(:phia_ui, "priv/templates/class_merger/#{filename}")
    end
  end

  # Pipeline steps for eject_component/2.
  # Each step receives a context map and enriches it, or short-circuits with
  # {:error, reason} which is then passed through unchanged by all downstream
  # steps (railway-oriented programming pattern).

  defp validate(%{component: name} = ctx) do
    if name in @known_components do
      ctx
    else
      {:error, "Unknown component: #{name}. Available: #{Enum.join(@known_components, ", ")}"}
    end
  end

  defp resolve_target(%{component: name, root: root} = ctx) do
    ctx
    |> Map.put(:target, component_path(root, name))
    |> Map.put(:template, template_path(name))
  end

  defp resolve_target({:error, _} = err), do: err

  defp render_content(%{template: tpl} = ctx) do
    Map.put(ctx, :content, render_template(tpl, app_web_name()))
  end

  defp render_content({:error, _} = err), do: err

  defp write_file(%{target: target, content: content, component: name, root: root}) do
    File.mkdir_p!(Path.dirname(target))
    # Always eject ClassMerger first so the component's import can resolve.
    eject_class_merger(root)
    # Copy the JS hook file if one exists for this component.
    eject_js_hooks(name, root)
    if Mix.Generator.create_file(target, content), do: :ok, else: :already_exists
  end

  defp write_file({:error, _} = err), do: err

  # Resolves the EEx template path for a component.
  # Prefers a local priv/ path (useful when developing phia_ui itself) and
  # falls back to the installed application's priv directory.
  defp template_path(component_name) do
    filename = "#{component_name}.ex.eex"
    local_base = Path.join([File.cwd!(), "priv/templates/components"])

    case Path.wildcard(Path.join(local_base, "**/#{filename}")) do
      [path | _] ->
        path

      [] ->
        installed_base = Application.app_dir(:phia_ui, "priv/templates/components")

        case Path.wildcard(Path.join(installed_base, "**/#{filename}")) do
          [path | _] -> path
          [] -> Path.join(local_base, filename)
        end
    end
  end

  # Resolves the JS hook template path for a component.
  # Returns {:ok, path} when found, :not_found when the component has no hook.
  defp js_hook_template_path(component_name) do
    filename = "#{component_name}.js"
    local = Path.join([File.cwd!(), "priv/templates/js/hooks", filename])

    if File.exists?(local) do
      {:ok, local}
    else
      installed = Application.app_dir(:phia_ui, "priv/templates/js/hooks/#{filename}")

      if File.exists?(installed) do
        {:ok, installed}
      else
        :not_found
      end
    end
  end
end
