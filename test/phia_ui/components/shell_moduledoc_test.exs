defmodule PhiaUi.Components.ShellModuledocTest do
  use ExUnit.Case, async: true

  # Fetch the compiled @moduledoc string from the module.
  @moduledoc_text (case Code.fetch_docs(PhiaUi.Components.Shell) do
                     {:docs_v1, _, _, _, %{"en" => text}, _, _} -> text
                     _ -> ""
                   end)

  describe "@moduledoc exists" do
    test "module has a non-empty @moduledoc" do
      refute @moduledoc_text == "", "PhiaUi.Components.Shell must have a @moduledoc"
    end
  end

  describe "@moduledoc sub-components section" do
    test "documents shell/1" do
      assert @moduledoc_text =~ "shell/1"
    end

    test "documents sidebar/1" do
      assert @moduledoc_text =~ "sidebar/1"
    end

    test "documents sidebar_item/1" do
      assert @moduledoc_text =~ "sidebar_item/1"
    end

    test "documents mobile_sidebar_toggle/1" do
      assert @moduledoc_text =~ "mobile_sidebar_toggle/1"
    end

    test "documents topbar/1" do
      assert @moduledoc_text =~ "topbar/1"
    end
  end

  describe "@moduledoc example — LiveView structure" do
    test "example defines a LiveView module" do
      assert @moduledoc_text =~ "live_view"
    end

    test "example has def render" do
      assert @moduledoc_text =~ "def render"
    end

    test "example has a mount or handle_params to set live_action" do
      assert @moduledoc_text =~ "handle_params" or @moduledoc_text =~ "mount",
             "Example must show how @live_action or assigns are set"
    end
  end

  describe "@moduledoc example — shell named slots" do
    test "example uses :topbar named slot" do
      assert @moduledoc_text =~ "<:topbar>"
    end

    test "example uses :sidebar named slot" do
      assert @moduledoc_text =~ "<:sidebar>"
    end

    test "example has main content area inside shell" do
      assert @moduledoc_text =~ "<main"
    end
  end

  describe "@moduledoc example — sidebar sub-components" do
    test "example uses sidebar/1 inside :sidebar slot" do
      assert @moduledoc_text =~ "<.sidebar>"
    end

    test "example uses :brand slot in sidebar" do
      assert @moduledoc_text =~ "<:brand>"
    end

    test "example uses :nav_items slot in sidebar" do
      assert @moduledoc_text =~ "<:nav_items>"
    end

    test "example uses :footer_items slot in sidebar" do
      assert @moduledoc_text =~ "<:footer_items>"
    end

    test "example uses sidebar_item with href" do
      assert @moduledoc_text =~ "href="
    end

    test "example uses sidebar_item with active attr" do
      assert @moduledoc_text =~ "active="
    end

    test "example uses live_action for active state detection" do
      assert @moduledoc_text =~ "live_action"
    end
  end

  describe "@moduledoc example — mobile toggle" do
    test "example uses mobile_sidebar_toggle inside :topbar" do
      assert @moduledoc_text =~ "mobile_sidebar_toggle"
    end
  end
end
