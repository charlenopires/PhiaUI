defmodule PhiaUiDesign.Canvas.Node do
  @moduledoc """
  Represents a single node in the design canvas scene graph.

  Each node is either a PhiaUI component, a generic HTML element,
  a text node, or a frame (grouping container).
  """

  @type node_type :: :phia_component | :html_element | :text | :frame
  @type family_role :: :root | :child | nil

  @type layout_direction :: :vertical | :horizontal | nil
  @type size_value :: :fill | :hug | integer() | String.t() | nil

  @type t :: %__MODULE__{
          id: String.t(),
          type: node_type(),
          component: atom() | nil,
          module: module() | nil,
          attrs: map(),
          slots: map(),
          tag: String.t() | nil,
          classes: String.t() | nil,
          text_content: String.t() | nil,
          children: [String.t()],
          parent_id: String.t() | nil,
          locked: boolean(),
          visible: boolean(),
          name: String.t(),
          layout: layout_direction(),
          gap: integer() | String.t() | nil,
          padding: integer() | [integer()] | String.t() | nil,
          justify_content: atom() | nil,
          align_items: atom() | nil,
          wrap: boolean(),
          width: size_value(),
          height: size_value()
        }

  @enforce_keys [:id, :type]
  defstruct [
    :id,
    :type,
    :component,
    :module,
    :tag,
    :classes,
    :text_content,
    :parent_id,
    :layout,
    :gap,
    :padding,
    :justify_content,
    :align_items,
    :width,
    :height,
    attrs: %{},
    slots: %{},
    children: [],
    locked: false,
    visible: true,
    wrap: false,
    name: ""
  ]

  @doc "Create a new PhiaUI component node"
  def new_component(component, opts \\ []) do
    id = Keyword.get(opts, :id, generate_id())

    %__MODULE__{
      id: id,
      type: :phia_component,
      component: component,
      module: Keyword.get(opts, :module),
      attrs: Keyword.get(opts, :attrs, %{}),
      slots: Keyword.get(opts, :slots, %{}),
      parent_id: Keyword.get(opts, :parent_id),
      name: Keyword.get(opts, :name, to_string(component))
    }
  end

  @doc "Create a new HTML element node"
  def new_element(tag, opts \\ []) do
    id = Keyword.get(opts, :id, generate_id())

    %__MODULE__{
      id: id,
      type: :html_element,
      tag: tag,
      classes: Keyword.get(opts, :classes),
      parent_id: Keyword.get(opts, :parent_id),
      name: Keyword.get(opts, :name, tag),
      children: Keyword.get(opts, :children, [])
    }
  end

  @doc "Create a new text node"
  def new_text(content, opts \\ []) do
    id = Keyword.get(opts, :id, generate_id())

    %__MODULE__{
      id: id,
      type: :text,
      text_content: content,
      parent_id: Keyword.get(opts, :parent_id),
      name: Keyword.get(opts, :name, String.slice(content, 0..20))
    }
  end

  @doc "Create a frame (grouping container)"
  def new_frame(opts \\ []) do
    id = Keyword.get(opts, :id, generate_id())

    %__MODULE__{
      id: id,
      type: :frame,
      classes: Keyword.get(opts, :classes),
      parent_id: Keyword.get(opts, :parent_id),
      name: Keyword.get(opts, :name, "Frame"),
      children: Keyword.get(opts, :children, []),
      layout: Keyword.get(opts, :layout),
      gap: Keyword.get(opts, :gap),
      padding: Keyword.get(opts, :padding),
      justify_content: Keyword.get(opts, :justify_content),
      align_items: Keyword.get(opts, :align_items),
      wrap: Keyword.get(opts, :wrap, false),
      width: Keyword.get(opts, :width),
      height: Keyword.get(opts, :height)
    }
  end

  defp generate_id do
    :crypto.strong_rand_bytes(8) |> Base.url_encode64(padding: false)
  end
end
