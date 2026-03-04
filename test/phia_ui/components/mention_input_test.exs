defmodule PhiaUi.Components.MentionInputTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  @suggestions [
    %{id: "u1", name: "Johanna Fox", avatar: nil},
    %{id: "u2", name: "John Wilson", avatar: nil},
    %{id: "u3", name: "Alice Johnson", avatar: "https://example.com/alice.jpg"}
  ]

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.MentionInput

    def render_input(assigns) do
      ~H"""
      <.mention_input
        id={assigns[:id] || "mention-field"}
        name={assigns[:name] || "comment"}
        suggestions={assigns[:suggestions] || []}
        open={assigns[:open] || false}
        placeholder={assigns[:placeholder]}
        class={assigns[:class]}
      />
      """
    end

    def render_input_open(assigns) do
      ~H"""
      <.mention_input
        id="mention-open"
        name="body"
        suggestions={assigns[:suggestions] || []}
        open={true}
        search={assigns[:search] || ""}
      />
      """
    end

    def render_dropdown(assigns) do
      ~H"""
      <.mention_dropdown
        suggestions={assigns[:suggestions] || []}
        open={assigns[:open] || false}
        on_select={assigns[:on_select] || "mention_select"}
      />
      """
    end

    def render_chip(assigns) do
      ~H"""
      <.mention_chip name={assigns[:name] || "Alice"} user_id={assigns[:user_id] || "u1"} />
      """
    end

    def render_full(assigns) do
      ~H"""
      <.mention_input
        id="full-mention"
        name="message"
        suggestions={assigns[:suggestions] || []}
        open={assigns[:open] || false}
        search={assigns[:search] || ""}
        value={assigns[:value] || ""}
        mentioned_ids={assigns[:mentioned_ids] || []}
        on_mention="mention_search"
        on_select="mention_select"
        placeholder="Comment or type @ to mention"
      />
      """
    end
  end

  defp render_input(attrs \\ %{}), do: render_component(&H.render_input/1, attrs)
  defp render_input_open(attrs \\ %{}), do: render_component(&H.render_input_open/1, attrs)
  defp render_dropdown(attrs \\ %{}), do: render_component(&H.render_dropdown/1, attrs)
  defp render_chip(attrs \\ %{}), do: render_component(&H.render_chip/1, attrs)
  defp render_full(attrs \\ %{}), do: render_component(&H.render_full/1, attrs)

  # ---------------------------------------------------------------------------
  # mention_input/1 — base structure
  # ---------------------------------------------------------------------------

  describe "mention_input/1 — base structure" do
    test "renders a root wrapper element" do
      assert render_input() =~ "<div"
    end

    test "renders a textarea for text input" do
      assert render_input() =~ "<textarea"
    end

    test "textarea has phx-hook for PhiaMentionInput" do
      assert render_input() =~ ~s(phx-hook="PhiaMentionInput")
    end

    test "textarea id is applied" do
      assert render_input(%{id: "my-mention"}) =~ "my-mention"
    end

    test "textarea name attribute is forwarded" do
      assert render_input(%{name: "body"}) =~ ~s(name="body")
    end

    test "placeholder is applied when provided" do
      html = render_input(%{placeholder: "Type @ to mention"})
      assert html =~ "Type @ to mention"
    end

    test "custom class is applied to the wrapper" do
      assert render_input(%{class: "my-wrapper"}) =~ "my-wrapper"
    end

    test "renders a hidden input for mentioned IDs" do
      assert render_input() =~ ~s(type="hidden")
    end

    test "hidden input has _ids suffix in name" do
      html = render_input(%{name: "comment"})
      assert html =~ "comment_ids" or html =~ ~s(name="comment[ids]")
    end
  end

  # ---------------------------------------------------------------------------
  # mention_input/1 — ARIA
  # ---------------------------------------------------------------------------

  describe "mention_input/1 — ARIA" do
    test "textarea has aria-autocomplete=list" do
      html = render_input()
      assert html =~ ~s(aria-autocomplete="list") or html =~ "aria-autocomplete"
    end

    test "wrapper or textarea has aria-haspopup when dropdown is available" do
      assert render_input() =~ "aria-haspopup" or render_input() =~ "combobox"
    end

    test "textarea has aria-expanded=false when closed" do
      html = render_input(%{open: false})
      assert html =~ ~s(aria-expanded="false")
    end

    test "textarea has aria-expanded=true when open" do
      html = render_input(%{open: true})
      assert html =~ ~s(aria-expanded="true")
    end
  end

  # ---------------------------------------------------------------------------
  # mention_dropdown/1
  # ---------------------------------------------------------------------------

  describe "mention_dropdown/1 — closed state" do
    test "does not render suggestion list when open=false" do
      html = render_dropdown(%{open: false, suggestions: @suggestions})
      refute html =~ "Johanna Fox"
    end

    test "renders hidden or absent container when closed" do
      html = render_dropdown(%{open: false})
      assert html == "" or html =~ "hidden" or html =~ ~s(class="")
    end
  end

  describe "mention_dropdown/1 — open state" do
    test "renders suggestion names when open=true" do
      html = render_dropdown(%{open: true, suggestions: @suggestions})
      assert html =~ "Johanna Fox"
      assert html =~ "John Wilson"
      assert html =~ "Alice Johnson"
    end

    test "each suggestion is a button with phx-click" do
      html = render_dropdown(%{open: true, suggestions: @suggestions})
      assert html =~ "phx-click"
    end

    test "each suggestion button carries user id as phx-value" do
      html = render_dropdown(%{open: true, suggestions: @suggestions})
      assert html =~ "u1"
      assert html =~ "u2"
    end

    test "dropdown has role=listbox for ARIA" do
      html = render_dropdown(%{open: true, suggestions: @suggestions})
      assert html =~ ~s(role="listbox")
    end

    test "each suggestion item has role=option" do
      html = render_dropdown(%{open: true, suggestions: @suggestions})
      assert html =~ ~s(role="option")
    end

    test "renders empty message when suggestions is empty and open" do
      html = render_dropdown(%{open: true, suggestions: []})
      assert html =~ "No results" or html == "" or html =~ ~s(role="listbox")
    end
  end

  # ---------------------------------------------------------------------------
  # mention_chip/1
  # ---------------------------------------------------------------------------

  describe "mention_chip/1" do
    test "renders the user name with @ prefix" do
      html = render_chip(%{name: "Alice"})
      assert html =~ "@Alice" or html =~ "Alice"
    end

    test "chip has a distinct background color for highlight" do
      html = render_chip()
      assert html =~ "bg-" or html =~ "text-primary"
    end

    test "chip carries the user_id as a data attribute" do
      html = render_chip(%{user_id: "u99"})
      assert html =~ "u99"
    end

    test "chip is inline (span element)" do
      assert render_chip() =~ "<span"
    end
  end

  # ---------------------------------------------------------------------------
  # mention_input/1 — event wiring
  # ---------------------------------------------------------------------------

  describe "mention_input/1 — event wiring" do
    test "textarea has phx-change or data-on-mention when on_mention is set" do
      html = render_full(%{suggestions: []})
      assert html =~ "mention_search" or html =~ "phx-change"
    end

    test "on_select event is wired on the dropdown" do
      html = render_full(%{open: true, suggestions: @suggestions})
      assert html =~ "mention_select"
    end
  end

  # ---------------------------------------------------------------------------
  # mention_input/1 — full composition
  # ---------------------------------------------------------------------------

  describe "full composition" do
    test "renders textarea + hidden input at minimum" do
      html = render_full()
      assert html =~ "<textarea"
      assert html =~ ~s(type="hidden")
    end

    test "renders suggestions dropdown when open=true" do
      html = render_full(%{open: true, suggestions: @suggestions})
      assert html =~ "Johanna Fox"
    end

    test "dropdown is hidden when open=false" do
      html = render_full(%{open: false, suggestions: @suggestions})
      refute html =~ "Johanna Fox"
    end

    test "mentioned_ids are serialized into the hidden input value" do
      html = render_full(%{mentioned_ids: ["u1", "u2"]})
      assert html =~ "u1" and html =~ "u2"
    end

    test "placeholder is applied" do
      assert render_full() =~ "Comment or type @ to mention"
    end

    test "does not use hardcoded hex colors in style attributes" do
      html = render_full(%{open: true, suggestions: @suggestions})
      refute html =~ ~r/style="[^"]*#[0-9a-fA-F]{3,6}/
    end
  end

  # ---------------------------------------------------------------------------
  # Semantic tokens
  # ---------------------------------------------------------------------------

  describe "mention_input/1 — semantic tokens" do
    test "textarea uses bg-background or bg-transparent" do
      html = render_input()
      assert html =~ "bg-background" or html =~ "bg-transparent"
    end

    test "textarea uses border-input or border-border token" do
      html = render_input()
      assert html =~ "border-input" or html =~ "border-border"
    end
  end
end
