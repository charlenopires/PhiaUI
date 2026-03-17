defmodule PhiaUi.Components.Editor.TipTapHelpers do
  @moduledoc """
  Pure Elixir utilities for working with TipTap JSON content.

  TipTap stores documents as a JSON tree of typed nodes with marks. This module
  provides server-side operations — HTML rendering, plain-text extraction,
  validation, and sanitization — so you can process editor content without
  JavaScript.

  ## TipTap JSON Format

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

      alias PhiaUi.Components.Editor.TipTapHelpers

      # Render JSON to safe HTML
      html = TipTapHelpers.content_to_html(json)

      # Extract plain text for search indexing
      text = TipTapHelpers.content_to_text(json)

      # Validate against allowed schema
      {:ok, json} = TipTapHelpers.validate_content(json, allowed_nodes: ~w(paragraph heading))

      # Count words
      count = TipTapHelpers.word_count(json)
  """

  @default_allowed_nodes ~w(doc paragraph heading text hardBreak blockquote
    bulletList orderedList listItem codeBlock horizontalRule image)

  @default_allowed_marks ~w(bold italic underline strike code link)

  # ---------------------------------------------------------------------------
  # empty_document/0
  # ---------------------------------------------------------------------------

  @doc """
  Returns the canonical empty TipTap document.

  ## Example

      iex> TipTapHelpers.empty_document()
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
  Converts a TipTap JSON document to an HTML string.

  The output is *not* marked as safe — use `Phoenix.HTML.raw/1` when rendering
  in templates, after sanitizing user content.

  ## Examples

      iex> doc = %{"type" => "doc", "content" => [
      ...>   %{"type" => "paragraph", "content" => [
      ...>     %{"type" => "text", "text" => "Hello"}
      ...>   ]}
      ...> ]}
      iex> TipTapHelpers.content_to_html(doc)
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
  Extracts plain text from a TipTap JSON document.

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
      iex> TipTapHelpers.content_to_text(doc)
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
  Validates a TipTap JSON document against allowed node and mark types.

  Returns `{:ok, doc}` if valid, or `{:error, reasons}` with a list of issues.

  ## Options

    * `:allowed_nodes` — list of allowed node type strings (default: standard set)
    * `:allowed_marks` — list of allowed mark type strings (default: standard set)

  ## Examples

      iex> doc = %{"type" => "doc", "content" => [%{"type" => "paragraph"}]}
      iex> TipTapHelpers.validate_content(doc)
      {:ok, doc}

      iex> doc = %{"type" => "doc", "content" => [%{"type" => "script"}]}
      iex> TipTapHelpers.validate_content(doc)
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
  Strips disallowed nodes and marks from a TipTap JSON document.

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
      iex> TipTapHelpers.sanitize_content(doc)
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
  Counts words in a TipTap JSON document.

  ## Examples

      iex> doc = %{"type" => "doc", "content" => [
      ...>   %{"type" => "paragraph", "content" => [
      ...>     %{"type" => "text", "text" => "Hello beautiful world"}
      ...>   ]}
      ...> ]}
      iex> TipTapHelpers.word_count(doc)
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
  # Private — HTML rendering
  # ===========================================================================

  defp node_to_html(%{"type" => "text", "text" => text} = node) do
    escaped = Phoenix.HTML.html_escape(text) |> Phoenix.HTML.safe_to_string()
    marks = Map.get(node, "marks", [])
    wrap_marks(escaped, marks)
  end

  defp node_to_html(%{"type" => "paragraph", "attrs" => %{"textAlign" => align}, "content" => content})
       when align in ~w(left center right justify) do
    inner = content |> Enum.map(&node_to_html/1) |> Enum.join()
    "<p style=\"text-align: #{align}\">#{inner}</p>"
  end

  defp node_to_html(%{"type" => "paragraph", "content" => content}) do
    inner = content |> Enum.map(&node_to_html/1) |> Enum.join()
    "<p>#{inner}</p>"
  end
  defp node_to_html(%{"type" => "paragraph"}), do: "<p></p>"

  defp node_to_html(%{"type" => "heading", "attrs" => %{"level" => level, "textAlign" => align}, "content" => content})
       when level in 1..6 and align in ~w(left center right justify) do
    inner = content |> Enum.map(&node_to_html/1) |> Enum.join()
    "<h#{level} style=\"text-align: #{align}\">#{inner}</h#{level}>"
  end

  defp node_to_html(%{"type" => "heading", "attrs" => %{"level" => level}, "content" => content})
       when level in 1..6 do
    inner = content |> Enum.map(&node_to_html/1) |> Enum.join()
    "<h#{level}>#{inner}</h#{level}>"
  end
  defp node_to_html(%{"type" => "heading", "attrs" => %{"level" => level}}) when level in 1..6 do
    "<h#{level}></h#{level}>"
  end

  defp node_to_html(%{"type" => "blockquote", "content" => content}) do
    inner = content |> Enum.map(&node_to_html/1) |> Enum.join()
    "<blockquote>#{inner}</blockquote>"
  end

  defp node_to_html(%{"type" => "codeBlock", "content" => content}) do
    inner = content |> Enum.map(&node_to_html/1) |> Enum.join()
    "<pre><code>#{inner}</code></pre>"
  end
  defp node_to_html(%{"type" => "codeBlock"}), do: "<pre><code></code></pre>"

  defp node_to_html(%{"type" => "bulletList", "content" => content}) do
    inner = content |> Enum.map(&node_to_html/1) |> Enum.join()
    "<ul>#{inner}</ul>"
  end

  defp node_to_html(%{"type" => "orderedList", "content" => content}) do
    inner = content |> Enum.map(&node_to_html/1) |> Enum.join()
    "<ol>#{inner}</ol>"
  end

  defp node_to_html(%{"type" => "listItem", "content" => content}) do
    inner = content |> Enum.map(&node_to_html/1) |> Enum.join()
    "<li>#{inner}</li>"
  end

  defp node_to_html(%{"type" => "horizontalRule"}), do: "<hr>"

  defp node_to_html(%{"type" => "hardBreak"}), do: "<br>"

  defp node_to_html(%{"type" => "image", "attrs" => attrs}) do
    src = Phoenix.HTML.html_escape(Map.get(attrs, "src", "")) |> Phoenix.HTML.safe_to_string()
    alt = Phoenix.HTML.html_escape(Map.get(attrs, "alt", "")) |> Phoenix.HTML.safe_to_string()
    title = Map.get(attrs, "title")
    title_attr = if title, do: " title=\"#{Phoenix.HTML.html_escape(title) |> Phoenix.HTML.safe_to_string()}\"", else: ""
    "<img src=\"#{src}\" alt=\"#{alt}\"#{title_attr}>"
  end

  # Tables
  defp node_to_html(%{"type" => "table", "content" => content}) do
    inner = content |> Enum.map(&node_to_html/1) |> Enum.join()
    "<table>#{inner}</table>"
  end

  defp node_to_html(%{"type" => "tableRow", "content" => content}) do
    inner = content |> Enum.map(&node_to_html/1) |> Enum.join()
    "<tr>#{inner}</tr>"
  end

  defp node_to_html(%{"type" => "tableHeader", "content" => content}) do
    inner = content |> Enum.map(&node_to_html/1) |> Enum.join()
    "<th>#{inner}</th>"
  end

  defp node_to_html(%{"type" => "tableCell", "content" => content}) do
    inner = content |> Enum.map(&node_to_html/1) |> Enum.join()
    "<td>#{inner}</td>"
  end

  # Task lists
  defp node_to_html(%{"type" => "taskList", "content" => content}) do
    inner = content |> Enum.map(&node_to_html/1) |> Enum.join()
    "<ul data-type=\"taskList\">#{inner}</ul>"
  end

  defp node_to_html(%{"type" => "taskItem", "attrs" => %{"checked" => true}, "content" => content}) do
    inner = content |> Enum.map(&node_to_html/1) |> Enum.join()
    "<li data-type=\"taskItem\" data-checked=\"true\"><label><input type=\"checkbox\" checked></label><div>#{inner}</div></li>"
  end

  defp node_to_html(%{"type" => "taskItem", "content" => content}) do
    inner = content |> Enum.map(&node_to_html/1) |> Enum.join()
    "<li data-type=\"taskItem\" data-checked=\"false\"><label><input type=\"checkbox\"></label><div>#{inner}</div></li>"
  end

  defp node_to_html(%{"type" => "taskItem"}), do: "<li data-type=\"taskItem\" data-checked=\"false\"><label><input type=\"checkbox\"></label><div></div></li>"

  # Unknown node — skip
  defp node_to_html(_), do: ""

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
