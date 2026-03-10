defmodule PhiaUiDesign.Web.ComponentRendererTest do
  use ExUnit.Case, async: true

  alias PhiaUiDesign.Web.ComponentRenderer

  # ---------------------------------------------------------------------------
  # render_to_html/4 — nil module
  # ---------------------------------------------------------------------------

  describe "render_to_html/4 with nil module" do
    test "returns {:error, \"no module\"}" do
      assert {:error, "no module"} =
               ComponentRenderer.render_to_html(nil, :button, %{}, %{})
    end

    test "returns error regardless of function name" do
      assert {:error, "no module"} =
               ComponentRenderer.render_to_html(nil, :anything, %{variant: :primary}, %{})
    end

    test "returns error regardless of attrs and slots" do
      assert {:error, "no module"} =
               ComponentRenderer.render_to_html(nil, :button, %{size: :lg}, %{inner_block: "Hi"})
    end
  end

  # ---------------------------------------------------------------------------
  # render_to_html/4 — non-existent module
  # ---------------------------------------------------------------------------

  describe "render_to_html/4 with non-existent function" do
    test "returns error when function is not exported" do
      assert {:error, reason} =
               ComponentRenderer.render_to_html(
                 PhiaUi.Components.Button,
                 :nonexistent_function,
                 %{},
                 %{}
               )

      assert reason =~ "not exported"
    end
  end

  # ---------------------------------------------------------------------------
  # render_to_html/4 — real button component
  # ---------------------------------------------------------------------------

  describe "render_to_html/4 with PhiaUi.Components.Button.button/1" do
    test "renders a button with default attrs" do
      assert {:ok, html} =
               ComponentRenderer.render_to_html(
                 PhiaUi.Components.Button,
                 :button,
                 %{},
                 %{inner_block: "Click me"}
               )

      assert html =~ "Click me"
      assert html =~ "<button"
    end

    test "renders a button with variant attr (atom)" do
      assert {:ok, html} =
               ComponentRenderer.render_to_html(
                 PhiaUi.Components.Button,
                 :button,
                 %{variant: :destructive},
                 %{inner_block: "Delete"}
               )

      assert html =~ "Delete"
      assert html =~ "destructive"
    end

    test "renders a button with size attr (atom)" do
      assert {:ok, html} =
               ComponentRenderer.render_to_html(
                 PhiaUi.Components.Button,
                 :button,
                 %{size: :lg},
                 %{inner_block: "Large"}
               )

      assert html =~ "Large"
    end

    test "returns error when inner_block slot is missing (required slot)" do
      # button/1 has `slot :inner_block, required: true`, so omitting it
      # causes a KeyError at render time which is caught and returned as error
      result =
        ComponentRenderer.render_to_html(
          PhiaUi.Components.Button,
          :button,
          %{},
          %{}
        )

      assert {:error, _reason} = result
    end
  end

  # ---------------------------------------------------------------------------
  # render_to_html/4 — real badge component
  # ---------------------------------------------------------------------------

  describe "render_to_html/4 with PhiaUi.Components.Badge.badge/1" do
    test "renders a badge with text content" do
      assert {:ok, html} =
               ComponentRenderer.render_to_html(
                 PhiaUi.Components.Badge,
                 :badge,
                 %{},
                 %{inner_block: "New"}
               )

      assert html =~ "New"
    end

    test "renders a badge with variant (atom)" do
      assert {:ok, html} =
               ComponentRenderer.render_to_html(
                 PhiaUi.Components.Badge,
                 :badge,
                 %{variant: :outline},
                 %{inner_block: "Status"}
               )

      assert html =~ "Status"
    end
  end

  # ---------------------------------------------------------------------------
  # render_to_html/4 — slot handling
  # ---------------------------------------------------------------------------

  describe "render_to_html/4 slot handling" do
    test "passes inner_block slot as proper Phoenix slot struct" do
      assert {:ok, html} =
               ComponentRenderer.render_to_html(
                 PhiaUi.Components.Button,
                 :button,
                 %{},
                 %{inner_block: "Slot text"}
               )

      assert html =~ "Slot text"
    end

    test "empty string inner_block is not wrapped (component may error if required)" do
      # When inner_block is "", the renderer does not build a slot struct.
      # For button (which requires inner_block), this produces an error.
      result =
        ComponentRenderer.render_to_html(
          PhiaUi.Components.Button,
          :button,
          %{},
          %{inner_block: ""}
        )

      assert {:error, _} = result
    end

    test "non-binary inner_block values are ignored (component may error if required)" do
      # When inner_block is a non-binary value (like 42), the renderer does
      # not wrap it as a slot. For button (required slot), this returns error.
      result =
        ComponentRenderer.render_to_html(
          PhiaUi.Components.Button,
          :button,
          %{},
          %{inner_block: 42}
        )

      assert {:error, _} = result
    end

    test "nil slots map is handled (component may error if slot is required)" do
      # nil slots means no inner_block is built. Button requires inner_block.
      result =
        ComponentRenderer.render_to_html(
          PhiaUi.Components.Button,
          :button,
          %{},
          nil
        )

      assert {:error, _} = result
    end

    test "handles string-keyed inner_block in slots" do
      assert {:ok, html} =
               ComponentRenderer.render_to_html(
                 PhiaUi.Components.Button,
                 :button,
                 %{},
                 %{"inner_block" => "String key"}
               )

      assert html =~ "String key"
    end

    test "badge renders successfully with inner_block slot text" do
      assert {:ok, html} =
               ComponentRenderer.render_to_html(
                 PhiaUi.Components.Badge,
                 :badge,
                 %{},
                 %{inner_block: "Tag"}
               )

      assert html =~ "Tag"
    end
  end

  # ---------------------------------------------------------------------------
  # render_to_html/4 — error fallback
  # ---------------------------------------------------------------------------

  describe "render_to_html/4 error fallback" do
    test "returns error for a module that does not exist" do
      assert {:error, _reason} =
               ComponentRenderer.render_to_html(
                 :nonexistent_module_abc123,
                 :button,
                 %{},
                 %{}
               )
    end

    test "returns error for non-component module" do
      assert {:error, reason} =
               ComponentRenderer.render_to_html(
                 String,
                 :upcase,
                 %{},
                 %{}
               )

      assert is_binary(reason)
    end

    test "error message is a readable string" do
      {:error, reason} =
        ComponentRenderer.render_to_html(
          PhiaUi.Components.Button,
          :no_such_component,
          %{},
          %{}
        )

      assert is_binary(reason)
      assert String.length(reason) > 0
    end
  end

  # ---------------------------------------------------------------------------
  # slot_text/1 helper component
  # ---------------------------------------------------------------------------

  describe "slot_text/1" do
    test "renders text content from assigns" do
      rendered =
        ComponentRenderer.slot_text(%{__changed__: nil, text: "Hello world"})
        |> Phoenix.HTML.Safe.to_iodata()
        |> IO.iodata_to_binary()

      assert rendered =~ "Hello world"
    end

    test "renders empty string when text is empty" do
      rendered =
        ComponentRenderer.slot_text(%{__changed__: nil, text: ""})
        |> Phoenix.HTML.Safe.to_iodata()
        |> IO.iodata_to_binary()

      assert rendered == ""
    end
  end

  # ---------------------------------------------------------------------------
  # render_to_html/4 — attr defaults
  # ---------------------------------------------------------------------------

  describe "render_to_html/4 attribute defaults" do
    test "applies component attr defaults when attrs are missing" do
      # button has defaults for variant, size, etc. — should not crash
      assert {:ok, html} =
               ComponentRenderer.render_to_html(
                 PhiaUi.Components.Button,
                 :button,
                 %{},
                 %{inner_block: "With defaults"}
               )

      assert html =~ "With defaults"
    end

    test "user-provided attrs override defaults" do
      assert {:ok, html} =
               ComponentRenderer.render_to_html(
                 PhiaUi.Components.Button,
                 :button,
                 %{variant: :outline},
                 %{inner_block: "Outlined"}
               )

      assert html =~ "Outlined"
    end
  end
end
