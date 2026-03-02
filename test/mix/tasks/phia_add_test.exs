defmodule Mix.Tasks.Phia.AddTest do
  use ExUnit.Case, async: false

  alias Mix.Tasks.Phia.Add

  @tmp_dir System.tmp_dir!()

  # ---------------------------------------------------------------------------
  # app_web_name/0
  # ---------------------------------------------------------------------------

  describe "app_web_name/0" do
    test "derives web module name from current mix project app" do
      # Running inside phia_ui, so app is :phia_ui → "PhiaUiWeb"
      assert Add.app_web_name() == "PhiaUiWeb"
    end

    test "returns a string" do
      assert is_binary(Add.app_web_name())
    end

    test "ends with Web suffix" do
      assert String.ends_with?(Add.app_web_name(), "Web")
    end
  end

  # ---------------------------------------------------------------------------
  # component_path/2
  # ---------------------------------------------------------------------------

  describe "component_path/2" do
    test "builds path rooted under lib/{app_web}/components/ui/" do
      path = Add.component_path("/project", "button")
      assert path =~ "lib/phia_ui_web/components/ui/button.ex"
    end

    test "path includes the ui/ subdirectory" do
      path = Add.component_path("/project", "button")
      assert path =~ "/components/ui/"
    end

    test "uses snake_case for the app_web directory" do
      path = Add.component_path("/project", "button")
      assert path =~ "phia_ui_web"
    end

    test "uses the component name as the file name" do
      path = Add.component_path("/project", "card")
      assert String.ends_with?(path, "card.ex")
    end

    test "table component path ends with table.ex" do
      path = Add.component_path("/project", "table")
      assert String.ends_with?(path, "table.ex")
    end
  end

  # ---------------------------------------------------------------------------
  # eject_component/2
  # ---------------------------------------------------------------------------

  describe "eject_component/2" do
    test "ejected component output has proper HEEx markers (EEx.eval_file not String.replace)" do
      # <%%= render_slot(@inner_block) %> in template must be rendered as
      # <%= render_slot(@inner_block) %> — no raw escape sequences in output.
      dir = Path.join(@tmp_dir, "phia_add_#{:erlang.unique_integer([:positive])}")
      prev_shell = Mix.shell()
      Mix.shell(Mix.Shell.Process)

      Add.eject_component("button", dir)
      assert_receive {:mix_shell, :info, _}

      Mix.shell(prev_shell)

      content = File.read!(Add.component_path(dir, "button"))
      refute content =~ "<%%= "
      assert content =~ "<%= render_slot(@inner_block) %>"

      File.rm_rf!(dir)
    end

    test "ejects button component to target directory" do
      dir = Path.join(@tmp_dir, "phia_add_#{:erlang.unique_integer([:positive])}")
      File.mkdir_p!(dir)

      assert :ok = Add.eject_component("button", dir)

      target = Add.component_path(dir, "button")
      assert File.exists?(target)

      File.rm_rf!(dir)
    end

    test "ejected button file contains PhiaUiWeb module namespace" do
      dir = Path.join(@tmp_dir, "phia_add_#{:erlang.unique_integer([:positive])}")
      File.mkdir_p!(dir)

      Add.eject_component("button", dir)

      target = Add.component_path(dir, "button")
      content = File.read!(target)
      assert content =~ "PhiaUiWeb"

      File.rm_rf!(dir)
    end

    test "ejected button file is valid Elixir (contains defmodule)" do
      dir = Path.join(@tmp_dir, "phia_add_#{:erlang.unique_integer([:positive])}")
      File.mkdir_p!(dir)

      Add.eject_component("button", dir)

      target = Add.component_path(dir, "button")
      content = File.read!(target)
      assert content =~ "defmodule PhiaUiWeb.Components.UI.Button do"

      File.rm_rf!(dir)
    end

    test "ejected module uses .UI. namespace" do
      dir = Path.join(@tmp_dir, "phia_add_#{:erlang.unique_integer([:positive])}")
      File.mkdir_p!(dir)

      Add.eject_component("badge", dir)

      target = Add.component_path(dir, "badge")
      content = File.read!(target)
      assert content =~ ".Components.UI."

      File.rm_rf!(dir)
    end

    test "ejects card component" do
      dir = Path.join(@tmp_dir, "phia_add_#{:erlang.unique_integer([:positive])}")
      File.mkdir_p!(dir)

      assert :ok = Add.eject_component("card", dir)
      target = Add.component_path(dir, "card")
      assert File.exists?(target)
      content = File.read!(target)
      assert content =~ "PhiaUiWeb.Components.UI.Card"

      File.rm_rf!(dir)
    end

    test "ejects badge component" do
      dir = Path.join(@tmp_dir, "phia_add_#{:erlang.unique_integer([:positive])}")
      File.mkdir_p!(dir)

      assert :ok = Add.eject_component("badge", dir)
      target = Add.component_path(dir, "badge")
      assert File.exists?(target)

      File.rm_rf!(dir)
    end

    test "ejects table component" do
      dir = Path.join(@tmp_dir, "phia_add_#{:erlang.unique_integer([:positive])}")
      File.mkdir_p!(dir)

      assert :ok = Add.eject_component("table", dir)
      target = Add.component_path(dir, "table")
      assert File.exists?(target)

      File.rm_rf!(dir)
    end

    test "returns error tuple for unknown component" do
      dir = Path.join(@tmp_dir, "phia_add_#{:erlang.unique_integer([:positive])}")
      File.mkdir_p!(dir)

      result = Add.eject_component("nonexistent_component", dir)
      assert {:error, _reason} = result

      File.rm_rf!(dir)
    end

    test "error message mentions the component name" do
      dir = Path.join(@tmp_dir, "phia_add_#{:erlang.unique_integer([:positive])}")
      File.mkdir_p!(dir)

      {:error, reason} = Add.eject_component("nonexistent_component", dir)
      assert reason =~ "nonexistent_component"

      File.rm_rf!(dir)
    end

    test "creates parent directories if they do not exist" do
      dir = Path.join(@tmp_dir, "phia_add_#{:erlang.unique_integer([:positive])}")
      # Do NOT pre-create dir, let eject_component handle it

      Add.eject_component("button", dir)

      target = Add.component_path(dir, "button")
      assert File.exists?(target)

      File.rm_rf!(dir)
    end

    test "idempotent: does not raise on repeated runs (file already exists)" do
      dir = Path.join(@tmp_dir, "phia_add_#{:erlang.unique_integer([:positive])}")
      File.mkdir_p!(dir)

      prev_shell = Mix.shell()
      Mix.shell(Mix.Shell.Process)

      # First run — creates the file
      Add.eject_component("button", dir)
      # Drain Mix.Generator info messages
      assert_receive {:mix_shell, :info, _}

      # Second run — file exists, answer "no" to overwrite prompt
      send(self(), {:mix_shell_input, :yes?, false})
      Add.eject_component("button", dir)
      assert_receive {:mix_shell, :info, _}

      Mix.shell(prev_shell)
      File.rm_rf!(dir)
    end

    test "uses Mix.Generator conflict handling when component file already exists" do
      dir = Path.join(@tmp_dir, "phia_add_#{:erlang.unique_integer([:positive])}")
      target = Add.component_path(dir, "button")
      File.mkdir_p!(Path.dirname(target))
      File.write!(target, "# sentinel content")

      prev_shell = Mix.shell()
      Mix.shell(Mix.Shell.Process)

      # Answer "no" to overwrite prompt
      send(self(), {:mix_shell_input, :yes?, false})
      Add.eject_component("button", dir)

      # Mix.Generator must have logged "* create ..."
      assert_receive {:mix_shell, :info, _}

      # Original content preserved
      assert File.read!(target) == "# sentinel content"

      Mix.shell(prev_shell)
      File.rm_rf!(dir)
    end
  end

  # ---------------------------------------------------------------------------
  # eject_class_merger/1
  # ---------------------------------------------------------------------------

  describe "eject_class_merger/1" do
    test "creates class_merger.ex under lib/{app_web}/" do
      dir = Path.join(@tmp_dir, "phia_cm_#{:erlang.unique_integer([:positive])}")
      File.mkdir_p!(dir)

      Add.eject_class_merger(dir)

      app_web_dir = Add.app_web_name() |> Macro.underscore()
      path = Path.join([dir, "lib", app_web_dir, "class_merger.ex"])
      assert File.exists?(path)

      File.rm_rf!(dir)
    end

    test "creates class_merger/cache.ex" do
      dir = Path.join(@tmp_dir, "phia_cm_#{:erlang.unique_integer([:positive])}")
      File.mkdir_p!(dir)

      Add.eject_class_merger(dir)

      app_web_dir = Add.app_web_name() |> Macro.underscore()
      path = Path.join([dir, "lib", app_web_dir, "class_merger", "cache.ex"])
      assert File.exists?(path)

      File.rm_rf!(dir)
    end

    test "creates class_merger/groups.ex" do
      dir = Path.join(@tmp_dir, "phia_cm_#{:erlang.unique_integer([:positive])}")
      File.mkdir_p!(dir)

      Add.eject_class_merger(dir)

      app_web_dir = Add.app_web_name() |> Macro.underscore()
      path = Path.join([dir, "lib", app_web_dir, "class_merger", "groups.ex"])
      assert File.exists?(path)

      File.rm_rf!(dir)
    end

    test "ejected class_merger.ex contains the host app module name" do
      dir = Path.join(@tmp_dir, "phia_cm_#{:erlang.unique_integer([:positive])}")
      File.mkdir_p!(dir)

      Add.eject_class_merger(dir)

      app_web_dir = Add.app_web_name() |> Macro.underscore()
      content = File.read!(Path.join([dir, "lib", app_web_dir, "class_merger.ex"]))
      assert content =~ "defmodule PhiaUiWeb.ClassMerger do"
      assert content =~ "alias PhiaUiWeb.ClassMerger.Cache"
      assert content =~ "alias PhiaUiWeb.ClassMerger.Groups"

      File.rm_rf!(dir)
    end

    test "ejected class_merger.ex does NOT contain old PhiaUi module name" do
      dir = Path.join(@tmp_dir, "phia_cm_#{:erlang.unique_integer([:positive])}")
      File.mkdir_p!(dir)

      Add.eject_class_merger(dir)

      app_web_dir = Add.app_web_name() |> Macro.underscore()
      content = File.read!(Path.join([dir, "lib", app_web_dir, "class_merger.ex"]))
      refute content =~ "PhiaUi.ClassMerger"

      File.rm_rf!(dir)
    end

    test "idempotent: does not overwrite existing ClassMerger files" do
      dir = Path.join(@tmp_dir, "phia_cm_#{:erlang.unique_integer([:positive])}")
      File.mkdir_p!(dir)

      Add.eject_class_merger(dir)

      app_web_dir = Add.app_web_name() |> Macro.underscore()
      path = Path.join([dir, "lib", app_web_dir, "class_merger.ex"])
      original_content = File.read!(path)

      # Overwrite with sentinel text
      File.write!(path, "# sentinel")
      Add.eject_class_merger(dir)

      # Should not have overwritten — sentinel still present
      assert File.read!(path) == "# sentinel"
      # Restore for cleanup
      File.write!(path, original_content)

      File.rm_rf!(dir)
    end
  end

  # ---------------------------------------------------------------------------
  # eject_component/2 auto-ejects ClassMerger dependency
  # ---------------------------------------------------------------------------

  describe "eject_component/2 with automatic dependencies" do
    test "ejecting button also creates class_merger.ex" do
      dir = Path.join(@tmp_dir, "phia_dep_#{:erlang.unique_integer([:positive])}")
      File.mkdir_p!(dir)

      Add.eject_component("button", dir)

      app_web_dir = Add.app_web_name() |> Macro.underscore()
      cm_path = Path.join([dir, "lib", app_web_dir, "class_merger.ex"])
      assert File.exists?(cm_path)

      File.rm_rf!(dir)
    end

    test "ejecting card also creates ClassMerger" do
      dir = Path.join(@tmp_dir, "phia_dep_#{:erlang.unique_integer([:positive])}")
      File.mkdir_p!(dir)

      Add.eject_component("card", dir)

      app_web_dir = Add.app_web_name() |> Macro.underscore()
      cm_path = Path.join([dir, "lib", app_web_dir, "class_merger.ex"])
      assert File.exists?(cm_path)

      File.rm_rf!(dir)
    end
  end

  # ---------------------------------------------------------------------------
  # eject_js_hooks/2
  # ---------------------------------------------------------------------------

  describe "eject_js_hooks/2" do
    @hook_tpl Path.join([File.cwd!(), "priv/templates/js/hooks/button.js"])

    test "is a no-op for components without a hook template" do
      dir = Path.join(@tmp_dir, "phia_hooks_#{:erlang.unique_integer([:positive])}")
      File.mkdir_p!(dir)

      Add.eject_js_hooks("button", dir)

      refute File.exists?(Path.join([dir, "assets", "js", "phia_hooks", "button.js"]))

      File.rm_rf!(dir)
    end

    test "copies hook template to assets/js/phia_hooks/{component}.js" do
      dir = Path.join(@tmp_dir, "phia_hooks_#{:erlang.unique_integer([:positive])}")
      File.mkdir_p!(dir)
      File.mkdir_p!(Path.dirname(@hook_tpl))
      File.write!(@hook_tpl, "// PhiaUI Button hook\nexport default {}\n")

      Add.eject_js_hooks("button", dir)

      target = Path.join([dir, "assets", "js", "phia_hooks", "button.js"])
      assert File.exists?(target)
      assert File.read!(target) =~ "PhiaUI Button hook"

      File.rm!(@hook_tpl)
      File.rm_rf!(dir)
    end

    test "idempotent: does not overwrite existing hook file" do
      dir = Path.join(@tmp_dir, "phia_hooks_#{:erlang.unique_integer([:positive])}")
      File.mkdir_p!(Path.dirname(@hook_tpl))
      File.write!(@hook_tpl, "// hook content")

      target = Path.join([dir, "assets", "js", "phia_hooks", "button.js"])
      File.mkdir_p!(Path.dirname(target))
      File.write!(target, "// sentinel")

      Add.eject_js_hooks("button", dir)

      assert File.read!(target) == "// sentinel"

      File.rm!(@hook_tpl)
      File.rm_rf!(dir)
    end
  end

  # ---------------------------------------------------------------------------
  # eject_component/2 with js hooks
  # ---------------------------------------------------------------------------

  describe "eject_component/2 with js hooks" do
    @button_hook_tpl Path.join([File.cwd!(), "priv/templates/js/hooks/button.js"])

    test "ejects component js hook when hook template exists" do
      dir = Path.join(@tmp_dir, "phia_hooks_#{:erlang.unique_integer([:positive])}")
      File.mkdir_p!(dir)
      File.mkdir_p!(Path.dirname(@button_hook_tpl))
      File.write!(@button_hook_tpl, "// button hook")

      Add.eject_component("button", dir)

      target = Path.join([dir, "assets", "js", "phia_hooks", "button.js"])
      assert File.exists?(target)

      File.rm!(@button_hook_tpl)
      File.rm_rf!(dir)
    end

    test "eject_component does not create hook file when no hook template" do
      dir = Path.join(@tmp_dir, "phia_hooks_#{:erlang.unique_integer([:positive])}")
      File.mkdir_p!(dir)

      Add.eject_component("button", dir)

      refute File.exists?(Path.join([dir, "assets", "js", "phia_hooks", "button.js"]))

      File.rm_rf!(dir)
    end
  end

  # ---------------------------------------------------------------------------
  # next_steps_message/1
  # ---------------------------------------------------------------------------

  describe "next_steps_message/1" do
    test "returns a non-empty string" do
      msg = Add.next_steps_message("button")
      assert is_binary(msg)
      assert String.length(msg) > 0
    end

    test "mentions the component name" do
      msg = Add.next_steps_message("button")
      assert msg =~ "button" or msg =~ "Button"
    end

    test "mentions phia.install" do
      msg = Add.next_steps_message("button")
      assert msg =~ "phia.install"
    end

    test "mentions ClassMerger import" do
      msg = Add.next_steps_message("button")
      assert msg =~ "ClassMerger"
    end
  end
end
