defmodule PhiaUiDesign.Web.EditorLive do
  @moduledoc """
  Main LiveView for the PhiaUI Design visual editor.

  Orchestrates the entire editor UI:

  - **Toolbar** — undo/redo, theme selector, responsive preview, templates, save/load, export
  - **Left panel** — component catalog (searchable, grouped by tier) and layer tree
  - **Canvas** — real component rendering with selection overlays
  - **Right panel** — property inspector for the selected node and real-time code generation

  ## Architecture

  State is held in:

  - `Scene` — ETS-backed scene graph (nodes, parent-child relations)
  - `Selection` — plain struct tracking selected / hovered node IDs
  - `History` — Agent-backed undo/redo command stack

  Every user action (insert, delete, update) mutates the Scene ETS
  table, pushes a command to History, and recomputes the derived
  assigns (`:tree`, `:selected_node`, `:generated_code`).
  """

  use Phoenix.LiveView

  alias PhiaUiDesign.Canvas.{Scene, History, Selection, Persistence}
  alias PhiaUiDesign.Codegen.{HeexEmitter, LiveviewEmitter}
  alias PhiaUiDesign.Templates.PageTemplates
  alias PhiaUiDesign.Web.ComponentRenderer

  # ---------------------------------------------------------------------------
  # Lifecycle
  # ---------------------------------------------------------------------------

  @impl true
  def mount(_params, _session, socket) do
    scene = Scene.new()
    {:ok, history} = History.start_link()

    catalog =
      try do
        PhiaUiDesign.Catalog.CatalogServer.by_tier()
      rescue
        _ -> []
      end

    templates = PageTemplates.list()

    socket =
      socket
      |> assign(:scene, scene)
      |> assign(:history, history)
      |> assign(:selection, Selection.new())
      |> assign(:catalog, catalog)
      |> assign(:search_query, "")
      |> assign(:filtered_catalog, catalog)
      |> assign(:selected_node, nil)
      |> assign(:generated_code, "")
      |> assign(:code_format, :heex)
      |> assign(:current_theme, :zinc)
      |> assign(:panel, :components)
      |> assign(:tree, [])
      |> assign(:templates, templates)
      |> assign(:show_templates, false)
      |> assign(:viewport, :desktop)
      |> update_tree()
      |> update_code()

    {:ok, socket}
  end

  # ---------------------------------------------------------------------------
  # Render
  # ---------------------------------------------------------------------------

  @impl true
  def render(assigns) do
    ~H"""
    <div class="editor-layout" id="editor" phx-hook="EditorKeyboard">
      <%!-- ── Toolbar ── --%>
      <div class="editor-toolbar">
        <span style="font-weight:700;font-size:0.875rem;margin-right:0.5rem;">
          PhiaUI Design
        </span>

        <button class="toolbar-btn" phx-click="show_templates">
          Templates
        </button>

        <span style="flex:1;"></span>

        <%!-- Viewport controls (Phase F) --%>
        <div class="viewport-controls">
          <button
            class={"viewport-btn #{if @viewport == :desktop, do: "viewport-btn-active"}"}
            phx-click="set_viewport"
            phx-value-size="desktop"
            title="Desktop"
          >
            D
          </button>
          <button
            class={"viewport-btn #{if @viewport == :tablet, do: "viewport-btn-active"}"}
            phx-click="set_viewport"
            phx-value-size="tablet"
            title="Tablet (768px)"
          >
            T
          </button>
          <button
            class={"viewport-btn #{if @viewport == :mobile, do: "viewport-btn-active"}"}
            phx-click="set_viewport"
            phx-value-size="mobile"
            title="Mobile (375px)"
          >
            M
          </button>
        </div>

        <span class="toolbar-separator"></span>

        <button class="toolbar-btn" phx-click="undo" disabled={!History.can_undo?(@history)}>
          Undo
        </button>
        <button class="toolbar-btn" phx-click="redo" disabled={!History.can_redo?(@history)}>
          Redo
        </button>

        <span class="toolbar-separator"></span>

        <select name="theme" phx-change="change_theme" class="theme-select">
          <option
            :for={t <- ~w(zinc slate blue rose orange green violet neutral)}
            value={t}
            selected={String.to_atom(t) == @current_theme}
          >
            {t}
          </option>
        </select>

        <span class="toolbar-separator"></span>

        <button class="toolbar-btn" phx-click="save_project">
          Save
        </button>

        <button class="toolbar-btn toolbar-btn-primary" phx-click="export_code">
          Export
        </button>
      </div>

      <%!-- ── Left Panel ── --%>
      <div class="editor-left-panel">
        <%!-- Panel tabs --%>
        <div style="display:flex;border-bottom:1px solid hsl(var(--border,240 5.9% 90%));">
          <button
            class={"tab-btn #{if @panel == :components, do: "tab-btn-active"}"}
            phx-click="set_panel"
            phx-value-panel="components"
          >
            Components
          </button>
          <button
            class={"tab-btn #{if @panel == :layers, do: "tab-btn-active"}"}
            phx-click="set_panel"
            phx-value-panel="layers"
          >
            Layers
          </button>
        </div>

        <%!-- Components panel --%>
        <div :if={@panel == :components}>
          <div class="panel-section">
            <input
              type="search"
              placeholder="Search components..."
              phx-change="search_components"
              phx-debounce="200"
              name="query"
              value={@search_query}
              class="property-input"
              style="width:100%;"
            />
          </div>
          <div :for={{tier, components} <- @filtered_catalog} class="panel-section">
            <div class="panel-section-title">{tier}</div>
            <div
              :for={comp <- components}
              class="component-item"
              phx-click="insert_component"
              phx-value-name={comp.name}
            >
              {comp.name}
            </div>
          </div>
        </div>

        <%!-- Layers panel --%>
        <div :if={@panel == :layers} style="padding:0.5rem;">
          <div :if={@tree == []} class="props-empty">
            Empty canvas. Add components from the panel.
          </div>
          <.render_layer_tree tree={@tree} selection={@selection} />
        </div>
      </div>

      <%!-- ── Canvas ── --%>
      <div class="editor-canvas" id="canvas" phx-click="canvas_click">
        <div :if={@tree == []} class="empty-state">
          <div class="empty-state-inner">
            <p class="empty-state-title">Empty Canvas</p>
            <p class="empty-state-text">
              Click a component on the left panel to add it, or use Templates to start with a page layout.
            </p>
          </div>
        </div>
        <div
          :if={@tree != []}
          class="canvas-content canvas-viewport"
          style={viewport_style(@viewport)}
        >
          <.render_canvas_tree tree={@tree} scene={@scene} selection={@selection} />
        </div>
      </div>

      <%!-- ── Right Panel ── --%>
      <div class="editor-right-panel">
        <%!-- Properties --%>
        <div :if={@selected_node}>
          <div class="panel-section">
            <div class="panel-section-title">Properties — {@selected_node.name}</div>
            <div :for={{key, value} <- @selected_node.attrs} class="property-row">
              <label class="property-label">{key}</label>
              <input
                class="property-input"
                name={"attr-#{key}"}
                value={to_string(value)}
                phx-change="update_attr"
                phx-value-key={key}
                phx-debounce="300"
              />
            </div>
          </div>
          <div class="panel-section">
            <div class="panel-section-title">Slots</div>
            <div :for={{slot_name, content} <- @selected_node.slots} class="property-row">
              <label class="property-label">{slot_name}</label>
              <input
                class="property-input"
                name={"slot-#{slot_name}"}
                value={content || ""}
                phx-change="update_slot"
                phx-value-slot={slot_name}
                phx-debounce="300"
              />
            </div>
          </div>
          <div class="panel-section">
            <button
              class="toolbar-btn delete-btn"
              phx-click="delete_node"
              phx-value-id={@selected_node.id}
            >
              Delete
            </button>
          </div>
        </div>
        <div :if={!@selected_node} class="panel-section props-empty">
          Select a node to edit its properties.
        </div>

        <%!-- Code panel --%>
        <div class="code-divider">
          <div class="code-tabs">
            <button
              class={"tab-btn #{if @code_format == :heex, do: "tab-btn-active"}"}
              phx-click="set_code_format"
              phx-value-format="heex"
            >
              HEEx
            </button>
            <button
              class={"tab-btn #{if @code_format == :liveview, do: "tab-btn-active"}"}
              phx-click="set_code_format"
              phx-value-format="liveview"
            >
              LiveView
            </button>
          </div>
          <div class="code-panel">
            <pre><code>{@generated_code}</code></pre>
          </div>
          <div class="panel-section">
            <button
              class="toolbar-btn copy-btn"
              phx-click="copy_code"
              id="copy-btn"
              phx-hook="CopyClipboard"
              data-code={@generated_code}
            >
              Copy Code
            </button>
          </div>
        </div>
      </div>

      <%!-- ── Template Modal (Phase D) ── --%>
      <div :if={@show_templates} class="modal-backdrop" phx-click="hide_templates">
        <div class="modal-content" phx-click-away="hide_templates">
          <div class="modal-header">
            <span class="modal-title">New from Template</span>
            <button class="toolbar-btn" phx-click="hide_templates">Close</button>
          </div>
          <div class="template-grid">
            <div
              :for={tpl <- @templates}
              class="template-card"
              phx-click="apply_template"
              phx-value-key={tpl.key}
            >
              <div class="template-card-name">{tpl.name}</div>
              <div class="template-card-desc">{tpl.description}</div>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Canvas tree renderer
  # ---------------------------------------------------------------------------

  defp render_canvas_tree(assigns) do
    ~H"""
    <div :for={tree_node <- @tree}>
      <.render_canvas_node tree_node={tree_node} scene={@scene} selection={@selection} />
    </div>
    """
  end

  defp render_canvas_node(assigns) do
    node = assigns.tree_node.node
    children = assigns.tree_node.children
    selected = Selection.selected?(assigns.selection, node.id)

    # Phase A: attempt real component rendering
    preview_html =
      if node.type == :phia_component and node.module do
        case ComponentRenderer.render_to_html(node.module, node.component, node.attrs, node.slots) do
          {:ok, html} -> Phoenix.HTML.raw(html)
          _ -> nil
        end
      end

    assigns =
      assigns
      |> assign(:node, node)
      |> assign(:children, children)
      |> assign(:selected, selected)
      |> assign(:preview_html, preview_html)

    ~H"""
    <div
      class="node-wrapper"
      data-node-id={@node.id}
      data-selected={to_string(@selected)}
      phx-click="select_node"
      phx-value-id={@node.id}
      style="cursor:pointer;"
    >
      <div :if={@preview_html} class="component-preview">
        {@preview_html}
      </div>
      <div :if={!@preview_html}>
        <.render_node_content
          node={@node}
          children={@children}
          scene={@scene}
          selection={@selection}
        />
      </div>
    </div>
    """
  end

  # PhiaUI component — placeholder fallback
  defp render_node_content(%{node: %{type: :phia_component}} = assigns) do
    ~H"""
    <div class="node-placeholder" data-component={@node.component}>
      <span class="node-label">
        &lt;.{@node.component}&gt;
      </span>
      <span :if={@node.slots[:inner_block]} class="node-inner-text">
        {@node.slots[:inner_block]}
      </span>
      <div :if={@children != []} class="node-children">
        <div :for={child <- @children}>
          <.render_canvas_node tree_node={child} scene={@scene} selection={@selection} />
        </div>
      </div>
    </div>
    """
  end

  # HTML element
  defp render_node_content(%{node: %{type: :html_element}} = assigns) do
    ~H"""
    <div style="padding:0.5rem;" class={@node.classes}>
      <div :if={@children != []}>
        <div :for={child <- @children}>
          <.render_canvas_node tree_node={child} scene={@scene} selection={@selection} />
        </div>
      </div>
    </div>
    """
  end

  # Text node
  defp render_node_content(%{node: %{type: :text}} = assigns) do
    ~H"""
    <span>{@node.text_content}</span>
    """
  end

  # Frame (grouping container)
  defp render_node_content(%{node: %{type: :frame}} = assigns) do
    ~H"""
    <div class={@node.classes} style="padding:0.5rem;">
      <div :if={@children != []}>
        <div :for={child <- @children}>
          <.render_canvas_node tree_node={child} scene={@scene} selection={@selection} />
        </div>
      </div>
    </div>
    """
  end

  # Fallback
  defp render_node_content(assigns) do
    ~H"""
    <div>Unknown node type</div>
    """
  end

  # ---------------------------------------------------------------------------
  # Layer tree renderer
  # ---------------------------------------------------------------------------

  defp render_layer_tree(assigns) do
    ~H"""
    <div :for={tree_node <- @tree}>
      <.render_layer_node tree_node={tree_node} selection={@selection} depth={0} />
    </div>
    """
  end

  defp render_layer_node(assigns) do
    node = assigns.tree_node.node
    children = assigns.tree_node.children
    selected = Selection.selected?(assigns.selection, node.id)

    assigns =
      assigns
      |> assign(:node, node)
      |> assign(:children, children)
      |> assign(:selected, selected)

    ~H"""
    <div
      class="layer-item"
      data-selected={to_string(@selected)}
      style={"padding-left:#{@depth * 16 + 8}px"}
      phx-click="select_node"
      phx-value-id={@node.id}
    >
      <span style="font-size:0.6875rem;opacity:0.5;">
        {layer_icon(@node.type)}
      </span>
      <span>{@node.name}</span>
    </div>
    <div :for={child <- @children}>
      <.render_layer_node tree_node={child} selection={@selection} depth={@depth + 1} />
    </div>
    """
  end

  defp layer_icon(:phia_component), do: "\u25C6"
  defp layer_icon(:html_element), do: "\u25A1"
  defp layer_icon(:text), do: "T"
  defp layer_icon(:frame), do: "\u25A2"
  defp layer_icon(_), do: "\u00B7"

  # ---------------------------------------------------------------------------
  # Event handlers
  # ---------------------------------------------------------------------------

  @impl true
  def handle_event("insert_component", %{"name" => name}, socket) do
    component_key =
      try do
        String.to_existing_atom(name)
      rescue
        ArgumentError -> String.to_atom(name)
      end

    parent_id = Selection.single_selected(socket.assigns.selection)

    default_slots = %{inner_block: default_content(component_key)}

    {:ok, node} =
      Scene.insert_component(
        socket.assigns.scene,
        component_key,
        attrs: default_attrs(component_key),
        slots: default_slots,
        parent_id: parent_id
      )

    History.push(socket.assigns.history, {:insert, node})

    socket =
      socket
      |> assign(:selection, Selection.select(socket.assigns.selection, node.id))
      |> update_selected_node()
      |> update_tree()
      |> update_code()

    {:noreply, socket}
  end

  def handle_event("select_node", %{"id" => id}, socket) do
    socket =
      socket
      |> assign(:selection, Selection.select(socket.assigns.selection, id))
      |> update_selected_node()

    {:noreply, socket}
  end

  def handle_event("canvas_click", _params, socket) do
    socket =
      socket
      |> assign(:selection, Selection.clear(socket.assigns.selection))
      |> assign(:selected_node, nil)

    {:noreply, socket}
  end

  def handle_event("delete_node", %{"id" => id}, socket) do
    case Scene.get_node(socket.assigns.scene, id) do
      {:ok, node} ->
        History.push(socket.assigns.history, {:delete, node})
        Scene.delete_node(socket.assigns.scene, id)

        socket =
          socket
          |> assign(:selection, Selection.clear(socket.assigns.selection))
          |> assign(:selected_node, nil)
          |> update_tree()
          |> update_code()

        {:noreply, socket}

      _ ->
        {:noreply, socket}
    end
  end

  def handle_event("update_attr", %{"key" => key, "value" => value}, socket) do
    case Selection.single_selected(socket.assigns.selection) do
      nil ->
        {:noreply, socket}

      node_id ->
        parsed_value = parse_attr_value(value)
        attr_key = safe_to_existing_atom(key)
        Scene.update_attrs(socket.assigns.scene, node_id, %{attr_key => parsed_value})

        socket =
          socket
          |> update_selected_node()
          |> update_tree()
          |> update_code()

        {:noreply, socket}
    end
  end

  def handle_event("update_slot", %{"slot" => slot_name, "value" => value}, socket) do
    case Selection.single_selected(socket.assigns.selection) do
      nil ->
        {:noreply, socket}

      node_id ->
        case Scene.get_node(socket.assigns.scene, node_id) do
          {:ok, node} ->
            new_slots = Map.put(node.slots, String.to_atom(slot_name), value)
            Scene.update_node(socket.assigns.scene, node_id, %{slots: new_slots})

            socket =
              socket
              |> update_selected_node()
              |> update_tree()
              |> update_code()

            {:noreply, socket}

          _ ->
            {:noreply, socket}
        end
    end
  end

  def handle_event("search_components", %{"query" => query}, socket) do
    filtered =
      if query == "" do
        socket.assigns.catalog
      else
        query_down = String.downcase(query)

        socket.assigns.catalog
        |> Enum.map(fn {tier, comps} ->
          filtered_comps =
            Enum.filter(comps, fn c ->
              String.contains?(String.downcase(c.name), query_down)
            end)

          {tier, filtered_comps}
        end)
        |> Enum.reject(fn {_tier, comps} -> comps == [] end)
      end

    {:noreply, assign(socket, search_query: query, filtered_catalog: filtered)}
  end

  def handle_event("set_panel", %{"panel" => panel}, socket) do
    {:noreply, assign(socket, :panel, String.to_existing_atom(panel))}
  end

  def handle_event("set_code_format", %{"format" => format}, socket) do
    socket =
      socket
      |> assign(:code_format, String.to_existing_atom(format))
      |> update_code()

    {:noreply, socket}
  end

  def handle_event("change_theme", %{"theme" => theme}, socket) do
    {:noreply, assign(socket, :current_theme, String.to_existing_atom(theme))}
  end

  # Phase D: Template picker
  def handle_event("show_templates", _params, socket) do
    {:noreply, assign(socket, :show_templates, true)}
  end

  def handle_event("hide_templates", _params, socket) do
    {:noreply, assign(socket, :show_templates, false)}
  end

  def handle_event("apply_template", %{"key" => key}, socket) do
    template_key = safe_to_existing_atom(key)

    case PageTemplates.apply_template(socket.assigns.scene, template_key) do
      {:ok, _scene} ->
        socket =
          socket
          |> assign(:show_templates, false)
          |> assign(:selection, Selection.clear(socket.assigns.selection))
          |> assign(:selected_node, nil)
          |> update_tree()
          |> update_code()

        {:noreply, put_flash(socket, :info, "Template applied!")}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Failed to apply template.")}
    end
  end

  # Phase F: Responsive preview
  def handle_event("set_viewport", %{"size" => size}, socket) do
    viewport = safe_to_existing_atom(size)
    {:noreply, assign(socket, :viewport, viewport)}
  end

  # Phase C: Save project
  def handle_event("save_project", _params, socket) do
    path = default_project_path()

    case Persistence.save(socket.assigns.scene, path, theme: socket.assigns.current_theme) do
      :ok ->
        {:noreply, put_flash(socket, :info, "Saved to #{path}")}

      {:error, reason} ->
        {:noreply, put_flash(socket, :error, "Save failed: #{inspect(reason)}")}
    end
  end

  def handle_event("undo", _params, socket) do
    case History.undo(socket.assigns.history) do
      {:insert, node} ->
        Scene.delete_node(socket.assigns.scene, node.id)

        socket =
          socket
          |> assign(:selection, Selection.clear(socket.assigns.selection))
          |> assign(:selected_node, nil)
          |> update_tree()
          |> update_code()

        {:noreply, socket}

      {:delete, node} ->
        Scene.insert(socket.assigns.scene, node)

        socket =
          socket
          |> update_tree()
          |> update_code()

        {:noreply, socket}

      _ ->
        {:noreply, socket}
    end
  end

  def handle_event("redo", _params, socket) do
    case History.redo(socket.assigns.history) do
      {:insert, node} ->
        Scene.insert(socket.assigns.scene, node)

        socket =
          socket
          |> update_tree()
          |> update_code()

        {:noreply, socket}

      {:delete, node} ->
        Scene.delete_node(socket.assigns.scene, node.id)

        socket =
          socket
          |> assign(:selection, Selection.clear(socket.assigns.selection))
          |> assign(:selected_node, nil)
          |> update_tree()
          |> update_code()

        {:noreply, socket}

      _ ->
        {:noreply, socket}
    end
  end

  def handle_event("export_code", _params, socket) do
    {:noreply, put_flash(socket, :info, "Code exported! Use Copy to clipboard.")}
  end

  def handle_event("copy_code", _params, socket) do
    # Clipboard write is handled client-side by the CopyClipboard hook
    {:noreply, socket}
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  defp update_tree(socket) do
    tree = Scene.to_tree(socket.assigns.scene)
    assign(socket, :tree, tree)
  end

  defp update_selected_node(socket) do
    case Selection.single_selected(socket.assigns.selection) do
      nil ->
        assign(socket, :selected_node, nil)

      id ->
        case Scene.get_node(socket.assigns.scene, id) do
          {:ok, node} -> assign(socket, :selected_node, node)
          _ -> assign(socket, :selected_node, nil)
        end
    end
  end

  defp update_code(socket) do
    code =
      case socket.assigns.code_format do
        :heex -> HeexEmitter.emit(socket.assigns.scene)
        :liveview -> LiveviewEmitter.emit(socket.assigns.scene, "MyAppWeb.DesignedLive")
      end

    assign(socket, :generated_code, code)
  end

  defp parse_attr_value("true"), do: true
  defp parse_attr_value("false"), do: false

  defp parse_attr_value(":" <> atom_str) do
    safe_to_existing_atom(atom_str)
  end

  defp parse_attr_value(value) do
    case Integer.parse(value) do
      {int, ""} ->
        int

      _ ->
        case Float.parse(value) do
          {f, ""} -> f
          _ -> value
        end
    end
  end

  defp safe_to_existing_atom(str) do
    String.to_existing_atom(str)
  rescue
    ArgumentError -> String.to_atom(str)
  end

  defp default_attrs(:button), do: %{variant: :default, size: :default}
  defp default_attrs(:badge), do: %{variant: :default}
  defp default_attrs(:input), do: %{type: "text", placeholder: "Enter text..."}
  defp default_attrs(_), do: %{}

  defp default_content(:button), do: "Button"
  defp default_content(:badge), do: "Badge"
  defp default_content(:card), do: nil

  defp default_content(name) do
    name
    |> to_string()
    |> String.replace("_", " ")
    |> String.capitalize()
  end

  defp viewport_style(:desktop), do: ""
  defp viewport_style(:tablet), do: "max-width:768px;"
  defp viewport_style(:mobile), do: "max-width:375px;"
  defp viewport_style(_), do: ""

  defp default_project_path do
    Path.join([File.cwd!(), "priv", "phiaui_design", "projects", "untitled.phia.json"])
  end
end
