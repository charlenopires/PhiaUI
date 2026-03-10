defmodule PhiaUiDesign.Codegen.LiveviewEmitter do
  @moduledoc """
  Generates a complete Phoenix LiveView module source string from a scene graph.

  The output is a ready-to-paste `.ex` file containing:

  - `use MyAppWeb, :live_view`
  - `import` statements for every PhiaUI module referenced by components in the scene
  - A `mount/3` callback that assigns any specified initial state
  - A `render/1` callback containing the emitted HEEx template
  - Optional `handle_event/3` callbacks

  Also provides helpers to list required JS hooks and `mix phia.add` commands
  so the consumer app can install everything the design needs.
  """

  alias PhiaUiDesign.Canvas.Scene
  alias PhiaUiDesign.Codegen.HeexEmitter

  @doc """
  Generate a complete LiveView module source string.

  ## Parameters

  - `scene` - the ETS scene reference
  - `module_name` - fully-qualified module name string, e.g. `"MyAppWeb.DashboardLive"`

  ## Options

  - `:web_module` - the Phoenix web module (default: `"MyAppWeb"`)
  - `:assigns` - map of assigns to set in `mount/3` (default: `%{}`)
  - `:events` - list of `{event_name, body_string}` tuples for `handle_event/3` callbacks (default: `[]`)
  """
  @spec emit(reference(), String.t(), keyword()) :: String.t()
  def emit(scene, module_name, opts \\ []) do
    web_module = Keyword.get(opts, :web_module, "MyAppWeb")
    heex = HeexEmitter.emit(scene, indent: 4)
    components = Scene.components_used(scene)
    imports = build_imports(components)
    assigns_code = build_mount_assigns(Keyword.get(opts, :assigns, %{}))
    events_code = build_event_handlers(Keyword.get(opts, :events, []))

    [
      "defmodule #{module_name} do",
      "  use #{web_module}, :live_view",
      "",
      imports,
      "  @impl true",
      "  def mount(_params, _session, socket) do",
      "    {:ok, assign(socket#{assigns_code})}",
      "  end",
      "",
      "  @impl true",
      "  def render(assigns) do",
      "    ~H\"\"\"",
      heex,
      "    \"\"\"",
      "  end",
      events_code,
      "end"
    ]
    |> List.flatten()
    |> Enum.reject(&is_nil/1)
    |> Enum.join("\n")
    |> Kernel.<>("\n")
  end

  @doc """
  Generate import statements for the modules that provide the used components.

  Looks up each component key in `PhiaUi.ComponentRegistry`, collects the
  unique modules, and returns a list of `import Module` lines.
  """
  @spec generate_imports([atom()]) :: String.t()
  def generate_imports(component_keys) do
    component_keys
    |> resolve_modules()
    |> Enum.map(fn mod -> "  import #{inspect(mod)}" end)
    |> Enum.join("\n")
  end

  @doc """
  Return the list of JS hook names required by the given component keys.

  The hooks must be registered in the LiveSocket on the client side.
  """
  @spec required_hooks([atom()]) :: [String.t()]
  def required_hooks(component_keys) do
    component_keys
    |> Enum.map(&PhiaUi.ComponentRegistry.get/1)
    |> Enum.reject(&is_nil/1)
    |> Enum.flat_map(& &1.js_hooks)
    |> Enum.uniq()
    |> Enum.sort()
  end

  @doc """
  Return the `mix phia.add` commands needed to install all used components.
  """
  @spec required_add_commands([atom()]) :: [String.t()]
  def required_add_commands(component_keys) do
    component_keys
    |> Enum.sort()
    |> Enum.map(fn key -> "mix phia.add #{key}" end)
  end

  # ---------------------------------------------------------------------------
  # Private
  # ---------------------------------------------------------------------------

  defp resolve_modules(component_keys) do
    component_keys
    |> Enum.map(&PhiaUi.ComponentRegistry.get/1)
    |> Enum.reject(&is_nil/1)
    |> Enum.map(& &1.module)
    |> Enum.uniq()
    |> Enum.sort()
  end

  defp build_imports(component_keys) do
    lines = generate_imports(component_keys)

    if lines == "" do
      nil
    else
      lines <> "\n"
    end
  end

  defp build_mount_assigns(assigns) when map_size(assigns) == 0, do: ""

  defp build_mount_assigns(assigns) do
    pairs =
      assigns
      |> Enum.sort_by(fn {k, _v} -> to_string(k) end)
      |> Enum.map(fn {k, v} -> "#{k}: #{inspect(v)}" end)

    ", " <> Enum.join(pairs, ", ")
  end

  defp build_event_handlers([]), do: nil

  defp build_event_handlers(events) do
    handlers =
      Enum.map(events, fn {name, body} ->
        [
          "",
          "  @impl true",
          "  def handle_event(\"#{name}\", params, socket) do",
          "    #{body}",
          "  end"
        ]
      end)

    List.flatten(handlers) |> Enum.join("\n")
  end
end
