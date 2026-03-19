defmodule PhiaUi.Components.Editor.EditorContent do
  @moduledoc """
  Pure Elixir utilities for working with editor JSON content.

  Documents are stored as a JSON tree of typed nodes with marks. This module
  provides server-side operations — HTML rendering, plain-text extraction,
  validation, and sanitization — so you can process editor content without
  JavaScript.

  ## Editor JSON Format

      %{
        "type" => "doc",
        "content" => [
          %{
            "type" => "paragraph",
            "content" => [
              %{"type" => "text", "text" => "Hello ", "marks" => [%{"type" => "bold"}]},
              %{"type" => "text", "text" => "world"}
            ]
          }
        ]
      }

  ## Usage

      alias PhiaUi.Components.Editor.EditorContent

      # Render JSON to safe HTML
      html = EditorContent.content_to_html(json)

      # Extract plain text for search indexing
      text = EditorContent.content_to_text(json)

      # Validate against allowed schema
      {:ok, json} = EditorContent.validate_content(json, allowed_nodes: ~w(paragraph heading))

      # Count words
      count = EditorContent.word_count(json)
  """

  @default_allowed_nodes ~w(doc paragraph heading text hardBreak blockquote
    bulletList orderedList listItem codeBlock horizontalRule image
    taskList taskItem table tableRow tableHeader tableCell
    callout details columns embed equation diagram fileAttachment)

  @default_allowed_marks ~w(bold italic underline strike code link superscript subscript highlight textStyle)

  # ---------------------------------------------------------------------------
  # empty_document/0
  # ---------------------------------------------------------------------------

  @doc """
  Returns the canonical empty document.

  ## Example

      iex> EditorContent.empty_document()
      %{"type" => "doc", "content" => [%{"type" => "paragraph"}]}
  """
  @spec empty_document() :: map()
  def empty_document do
    %{"type" => "doc", "content" => [%{"type" => "paragraph"}]}
  end

  # ---------------------------------------------------------------------------
  # content_to_html/1
  # ---------------------------------------------------------------------------

  @doc """
  Converts an editor JSON document to an HTML string.

  The output is *not* marked as safe — use `Phoenix.HTML.raw/1` when rendering
  in templates, after sanitizing user content.

  ## Examples

      iex> doc = %{"type" => "doc", "content" => [
      ...>   %{"type" => "paragraph", "content" => [
      ...>     %{"type" => "text", "text" => "Hello"}
      ...>   ]}
      ...> ]}
      iex> EditorContent.content_to_html(doc)
      "<p>Hello</p>"
  """
  @spec content_to_html(map() | nil) :: String.t()
  def content_to_html(nil), do: ""
  def content_to_html(%{"type" => "doc", "content" => content}) when is_list(content) do
    content
    |> Enum.map(&node_to_html/1)
    |> Enum.join()
  end
  def content_to_html(%{"type" => "doc"}), do: ""
  def content_to_html(_), do: ""

  # ---------------------------------------------------------------------------
  # content_to_text/1
  # ---------------------------------------------------------------------------

  @doc """
  Extracts plain text from an editor JSON document.

  Block-level nodes are separated by newlines. Useful for search indexing,
  word counting, and preview generation.

  ## Examples

      iex> doc = %{"type" => "doc", "content" => [
      ...>   %{"type" => "paragraph", "content" => [
      ...>     %{"type" => "text", "text" => "Hello world"}
      ...>   ]},
      ...>   %{"type" => "paragraph", "content" => [
      ...>     %{"type" => "text", "text" => "Second paragraph"}
      ...>   ]}
      ...> ]}
      iex> EditorContent.content_to_text(doc)
      "Hello world\\nSecond paragraph"
  """
  @spec content_to_text(map() | nil) :: String.t()
  def content_to_text(nil), do: ""
  def content_to_text(%{"type" => "doc", "content" => content}) when is_list(content) do
    content
    |> Enum.map(&node_to_text/1)
    |> Enum.reject(&(&1 == ""))
    |> Enum.join("\n")
  end
  def content_to_text(%{"type" => "doc"}), do: ""
  def content_to_text(_), do: ""

  # ---------------------------------------------------------------------------
  # validate_content/2
  # ---------------------------------------------------------------------------

  @doc """
  Validates an editor JSON document against allowed node and mark types.

  Returns `{:ok, doc}` if valid, or `{:error, reasons}` with a list of issues.

  ## Options

    * `:allowed_nodes` — list of allowed node type strings (default: standard set)
    * `:allowed_marks` — list of allowed mark type strings (default: standard set)

  ## Examples

      iex> doc = %{"type" => "doc", "content" => [%{"type" => "paragraph"}]}
      iex> EditorContent.validate_content(doc)
      {:ok, doc}

      iex> doc = %{"type" => "doc", "content" => [%{"type" => "script"}]}
      iex> EditorContent.validate_content(doc)
      {:error, ["disallowed node type: script"]}
  """
  @spec validate_content(map(), keyword()) :: {:ok, map()} | {:error, [String.t()]}
  def validate_content(doc, opts \\ [])

  def validate_content(%{"type" => "doc", "content" => content} = doc, opts) when is_list(content) do
    allowed_nodes = Keyword.get(opts, :allowed_nodes, @default_allowed_nodes)
    allowed_marks = Keyword.get(opts, :allowed_marks, @default_allowed_marks)

    errors = collect_errors(content, allowed_nodes, allowed_marks)

    case errors do
      [] -> {:ok, doc}
      errors -> {:error, Enum.uniq(errors)}
    end
  end

  def validate_content(%{"type" => "doc"}, _opts), do: {:ok, %{"type" => "doc", "content" => []}}
  def validate_content(_, _opts), do: {:error, ["invalid document: missing type \"doc\""]}

  # ---------------------------------------------------------------------------
  # sanitize_content/2
  # ---------------------------------------------------------------------------

  @doc """
  Strips disallowed nodes and marks from an editor JSON document.

  Nodes with disallowed types are removed entirely. Marks with disallowed types
  are stripped from text nodes (text is kept). Returns the cleaned document.

  ## Options

    * `:allowed_nodes` — list of allowed node type strings
    * `:allowed_marks` — list of allowed mark type strings

  ## Examples

      iex> doc = %{"type" => "doc", "content" => [
      ...>   %{"type" => "paragraph", "content" => [%{"type" => "text", "text" => "ok"}]},
      ...>   %{"type" => "script", "content" => []}
      ...> ]}
      iex> EditorContent.sanitize_content(doc)
      %{"type" => "doc", "content" => [
        %{"type" => "paragraph", "content" => [%{"type" => "text", "text" => "ok"}]}
      ]}
  """
  @spec sanitize_content(map(), keyword()) :: map()
  def sanitize_content(doc, opts \\ [])

  def sanitize_content(%{"type" => "doc", "content" => content}, opts) when is_list(content) do
    allowed_nodes = Keyword.get(opts, :allowed_nodes, @default_allowed_nodes)
    allowed_marks = Keyword.get(opts, :allowed_marks, @default_allowed_marks)

    cleaned = sanitize_nodes(content, allowed_nodes, allowed_marks)
    %{"type" => "doc", "content" => cleaned}
  end

  def sanitize_content(%{"type" => "doc"}, _opts), do: empty_document()
  def sanitize_content(_, _opts), do: empty_document()

  # ---------------------------------------------------------------------------
  # word_count/1
  # ---------------------------------------------------------------------------

  @doc """
  Counts words in an editor JSON document.

  ## Examples

      iex> doc = %{"type" => "doc", "content" => [
      ...>   %{"type" => "paragraph", "content" => [
      ...>     %{"type" => "text", "text" => "Hello beautiful world"}
      ...>   ]}
      ...> ]}
      iex> EditorContent.word_count(doc)
      3
  """
  @spec word_count(map() | nil) :: non_neg_integer()
  def word_count(nil), do: 0
  def word_count(doc) do
    text = content_to_text(doc)
    case String.trim(text) do
      "" -> 0
      trimmed -> trimmed |> String.split(~r/\s+/, trim: true) |> length()
    end
  end

  # ===========================================================================
  # Public — node_to_html/1 (extensible for new block types)
  # ===========================================================================

  @doc false
  def node_to_html(%{"type" => "text", "text" => text} = node) do
    escaped = Phoenix.HTML.html_escape(text) |> Phoenix.HTML.safe_to_string()
    marks = Map.get(node, "marks", [])
    wrap_marks(escaped, marks)
  end

  def node_to_html(%{"type" => "paragraph", "attrs" => %{"textAlign" => align}, "content" => content})
       when align in ~w(left center right justify) do
    inner = content |> Enum.map(&node_to_html/1) |> Enum.join()
    "<p style=\"text-align: #{align}\">#{inner}</p>"
  end

  def node_to_html(%{"type" => "paragraph", "content" => content}) do
    inner = content |> Enum.map(&node_to_html/1) |> Enum.join()
    "<p>#{inner}</p>"
  end
  def node_to_html(%{"type" => "paragraph"}), do: "<p></p>"

  def node_to_html(%{"type" => "heading", "attrs" => %{"level" => level, "textAlign" => align}, "content" => content})
       when level in 1..6 and align in ~w(left center right justify) do
    inner = content |> Enum.map(&node_to_html/1) |> Enum.join()
    "<h#{level} style=\"text-align: #{align}\">#{inner}</h#{level}>"
  end

  def node_to_html(%{"type" => "heading", "attrs" => %{"level" => level}, "content" => content})
       when level in 1..6 do
    inner = content |> Enum.map(&node_to_html/1) |> Enum.join()
    "<h#{level}>#{inner}</h#{level}>"
  end
  def node_to_html(%{"type" => "heading", "attrs" => %{"level" => level}}) when level in 1..6 do
    "<h#{level}></h#{level}>"
  end

  def node_to_html(%{"type" => "blockquote", "content" => content}) do
    inner = content |> Enum.map(&node_to_html/1) |> Enum.join()
    "<blockquote>#{inner}</blockquote>"
  end

  def node_to_html(%{"type" => "codeBlock", "content" => content}) do
    inner = content |> Enum.map(&node_to_html/1) |> Enum.join()
    "<pre><code>#{inner}</code></pre>"
  end
  def node_to_html(%{"type" => "codeBlock"}), do: "<pre><code></code></pre>"

  def node_to_html(%{"type" => "bulletList", "content" => content}) do
    inner = content |> Enum.map(&node_to_html/1) |> Enum.join()
    "<ul>#{inner}</ul>"
  end

  def node_to_html(%{"type" => "orderedList", "content" => content}) do
    inner = content |> Enum.map(&node_to_html/1) |> Enum.join()
    "<ol>#{inner}</ol>"
  end

  def node_to_html(%{"type" => "listItem", "content" => content}) do
    inner = content |> Enum.map(&node_to_html/1) |> Enum.join()
    "<li>#{inner}</li>"
  end

  def node_to_html(%{"type" => "horizontalRule"}), do: "<hr>"

  def node_to_html(%{"type" => "hardBreak"}), do: "<br>"

  def node_to_html(%{"type" => "image", "attrs" => attrs}) do
    src = Phoenix.HTML.html_escape(Map.get(attrs, "src", "")) |> Phoenix.HTML.safe_to_string()
    alt = Phoenix.HTML.html_escape(Map.get(attrs, "alt", "")) |> Phoenix.HTML.safe_to_string()
    title = Map.get(attrs, "title")
    title_attr = if title, do: " title=\"#{Phoenix.HTML.html_escape(title) |> Phoenix.HTML.safe_to_string()}\"", else: ""
    "<img src=\"#{src}\" alt=\"#{alt}\"#{title_attr}>"
  end

  # Tables
  def node_to_html(%{"type" => "table", "content" => content}) do
    inner = content |> Enum.map(&node_to_html/1) |> Enum.join()
    "<table>#{inner}</table>"
  end

  def node_to_html(%{"type" => "tableRow", "content" => content}) do
    inner = content |> Enum.map(&node_to_html/1) |> Enum.join()
    "<tr>#{inner}</tr>"
  end

  def node_to_html(%{"type" => "tableHeader", "content" => content}) do
    inner = content |> Enum.map(&node_to_html/1) |> Enum.join()
    "<th>#{inner}</th>"
  end

  def node_to_html(%{"type" => "tableCell", "content" => content}) do
    inner = content |> Enum.map(&node_to_html/1) |> Enum.join()
    "<td>#{inner}</td>"
  end

  # Task lists
  def node_to_html(%{"type" => "taskList", "content" => content}) do
    inner = content |> Enum.map(&node_to_html/1) |> Enum.join()
    "<ul data-type=\"taskList\">#{inner}</ul>"
  end

  def node_to_html(%{"type" => "taskItem", "attrs" => %{"checked" => true}, "content" => content}) do
    inner = content |> Enum.map(&node_to_html/1) |> Enum.join()
    "<li data-type=\"taskItem\" data-checked=\"true\"><label><input type=\"checkbox\" checked></label><div>#{inner}</div></li>"
  end

  def node_to_html(%{"type" => "taskItem", "content" => content}) do
    inner = content |> Enum.map(&node_to_html/1) |> Enum.join()
    "<li data-type=\"taskItem\" data-checked=\"false\"><label><input type=\"checkbox\"></label><div>#{inner}</div></li>"
  end

  def node_to_html(%{"type" => "taskItem"}), do: "<li data-type=\"taskItem\" data-checked=\"false\"><label><input type=\"checkbox\"></label><div></div></li>"

  # Callout block
  def node_to_html(%{"type" => "callout", "attrs" => attrs, "content" => content}) do
    variant = Map.get(attrs, "variant", "info")
    icon = Map.get(attrs, "icon", "")
    inner = content |> Enum.map(&node_to_html/1) |> Enum.join()
    "<div data-type=\"callout\" data-variant=\"#{variant}\"><span data-callout-icon>#{icon}</span><div>#{inner}</div></div>"
  end
  def node_to_html(%{"type" => "callout", "content" => content}) do
    inner = content |> Enum.map(&node_to_html/1) |> Enum.join()
    "<div data-type=\"callout\" data-variant=\"info\"><div>#{inner}</div></div>"
  end

  # Details/collapsible
  def node_to_html(%{"type" => "details", "attrs" => %{"summary" => summary}, "content" => content}) do
    escaped_summary = Phoenix.HTML.html_escape(summary) |> Phoenix.HTML.safe_to_string()
    inner = content |> Enum.map(&node_to_html/1) |> Enum.join()
    "<details><summary>#{escaped_summary}</summary>#{inner}</details>"
  end
  def node_to_html(%{"type" => "details", "content" => content}) do
    inner = content |> Enum.map(&node_to_html/1) |> Enum.join()
    "<details><summary>Details</summary>#{inner}</details>"
  end

  # Columns layout
  def node_to_html(%{"type" => "columns", "attrs" => attrs, "content" => content}) do
    cols = Map.get(attrs, "count", 2)
    inner = content |> Enum.map(&node_to_html/1) |> Enum.join()
    "<div data-type=\"columns\" data-columns=\"#{cols}\" style=\"display:grid;grid-template-columns:repeat(#{cols},1fr);gap:1rem\">#{inner}</div>"
  end

  # Embed
  def node_to_html(%{"type" => "embed", "attrs" => %{"src" => src}}) do
    escaped = Phoenix.HTML.html_escape(src) |> Phoenix.HTML.safe_to_string()
    "<div data-type=\"embed\"><iframe src=\"#{escaped}\" frameborder=\"0\" allowfullscreen loading=\"lazy\"></iframe></div>"
  end

  # Equation
  def node_to_html(%{"type" => "equation", "attrs" => %{"latex" => latex}}) do
    escaped = Phoenix.HTML.html_escape(latex) |> Phoenix.HTML.safe_to_string()
    "<div data-type=\"equation\" data-latex=\"#{escaped}\"><code>#{escaped}</code></div>"
  end

  # Diagram
  def node_to_html(%{"type" => "diagram", "attrs" => %{"source" => source}}) do
    escaped = Phoenix.HTML.html_escape(source) |> Phoenix.HTML.safe_to_string()
    "<div data-type=\"diagram\"><pre>#{escaped}</pre></div>"
  end

  # File attachment
  def node_to_html(%{"type" => "fileAttachment", "attrs" => attrs}) do
    name = Phoenix.HTML.html_escape(Map.get(attrs, "name", "file")) |> Phoenix.HTML.safe_to_string()
    size = Map.get(attrs, "size", "")
    href = Phoenix.HTML.html_escape(Map.get(attrs, "href", "#")) |> Phoenix.HTML.safe_to_string()
    "<div data-type=\"fileAttachment\"><a href=\"#{href}\">#{name}</a><span>#{size}</span></div>"
  end

  # Unknown node — skip
  def node_to_html(_), do: ""

  # ===========================================================================
  # Private — mark wrapping
  # ===========================================================================

  defp wrap_marks(html, []), do: html
  defp wrap_marks(html, [%{"type" => "bold"} | rest]), do: wrap_marks("<strong>#{html}</strong>", rest)
  defp wrap_marks(html, [%{"type" => "italic"} | rest]), do: wrap_marks("<em>#{html}</em>", rest)
  defp wrap_marks(html, [%{"type" => "underline"} | rest]), do: wrap_marks("<u>#{html}</u>", rest)
  defp wrap_marks(html, [%{"type" => "strike"} | rest]), do: wrap_marks("<s>#{html}</s>", rest)
  defp wrap_marks(html, [%{"type" => "code"} | rest]), do: wrap_marks("<code>#{html}</code>", rest)
  defp wrap_marks(html, [%{"type" => "link", "attrs" => %{"href" => href}} | rest]) do
    escaped_href = Phoenix.HTML.html_escape(href) |> Phoenix.HTML.safe_to_string()
    wrap_marks("<a href=\"#{escaped_href}\">#{html}</a>", rest)
  end
  defp wrap_marks(html, [%{"type" => "superscript"} | rest]), do: wrap_marks("<sup>#{html}</sup>", rest)
  defp wrap_marks(html, [%{"type" => "subscript"} | rest]), do: wrap_marks("<sub>#{html}</sub>", rest)
  defp wrap_marks(html, [%{"type" => "highlight", "attrs" => %{"color" => color}} | rest]) do
    escaped = Phoenix.HTML.html_escape(color) |> Phoenix.HTML.safe_to_string()
    wrap_marks("<mark style=\"background-color: #{escaped}\">#{html}</mark>", rest)
  end
  defp wrap_marks(html, [%{"type" => "highlight"} | rest]), do: wrap_marks("<mark>#{html}</mark>", rest)
  defp wrap_marks(html, [%{"type" => "textStyle", "attrs" => attrs} | rest]) do
    styles =
      Enum.flat_map(attrs, fn
        {"color", c} -> ["color: #{Phoenix.HTML.html_escape(c) |> Phoenix.HTML.safe_to_string()}"]
        {"fontFamily", f} -> ["font-family: #{Phoenix.HTML.html_escape(f) |> Phoenix.HTML.safe_to_string()}"]
        {"fontSize", s} -> ["font-size: #{Phoenix.HTML.html_escape(s) |> Phoenix.HTML.safe_to_string()}"]
        _ -> []
      end)
      |> Enum.join("; ")

    if styles == "" do
      wrap_marks(html, rest)
    else
      wrap_marks("<span style=\"#{styles}\">#{html}</span>", rest)
    end
  end
  # Unknown mark — skip
  defp wrap_marks(html, [_ | rest]), do: wrap_marks(html, rest)

  # ===========================================================================
  # Private — text extraction
  # ===========================================================================

  defp node_to_text(%{"type" => "text", "text" => text}), do: text
  defp node_to_text(%{"type" => "hardBreak"}), do: "\n"
  defp node_to_text(%{"content" => content}) when is_list(content) do
    content |> Enum.map(&node_to_text/1) |> Enum.join()
  end
  defp node_to_text(_), do: ""

  # ===========================================================================
  # Private — validation
  # ===========================================================================

  defp collect_errors(nodes, allowed_nodes, allowed_marks) do
    Enum.flat_map(nodes, fn node ->
      type = Map.get(node, "type", "unknown")
      node_errors = if type in allowed_nodes, do: [], else: ["disallowed node type: #{type}"]

      mark_errors =
        node
        |> Map.get("marks", [])
        |> Enum.flat_map(fn %{"type" => mark_type} ->
          if mark_type in allowed_marks, do: [], else: ["disallowed mark type: #{mark_type}"]
        end)

      child_errors =
        node
        |> Map.get("content", [])
        |> collect_errors(allowed_nodes, allowed_marks)

      node_errors ++ mark_errors ++ child_errors
    end)
  end

  # ===========================================================================
  # Private — sanitization
  # ===========================================================================

  defp sanitize_nodes(nodes, allowed_nodes, allowed_marks) do
    nodes
    |> Enum.filter(fn %{"type" => type} -> type in allowed_nodes end)
    |> Enum.map(fn node -> sanitize_node(node, allowed_nodes, allowed_marks) end)
  end

  defp sanitize_node(%{"type" => "text"} = node, _allowed_nodes, allowed_marks) do
    marks = Map.get(node, "marks", [])
    filtered_marks = Enum.filter(marks, fn %{"type" => type} -> type in allowed_marks end)

    case filtered_marks do
      [] -> Map.delete(node, "marks")
      marks -> Map.put(node, "marks", marks)
    end
  end

  defp sanitize_node(%{"content" => content} = node, allowed_nodes, allowed_marks) when is_list(content) do
    Map.put(node, "content", sanitize_nodes(content, allowed_nodes, allowed_marks))
  end

  defp sanitize_node(node, _allowed_nodes, _allowed_marks), do: node
end
