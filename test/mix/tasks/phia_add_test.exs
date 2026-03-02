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
    test "builds path rooted under lib/{app_web}/components/" do
      path = Add.component_path("/project", "button")
      assert path =~ "lib/phia_ui_web/components/button.ex"
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
      assert content =~ "defmodule PhiaUiWeb.Components.Button do"

      File.rm_rf!(dir)
    end

    test "ejects card component" do
      dir = Path.join(@tmp_dir, "phia_add_#{:erlang.unique_integer([:positive])}")
      File.mkdir_p!(dir)

      assert :ok = Add.eject_component("card", dir)
      target = Add.component_path(dir, "card")
      assert File.exists?(target)
      content = File.read!(target)
      assert content =~ "PhiaUiWeb.Components.Card"

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

      Add.eject_component("button", dir)
      # Second run — file exists, should not crash
      assert Add.eject_component("button", dir) in [:ok, :already_exists]

      File.rm_rf!(dir)
    end
  end
end
