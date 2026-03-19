defmodule PhiaUi.Components.Editor.EditorContentTest do
  use ExUnit.Case, async: true

  alias PhiaUi.Components.Editor.EditorContent

  # ---------------------------------------------------------------------------
  # empty_document/0
  # ---------------------------------------------------------------------------

  describe "empty_document/0" do
    test "returns canonical empty doc" do
      doc = EditorContent.empty_document()
      assert doc == %{"type" => "doc", "content" => [%{"type" => "paragraph"}]}
    end
  end

  # ---------------------------------------------------------------------------
  # content_to_html/1
  # ---------------------------------------------------------------------------

  describe "content_to_html/1" do
    test "returns empty string for nil" do
      assert EditorContent.content_to_html(nil) == ""
    end

    test "returns empty string for empty doc" do
      assert EditorContent.content_to_html(%{"type" => "doc"}) == ""
    end

    test "renders paragraph with text" do
      doc = %{
        "type" => "doc",
        "content" => [
          %{
            "type" => "paragraph",
            "content" => [%{"type" => "text", "text" => "Hello world"}]
          }
        ]
      }

      assert EditorContent.content_to_html(doc) == "<p>Hello world</p>"
    end

    test "renders bold mark" do
      doc = %{
        "type" => "doc",
        "content" => [
          %{
            "type" => "paragraph",
            "content" => [
              %{"type" => "text", "text" => "bold text", "marks" => [%{"type" => "bold"}]}
            ]
          }
        ]
      }

      assert EditorContent.content_to_html(doc) == "<p><strong>bold text</strong></p>"
    end

    test "renders italic mark" do
      doc = %{
        "type" => "doc",
        "content" => [
          %{
            "type" => "paragraph",
            "content" => [
              %{"type" => "text", "text" => "italic", "marks" => [%{"type" => "italic"}]}
            ]
          }
        ]
      }

      assert EditorContent.content_to_html(doc) == "<p><em>italic</em></p>"
    end

    test "renders nested marks" do
      doc = %{
        "type" => "doc",
        "content" => [
          %{
            "type" => "paragraph",
            "content" => [
              %{
                "type" => "text",
                "text" => "both",
                "marks" => [%{"type" => "bold"}, %{"type" => "italic"}]
              }
            ]
          }
        ]
      }

      html = EditorContent.content_to_html(doc)
      assert html =~ "<strong>"
      assert html =~ "<em>"
      assert html =~ "both"
    end

    test "renders link mark with href" do
      doc = %{
        "type" => "doc",
        "content" => [
          %{
            "type" => "paragraph",
            "content" => [
              %{
                "type" => "text",
                "text" => "click",
                "marks" => [
                  %{"type" => "link", "attrs" => %{"href" => "https://example.com"}}
                ]
              }
            ]
          }
        ]
      }

      html = EditorContent.content_to_html(doc)
      assert html =~ ~s[<a href="https://example.com">click</a>]
    end

    test "renders heading" do
      doc = %{
        "type" => "doc",
        "content" => [
          %{
            "type" => "heading",
            "attrs" => %{"level" => 2},
            "content" => [%{"type" => "text", "text" => "Title"}]
          }
        ]
      }

      assert EditorContent.content_to_html(doc) == "<h2>Title</h2>"
    end

    test "renders blockquote" do
      doc = %{
        "type" => "doc",
        "content" => [
          %{
            "type" => "blockquote",
            "content" => [
              %{
                "type" => "paragraph",
                "content" => [%{"type" => "text", "text" => "quoted"}]
              }
            ]
          }
        ]
      }

      assert EditorContent.content_to_html(doc) == "<blockquote><p>quoted</p></blockquote>"
    end

    test "renders bullet list" do
      doc = %{
        "type" => "doc",
        "content" => [
          %{
            "type" => "bulletList",
            "content" => [
              %{
                "type" => "listItem",
                "content" => [
                  %{
                    "type" => "paragraph",
                    "content" => [%{"type" => "text", "text" => "item 1"}]
                  }
                ]
              }
            ]
          }
        ]
      }

      html = EditorContent.content_to_html(doc)
      assert html =~ "<ul>"
      assert html =~ "<li>"
      assert html =~ "item 1"
    end

    test "renders code block" do
      doc = %{
        "type" => "doc",
        "content" => [
          %{
            "type" => "codeBlock",
            "content" => [%{"type" => "text", "text" => "def foo, do: :bar"}]
          }
        ]
      }

      assert EditorContent.content_to_html(doc) == "<pre><code>def foo, do: :bar</code></pre>"
    end

    test "renders horizontal rule" do
      doc = %{
        "type" => "doc",
        "content" => [%{"type" => "horizontalRule"}]
      }

      assert EditorContent.content_to_html(doc) == "<hr>"
    end

    test "renders hard break" do
      doc = %{
        "type" => "doc",
        "content" => [
          %{
            "type" => "paragraph",
            "content" => [
              %{"type" => "text", "text" => "line 1"},
              %{"type" => "hardBreak"},
              %{"type" => "text", "text" => "line 2"}
            ]
          }
        ]
      }

      assert EditorContent.content_to_html(doc) == "<p>line 1<br>line 2</p>"
    end

    test "escapes HTML in text content" do
      doc = %{
        "type" => "doc",
        "content" => [
          %{
            "type" => "paragraph",
            "content" => [%{"type" => "text", "text" => "<script>alert('xss')</script>"}]
          }
        ]
      }

      html = EditorContent.content_to_html(doc)
      refute html =~ "<script>"
      assert html =~ "&lt;script&gt;"
    end

    test "renders empty paragraph" do
      doc = %{
        "type" => "doc",
        "content" => [%{"type" => "paragraph"}]
      }

      assert EditorContent.content_to_html(doc) == "<p></p>"
    end

    test "renders image" do
      doc = %{
        "type" => "doc",
        "content" => [
          %{
            "type" => "image",
            "attrs" => %{"src" => "https://example.com/img.png", "alt" => "a photo"}
          }
        ]
      }

      html = EditorContent.content_to_html(doc)
      assert html =~ ~s[src="https://example.com/img.png"]
      assert html =~ ~s[alt="a photo"]
    end

    test "skips unknown node types" do
      doc = %{
        "type" => "doc",
        "content" => [
          %{"type" => "unknownWidget"},
          %{
            "type" => "paragraph",
            "content" => [%{"type" => "text", "text" => "kept"}]
          }
        ]
      }

      assert EditorContent.content_to_html(doc) == "<p>kept</p>"
    end

    test "renders callout block" do
      doc = %{
        "type" => "doc",
        "content" => [
          %{
            "type" => "callout",
            "attrs" => %{"variant" => "warning", "icon" => "!"},
            "content" => [
              %{"type" => "paragraph", "content" => [%{"type" => "text", "text" => "Be careful"}]}
            ]
          }
        ]
      }

      html = EditorContent.content_to_html(doc)
      assert html =~ "data-type=\"callout\""
      assert html =~ "data-variant=\"warning\""
      assert html =~ "Be careful"
    end

    test "renders details block" do
      doc = %{
        "type" => "doc",
        "content" => [
          %{
            "type" => "details",
            "attrs" => %{"summary" => "Click to expand"},
            "content" => [
              %{"type" => "paragraph", "content" => [%{"type" => "text", "text" => "Hidden content"}]}
            ]
          }
        ]
      }

      html = EditorContent.content_to_html(doc)
      assert html =~ "<details>"
      assert html =~ "<summary>Click to expand</summary>"
      assert html =~ "Hidden content"
    end
  end

  # ---------------------------------------------------------------------------
  # content_to_text/1
  # ---------------------------------------------------------------------------

  describe "content_to_text/1" do
    test "returns empty string for nil" do
      assert EditorContent.content_to_text(nil) == ""
    end

    test "extracts text from paragraph" do
      doc = %{
        "type" => "doc",
        "content" => [
          %{
            "type" => "paragraph",
            "content" => [%{"type" => "text", "text" => "Hello world"}]
          }
        ]
      }

      assert EditorContent.content_to_text(doc) == "Hello world"
    end

    test "separates blocks with newlines" do
      doc = %{
        "type" => "doc",
        "content" => [
          %{
            "type" => "paragraph",
            "content" => [%{"type" => "text", "text" => "First"}]
          },
          %{
            "type" => "paragraph",
            "content" => [%{"type" => "text", "text" => "Second"}]
          }
        ]
      }

      assert EditorContent.content_to_text(doc) == "First\nSecond"
    end

    test "strips marks in text extraction" do
      doc = %{
        "type" => "doc",
        "content" => [
          %{
            "type" => "paragraph",
            "content" => [
              %{"type" => "text", "text" => "plain "},
              %{"type" => "text", "text" => "bold", "marks" => [%{"type" => "bold"}]}
            ]
          }
        ]
      }

      assert EditorContent.content_to_text(doc) == "plain bold"
    end
  end

  # ---------------------------------------------------------------------------
  # validate_content/2
  # ---------------------------------------------------------------------------

  describe "validate_content/2" do
    test "returns ok for valid document" do
      doc = %{
        "type" => "doc",
        "content" => [
          %{
            "type" => "paragraph",
            "content" => [%{"type" => "text", "text" => "valid"}]
          }
        ]
      }

      assert {:ok, ^doc} = EditorContent.validate_content(doc)
    end

    test "returns error for disallowed node type" do
      doc = %{
        "type" => "doc",
        "content" => [%{"type" => "script"}]
      }

      assert {:error, errors} = EditorContent.validate_content(doc)
      assert "disallowed node type: script" in errors
    end

    test "returns error for non-doc root" do
      assert {:error, ["invalid document: missing type \"doc\""]} =
               EditorContent.validate_content(%{"type" => "paragraph"})
    end
  end

  # ---------------------------------------------------------------------------
  # sanitize_content/2
  # ---------------------------------------------------------------------------

  describe "sanitize_content/2" do
    test "removes disallowed nodes" do
      doc = %{
        "type" => "doc",
        "content" => [
          %{
            "type" => "paragraph",
            "content" => [%{"type" => "text", "text" => "ok"}]
          },
          %{"type" => "script", "content" => []}
        ]
      }

      result = EditorContent.sanitize_content(doc)

      assert result == %{
               "type" => "doc",
               "content" => [
                 %{
                   "type" => "paragraph",
                   "content" => [%{"type" => "text", "text" => "ok"}]
                 }
               ]
             }
    end

    test "returns empty doc for nil" do
      assert EditorContent.sanitize_content(nil) == EditorContent.empty_document()
    end
  end

  # ---------------------------------------------------------------------------
  # word_count/1
  # ---------------------------------------------------------------------------

  describe "word_count/1" do
    test "returns 0 for nil" do
      assert EditorContent.word_count(nil) == 0
    end

    test "returns 0 for empty doc" do
      assert EditorContent.word_count(EditorContent.empty_document()) == 0
    end

    test "counts words in paragraph" do
      doc = %{
        "type" => "doc",
        "content" => [
          %{
            "type" => "paragraph",
            "content" => [%{"type" => "text", "text" => "Hello beautiful world"}]
          }
        ]
      }

      assert EditorContent.word_count(doc) == 3
    end

    test "counts words across multiple blocks" do
      doc = %{
        "type" => "doc",
        "content" => [
          %{
            "type" => "paragraph",
            "content" => [%{"type" => "text", "text" => "First paragraph"}]
          },
          %{
            "type" => "paragraph",
            "content" => [%{"type" => "text", "text" => "Second paragraph here"}]
          }
        ]
      }

      assert EditorContent.word_count(doc) == 5
    end
  end
end
