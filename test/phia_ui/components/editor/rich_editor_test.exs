defmodule PhiaUi.Components.Editor.RichEditorTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  # ---------------------------------------------------------------------------
  # Test helpers — all render functions live inside module H
  # ---------------------------------------------------------------------------

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.Editor.RichEditor

    # rich_editor
    def render_rich_editor(assigns) do
      assigns = Map.put_new(assigns, :id, "test-editor")
      assigns = Map.put_new(assigns, :field, nil)
      assigns = Map.put_new(assigns, :value, nil)
      assigns = Map.put_new(assigns, :placeholder, "Type here...")
      assigns = Map.put_new(assigns, :min_height, "200px")
      assigns = Map.put_new(assigns, :extensions, [:starter_kit, :placeholder])
      assigns = Map.put_new(assigns, :on_update, "editor:update")
      assigns = Map.put_new(assigns, :on_selection, "editor:selection")
      assigns = Map.put_new(assigns, :toolbar_variant, :default)
      assigns = Map.put_new(assigns, :show_word_count, true)
      assigns = Map.put_new(assigns, :show_find_replace, false)
      assigns = Map.put_new(assigns, :content_format, :json)
      assigns = Map.put_new(assigns, :collab_enabled, false)
      assigns = Map.put_new(assigns, :collab_doc_id, nil)
      assigns = Map.put_new(assigns, :collab_user, nil)
      assigns = Map.put_new(assigns, :class, nil)
      assigns = Map.put_new(assigns, :toolbar_extra, [])

      ~H"""
      <.rich_editor
        id={@id}
        field={@field}
        value={@value}
        placeholder={@placeholder}
        min_height={@min_height}
        extensions={@extensions}
        on_update={@on_update}
        on_selection={@on_selection}
        toolbar_variant={@toolbar_variant}
        show_word_count={@show_word_count}
        show_find_replace={@show_find_replace}
        content_format={@content_format}
        collab_enabled={@collab_enabled}
        collab_doc_id={@collab_doc_id}
        collab_user={@collab_user}
        class={@class}
      />
      """
    end

    # rich_toolbar
    def render_rich_toolbar(assigns) do
      assigns = Map.put_new(assigns, :variant, :default)
      assigns = Map.put_new(assigns, :editor_id, "test-editor")
      assigns = Map.put_new(assigns, :active_marks, [])
      assigns = Map.put_new(assigns, :active_nodes, [])
      assigns = Map.put_new(assigns, :heading_level, nil)
      assigns = Map.put_new(assigns, :class, nil)
      assigns = Map.put_new(assigns, :extra, [])

      ~H"""
      <.rich_toolbar
        variant={@variant}
        editor_id={@editor_id}
        active_marks={@active_marks}
        active_nodes={@active_nodes}
        heading_level={@heading_level}
        class={@class}
      />
      """
    end

    # rich_content
    def render_rich_content(assigns) do
      assigns = Map.put_new(assigns, :content, nil)
      assigns = Map.put_new(assigns, :prose_size, :base)
      assigns = Map.put_new(assigns, :class, nil)

      ~H"""
      <.rich_content content={@content} prose_size={@prose_size} class={@class} />
      """
    end

    # rich_bubble_menu
    def render_rich_bubble_menu(assigns) do
      assigns = Map.put_new(assigns, :id, "bubble-1")
      assigns = Map.put_new(assigns, :editor_id, "test-editor")
      assigns = Map.put_new(assigns, :class, nil)

      ~H"""
      <.rich_bubble_menu id={@id} editor_id={@editor_id} class={@class}>
        <button>Bold</button>
      </.rich_bubble_menu>
      """
    end

    # rich_floating_menu
    def render_rich_floating_menu(assigns) do
      assigns = Map.put_new(assigns, :id, "float-1")
      assigns = Map.put_new(assigns, :editor_id, "test-editor")
      assigns = Map.put_new(assigns, :class, nil)

      ~H"""
      <.rich_floating_menu id={@id} editor_id={@editor_id} class={@class}>
        <button>Heading</button>
      </.rich_floating_menu>
      """
    end

    # rich_slash_commands
    def render_rich_slash_commands(assigns) do
      assigns = Map.put_new(assigns, :id, "slash-1")
      assigns = Map.put_new(assigns, :editor_id, "test-editor")
      assigns = Map.put_new(assigns, :class, nil)

      ~H"""
      <.rich_slash_commands id={@id} editor_id={@editor_id} class={@class}>
        <:command label="Heading 1" action="setHeading" description="Large heading" />
        <:command label="Bullet List" action="toggleBulletList" />
      </.rich_slash_commands>
      """
    end

    # rich_mention
    def render_rich_mention(assigns) do
      assigns = Map.put_new(assigns, :id, "mention-1")
      assigns = Map.put_new(assigns, :editor_id, "test-editor")
      assigns = Map.put_new(assigns, :suggestions, [])
      assigns = Map.put_new(assigns, :class, nil)

      ~H"""
      <.rich_mention
        id={@id}
        editor_id={@editor_id}
        suggestions={@suggestions}
        class={@class}
      />
      """
    end

    # collab_cursors
    def render_collab_cursors(assigns) do
      assigns = Map.put_new(assigns, :id, "cursors-1")
      assigns = Map.put_new(assigns, :editor_id, "test-editor")
      assigns = Map.put_new(assigns, :cursors, [])
      assigns = Map.put_new(assigns, :class, nil)

      ~H"""
      <.collab_cursors
        id={@id}
        editor_id={@editor_id}
        cursors={@cursors}
        class={@class}
      />
      """
    end
  end

  # ===========================================================================
  # rich_editor/1
  # ===========================================================================

  describe "rich_editor/1" do
    test "renders with required id" do
      html = render_component(&H.render_rich_editor/1, %{id: "my-editor"})
      assert html =~ ~s[id="my-editor"]
      assert html =~ ~s[phx-hook="PhiaRichEditor"]
    end

    test "renders hidden input for form value" do
      html = render_component(&H.render_rich_editor/1, %{id: "ed"})
      assert html =~ ~s[type="hidden"]
      assert html =~ ~s[data-rich-hidden]
    end

    test "renders content area with data-rich-content" do
      html = render_component(&H.render_rich_editor/1, %{id: "ed"})
      assert html =~ ~s[data-rich-content]
    end

    test "renders placeholder data attr" do
      html =
        render_component(&H.render_rich_editor/1, %{id: "ed", placeholder: "Write something"})

      assert html =~ ~s[data-placeholder="Write something"]
    end

    test "renders word count footer by default" do
      html = render_component(&H.render_rich_editor/1, %{id: "ed"})
      assert html =~ "data-rich-footer"
      assert html =~ "data-rich-word-count"
    end

    test "hides word count when show_word_count is false" do
      html = render_component(&H.render_rich_editor/1, %{id: "ed", show_word_count: false})
      refute html =~ "data-rich-footer"
    end

    test "renders toolbar" do
      html = render_component(&H.render_rich_editor/1, %{id: "ed"})
      assert html =~ ~s[role="toolbar"]
      assert html =~ "Bold"
    end

    test "renders data-on-update event name" do
      html = render_component(&H.render_rich_editor/1, %{id: "ed", on_update: "content:changed"})
      assert html =~ ~s[data-on-update="content:changed"]
    end

    test "renders data-on-selection event name" do
      html =
        render_component(&H.render_rich_editor/1, %{id: "ed", on_selection: "sel:changed"})

      assert html =~ ~s[data-on-selection="sel:changed"]
    end

    test "renders data-content-format" do
      html = render_component(&H.render_rich_editor/1, %{id: "ed", content_format: :html})
      assert html =~ ~s[data-content-format="html"]
    end

    test "renders min-height style" do
      html = render_component(&H.render_rich_editor/1, %{id: "ed", min_height: "500px"})
      assert html =~ "min-height: 500px"
    end

    test "renders custom class" do
      html = render_component(&H.render_rich_editor/1, %{id: "ed", class: "my-custom"})
      assert html =~ "my-custom"
    end

    test "renders extensions as JSON data attr" do
      html =
        render_component(&H.render_rich_editor/1, %{
          id: "ed",
          extensions: [:starter_kit, :link]
        })

      assert html =~ "data-extensions"
    end
  end

  # ===========================================================================
  # rich_toolbar/1
  # ===========================================================================

  describe "rich_toolbar/1" do
    test "renders toolbar role" do
      html = render_component(&H.render_rich_toolbar/1, %{editor_id: "ed"})
      assert html =~ ~s[role="toolbar"]
    end

    test "renders formatting buttons" do
      html = render_component(&H.render_rich_toolbar/1, %{editor_id: "ed"})
      assert html =~ "Bold"
      assert html =~ "Italic"
      assert html =~ "Strikethrough"
      assert html =~ "Inline code"
    end

    test "renders block buttons" do
      html = render_component(&H.render_rich_toolbar/1, %{editor_id: "ed"})
      assert html =~ "Bullet list"
      assert html =~ "Ordered list"
      assert html =~ "Blockquote"
    end

    test "renders history buttons" do
      html = render_component(&H.render_rich_toolbar/1, %{editor_id: "ed"})
      assert html =~ "Undo"
      assert html =~ "Redo"
    end

    test "marks active bold button" do
      html =
        render_component(&H.render_rich_toolbar/1, %{
          editor_id: "ed",
          active_marks: ["bold"]
        })

      assert html =~ ~s[aria-pressed="true"]
    end

    test "marks inactive bold button" do
      html =
        render_component(&H.render_rich_toolbar/1, %{editor_id: "ed", active_marks: []})

      assert html =~ ~s[aria-pressed="false"]
    end

    test "renders separators" do
      html = render_component(&H.render_rich_toolbar/1, %{editor_id: "ed"})
      assert html =~ ~s[role="separator"]
    end
  end

  # ===========================================================================
  # rich_content/1
  # ===========================================================================

  describe "rich_content/1" do
    test "renders empty for nil content" do
      html = render_component(&H.render_rich_content/1, %{content: nil})
      assert html =~ "prose"
    end

    test "renders JSON content as HTML" do
      content = %{
        "type" => "doc",
        "content" => [
          %{
            "type" => "paragraph",
            "content" => [%{"type" => "text", "text" => "Hello from JSON"}]
          }
        ]
      }

      html = render_component(&H.render_rich_content/1, %{content: content})
      assert html =~ "Hello from JSON"
      assert html =~ "<p>"
    end

    test "renders JSON string content" do
      content =
        Jason.encode!(%{
          "type" => "doc",
          "content" => [
            %{
              "type" => "paragraph",
              "content" => [%{"type" => "text", "text" => "From string"}]
            }
          ]
        })

      html = render_component(&H.render_rich_content/1, %{content: content})
      assert html =~ "From string"
    end

    test "renders prose-sm variant" do
      html = render_component(&H.render_rich_content/1, %{content: nil, prose_size: :sm})
      assert html =~ "prose-sm"
    end

    test "renders prose-lg variant" do
      html = render_component(&H.render_rich_content/1, %{content: nil, prose_size: :lg})
      assert html =~ "prose-lg"
    end
  end

  # ===========================================================================
  # rich_bubble_menu/1
  # ===========================================================================

  describe "rich_bubble_menu/1" do
    test "renders with id and editor_id" do
      html = render_component(&H.render_rich_bubble_menu/1, %{id: "bub", editor_id: "ed"})
      assert html =~ ~s[id="bub"]
      assert html =~ ~s[data-editor-id="ed"]
      assert html =~ ~s[data-rich-bubble-menu]
    end

    test "renders as toolbar role" do
      html = render_component(&H.render_rich_bubble_menu/1, %{id: "bub", editor_id: "ed"})
      assert html =~ ~s[role="toolbar"]
    end

    test "renders inner block content" do
      html = render_component(&H.render_rich_bubble_menu/1, %{id: "bub", editor_id: "ed"})
      assert html =~ "Bold"
    end

    test "starts hidden" do
      html = render_component(&H.render_rich_bubble_menu/1, %{id: "bub", editor_id: "ed"})
      assert html =~ "hidden"
    end
  end

  # ===========================================================================
  # rich_floating_menu/1
  # ===========================================================================

  describe "rich_floating_menu/1" do
    test "renders with id and editor_id" do
      html =
        render_component(&H.render_rich_floating_menu/1, %{id: "float", editor_id: "ed"})

      assert html =~ ~s[id="float"]
      assert html =~ ~s[data-editor-id="ed"]
      assert html =~ ~s[data-rich-floating-menu]
    end

    test "renders as toolbar role" do
      html =
        render_component(&H.render_rich_floating_menu/1, %{id: "float", editor_id: "ed"})

      assert html =~ ~s[role="toolbar"]
    end

    test "starts hidden" do
      html =
        render_component(&H.render_rich_floating_menu/1, %{id: "float", editor_id: "ed"})

      assert html =~ "hidden"
    end
  end

  # ===========================================================================
  # rich_slash_commands/1
  # ===========================================================================

  describe "rich_slash_commands/1" do
    test "renders with id and editor_id" do
      html =
        render_component(&H.render_rich_slash_commands/1, %{id: "slash", editor_id: "ed"})

      assert html =~ ~s[id="slash"]
      assert html =~ ~s[data-editor-id="ed"]
      assert html =~ ~s[data-rich-slash-commands]
    end

    test "renders command items" do
      html =
        render_component(&H.render_rich_slash_commands/1, %{id: "slash", editor_id: "ed"})

      assert html =~ "Heading 1"
      assert html =~ "Bullet List"
    end

    test "renders command description" do
      html =
        render_component(&H.render_rich_slash_commands/1, %{id: "slash", editor_id: "ed"})

      assert html =~ "Large heading"
    end

    test "renders as listbox role" do
      html =
        render_component(&H.render_rich_slash_commands/1, %{id: "slash", editor_id: "ed"})

      assert html =~ ~s[role="listbox"]
    end
  end

  # ===========================================================================
  # rich_mention/1
  # ===========================================================================

  describe "rich_mention/1" do
    test "renders with id and editor_id" do
      html = render_component(&H.render_rich_mention/1, %{id: "men", editor_id: "ed"})
      assert html =~ ~s[id="men"]
      assert html =~ ~s[data-editor-id="ed"]
      assert html =~ ~s[data-rich-mention]
    end

    test "renders empty state when no suggestions" do
      html = render_component(&H.render_rich_mention/1, %{id: "men", editor_id: "ed"})
      assert html =~ "No matches found"
    end

    test "renders suggestions" do
      suggestions = [
        %{id: "1", label: "Alice"},
        %{id: "2", label: "Bob", avatar_url: "https://example.com/bob.jpg"}
      ]

      html =
        render_component(&H.render_rich_mention/1, %{
          id: "men",
          editor_id: "ed",
          suggestions: suggestions
        })

      assert html =~ "Alice"
      assert html =~ "Bob"
      assert html =~ "bob.jpg"
    end

    test "renders initial letter when no avatar" do
      suggestions = [%{id: "1", label: "Alice"}]

      html =
        render_component(&H.render_rich_mention/1, %{
          id: "men",
          editor_id: "ed",
          suggestions: suggestions
        })

      assert html =~ "A"
    end
  end

  # ===========================================================================
  # collab_cursors/1
  # ===========================================================================

  describe "collab_cursors/1" do
    test "renders with id and editor_id" do
      html =
        render_component(&H.render_collab_cursors/1, %{id: "cur", editor_id: "ed"})

      assert html =~ ~s[id="cur"]
      assert html =~ ~s[data-editor-id="ed"]
    end

    test "renders empty when no cursors" do
      html =
        render_component(&H.render_collab_cursors/1, %{
          id: "cur",
          editor_id: "ed",
          cursors: []
        })

      assert html =~ ~s[aria-label="Connected collaborators"]
    end

    test "renders cursor labels" do
      cursors = [
        %{name: "Alice", color: "#ef4444"},
        %{name: "Bob", color: "#3b82f6"}
      ]

      html =
        render_component(&H.render_collab_cursors/1, %{
          id: "cur",
          editor_id: "ed",
          cursors: cursors
        })

      assert html =~ "Alice"
      assert html =~ "Bob"
      assert html =~ "#ef4444"
      assert html =~ "#3b82f6"
    end

    test "renders cursor with avatar" do
      cursors = [
        %{name: "Alice", color: "#ef4444", avatar_url: "https://example.com/alice.jpg"}
      ]

      html =
        render_component(&H.render_collab_cursors/1, %{
          id: "cur",
          editor_id: "ed",
          cursors: cursors
        })

      assert html =~ "alice.jpg"
    end
  end
end
