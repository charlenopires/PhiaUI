defmodule PhiaUi.Editor.ExportHelpers do
  @moduledoc """
  Pure Elixir helpers for converting editor JSON documents to and from various
  text formats.

  These functions operate on the TipTap/ProseMirror JSON document format used
  by PhiaUI editor components. No JavaScript or external dependencies required.

  ## Supported Conversions

  ### Export (JSON to format)
  - `to_markdown/1` — Convert to Markdown
  - `to_latex/1`    — Convert to basic LaTeX

  ### Import (format to JSON)
  - `from_markdown/1` — Parse Markdown into editor JSON
  - `from_html/1`     — Parse HTML into editor JSON

  ## Document Format

  The editor JSON format follows the TipTap/ProseMirror schema:

      %{
        "type" => "doc",
        "content" => [
          %{"type" => "paragraph", "content" => [
            %{"type" => "text", "text" => "Hello ", "marks" => [%{"type" => "bold"}]},
            %{"type" => "text", "text" => "world"}
          ]}
        ]
      }
  """

  # ===========================================================================
  # to_markdown/1
  # ===========================================================================

  @doc """
  Converts an editor JSON document to a Markdown string.

  Walks the document tree and converts each node type to its Markdown equivalent.

  ## Examples

      iex> doc = %{"type" => "doc", "content" => [
      ...>   %{"type" => "heading", "attrs" => %{"level" => 2}, "content" => [
      ...>     %{"type" => "text", "text" => "Hello"}
      ...>   ]},
      ...>   %{"type" => "paragraph", "content" => [
      ...>     %{"type" => "text", "text" => "World"}
      ...>   ]}
      ...> ]}
      iex> PhiaUi.Editor.ExportHelpers.to_markdown(doc)
      "## Hello\\n\\nWorld\\n\\n"
  """
  @spec to_markdown(map() | nil) :: String.t()
  def to_markdown(nil), do: ""
  def to_markdown(%{"type" => "doc", "content" => content}) when is_list(content) do
    content
    |> Enum.map(&node_to_markdown/1)
    |> Enum.join()
  end
  def to_markdown(%{"type" => "doc"}), do: ""
  def to_markdown(_), do: ""

  defp node_to_markdown(%{"type" => "heading", "attrs" => %{"level" => level}, "content" => content})
       when level in 1..6 do
    prefix = String.duplicate("#", level)
    inner = inline_to_markdown(content)
    "#{prefix} #{inner}\n\n"
  end

  defp node_to_markdown(%{"type" => "heading", "attrs" => %{"level" => level}}) when level in 1..6 do
    prefix = String.duplicate("#", level)
    "#{prefix} \n\n"
  end

  defp node_to_markdown(%{"type" => "paragraph", "content" => content}) do
    inner = inline_to_markdown(content)
    "#{inner}\n\n"
  end
  defp node_to_markdown(%{"type" => "paragraph"}), do: "\n"

  defp node_to_markdown(%{"type" => "bulletList", "content" => items}) when is_list(items) do
    items
    |> Enum.map(&list_item_to_markdown(&1, "- "))
    |> Enum.join()
    |> Kernel.<>("\n")
  end

  defp node_to_markdown(%{"type" => "orderedList", "content" => items}) when is_list(items) do
    items
    |> Enum.with_index(1)
    |> Enum.map(fn {item, idx} -> list_item_to_markdown(item, "#{idx}. ") end)
    |> Enum.join()
    |> Kernel.<>("\n")
  end

  defp node_to_markdown(%{"type" => "listItem", "content" => content}) when is_list(content) do
    content
    |> Enum.map(&node_to_markdown/1)
    |> Enum.join()
    |> String.trim_trailing()
    |> Kernel.<>("\n")
  end

  defp node_to_markdown(%{"type" => "codeBlock", "content" => content}) do
    code = inline_text(content)
    "```\n#{code}\n```\n\n"
  end
  defp node_to_markdown(%{"type" => "codeBlock"}), do: "```\n```\n\n"

  defp node_to_markdown(%{"type" => "blockquote", "content" => content}) when is_list(content) do
    inner =
      content
      |> Enum.map(&node_to_markdown/1)
      |> Enum.join()
      |> String.trim_trailing()
      |> String.split("\n")
      |> Enum.map(&("> " <> &1))
      |> Enum.join("\n")

    "#{inner}\n\n"
  end

  defp node_to_markdown(%{"type" => "horizontalRule"}), do: "---\n\n"

  defp node_to_markdown(%{"type" => "image", "attrs" => attrs}) do
    src = Map.get(attrs, "src", "")
    alt = Map.get(attrs, "alt", "")
    "![#{alt}](#{src})\n\n"
  end

  defp node_to_markdown(%{"type" => "hardBreak"}), do: "  \n"

  defp node_to_markdown(_node), do: ""

  defp list_item_to_markdown(%{"type" => "listItem", "content" => content}, prefix) when is_list(content) do
    inner =
      content
      |> Enum.map(fn
        %{"type" => "paragraph", "content" => c} -> inline_to_markdown(c)
        node -> node_to_markdown(node) |> String.trim()
      end)
      |> Enum.join(" ")

    "#{prefix}#{inner}\n"
  end

  defp list_item_to_markdown(_, prefix), do: "#{prefix}\n"

  defp inline_to_markdown(content) when is_list(content) do
    Enum.map(content, &text_node_to_markdown/1) |> Enum.join()
  end
  defp inline_to_markdown(_), do: ""

  defp text_node_to_markdown(%{"type" => "text", "text" => text} = node) do
    marks = Map.get(node, "marks", [])
    wrap_markdown_marks(text, marks)
  end
  defp text_node_to_markdown(%{"type" => "hardBreak"}), do: "  \n"
  defp text_node_to_markdown(_), do: ""

  defp wrap_markdown_marks(text, []), do: text
  defp wrap_markdown_marks(text, [mark | rest]) do
    wrapped = apply_markdown_mark(text, mark)
    wrap_markdown_marks(wrapped, rest)
  end

  defp apply_markdown_mark(text, %{"type" => "bold"}), do: "**#{text}**"
  defp apply_markdown_mark(text, %{"type" => "italic"}), do: "*#{text}*"
  defp apply_markdown_mark(text, %{"type" => "strike"}), do: "~~#{text}~~"
  defp apply_markdown_mark(text, %{"type" => "code"}), do: "`#{text}`"
  defp apply_markdown_mark(text, %{"type" => "link", "attrs" => %{"href" => href}}), do: "[#{text}](#{href})"
  defp apply_markdown_mark(text, _), do: text

  defp inline_text(content) when is_list(content) do
    Enum.map(content, fn
      %{"type" => "text", "text" => text} -> text
      _ -> ""
    end)
    |> Enum.join()
  end
  defp inline_text(_), do: ""

  # ===========================================================================
  # to_latex/1
  # ===========================================================================

  @doc """
  Converts an editor JSON document to a basic LaTeX string.

  Produces a minimal LaTeX document body (no preamble). Suitable for embedding
  in a `\\begin{document}` block.

  ## Examples

      iex> doc = %{"type" => "doc", "content" => [
      ...>   %{"type" => "heading", "attrs" => %{"level" => 1}, "content" => [
      ...>     %{"type" => "text", "text" => "Title"}
      ...>   ]},
      ...>   %{"type" => "paragraph", "content" => [
      ...>     %{"type" => "text", "text" => "Hello"}
      ...>   ]}
      ...> ]}
      iex> PhiaUi.Editor.ExportHelpers.to_latex(doc)
      "\\\\section{Title}\\n\\nHello\\n\\n"
  """
  @spec to_latex(map() | nil) :: String.t()
  def to_latex(nil), do: ""
  def to_latex(%{"type" => "doc", "content" => content}) when is_list(content) do
    content
    |> Enum.map(&node_to_latex/1)
    |> Enum.join()
  end
  def to_latex(%{"type" => "doc"}), do: ""
  def to_latex(_), do: ""

  defp node_to_latex(%{"type" => "heading", "attrs" => %{"level" => level}, "content" => content})
       when level in 1..6 do
    cmd = latex_heading_command(level)
    inner = inline_to_latex(content)
    "\\#{cmd}{#{inner}}\n\n"
  end

  defp node_to_latex(%{"type" => "heading", "attrs" => %{"level" => level}}) when level in 1..6 do
    cmd = latex_heading_command(level)
    "\\#{cmd}{}\n\n"
  end

  defp node_to_latex(%{"type" => "paragraph", "content" => content}) do
    inner = inline_to_latex(content)
    "#{inner}\n\n"
  end
  defp node_to_latex(%{"type" => "paragraph"}), do: "\n"

  defp node_to_latex(%{"type" => "bulletList", "content" => items}) when is_list(items) do
    inner =
      items
      |> Enum.map(fn
        %{"type" => "listItem", "content" => c} ->
          text =
            c
            |> Enum.map(fn
              %{"type" => "paragraph", "content" => pc} -> inline_to_latex(pc)
              node -> node_to_latex(node) |> String.trim()
            end)
            |> Enum.join(" ")

          "  \\item #{text}\n"

        _ ->
          "  \\item\n"
      end)
      |> Enum.join()

    "\\begin{itemize}\n#{inner}\\end{itemize}\n\n"
  end

  defp node_to_latex(%{"type" => "orderedList", "content" => items}) when is_list(items) do
    inner =
      items
      |> Enum.map(fn
        %{"type" => "listItem", "content" => c} ->
          text =
            c
            |> Enum.map(fn
              %{"type" => "paragraph", "content" => pc} -> inline_to_latex(pc)
              node -> node_to_latex(node) |> String.trim()
            end)
            |> Enum.join(" ")

          "  \\item #{text}\n"

        _ ->
          "  \\item\n"
      end)
      |> Enum.join()

    "\\begin{enumerate}\n#{inner}\\end{enumerate}\n\n"
  end

  defp node_to_latex(%{"type" => "codeBlock", "content" => content}) do
    code = inline_text(content)
    "\\begin{verbatim}\n#{code}\n\\end{verbatim}\n\n"
  end
  defp node_to_latex(%{"type" => "codeBlock"}), do: "\\begin{verbatim}\n\\end{verbatim}\n\n"

  defp node_to_latex(%{"type" => "blockquote", "content" => content}) when is_list(content) do
    inner =
      content
      |> Enum.map(&node_to_latex/1)
      |> Enum.join()
      |> String.trim_trailing()

    "\\begin{quote}\n#{inner}\n\\end{quote}\n\n"
  end

  defp node_to_latex(%{"type" => "horizontalRule"}), do: "\\noindent\\rule{\\textwidth}{0.4pt}\n\n"

  defp node_to_latex(%{"type" => "image", "attrs" => attrs}) do
    src = Map.get(attrs, "src", "")
    "\\includegraphics{#{latex_escape(src)}}\n\n"
  end

  defp node_to_latex(_node), do: ""

  defp inline_to_latex(content) when is_list(content) do
    Enum.map(content, &text_node_to_latex/1) |> Enum.join()
  end
  defp inline_to_latex(_), do: ""

  defp text_node_to_latex(%{"type" => "text", "text" => text} = node) do
    escaped = latex_escape(text)
    marks = Map.get(node, "marks", [])
    wrap_latex_marks(escaped, marks)
  end
  defp text_node_to_latex(%{"type" => "hardBreak"}), do: "\\\\\n"
  defp text_node_to_latex(_), do: ""

  defp wrap_latex_marks(text, []), do: text
  defp wrap_latex_marks(text, [mark | rest]) do
    wrapped = apply_latex_mark(text, mark)
    wrap_latex_marks(wrapped, rest)
  end

  defp apply_latex_mark(text, %{"type" => "bold"}), do: "\\textbf{#{text}}"
  defp apply_latex_mark(text, %{"type" => "italic"}), do: "\\textit{#{text}}"
  defp apply_latex_mark(text, %{"type" => "underline"}), do: "\\underline{#{text}}"
  defp apply_latex_mark(text, %{"type" => "strike"}), do: "\\sout{#{text}}"
  defp apply_latex_mark(text, %{"type" => "code"}), do: "\\texttt{#{text}}"
  defp apply_latex_mark(text, %{"type" => "link", "attrs" => %{"href" => href}}), do: "\\href{#{latex_escape(href)}}{#{text}}"
  defp apply_latex_mark(text, _), do: text

  defp latex_heading_command(1), do: "section"
  defp latex_heading_command(2), do: "subsection"
  defp latex_heading_command(3), do: "subsubsection"
  defp latex_heading_command(4), do: "paragraph"
  defp latex_heading_command(5), do: "subparagraph"
  defp latex_heading_command(6), do: "subparagraph"

  defp latex_escape(text) do
    text
    |> String.replace("\\", "\\textbackslash{}")
    |> String.replace("{", "\\{")
    |> String.replace("}", "\\}")
    |> String.replace("&", "\\&")
    |> String.replace("%", "\\%")
    |> String.replace("$", "\\$")
    |> String.replace("#", "\\#")
    |> String.replace("_", "\\_")
    |> String.replace("~", "\\textasciitilde{}")
    |> String.replace("^", "\\textasciicircum{}")
  end

  # ===========================================================================
  # from_markdown/1
  # ===========================================================================

  @doc """
  Parses a Markdown string into an editor JSON document.

  Supports headings (`#`), paragraphs, bold (`**`), italic (`*`), code (`` ` ``),
  links (`[text](url)`), bullet lists (`-` or `*`), ordered lists (`1.`),
  code blocks (triple backticks), blockquotes (`>`), horizontal rules (`---`),
  and images (`![alt](src)`).

  ## Examples

      iex> PhiaUi.Editor.ExportHelpers.from_markdown("## Hello\\n\\nWorld")
      %{"type" => "doc", "content" => [
        %{"type" => "heading", "attrs" => %{"level" => 2}, "content" => [
          %{"type" => "text", "text" => "Hello"}
        ]},
        %{"type" => "paragraph", "content" => [
          %{"type" => "text", "text" => "World"}
        ]}
      ]}
  """
  @spec from_markdown(String.t()) :: map()
  def from_markdown(markdown) when is_binary(markdown) do
    nodes =
      markdown
      |> String.replace("\r\n", "\n")
      |> parse_markdown_blocks()
      |> Enum.reject(&is_nil/1)

    %{"type" => "doc", "content" => ensure_non_empty(nodes)}
  end

  def from_markdown(_), do: %{"type" => "doc", "content" => [%{"type" => "paragraph"}]}

  defp parse_markdown_blocks(text) do
    text
    |> split_blocks()
    |> Enum.flat_map(&parse_block/1)
  end

  defp split_blocks(text) do
    # Split on blank lines, preserving code blocks as single blocks
    text
    |> split_code_blocks()
    |> Enum.flat_map(fn
      {:code, code} -> [{:code, code}]
      {:text, text} -> text |> String.split(~r/\n{2,}/, trim: true) |> Enum.map(&{:text, &1})
    end)
  end

  defp split_code_blocks(text) do
    case String.split(text, ~r/```/, parts: :infinity) do
      [single] -> [{:text, single}]
      fragments -> pair_code_blocks(fragments, :text, [])
    end
  end

  defp pair_code_blocks([], _mode, acc), do: Enum.reverse(acc)
  defp pair_code_blocks([fragment | rest], :text, acc) do
    pair_code_blocks(rest, :code, [{:text, fragment} | acc])
  end
  defp pair_code_blocks([fragment | rest], :code, acc) do
    # Remove optional language tag on first line
    code = fragment |> String.replace(~r/\A[a-zA-Z]*\n/, "") |> String.trim_trailing("\n")
    pair_code_blocks(rest, :text, [{:code, code} | acc])
  end

  defp parse_block({:code, code}) do
    content = if code == "", do: [], else: [%{"type" => "text", "text" => code}]
    [%{"type" => "codeBlock", "content" => content}]
  end

  defp parse_block({:text, text}) do
    trimmed = String.trim(text)

    cond do
      trimmed == "" ->
        []

      Regex.match?(~r/\A\#{1,6}\s/, trimmed) ->
        [parse_heading(trimmed)]

      trimmed == "---" || trimmed == "***" || trimmed == "___" ->
        [%{"type" => "horizontalRule"}]

      Regex.match?(~r/\A!\[/, trimmed) ->
        [parse_image(trimmed)]

      Regex.match?(~r/\A>\s/, trimmed) ->
        [parse_blockquote(trimmed)]

      Regex.match?(~r/\A[-*]\s/, trimmed) ->
        [parse_bullet_list(trimmed)]

      Regex.match?(~r/\A\d+\.\s/, trimmed) ->
        [parse_ordered_list(trimmed)]

      true ->
        [parse_paragraph(trimmed)]
    end
  end

  defp parse_heading(text) do
    {hashes, rest} = text |> String.trim() |> split_heading()
    level = min(String.length(hashes), 6)
    content = parse_inline(rest)

    %{
      "type" => "heading",
      "attrs" => %{"level" => level},
      "content" => ensure_non_empty_inline(content)
    }
  end

  defp split_heading(text) do
    case Regex.run(~r/\A(\#{1,6})\s+(.*)/, text) do
      [_, hashes, rest] -> {hashes, rest}
      _ -> {"#", text}
    end
  end

  defp parse_paragraph(text) do
    content = parse_inline(text)
    %{"type" => "paragraph", "content" => ensure_non_empty_inline(content)}
  end

  defp parse_blockquote(text) do
    inner =
      text
      |> String.split("\n")
      |> Enum.map(fn line -> String.replace(line, ~r/\A>\s?/, "") end)
      |> Enum.join("\n")

    content = parse_markdown_blocks(inner)

    %{"type" => "blockquote", "content" => ensure_non_empty(content)}
  end

  defp parse_bullet_list(text) do
    items =
      text
      |> String.split("\n")
      |> Enum.map(fn line -> String.replace(line, ~r/\A[-*]\s+/, "") end)
      |> Enum.map(fn item_text ->
        %{
          "type" => "listItem",
          "content" => [parse_paragraph(item_text)]
        }
      end)

    %{"type" => "bulletList", "content" => items}
  end

  defp parse_ordered_list(text) do
    items =
      text
      |> String.split("\n")
      |> Enum.map(fn line -> String.replace(line, ~r/\A\d+\.\s+/, "") end)
      |> Enum.map(fn item_text ->
        %{
          "type" => "listItem",
          "content" => [parse_paragraph(item_text)]
        }
      end)

    %{"type" => "orderedList", "content" => items}
  end

  defp parse_image(text) do
    case Regex.run(~r/\A!\[([^\]]*)\]\(([^)]*)\)/, text) do
      [_, alt, src] ->
        %{"type" => "image", "attrs" => %{"src" => src, "alt" => alt}}

      _ ->
        parse_paragraph(text)
    end
  end

  defp parse_inline(text) when is_binary(text) do
    text
    |> tokenize_inline([])
    |> Enum.reject(&is_nil/1)
  end

  defp tokenize_inline("", acc), do: Enum.reverse(acc)

  defp tokenize_inline(text, acc) do
    cond do
      # Bold: **text**
      match = Regex.run(~r/\A\*\*(.+?)\*\*(.*)/, text, capture: :all) ->
        [_, inner, rest] = match
        node = %{"type" => "text", "text" => inner, "marks" => [%{"type" => "bold"}]}
        tokenize_inline(rest, [node | acc])

      # Italic: *text*
      match = Regex.run(~r/\A\*(.+?)\*(.*)/, text, capture: :all) ->
        [_, inner, rest] = match
        node = %{"type" => "text", "text" => inner, "marks" => [%{"type" => "italic"}]}
        tokenize_inline(rest, [node | acc])

      # Inline code: `text`
      match = Regex.run(~r/\A`(.+?)`(.*)/, text, capture: :all) ->
        [_, inner, rest] = match
        node = %{"type" => "text", "text" => inner, "marks" => [%{"type" => "code"}]}
        tokenize_inline(rest, [node | acc])

      # Link: [text](url)
      match = Regex.run(~r/\A\[([^\]]+)\]\(([^)]+)\)(.*)/, text, capture: :all) ->
        [_, label, href, rest] = match
        node = %{"type" => "text", "text" => label, "marks" => [%{"type" => "link", "attrs" => %{"href" => href}}]}
        tokenize_inline(rest, [node | acc])

      # Plain text up to the next special character
      match = Regex.run(~r/\A([^*`\[]+)(.*)/, text, capture: :all) ->
        [_, plain, rest] = match
        node = %{"type" => "text", "text" => plain}
        tokenize_inline(rest, [node | acc])

      # Single special character that did not match a pattern
      true ->
        {ch, rest} = String.split_at(text, 1)
        case acc do
          [%{"type" => "text", "text" => prev} = prev_node | tail] when not is_map_key(prev_node, "marks") ->
            merged = %{prev_node | "text" => prev <> ch}
            tokenize_inline(rest, [merged | tail])
          _ ->
            node = %{"type" => "text", "text" => ch}
            tokenize_inline(rest, [node | acc])
        end
    end
  end

  # ===========================================================================
  # from_html/1
  # ===========================================================================

  @doc """
  Parses an HTML string into an editor JSON document.

  Supports `<p>`, `<h1>`-`<h6>`, `<strong>`/`<b>`, `<em>`/`<i>`, `<a>`,
  `<ul>`/`<ol>`/`<li>`, `<pre><code>`, `<blockquote>`, `<hr>`, and `<img>`.

  Uses basic regex/string parsing — not a full HTML parser. Suitable for
  simple, well-formed HTML from editor output.

  ## Examples

      iex> PhiaUi.Editor.ExportHelpers.from_html("<p>Hello <strong>world</strong></p>")
      %{"type" => "doc", "content" => [
        %{"type" => "paragraph", "content" => [
          %{"type" => "text", "text" => "Hello "},
          %{"type" => "text", "text" => "world", "marks" => [%{"type" => "bold"}]}
        ]}
      ]}
  """
  @spec from_html(String.t()) :: map()
  def from_html(html) when is_binary(html) do
    nodes =
      html
      |> String.replace("\r\n", "\n")
      |> parse_html_blocks()
      |> Enum.reject(&is_nil/1)

    %{"type" => "doc", "content" => ensure_non_empty(nodes)}
  end

  def from_html(_), do: %{"type" => "doc", "content" => [%{"type" => "paragraph"}]}

  defp parse_html_blocks(html) do
    html
    |> extract_html_blocks()
    |> Enum.map(&parse_html_block/1)
    |> Enum.reject(&is_nil/1)
  end

  defp extract_html_blocks(html) do
    # Match top-level block elements
    regex = ~r/<(p|h[1-6]|blockquote|ul|ol|pre|hr|img)[^>]*>.*?<\/\1>|<(hr|img)\s*[^>]*\/?>|<(p|h[1-6]|blockquote|ul|ol|pre)[^>]*>.*?<\/\3>/s

    case Regex.scan(regex, html) do
      [] ->
        # Fallback: treat the whole thing as one paragraph
        trimmed = html |> strip_tags() |> String.trim()
        if trimmed == "", do: [], else: [html]

      matches ->
        Enum.map(matches, &List.first/1)
    end
  end

  defp parse_html_block(block) do
    cond do
      Regex.match?(~r/\A<h([1-6])/i, block) ->
        [_, level_str] = Regex.run(~r/\A<h([1-6])/i, block)
        level = String.to_integer(level_str)
        inner = extract_inner(block, "h#{level}")
        content = parse_html_inline(inner)

        %{
          "type" => "heading",
          "attrs" => %{"level" => level},
          "content" => ensure_non_empty_inline(content)
        }

      Regex.match?(~r/\A<p/i, block) ->
        inner = extract_inner(block, "p")
        content = parse_html_inline(inner)
        %{"type" => "paragraph", "content" => ensure_non_empty_inline(content)}

      Regex.match?(~r/\A<blockquote/i, block) ->
        inner = extract_inner(block, "blockquote")
        content = parse_html_blocks(inner)
        %{"type" => "blockquote", "content" => ensure_non_empty(content)}

      Regex.match?(~r/\A<ul/i, block) ->
        items = extract_list_items(block)
        %{"type" => "bulletList", "content" => items}

      Regex.match?(~r/\A<ol/i, block) ->
        items = extract_list_items(block)
        %{"type" => "orderedList", "content" => items}

      Regex.match?(~r/\A<pre/i, block) ->
        code = block |> extract_inner("pre") |> extract_code_content() |> html_unescape()
        content = if code == "", do: [], else: [%{"type" => "text", "text" => code}]
        %{"type" => "codeBlock", "content" => content}

      Regex.match?(~r/\A<hr/i, block) ->
        %{"type" => "horizontalRule"}

      Regex.match?(~r/\A<img/i, block) ->
        src = extract_attr(block, "src")
        alt = extract_attr(block, "alt")
        %{"type" => "image", "attrs" => %{"src" => src || "", "alt" => alt || ""}}

      true ->
        trimmed = strip_tags(block) |> String.trim()

        if trimmed == "" do
          nil
        else
          %{"type" => "paragraph", "content" => [%{"type" => "text", "text" => trimmed}]}
        end
    end
  end

  defp extract_inner(html, tag) do
    regex = Regex.compile!("<#{tag}[^>]*>(.*?)</#{tag}>", [:dotall, :caseless])

    case Regex.run(regex, html) do
      [_, inner] -> inner
      _ -> ""
    end
  end

  defp extract_code_content(html) do
    case Regex.run(~r/<code[^>]*>(.*?)<\/code>/s, html) do
      [_, code] -> code
      _ -> strip_tags(html)
    end
  end

  defp extract_list_items(html) do
    Regex.scan(~r/<li[^>]*>(.*?)<\/li>/s, html)
    |> Enum.map(fn [_, inner] ->
      content = parse_html_inline(inner)

      %{
        "type" => "listItem",
        "content" => [%{"type" => "paragraph", "content" => ensure_non_empty_inline(content)}]
      }
    end)
  end

  defp extract_attr(html, attr_name) do
    regex = Regex.compile!("#{attr_name}=[\"']([^\"']*)[\"']", [:caseless])

    case Regex.run(regex, html) do
      [_, value] -> value
      _ -> nil
    end
  end

  defp parse_html_inline(html) when is_binary(html) do
    html
    |> tokenize_html_inline([])
    |> Enum.reverse()
    |> Enum.reject(&is_nil/1)
  end

  defp tokenize_html_inline("", acc), do: acc

  defp tokenize_html_inline(html, acc) do
    cond do
      # Bold: <strong>text</strong> or <b>text</b>
      match = Regex.run(~r/\A<(?:strong|b)>(.*?)<\/(?:strong|b)>(.*)/s, html) ->
        [_, inner, rest] = match
        node = %{"type" => "text", "text" => strip_tags(inner), "marks" => [%{"type" => "bold"}]}
        tokenize_html_inline(rest, [node | acc])

      # Italic: <em>text</em> or <i>text</i>
      match = Regex.run(~r/\A<(?:em|i)>(.*?)<\/(?:em|i)>(.*)/s, html) ->
        [_, inner, rest] = match
        node = %{"type" => "text", "text" => strip_tags(inner), "marks" => [%{"type" => "italic"}]}
        tokenize_html_inline(rest, [node | acc])

      # Link: <a href="url">text</a>
      match = Regex.run(~r/\A<a\s[^>]*href=[\"']([^\"']*)[\"'][^>]*>(.*?)<\/a>(.*)/s, html) ->
        [_, href, inner, rest] = match
        node = %{"type" => "text", "text" => strip_tags(inner), "marks" => [%{"type" => "link", "attrs" => %{"href" => href}}]}
        tokenize_html_inline(rest, [node | acc])

      # Strikethrough: <s>text</s> or <del>text</del>
      match = Regex.run(~r/\A<(?:s|del|strike)>(.*?)<\/(?:s|del|strike)>(.*)/s, html) ->
        [_, inner, rest] = match
        node = %{"type" => "text", "text" => strip_tags(inner), "marks" => [%{"type" => "strike"}]}
        tokenize_html_inline(rest, [node | acc])

      # Code: <code>text</code>
      match = Regex.run(~r/\A<code>(.*?)<\/code>(.*)/s, html) ->
        [_, inner, rest] = match
        node = %{"type" => "text", "text" => inner, "marks" => [%{"type" => "code"}]}
        tokenize_html_inline(rest, [node | acc])

      # Line break: <br> or <br/>
      match = Regex.run(~r/\A<br\s*\/?>(.*)/s, html) ->
        [_, rest] = match
        tokenize_html_inline(rest, [%{"type" => "hardBreak"} | acc])

      # Skip other opening tags
      match = Regex.run(~r/\A<[^>]+>(.*)/s, html) ->
        [_, rest] = match
        tokenize_html_inline(rest, acc)

      # Plain text up to next tag
      match = Regex.run(~r/\A([^<]+)(.*)/s, html) ->
        [_, plain, rest] = match
        unescaped = html_unescape(plain)

        if unescaped == "" do
          tokenize_html_inline(rest, acc)
        else
          node = %{"type" => "text", "text" => unescaped}
          tokenize_html_inline(rest, [node | acc])
        end

      true ->
        acc
    end
  end

  defp strip_tags(html) do
    Regex.replace(~r/<[^>]*>/, html, "")
  end

  defp html_unescape(text) do
    text
    |> String.replace("&amp;", "&")
    |> String.replace("&lt;", "<")
    |> String.replace("&gt;", ">")
    |> String.replace("&quot;", "\"")
    |> String.replace("&#39;", "'")
    |> String.replace("&nbsp;", " ")
  end

  # ===========================================================================
  # Shared helpers
  # ===========================================================================

  defp ensure_non_empty([]), do: [%{"type" => "paragraph"}]
  defp ensure_non_empty(nodes), do: nodes

  defp ensure_non_empty_inline([]), do: [%{"type" => "text", "text" => ""}]
  defp ensure_non_empty_inline(nodes), do: nodes
end
