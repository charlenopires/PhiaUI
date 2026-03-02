defmodule Mix.Tasks.Phia.Add do
  @moduledoc """
  Ejects a PhiaUI component into the current Phoenix project.

  Copies the component source (rendered from an EEx template) into
  `lib/{app_web}/components/{component}.ex` so the host project owns and can
  freely customise the code.

  ## Usage

      mix phia.add <component>

  ## Available components

      button    badge    card    table    dialog

  ## Behaviour

  - Derives the web module name from `Mix.Project.config()[:app]`
    (e.g., `:my_app` → `MyAppWeb`).
  - Renders the EEx template from PhiaUI's `priv/templates/components/`.
  - Writes the file with `Mix.Generator.create_file/3` (conflict-aware).
  - **Idempotent**: if the file already exists the user is prompted.
  - Prints a confirmation message via `Mix.shell().info/1`.

  ## Options

      --help    Print this help message
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
  Builds the target file path for a component under `root`.

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

  Also automatically ejects ClassMerger (a required dependency for all
  components) unless it is already present.

  Returns `:ok` on success, `:already_exists` if the file is already present,
  or `{:error, reason}` for unknown components.
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

  Creates three files:
  - `lib/{app_web}/class_merger.ex`
  - `lib/{app_web}/class_merger/cache.ex`
  - `lib/{app_web}/class_merger/groups.ex`

  Skips any file that already exists (idempotent).
  """
  @spec eject_class_merger(Path.t()) :: :ok
  def eject_class_merger(root) do
    app_web_dir = app_web_name() |> Macro.underscore()
    module = app_web_name()

    class_merger_files() |> Enum.each(fn {tpl_file, target_rel} ->
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
  if a hook template exists at `priv/templates/js/hooks/{component}.js`.

  No-op (returns `:ok`) when no hook template is found.
  Idempotent: skips copy if the target already exists.
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
  # HEEx markers in templates must be escaped as `<%%= %>` so EEx passes
  # them through as literal `<%= %>` in the output.
  defp render_template(path, module_name) do
    EEx.eval_file(path, assigns: [module_name: module_name, app_web: module_name])
  end

  # Returns [{template_filename, target_relative_path}, ...]
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
  # Each step receives a context map or passes {:error, reason} through unchanged.

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
    eject_class_merger(root)
    eject_js_hooks(name, root)
    if Mix.Generator.create_file(target, content), do: :ok, else: :already_exists
  end

  defp write_file({:error, _} = err), do: err

  defp template_path(component_name) do
    filename = "#{component_name}.ex.eex"
    # When running inside the phia_ui library itself, use priv/ directly.
    # When installed as a dep, use Application.app_dir/2.
    local = Path.join([File.cwd!(), "priv/templates/components", filename])

    if File.exists?(local) do
      local
    else
      Application.app_dir(:phia_ui, "priv/templates/components/#{filename}")
    end
  end

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
