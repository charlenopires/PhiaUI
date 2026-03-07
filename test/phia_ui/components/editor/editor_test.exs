defmodule PhiaUi.Components.EditorTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  # ---------------------------------------------------------------------------
  # Test helpers — all render functions live inside module H
  # ---------------------------------------------------------------------------

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.Editor

    # editor_toolbar
    def render_editor_toolbar(assigns) do
      ~H"""
      <.editor_toolbar aria_label={assigns[:aria_label] || "toolbar"} variant={assigns[:variant] || :default} class={assigns[:class]}>
        <span>content</span>
      </.editor_toolbar>
      """
    end

    # toolbar_button
    def render_toolbar_button(assigns) do
      ~H"""
      <.toolbar_button
        action={assigns[:action] || "bold"}
        aria_label={assigns[:aria_label] || "Bold"}
        active={assigns[:active] || false}
        disabled={assigns[:disabled] || false}
        size={assigns[:size] || :sm}
        tooltip={assigns[:tooltip]}
        class={assigns[:class]}
      >
        <span>B</span>
      </.toolbar_button>
      """
    end

    # toolbar_group
    def render_toolbar_group(assigns) do
      ~H"""
      <.toolbar_group label={assigns[:label]} class={assigns[:class]}>
        <span>grouped</span>
      </.toolbar_group>
      """
    end

    # toolbar_separator
    def render_toolbar_separator(assigns) do
      ~H"""
      <.toolbar_separator class={assigns[:class]} />
      """
    end

    # bubble_menu
    def render_bubble_menu(assigns) do
      ~H"""
      <.bubble_menu id={assigns[:id] || "bubble-1"} editor_id={assigns[:editor_id] || "ed"} class={assigns[:class]}>
        <span>actions</span>
      </.bubble_menu>
      """
    end

    # floating_menu
    def render_floating_menu(assigns) do
      ~H"""
      <.floating_menu id={assigns[:id] || "float-1"} editor_id={assigns[:editor_id] || "ed"} trigger={assigns[:trigger] || :empty_line}>
        <span>items</span>
      </.floating_menu>
      """
    end

    # slash_command_menu
    def render_slash_command_menu(assigns) do
      ~H"""
      <.slash_command_menu id="slash-1" editor_id="ed" on_select="cmd_selected">
        <:item value="h1" label="Heading 1" icon="H1" description="Big heading" shortcut="/h1" />
        <:item value="bulletList" label="Bullet List" />
      </.slash_command_menu>
      """
    end

    # inline_edit
    def render_inline_edit(assigns) do
      ~H"""
      <.inline_edit
        id={assigns[:id] || "ie-1"}
        value={assigns[:value]}
        type={assigns[:type] || :text}
        placeholder={assigns[:placeholder] || "Click to edit"}
        on_submit={assigns[:on_submit]}
        show_buttons={assigns[:show_buttons] || false}
        loading={assigns[:loading] || false}
        error={assigns[:error]}
        options={assigns[:options] || []}
      >
        <:preview :if={assigns[:preview]}>{assigns[:preview]}</:preview>
      </.inline_edit>
      """
    end

    # inline_edit_group
    def render_inline_edit_group(assigns) do
      ~H"""
      <.inline_edit_group
        id={assigns[:id] || "ieg-1"}
        on_save_all={assigns[:on_save_all]}
        on_cancel_all={assigns[:on_cancel_all]}
      >
        <span>fields</span>
      </.inline_edit_group>
      """
    end

    # editor_color_picker
    def render_editor_color_picker(assigns) do
      ~H"""
      <.editor_color_picker
        action={assigns[:action] || "foreColor"}
        label={assigns[:label] || "Text color"}
        colors={assigns[:colors] || []}
        value={assigns[:value]}
      />
      """
    end

    # editor_toolbar_dropdown
    def render_editor_toolbar_dropdown(assigns) do
      ~H"""
      <.editor_toolbar_dropdown id={assigns[:id] || "dd-1"} label={assigns[:label] || "Paragraph"} value={assigns[:value]}>
        <:item value="paragraph" label="Paragraph" />
        <:item value="h1" action="h1" label="Heading 1" />
      </.editor_toolbar_dropdown>
      """
    end

    # editor_link_dialog
    def render_editor_link_dialog(assigns) do
      ~H"""
      <.editor_link_dialog
        id={assigns[:id] || "link-dialog-1"}
        on_submit={assigns[:on_submit]}
        initial_url={assigns[:initial_url]}
        initial_title={assigns[:initial_title]}
      />
      """
    end

    # editor_code_block
    def render_editor_code_block(assigns) do
      ~H"""
      <.editor_code_block
        id={assigns[:id] || "code-1"}
        language={assigns[:language]}
        filename={assigns[:filename]}
        show_copy={assigns[:show_copy] != false}
        copy_value={assigns[:copy_value]}
        show_line_numbers={assigns[:show_line_numbers] || false}
        class={assigns[:class]}
      >
        def hello, do: :world
      </.editor_code_block>
      """
    end

    # editor_character_count
    def render_editor_character_count(assigns) do
      ~H"""
      <.editor_character_count
        count={assigns[:count] || 0}
        max={assigns[:max]}
        mode={assigns[:mode] || :characters}
        show_bar={assigns[:show_bar] || false}
      />
      """
    end

    # markdown_editor
    def render_markdown_editor(assigns) do
      ~H"""
      <.markdown_editor
        id={assigns[:id] || "md-1"}
        value={assigns[:value]}
        preview_html={assigns[:preview_html]}
        on_change={assigns[:on_change]}
        label={assigns[:label]}
        placeholder={assigns[:placeholder] || "Write in Markdown..."}
        min_height={assigns[:min_height] || "200px"}
      />
      """
    end

    # rich_text_viewer
    def render_rich_text_viewer(assigns) do
      ~H"""
      <.rich_text_viewer
        content={assigns[:content] || ""}
        prose_size={assigns[:prose_size] || :base}
        class={assigns[:class]}
      />
      """
    end

    # editor_find_replace
    def render_editor_find_replace(assigns) do
      ~H"""
      <.editor_find_replace
        id={assigns[:id] || "find-1"}
        editor_id={assigns[:editor_id] || "ed"}
        class={assigns[:class]}
      />
      """
    end

    # editor_word_count
    def render_editor_word_count(assigns) do
      ~H"""
      <.editor_word_count
        content={assigns[:content] || ""}
        show_reading_time={assigns[:show_reading_time] != false}
        words_per_minute={assigns[:words_per_minute] || 200}
      />
      """
    end

    # advanced_editor
    def render_advanced_editor(assigns) do
      ~H"""
      <.advanced_editor
        id={assigns[:id] || "adv-1"}
        value={assigns[:value]}
        placeholder={assigns[:placeholder]}
        min_height={assigns[:min_height] || "300px"}
        show_word_count={assigns[:show_word_count] != false}
        show_find_replace={assigns[:show_find_replace] || false}
        class={assigns[:class]}
      />
      """
    end
  end

  # ===========================================================================
  # Group A — Toolbar Primitives
  # ===========================================================================

  describe "editor_toolbar/1" do
    test "renders role=toolbar" do
      html = render_component(&H.render_editor_toolbar/1, %{})
      assert html =~ ~s(role="toolbar")
    end

    test "renders aria-label" do
      html = render_component(&H.render_editor_toolbar/1, %{aria_label: "My toolbar"})
      assert html =~ ~s(aria-label="My toolbar")
    end

    test "default variant renders border class" do
      html = render_component(&H.render_editor_toolbar/1, %{variant: :default})
      assert html =~ "border-input"
    end

    test "floating variant renders shadow-lg" do
      html = render_component(&H.render_editor_toolbar/1, %{variant: :floating})
      assert html =~ "shadow-lg"
    end

    test "compact variant renders gap-px" do
      html = render_component(&H.render_editor_toolbar/1, %{variant: :compact})
      assert html =~ "gap-px"
    end

    test "applies additional class" do
      html = render_component(&H.render_editor_toolbar/1, %{class: "my-custom-toolbar"})
      assert html =~ "my-custom-toolbar"
    end

    test "renders inner_block slot" do
      html = render_component(&H.render_editor_toolbar/1, %{})
      assert html =~ "content"
    end
  end

  describe "toolbar_button/1" do
    test "renders data-action" do
      html = render_component(&H.render_toolbar_button/1, %{action: "bold"})
      assert html =~ ~s(data-action="bold")
    end

    test "renders aria-label" do
      html = render_component(&H.render_toolbar_button/1, %{aria_label: "Bold"})
      assert html =~ ~s(aria-label="Bold")
    end

    test "aria-pressed is false by default" do
      html = render_component(&H.render_toolbar_button/1, %{})
      assert html =~ ~s(aria-pressed="false")
    end

    test "aria-pressed is true when active" do
      html = render_component(&H.render_toolbar_button/1, %{active: true})
      assert html =~ ~s(aria-pressed="true")
    end

    test "active adds bg-accent class" do
      html = render_component(&H.render_toolbar_button/1, %{active: true})
      assert html =~ "bg-accent"
    end

    test "disabled renders disabled attribute" do
      html = render_component(&H.render_toolbar_button/1, %{disabled: true})
      assert html =~ "disabled"
    end

    test "tooltip renders title attribute" do
      html = render_component(&H.render_toolbar_button/1, %{tooltip: "Bold Ctrl+B"})
      assert html =~ ~s[title="Bold Ctrl+B"]
    end

    test "size xs produces h-6" do
      html = render_component(&H.render_toolbar_button/1, %{size: :xs})
      assert html =~ "h-6"
    end

    test "size sm produces h-7" do
      html = render_component(&H.render_toolbar_button/1, %{size: :sm})
      assert html =~ "h-7"
    end

    test "size md produces h-8" do
      html = render_component(&H.render_toolbar_button/1, %{size: :md})
      assert html =~ "h-8"
    end

    test "renders type=button" do
      html = render_component(&H.render_toolbar_button/1, %{})
      assert html =~ ~s(type="button")
    end

    test "renders inner_block" do
      html = render_component(&H.render_toolbar_button/1, %{})
      assert html =~ ">B<"
    end
  end

  describe "toolbar_group/1" do
    test "renders role=group" do
      html = render_component(&H.render_toolbar_group/1, %{})
      assert html =~ ~s(role="group")
    end

    test "renders aria-label when label provided" do
      html = render_component(&H.render_toolbar_group/1, %{label: "Formatting"})
      assert html =~ ~s(aria-label="Formatting")
    end

    test "renders inner_block" do
      html = render_component(&H.render_toolbar_group/1, %{})
      assert html =~ "grouped"
    end

    test "applies additional class" do
      html = render_component(&H.render_toolbar_group/1, %{class: "my-group"})
      assert html =~ "my-group"
    end
  end

  describe "toolbar_separator/1" do
    test "renders role=separator" do
      html = render_component(&H.render_toolbar_separator/1, %{})
      assert html =~ ~s(role="separator")
    end

    test "renders vertical orientation" do
      html = render_component(&H.render_toolbar_separator/1, %{})
      assert html =~ ~s(aria-orientation="vertical")
    end

    test "renders w-px divider" do
      html = render_component(&H.render_toolbar_separator/1, %{})
      assert html =~ "w-px"
    end

    test "applies additional class" do
      html = render_component(&H.render_toolbar_separator/1, %{class: "mx-2"})
      assert html =~ "mx-2"
    end
  end

  # ===========================================================================
  # Group B — Floating / Contextual
  # ===========================================================================

  describe "bubble_menu/1" do
    test "renders phx-hook PhiaBubbleMenu" do
      html = render_component(&H.render_bubble_menu/1, %{})
      assert html =~ ~s(phx-hook="PhiaBubbleMenu")
    end

    test "renders data-editor-id" do
      html = render_component(&H.render_bubble_menu/1, %{editor_id: "my-ed"})
      assert html =~ ~s(data-editor-id="my-ed")
    end

    test "is hidden by default" do
      html = render_component(&H.render_bubble_menu/1, %{})
      assert html =~ "hidden"
    end

    test "renders id attribute" do
      html = render_component(&H.render_bubble_menu/1, %{id: "my-bubble"})
      assert html =~ ~s(id="my-bubble")
    end

    test "renders inner_block" do
      html = render_component(&H.render_bubble_menu/1, %{})
      assert html =~ "actions"
    end
  end

  describe "floating_menu/1" do
    test "renders phx-hook PhiaFloatingMenu" do
      html = render_component(&H.render_floating_menu/1, %{})
      assert html =~ ~s(phx-hook="PhiaFloatingMenu")
    end

    test "renders data-editor-id" do
      html = render_component(&H.render_floating_menu/1, %{editor_id: "ed-x"})
      assert html =~ ~s(data-editor-id="ed-x")
    end

    test "renders data-trigger" do
      html = render_component(&H.render_floating_menu/1, %{trigger: :slash})
      assert html =~ ~s(data-trigger="slash")
    end

    test "renders empty_line trigger by default" do
      html = render_component(&H.render_floating_menu/1, %{})
      assert html =~ ~s(data-trigger="empty_line")
    end

    test "is hidden by default" do
      html = render_component(&H.render_floating_menu/1, %{})
      assert html =~ "hidden"
    end
  end

  describe "slash_command_menu/1" do
    test "renders phx-hook PhiaSlashCommand" do
      html = render_component(&H.render_slash_command_menu/1, %{})
      assert html =~ ~s(phx-hook="PhiaSlashCommand")
    end

    test "renders data-on-select" do
      html = render_component(&H.render_slash_command_menu/1, %{})
      assert html =~ ~s(data-on-select="cmd_selected")
    end

    test "renders data-items JSON" do
      html = render_component(&H.render_slash_command_menu/1, %{})
      assert html =~ "data-items="
      assert html =~ "h1"
      assert html =~ "Heading 1"
    end

    test "renders search input" do
      html = render_component(&H.render_slash_command_menu/1, %{})
      assert html =~ ~s(data-slash-search)
    end

    test "renders slash item rows" do
      html = render_component(&H.render_slash_command_menu/1, %{})
      assert html =~ "data-slash-item"
      assert html =~ "Heading 1"
      assert html =~ "Bullet List"
    end

    test "renders icon for item with icon" do
      html = render_component(&H.render_slash_command_menu/1, %{})
      assert html =~ "H1"
    end

    test "renders shortcut for item with shortcut" do
      html = render_component(&H.render_slash_command_menu/1, %{})
      assert html =~ "/h1"
    end

    test "renders description for item with description" do
      html = render_component(&H.render_slash_command_menu/1, %{})
      assert html =~ "Big heading"
    end

    test "is hidden by default" do
      html = render_component(&H.render_slash_command_menu/1, %{})
      assert html =~ "hidden"
    end
  end

  # ===========================================================================
  # Group C — Enhanced Inline Editing
  # ===========================================================================

  describe "inline_edit/1" do
    test "renders phx-hook PhiaEditable" do
      html = render_component(&H.render_inline_edit/1, %{})
      assert html =~ ~s(phx-hook="PhiaEditable")
    end

    test "renders id attribute" do
      html = render_component(&H.render_inline_edit/1, %{id: "name-edit"})
      assert html =~ ~s(id="name-edit")
    end

    test "renders data-editable-preview" do
      html = render_component(&H.render_inline_edit/1, %{})
      assert html =~ "data-editable-preview"
    end

    test "renders data-editable-input" do
      html = render_component(&H.render_inline_edit/1, %{})
      assert html =~ "data-editable-input"
    end

    test "renders text input for type :text" do
      html = render_component(&H.render_inline_edit/1, %{type: :text})
      assert html =~ ~s(type="text")
    end

    test "renders number input for type :number" do
      html = render_component(&H.render_inline_edit/1, %{type: :number})
      assert html =~ ~s(type="number")
    end

    test "renders textarea for type :textarea" do
      html = render_component(&H.render_inline_edit/1, %{type: :textarea})
      assert html =~ "<textarea"
    end

    test "renders select for type :select" do
      html = render_component(&H.render_inline_edit/1, %{type: :select, options: ["a", "b"]})
      assert html =~ "<select"
      assert html =~ ~s[value="a"]
    end

    test "renders error message when error is set" do
      html = render_component(&H.render_inline_edit/1, %{error: "is required"})
      assert html =~ "is required"
      assert html =~ "text-destructive"
    end

    test "renders save/cancel buttons when show_buttons is true" do
      html = render_component(&H.render_inline_edit/1, %{show_buttons: true})
      assert html =~ "Save"
      assert html =~ "Cancel"
    end

    test "does not render buttons when show_buttons is false" do
      html = render_component(&H.render_inline_edit/1, %{show_buttons: false})
      refute html =~ "data-edit-submit"
    end

    test "renders spinner when loading" do
      html = render_component(&H.render_inline_edit/1, %{loading: true})
      assert html =~ "animate-spin"
    end

    test "renders data-on-submit" do
      html = render_component(&H.render_inline_edit/1, %{on_submit: "save_event"})
      assert html =~ ~s(data-on-submit="save_event")
    end

    test "renders placeholder in data attr" do
      html = render_component(&H.render_inline_edit/1, %{placeholder: "Edit me"})
      assert html =~ ~s(data-placeholder="Edit me")
    end
  end

  describe "inline_edit_group/1" do
    test "renders id attribute" do
      html = render_component(&H.render_inline_edit_group/1, %{id: "profile-group"})
      assert html =~ ~s(id="profile-group")
    end

    test "renders save all button when on_save_all set" do
      html = render_component(&H.render_inline_edit_group/1, %{on_save_all: "save_all"})
      assert html =~ "Save all"
      assert html =~ ~s(phx-click="save_all")
    end

    test "renders cancel button when on_cancel_all set" do
      html = render_component(&H.render_inline_edit_group/1, %{on_cancel_all: "reset_all"})
      assert html =~ "Cancel"
      assert html =~ ~s(phx-click="reset_all")
    end

    test "does not render default buttons when neither attr set" do
      html = render_component(&H.render_inline_edit_group/1, %{})
      refute html =~ "Save all"
    end

    test "renders inner_block" do
      html = render_component(&H.render_inline_edit_group/1, %{})
      assert html =~ "fields"
    end
  end

  # ===========================================================================
  # Group D — Rich Text Utilities
  # ===========================================================================

  describe "editor_color_picker/1" do
    test "renders phx-hook PhiaEditorColorPicker" do
      html = render_component(&H.render_editor_color_picker/1, %{})
      assert html =~ ~s(phx-hook="PhiaEditorColorPicker")
    end

    test "renders data-action" do
      html = render_component(&H.render_editor_color_picker/1, %{action: "foreColor"})
      assert html =~ ~s(data-action="foreColor")
    end

    test "renders data-color-trigger button" do
      html = render_component(&H.render_editor_color_picker/1, %{})
      assert html =~ "data-color-trigger"
    end

    test "renders default palette (14 swatches)" do
      html = render_component(&H.render_editor_color_picker/1, %{})
      assert html =~ "data-color-swatch"
      assert html =~ "#000000"
      assert html =~ "#FFFFFF"
    end

    test "renders custom palette when colors provided" do
      html = render_component(&H.render_editor_color_picker/1, %{colors: ["#FF0000", "#00FF00"]})
      assert html =~ "#FF0000"
      assert html =~ "#00FF00"
    end

    test "renders color panel hidden by default" do
      html = render_component(&H.render_editor_color_picker/1, %{})
      assert html =~ "data-color-panel"
      assert html =~ "hidden"
    end

    test "renders label text" do
      html = render_component(&H.render_editor_color_picker/1, %{label: "Highlight"})
      assert html =~ "Highlight"
    end
  end

  describe "editor_toolbar_dropdown/1" do
    test "renders phx-hook PhiaEditorDropdown" do
      html = render_component(&H.render_editor_toolbar_dropdown/1, %{})
      assert html =~ ~s(phx-hook="PhiaEditorDropdown")
    end

    test "renders id attribute" do
      html = render_component(&H.render_editor_toolbar_dropdown/1, %{id: "my-dd"})
      assert html =~ ~s(id="my-dd")
    end

    test "renders data-dropdown-trigger button" do
      html = render_component(&H.render_editor_toolbar_dropdown/1, %{})
      assert html =~ "data-dropdown-trigger"
    end

    test "renders dropdown panel" do
      html = render_component(&H.render_editor_toolbar_dropdown/1, %{})
      assert html =~ "data-dropdown-panel"
    end

    test "renders item options" do
      html = render_component(&H.render_editor_toolbar_dropdown/1, %{})
      assert html =~ "Paragraph"
      assert html =~ "Heading 1"
    end

    test "renders data-value on items" do
      html = render_component(&H.render_editor_toolbar_dropdown/1, %{})
      assert html =~ ~s(data-value="h1")
    end

    test "renders data-action on items" do
      html = render_component(&H.render_editor_toolbar_dropdown/1, %{})
      assert html =~ ~s(data-action="h1")
    end

    test "shows value in label when value provided" do
      html = render_component(&H.render_editor_toolbar_dropdown/1, %{value: "Heading 2"})
      assert html =~ "Heading 2"
    end

    test "panel is hidden by default" do
      html = render_component(&H.render_editor_toolbar_dropdown/1, %{})
      assert html =~ "hidden"
    end
  end

  describe "editor_link_dialog/1" do
    test "renders id attribute" do
      html = render_component(&H.render_editor_link_dialog/1, %{id: "link-dlg"})
      assert html =~ ~s(id="link-dlg")
    end

    test "is hidden by default" do
      html = render_component(&H.render_editor_link_dialog/1, %{})
      assert html =~ "hidden"
    end

    test "renders URL input field" do
      html = render_component(&H.render_editor_link_dialog/1, %{})
      assert html =~ "data-link-url"
      assert html =~ ~s(type="url")
    end

    test "renders title input field" do
      html = render_component(&H.render_editor_link_dialog/1, %{})
      assert html =~ "data-link-title"
    end

    test "renders new tab checkbox" do
      html = render_component(&H.render_editor_link_dialog/1, %{})
      assert html =~ "data-link-new-tab"
    end

    test "renders Insert link button" do
      html = render_component(&H.render_editor_link_dialog/1, %{})
      assert html =~ "Insert link"
    end

    test "renders close button" do
      html = render_component(&H.render_editor_link_dialog/1, %{})
      assert html =~ "data-link-close"
    end

    test "pre-fills initial_url when provided" do
      html = render_component(&H.render_editor_link_dialog/1, %{initial_url: "https://example.com"})
      assert html =~ "https://example.com"
    end

    test "renders submit button with phx-click when on_submit set" do
      html = render_component(&H.render_editor_link_dialog/1, %{on_submit: "link_submitted"})
      assert html =~ ~s(phx-click="link_submitted")
    end
  end

  describe "editor_code_block/1" do
    test "renders data-code-block attribute" do
      html = render_component(&H.render_editor_code_block/1, %{})
      assert html =~ "data-code-block"
    end

    test "renders language badge when language provided" do
      html = render_component(&H.render_editor_code_block/1, %{language: "elixir"})
      assert html =~ "elixir"
    end

    test "renders filename when filename provided" do
      html = render_component(&H.render_editor_code_block/1, %{filename: "app.ex"})
      assert html =~ "app.ex"
    end

    test "renders copy button when show_copy and copy_value provided" do
      html = render_component(&H.render_editor_code_block/1, %{show_copy: true, copy_value: "code here"})
      assert html =~ ~s(phx-hook="PhiaCopyButton")
      assert html =~ "Copy"
    end

    test "does not render copy button when copy_value not provided" do
      html = render_component(&H.render_editor_code_block/1, %{show_copy: true})
      refute html =~ ~s(phx-hook="PhiaCopyButton")
    end

    test "renders pre element with code" do
      html = render_component(&H.render_editor_code_block/1, %{})
      assert html =~ "<pre"
      assert html =~ "<code>"
    end

    test "renders traffic light dots" do
      html = render_component(&H.render_editor_code_block/1, %{})
      assert html =~ "bg-red-400"
      assert html =~ "bg-green-400"
    end

    test "renders line number column when show_line_numbers is true" do
      html = render_component(&H.render_editor_code_block/1, %{show_line_numbers: true})
      assert html =~ "select-none"
    end
  end

  describe "editor_character_count/1" do
    test "renders character count when mode is :characters" do
      html = render_component(&H.render_editor_character_count/1, %{count: 42, mode: :characters})
      assert html =~ "42"
      assert html =~ "characters"
    end

    test "renders word count estimate when mode is :words" do
      html = render_component(&H.render_editor_character_count/1, %{count: 50, mode: :words})
      assert html =~ "words"
    end

    test "renders both when mode is :both" do
      html = render_component(&H.render_editor_character_count/1, %{count: 50, mode: :both})
      assert html =~ "characters"
      assert html =~ "words"
    end

    test "renders max limit when max provided" do
      html = render_component(&H.render_editor_character_count/1, %{count: 10, max: 100})
      assert html =~ "/ 100"
    end

    test "renders progress bar when show_bar and max provided" do
      html = render_component(&H.render_editor_character_count/1, %{count: 50, max: 100, show_bar: true})
      assert html =~ "w-full"
      assert html =~ "bg-primary"
    end

    test "progress bar turns destructive at max" do
      html = render_component(&H.render_editor_character_count/1, %{count: 100, max: 100, show_bar: true})
      assert html =~ "bg-destructive"
    end

    test "does not render bar when show_bar is false" do
      html = render_component(&H.render_editor_character_count/1, %{count: 50, max: 100, show_bar: false})
      refute html =~ "bg-primary"
    end
  end

  describe "markdown_editor/1" do
    test "renders phx-hook PhiaMarkdownEditor" do
      html = render_component(&H.render_markdown_editor/1, %{})
      assert html =~ ~s(phx-hook="PhiaMarkdownEditor")
    end

    test "renders id attribute" do
      html = render_component(&H.render_markdown_editor/1, %{id: "md-editor"})
      assert html =~ ~s(id="md-editor")
    end

    test "renders Write tab" do
      html = render_component(&H.render_markdown_editor/1, %{})
      assert html =~ "Write"
    end

    test "renders Preview tab" do
      html = render_component(&H.render_markdown_editor/1, %{})
      assert html =~ "Preview"
    end

    test "renders label when provided" do
      html = render_component(&H.render_markdown_editor/1, %{label: "Article body"})
      assert html =~ "Article body"
    end

    test "does not render label when nil" do
      html = render_component(&H.render_markdown_editor/1, %{})
      refute html =~ "<label"
    end

    test "renders textarea with placeholder" do
      html = render_component(&H.render_markdown_editor/1, %{placeholder: "Type here..."})
      assert html =~ "Type here..."
    end

    test "renders min-height style" do
      html = render_component(&H.render_markdown_editor/1, %{min_height: "400px"})
      assert html =~ "min-height: 400px"
    end

    test "renders preview pane" do
      html = render_component(&H.render_markdown_editor/1, %{})
      assert html =~ "data-md-preview"
    end

    test "renders data-on-change" do
      html = render_component(&H.render_markdown_editor/1, %{on_change: "md_update"})
      assert html =~ ~s(data-on-change="md_update")
    end

    test "renders preview_html when provided" do
      html = render_component(&H.render_markdown_editor/1, %{preview_html: "<p>Hello</p>"})
      assert html =~ "<p>Hello</p>"
    end

    test "renders nothing-to-preview when preview_html is nil" do
      html = render_component(&H.render_markdown_editor/1, %{})
      assert html =~ "Nothing to preview"
    end
  end

  describe "rich_text_viewer/1" do
    test "renders prose class" do
      html = render_component(&H.render_rich_text_viewer/1, %{content: "<p>Hello</p>"})
      assert html =~ "prose"
    end

    test "renders raw HTML content" do
      html = render_component(&H.render_rich_text_viewer/1, %{content: "<p>Hello world</p>"})
      assert html =~ "<p>Hello world</p>"
    end

    test "prose-sm class for size :sm" do
      html = render_component(&H.render_rich_text_viewer/1, %{content: "", prose_size: :sm})
      assert html =~ "prose-sm"
    end

    test "prose-lg class for size :lg" do
      html = render_component(&H.render_rich_text_viewer/1, %{content: "", prose_size: :lg})
      assert html =~ "prose-lg"
    end

    test "no extra size class for size :base" do
      html = render_component(&H.render_rich_text_viewer/1, %{content: "", prose_size: :base})
      assert html =~ "prose"
      refute html =~ "prose-sm"
      refute html =~ "prose-lg"
    end

    test "applies additional class" do
      html = render_component(&H.render_rich_text_viewer/1, %{content: "", class: "my-viewer"})
      assert html =~ "my-viewer"
    end
  end

  describe "editor_find_replace/1" do
    test "renders phx-hook PhiaEditorFindReplace" do
      html = render_component(&H.render_editor_find_replace/1, %{})
      assert html =~ ~s(phx-hook="PhiaEditorFindReplace")
    end

    test "renders id attribute" do
      html = render_component(&H.render_editor_find_replace/1, %{id: "find-bar"})
      assert html =~ ~s(id="find-bar")
    end

    test "renders data-editor-id" do
      html = render_component(&H.render_editor_find_replace/1, %{editor_id: "my-ed"})
      assert html =~ ~s(data-editor-id="my-ed")
    end

    test "is hidden by default" do
      html = render_component(&H.render_editor_find_replace/1, %{})
      assert html =~ "hidden"
    end

    test "renders data-find-input" do
      html = render_component(&H.render_editor_find_replace/1, %{})
      assert html =~ "data-find-input"
    end

    test "renders data-replace-input" do
      html = render_component(&H.render_editor_find_replace/1, %{})
      assert html =~ "data-replace-input"
    end

    test "renders prev/next buttons" do
      html = render_component(&H.render_editor_find_replace/1, %{})
      assert html =~ "data-find-prev"
      assert html =~ "data-find-next"
    end

    test "renders replace buttons" do
      html = render_component(&H.render_editor_find_replace/1, %{})
      assert html =~ "data-replace-one"
      assert html =~ "data-replace-all"
    end

    test "renders close button" do
      html = render_component(&H.render_editor_find_replace/1, %{})
      assert html =~ "data-find-close"
    end
  end

  describe "editor_word_count/1" do
    test "renders word count for non-empty content" do
      html = render_component(&H.render_editor_word_count/1, %{content: "hello world foo"})
      assert html =~ "3"
      assert html =~ "words"
    end

    test "renders zero words for empty content" do
      html = render_component(&H.render_editor_word_count/1, %{content: ""})
      assert html =~ "0"
    end

    test "renders character count" do
      html = render_component(&H.render_editor_word_count/1, %{content: "hello"})
      assert html =~ "5"
      assert html =~ "characters"
    end

    test "renders reading time when show_reading_time is true" do
      html = render_component(&H.render_editor_word_count/1, %{content: "hello world", show_reading_time: true})
      assert html =~ "min read"
    end

    test "does not render reading time when show_reading_time is false" do
      html = render_component(&H.render_editor_word_count/1, %{content: "hello world", show_reading_time: false})
      refute html =~ "min read"
    end

    test "reading time is at least 1 min" do
      html = render_component(&H.render_editor_word_count/1, %{content: "hi", show_reading_time: true})
      assert html =~ "1"
      assert html =~ "min read"
    end
  end

  # ===========================================================================
  # Bonus — Advanced Editor (TipTap-inspired)
  # ===========================================================================

  describe "advanced_editor/1" do
    test "renders phx-hook PhiaAdvancedEditor" do
      html = render_component(&H.render_advanced_editor/1, %{})
      assert html =~ ~s(phx-hook="PhiaAdvancedEditor")
    end

    test "renders id attribute" do
      html = render_component(&H.render_advanced_editor/1, %{id: "my-editor"})
      assert html =~ ~s(id="my-editor")
    end

    test "renders editor content area" do
      html = render_component(&H.render_advanced_editor/1, %{})
      assert html =~ "data-phia-editor"
    end

    test "renders hidden input for form integration" do
      html = render_component(&H.render_advanced_editor/1, %{})
      assert html =~ ~s(type="hidden")
    end

    test "renders toolbar with bold action" do
      html = render_component(&H.render_advanced_editor/1, %{})
      assert html =~ ~s(data-action="bold")
    end

    test "renders toolbar with italic action" do
      html = render_component(&H.render_advanced_editor/1, %{})
      assert html =~ ~s(data-action="italic")
    end

    test "renders toolbar with underline action" do
      html = render_component(&H.render_advanced_editor/1, %{})
      assert html =~ ~s(data-action="underline")
    end

    test "renders toolbar with undo/redo" do
      html = render_component(&H.render_advanced_editor/1, %{})
      assert html =~ ~s(data-action="undo")
      assert html =~ ~s(data-action="redo")
    end

    test "renders block format dropdown" do
      html = render_component(&H.render_advanced_editor/1, %{})
      assert html =~ ~s(phx-hook="PhiaEditorDropdown")
    end

    test "renders bubble menu" do
      html = render_component(&H.render_advanced_editor/1, %{})
      assert html =~ ~s(phx-hook="PhiaBubbleMenu")
    end

    test "renders color picker" do
      html = render_component(&H.render_advanced_editor/1, %{})
      assert html =~ ~s(phx-hook="PhiaEditorColorPicker")
    end

    test "renders word count footer when show_word_count is true" do
      html = render_component(&H.render_advanced_editor/1, %{show_word_count: true})
      assert html =~ "words"
      assert html =~ "characters"
    end

    test "does not render word count when show_word_count is false" do
      html = render_component(&H.render_advanced_editor/1, %{show_word_count: false})
      refute html =~ "min read"
    end

    test "renders find replace bar when show_find_replace is true" do
      html = render_component(&H.render_advanced_editor/1, %{show_find_replace: true})
      assert html =~ ~s(phx-hook="PhiaEditorFindReplace")
    end

    test "renders placeholder on editor area" do
      html = render_component(&H.render_advanced_editor/1, %{placeholder: "Start writing..."})
      assert html =~ ~s(data-placeholder="Start writing...")
    end

    test "applies min-height style" do
      html = render_component(&H.render_advanced_editor/1, %{min_height: "500px"})
      assert html =~ "min-height: 500px"
    end

    test "renders link dialog" do
      html = render_component(&H.render_advanced_editor/1, %{})
      assert html =~ "data-link-dialog"
    end

    test "renders link action in bubble menu" do
      html = render_component(&H.render_advanced_editor/1, %{})
      assert html =~ ~s(data-action="link")
    end

    test "applies additional class" do
      html = render_component(&H.render_advanced_editor/1, %{class: "my-editor-class"})
      assert html =~ "my-editor-class"
    end
  end
end
