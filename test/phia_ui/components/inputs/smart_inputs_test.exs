defmodule PhiaUi.Components.SmartInputsTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.SmartInputs

    attr(:id, :string, default: "dn")
    attr(:value, :any, default: 0)
    attr(:min, :any, default: nil)
    attr(:max, :any, default: nil)
    attr(:step, :any, default: 1)
    attr(:unit, :string, default: nil)
    attr(:on_change, :string, default: nil)
    attr(:disabled, :boolean, default: false)

    def render_drag_number(assigns) do
      ~H"""
      <.drag_number
        id={@id}
        value={@value}
        min={@min}
        max={@max}
        step={@step}
        unit={@unit}
        on_change={@on_change}
        disabled={@disabled}
      />
      """
    end

    attr(:id, :string, default: "sui")
    attr(:name, :string, default: "suggest")
    attr(:value, :string, default: "")
    attr(:suggestion, :string, default: nil)
    attr(:on_accept, :string, default: nil)
    attr(:placeholder, :string, default: nil)
    attr(:disabled, :boolean, default: false)

    def render_suggestion_input(assigns) do
      ~H"""
      <.suggestion_input
        id={@id}
        name={@name}
        value={@value}
        suggestion={@suggestion}
        on_accept={@on_accept}
        placeholder={@placeholder}
        disabled={@disabled}
      />
      """
    end

    attr(:id, :string, default: "ep")
    attr(:on_pick, :string, default: nil)
    attr(:trigger_label, :string, default: "😊")
    attr(:placement, :atom, default: :bottom)

    def render_emoji_picker(assigns) do
      ~H"""
      <.emoji_picker
        id={@id}
        on_pick={@on_pick}
        trigger_label={@trigger_label}
        placement={@placement}
      />
      """
    end

    attr(:id, :string, default: "ksi")
    attr(:name, :string, default: "shortcut")
    attr(:value, :string, default: nil)
    attr(:placeholder, :string, default: "Click to record shortcut…")
    attr(:on_change, :string, default: nil)
    attr(:disabled, :boolean, default: false)

    def render_keyboard_shortcut_input(assigns) do
      ~H"""
      <.keyboard_shortcut_input
        id={@id}
        name={@name}
        value={@value}
        placeholder={@placeholder}
        on_change={@on_change}
        disabled={@disabled}
      />
      """
    end

    attr(:field, Phoenix.HTML.FormField)
    attr(:label, :string, default: nil)
    attr(:suggestion, :string, default: nil)

    def render_form_drag_number(assigns) do
      ~H"""
      <.form_drag_number field={@field} label={@label} />
      """
    end

    def render_form_suggestion_input(assigns) do
      ~H"""
      <.form_suggestion_input field={@field} label={@label} suggestion={@suggestion} />
      """
    end

    def render_form_keyboard_shortcut_input(assigns) do
      ~H"""
      <.form_keyboard_shortcut_input field={@field} label={@label} />
      """
    end
  end

  defp render_drag_number(attrs \\ %{}) do
    render_component(&H.render_drag_number/1, attrs)
  end

  defp render_suggestion_input(attrs \\ %{}) do
    render_component(&H.render_suggestion_input/1, attrs)
  end

  defp render_emoji_picker(attrs \\ %{}) do
    render_component(&H.render_emoji_picker/1, attrs)
  end

  defp render_keyboard_shortcut_input(attrs \\ %{}) do
    render_component(&H.render_keyboard_shortcut_input/1, attrs)
  end

  defp make_field(name \\ "field", value \\ "", errors \\ []) do
    form = Phoenix.HTML.FormData.to_form(%{name => value}, as: :test)
    field = form[String.to_atom(name)]
    %{field | errors: errors}
  end

  # ---------------------------------------------------------------------------
  # drag_number/1
  # ---------------------------------------------------------------------------

  describe "drag_number/1 — structure" do
    test "renders root with phx-hook=PhiaDragNumber" do
      html = render_drag_number(%{id: "dn1"})
      assert html =~ ~s(phx-hook="PhiaDragNumber")
    end

    test "renders role=spinbutton" do
      html = render_drag_number()
      assert html =~ ~s(role="spinbutton")
    end

    test "renders aria-valuenow with current value" do
      html = render_drag_number(%{value: 42})
      assert html =~ ~s(aria-valuenow="42")
    end

    test "renders data-drag-display span with value" do
      html = render_drag_number(%{value: 7})
      assert html =~ "data-drag-display"
      assert html =~ "7"
    end

    test "renders unit suffix after value" do
      html = render_drag_number(%{value: 16, unit: "px"})
      assert html =~ "16px"
    end

    test "renders hidden input for form submission" do
      html = render_drag_number()
      assert html =~ "data-drag-input"
    end

    test "disabled=true adds opacity-50 and cursor-not-allowed" do
      html = render_drag_number(%{disabled: true})
      assert html =~ "opacity-50"
      assert html =~ "cursor-not-allowed"
    end

    test "non-disabled renders cursor-ew-resize" do
      html = render_drag_number(%{disabled: false})
      assert html =~ "cursor-ew-resize"
    end

    test "data-min and data-max attributes are set" do
      html = render_drag_number(%{min: 0, max: 100})
      assert html =~ ~s(data-min="0")
      assert html =~ ~s(data-max="100")
    end

    test "data-step attribute is set" do
      html = render_drag_number(%{step: 5})
      assert html =~ ~s(data-step="5")
    end
  end

  describe "form_drag_number/1" do
    test "renders label when provided" do
      html = render_component(&H.render_form_drag_number/1, %{
        field: make_field("size", "14"),
        label: "Font size"
      })
      assert html =~ "Font size"
    end

    test "renders phx-hook on drag number element" do
      html = render_component(&H.render_form_drag_number/1, %{
        field: make_field("size", "10"),
        label: nil
      })
      assert html =~ ~s(phx-hook="PhiaDragNumber")
    end

    test "renders error when field has errors" do
      html = render_component(&H.render_form_drag_number/1, %{
        field: make_field("size", "", [{"is required", []}]),
        label: nil
      })
      assert html =~ "is required"
    end
  end

  # ---------------------------------------------------------------------------
  # suggestion_input/1
  # ---------------------------------------------------------------------------

  describe "suggestion_input/1 — structure" do
    test "renders phx-hook=PhiaSuggestionInput" do
      html = render_suggestion_input(%{id: "sui1"})
      assert html =~ ~s(phx-hook="PhiaSuggestionInput")
    end

    test "renders text input with data-suggestion-input" do
      html = render_suggestion_input()
      assert html =~ "data-suggestion-input"
      assert html =~ ~s(type="text")
    end

    test "renders ghost overlay with data-suggestion-ghost" do
      html = render_suggestion_input()
      assert html =~ "data-suggestion-ghost"
    end

    test "current value appears in ghost spacer" do
      html = render_suggestion_input(%{value: "hel"})
      assert html =~ "hel"
    end

    test "suggestion tail shown when suggestion starts with value" do
      html = render_suggestion_input(%{value: "hel", suggestion: "hello"})
      assert html =~ "lo"
    end

    test "Tab hint shown when suggestion is present" do
      html = render_suggestion_input(%{suggestion: "hello"})
      assert html =~ "Tab"
    end

    test "no Tab hint when no suggestion" do
      html = render_suggestion_input(%{suggestion: nil})
      refute html =~ "Tab"
    end

    test "placeholder is set on the input" do
      html = render_suggestion_input(%{placeholder: "Type here…"})
      assert html =~ "Type here…"
    end

    test "disabled input has disabled attribute" do
      html = render_suggestion_input(%{disabled: true})
      assert html =~ "disabled"
    end

    test "autocomplete=off on input" do
      html = render_suggestion_input()
      assert html =~ ~s(autocomplete="off")
    end
  end

  describe "form_suggestion_input/1" do
    test "renders label" do
      html = render_component(&H.render_form_suggestion_input/1, %{
        field: make_field("q", ""),
        label: "Search",
        suggestion: nil
      })
      assert html =~ "Search"
    end
  end

  # ---------------------------------------------------------------------------
  # emoji_picker/1
  # ---------------------------------------------------------------------------

  describe "emoji_picker/1 — structure" do
    test "renders phx-hook=PhiaEmojiPicker" do
      html = render_emoji_picker(%{id: "ep1"})
      assert html =~ ~s(phx-hook="PhiaEmojiPicker")
    end

    test "renders trigger button" do
      html = render_emoji_picker()
      assert html =~ "data-emoji-trigger"
    end

    test "renders panel (initially hidden)" do
      html = render_emoji_picker()
      assert html =~ "data-emoji-panel"
      assert html =~ "hidden"
    end

    test "renders search input within panel" do
      html = render_emoji_picker()
      assert html =~ "data-emoji-search"
    end

    test "renders trigger with default emoji label" do
      html = render_emoji_picker(%{trigger_label: "🎉"})
      assert html =~ "🎉"
    end

    test "aria-haspopup=dialog on trigger" do
      html = render_emoji_picker()
      assert html =~ ~s(aria-haspopup="dialog")
    end

    test "data-placement attribute is set" do
      html = render_emoji_picker(%{placement: :top})
      assert html =~ ~s(data-placement="top")
    end

    test "data-on-pick attribute is set" do
      html = render_emoji_picker(%{on_pick: "emoji_picked"})
      assert html =~ ~s(data-on-pick="emoji_picked")
    end
  end

  # ---------------------------------------------------------------------------
  # keyboard_shortcut_input/1
  # ---------------------------------------------------------------------------

  describe "keyboard_shortcut_input/1 — structure" do
    test "renders phx-hook=PhiaKeyShortcut" do
      html = render_keyboard_shortcut_input(%{id: "ks1"})
      assert html =~ ~s(phx-hook="PhiaKeyShortcut")
    end

    test "renders placeholder when no value set" do
      html = render_keyboard_shortcut_input(%{value: nil})
      assert html =~ "data-shortcut-placeholder"
    end

    test "renders custom placeholder text" do
      html = render_keyboard_shortcut_input(%{value: nil, placeholder: "Press keys…"})
      assert html =~ "Press keys…"
    end

    test "renders kbd keys when value is set" do
      html = render_keyboard_shortcut_input(%{value: "Ctrl+K"})
      assert html =~ "<kbd"
      assert html =~ "Ctrl"
      assert html =~ "K"
    end

    test "multi-key shortcut renders multiple kbd elements" do
      html = render_keyboard_shortcut_input(%{value: "Ctrl+Shift+K"})
      count = html |> String.split("<kbd") |> length() |> Kernel.-(1)
      assert count == 3
    end

    test "renders clear button when value is set and not disabled" do
      html = render_keyboard_shortcut_input(%{value: "Ctrl+K", disabled: false})
      assert html =~ "data-shortcut-clear"
    end

    test "no clear button when value is nil" do
      html = render_keyboard_shortcut_input(%{value: nil})
      refute html =~ "data-shortcut-clear"
    end

    test "renders hidden input for form submission" do
      html = render_keyboard_shortcut_input()
      assert html =~ "data-shortcut-input"
    end

    test "disabled=true adds opacity-50" do
      html = render_keyboard_shortcut_input(%{disabled: true})
      assert html =~ "opacity-50"
    end

    test "data-on-change attribute set when on_change given" do
      html = render_keyboard_shortcut_input(%{on_change: "shortcut_changed"})
      assert html =~ ~s(data-on-change="shortcut_changed")
    end
  end

  describe "form_keyboard_shortcut_input/1" do
    test "renders label" do
      html = render_component(&H.render_form_keyboard_shortcut_input/1, %{
        field: make_field("shortcut", ""),
        label: "Save shortcut"
      })
      assert html =~ "Save shortcut"
    end

    test "renders errors from field" do
      html = render_component(&H.render_form_keyboard_shortcut_input/1, %{
        field: make_field("shortcut", "", [{"is required", []}]),
        label: nil
      })
      assert html =~ "is required"
    end
  end
end
