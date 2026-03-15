defmodule PhiaUi.Components.Editor.TipTapHelpersTest do
  use ExUnit.Case, async: true

  alias PhiaUi.Components.Editor.TipTapHelpers

  # ---------------------------------------------------------------------------
  # empty_document/0
  # ---------------------------------------------------------------------------

  describe "empty_document/0" do
    test "returns canonical empty doc" do
      doc = TipTapHelpers.empty_document()
      assert doc == %{"type" => "doc", "content" => [%{"type" => "paragraph"}]}
    end
  end

  # ---------------------------------------------------------------------------
  # content_to_html/1
  # ---------------------------------------------------------------------------

  describe "content_to_html/1" do
    test "returns empty string for nil" do
      assert TipTapHelpers.content_to_html(nil) == ""
    end

    test "returns empty string for empty doc" do
      assert TipTapHelpers.content_to_html(%{"type" => "doc"}) == ""
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

      assert TipTapHelpers.content_to_html(doc) == "<p>Hello world</p>"
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

      assert TipTapHelpers.content_to_html(doc) == "<p><strong>bold text</strong></p>"
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

      assert TipTapHelpers.content_to_html(doc) == "<p><em>italic</em></p>"
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

      html = TipTapHelpers.content_to_html(doc)
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

      html = TipTapHelpers.content_to_html(doc)
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

      assert TipTapHelpers.content_to_html(doc) == "<h2>Title</h2>"
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

      assert TipTapHelpers.content_to_html(doc) == "<blockquote><p>quoted</p></blockquote>"
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

      html = TipTapHelpers.content_to_html(doc)
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

      assert TipTapHelpers.content_to_html(doc) == "<pre><code>def foo, do: :bar</code></pre>"
    end

    test "renders horizontal rule" do
      doc = %{
        "type" => "doc",
        "content" => [%{"type" => "horizontalRule"}]
      }

      assert TipTapHelpers.content_to_html(doc) == "<hr>"
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

      assert TipTapHelpers.content_to_html(doc) == "<p>line 1<br>line 2</p>"
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

      html = TipTapHelpers.content_to_html(doc)
      refute html =~ "<script>"
      assert html =~ "&lt;script&gt;"
    end

    test "renders empty paragraph" do
      doc = %{
        "type" => "doc",
        "content" => [%{"type" => "paragraph"}]
      }

      assert TipTapHelpers.content_to_html(doc) == "<p></p>"
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

      html = TipTapHelpers.content_to_html(doc)
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

      assert TipTapHelpers.content_to_html(doc) == "<p>kept</p>"
    end
  end

  # ---------------------------------------------------------------------------
  # content_to_text/1
  # ---------------------------------------------------------------------------

  describe "content_to_text/1" do
    test "returns empty string for nil" do
      assert TipTapHelpers.content_to_text(nil) == ""
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

      assert TipTapHelpers.content_to_text(doc) == "Hello world"
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

      assert TipTapHelpers.content_to_text(doc) == "First\nSecond"
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

      assert TipTapHelpers.content_to_text(doc) == "plain bold"
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

      assert {:ok, ^doc} = TipTapHelpers.validate_content(doc)
    end

    test "returns error for disallowed node type" do
      doc = %{
        "type" => "doc",
        "content" => [%{"type" => "script"}]
      }

      assert {:error, errors} = TipTapHelpers.validate_content(doc)
      assert "disallowed node type: script" in errors
    end

    test "returns error for disallowed mark type" do
      doc = %{
        "type" => "doc",
        "content" => [
          %{
            "type" => "paragraph",
            "content" => [
              %{
                "type" => "text",
                "text" => "x",
                "marks" => [%{"type" => "highlight"}]
              }
            ]
          }
        ]
      }

      assert {:error, errors} = TipTapHelpers.validate_content(doc)
      assert "disallowed mark type: highlight" in errors
    end

    test "accepts custom allowed nodes" do
      doc = %{
        "type" => "doc",
        "content" => [%{"type" => "custom_widget"}]
      }

      assert {:ok, ^doc} =
               TipTapHelpers.validate_content(doc,
                 allowed_nodes: ~w(doc custom_widget text)
               )
    end

    test "returns error for non-doc root" do
      assert {:error, ["invalid document: missing type \"doc\""]} =
               TipTapHelpers.validate_content(%{"type" => "paragraph"})
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

      result = TipTapHelpers.sanitize_content(doc)

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

    test "strips disallowed marks" do
      doc = %{
        "type" => "doc",
        "content" => [
          %{
            "type" => "paragraph",
            "content" => [
              %{
                "type" => "text",
                "text" => "x",
                "marks" => [%{"type" => "bold"}, %{"type" => "font_color"}]
              }
            ]
          }
        ]
      }

      result = TipTapHelpers.sanitize_content(doc)
      text_node = get_in(result, ["content", Access.at(0), "content", Access.at(0)])
      assert text_node["marks"] == [%{"type" => "bold"}]
    end

    test "returns empty doc for nil" do
      assert TipTapHelpers.sanitize_content(nil) == TipTapHelpers.empty_document()
    end

    test "removes marks key when all marks stripped" do
      doc = %{
        "type" => "doc",
        "content" => [
          %{
            "type" => "paragraph",
            "content" => [
              %{
                "type" => "text",
                "text" => "x",
                "marks" => [%{"type" => "font_color"}]
              }
            ]
          }
        ]
      }

      result = TipTapHelpers.sanitize_content(doc)
      text_node = get_in(result, ["content", Access.at(0), "content", Access.at(0)])
      refute Map.has_key?(text_node, "marks")
    end
  end

  # ---------------------------------------------------------------------------
  # word_count/1
  # ---------------------------------------------------------------------------

  describe "word_count/1" do
    test "returns 0 for nil" do
      assert TipTapHelpers.word_count(nil) == 0
    end

    test "returns 0 for empty doc" do
      assert TipTapHelpers.word_count(TipTapHelpers.empty_document()) == 0
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

      assert TipTapHelpers.word_count(doc) == 3
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

      assert TipTapHelpers.word_count(doc) == 5
    end

    test "handles multiple whitespace" do
      doc = %{
        "type" => "doc",
        "content" => [
          %{
            "type" => "paragraph",
            "content" => [%{"type" => "text", "text" => "  word1   word2  "}]
          }
        ]
      }

      assert TipTapHelpers.word_count(doc) == 2
    end
  end
end
