defmodule Mix.Tasks.Phia.Add do
  @moduledoc """
  Ejects a PhiaUI component into the current Phoenix project.

  Copies the component source (rendered from an EEx template) into
  `lib/{app_web}/components/{component}.ex` so the host project owns and can
  freely customise the code.

  ## Usage

      mix phia.add <component>

  ## Available components

      button    badge    card    table

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

  @known_components ~w(button badge card table)

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
      "/project/lib/phia_ui_web/components/button.ex"
  """
  @spec component_path(Path.t(), String.t()) :: Path.t()
  def component_path(root, component_name) do
    app_web_dir = app_web_name() |> Macro.underscore()
    Path.join([root, "lib", app_web_dir, "components", "#{component_name}.ex"])
  end

  @doc """
  Ejects a component from PhiaUI's templates into `root`.

  Returns `:ok` on success, `:already_exists` if the file is already present
  and the user declines to overwrite, or `{:error, reason}` for unknown
  components.
  """
  @spec eject_component(String.t(), Path.t()) :: :ok | :already_exists | {:error, String.t()}
  def eject_component(component_name, root \\ File.cwd!()) do
    with {:ok, template_path} <- resolve_template(component_name) do
      target = component_path(root, component_name)
      module = app_web_name()
      content = render_template(template_path, module)
      File.mkdir_p!(Path.dirname(target))

      if File.exists?(target) do
        :already_exists
      else
        File.write!(target, content)
        :ok
      end
    end
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  # Substitutes the `<%= @module %>` placeholder in the template with the
  # actual module name. All other `<%= %>` markers in the template are HEEx /
  # docstring literals that must pass through unchanged, so we avoid running
  # EEx.eval_file which would try to compile them as Elixir expressions.
  defp render_template(path, module_name) do
    path
    |> File.read!()
    |> String.replace("<%= @module %>", module_name)
  end

  defp resolve_template(component_name) do
    if component_name in @known_components do
      {:ok, template_path(component_name)}
    else
      {:error,
       "Unknown component: #{component_name}. Available: #{Enum.join(@known_components, ", ")}"}
    end
  end

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
end
