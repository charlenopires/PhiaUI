defmodule Mix.Tasks.Phia.InstallTest do
  use ExUnit.Case, async: false

  alias Mix.Tasks.Phia.Install

  @theme_marker "/* PhiaUI Theme — do not remove this line */"
  @tmp_dir System.tmp_dir!()

  # Creates a temp css file, runs the installer against it, returns the result
  defp run_install(initial_content) do
    css_path = Path.join(@tmp_dir, "phia_test_app_#{:erlang.unique_integer([:positive])}.css")
    File.write!(css_path, initial_content)

    Install.inject_theme(css_path)

    result = File.read!(css_path)
    File.rm(css_path)
    result
  end

  describe "app_name/0" do
    test "returns the current mix project app name as atom" do
      assert Install.app_name() == :phia_ui
    end

    test "returns an atom" do
      assert is_atom(Install.app_name())
    end
  end

  describe "inject_hooks/1" do
    test "creates phia_hooks/index.js with PhiaHooks export" do
      dir = Path.join(@tmp_dir, "hooks_test_#{:erlang.unique_integer([:positive])}")
      File.mkdir_p!(dir)

      Install.inject_hooks(dir)

      hooks_path = Path.join([dir, "assets", "js", "phia_hooks", "index.js"])
      assert File.exists?(hooks_path)
      content = File.read!(hooks_path)
      assert content =~ "PhiaHooks"

      File.rm_rf!(dir)
    end

    test "idempotent: does not duplicate hooks file on repeated runs" do
      dir = Path.join(@tmp_dir, "hooks_idem_#{:erlang.unique_integer([:positive])}")
      File.mkdir_p!(dir)

      Install.inject_hooks(dir)
      Install.inject_hooks(dir)

      hooks_path = Path.join([dir, "assets", "js", "phia_hooks", "index.js"])
      content = File.read!(hooks_path)
      count = content |> String.split("PhiaHooks") |> length()
      # "PhiaHooks" should appear at most twice (once in export, once in object)
      assert count <= 3

      File.rm_rf!(dir)
    end
  end

  describe "inject_app_js/1" do
    test "adds phia hooks import to app.js" do
      dir = Path.join(@tmp_dir, "appjs_test_#{:erlang.unique_integer([:positive])}")
      js_path = Path.join([dir, "assets", "js", "app.js"])
      File.mkdir_p!(Path.dirname(js_path))
      File.write!(js_path, "let liveSocket = new LiveSocket(\"/live\", Socket, {hooks: {}})\n")

      Install.inject_app_js(dir)

      result = File.read!(js_path)
      assert result =~ "PhiaHooks"

      File.rm_rf!(dir)
    end

    test "idempotent: does not duplicate import on repeated runs" do
      dir = Path.join(@tmp_dir, "appjs_idem_#{:erlang.unique_integer([:positive])}")
      js_path = Path.join([dir, "assets", "js", "app.js"])
      File.mkdir_p!(Path.dirname(js_path))
      File.write!(js_path, "let liveSocket = new LiveSocket(\"/live\", Socket, {hooks: {}})\n")

      Install.inject_app_js(dir)
      Install.inject_app_js(dir)

      result = File.read!(js_path)
      count = result |> String.split("PhiaHooks") |> length()
      assert count <= 3

      File.rm_rf!(dir)
    end

    test "returns :already_installed when marker present" do
      dir = Path.join(@tmp_dir, "appjs_skip_#{:erlang.unique_integer([:positive])}")
      js_path = Path.join([dir, "assets", "js", "app.js"])
      File.mkdir_p!(Path.dirname(js_path))
      File.write!(js_path, "// phia_hooks_registered\nimport PhiaHooks from './phia_hooks/index.js'\n")

      result = Install.inject_app_js(dir)
      assert result == :already_installed

      File.rm_rf!(dir)
    end
  end

  describe "inject_theme/1" do
    test "injects theme block into an empty css file" do
      result = run_install("")
      assert result =~ "@theme {"
    end

    test "injected block contains oklch color tokens" do
      result = run_install("")
      assert result =~ "--color-primary:"
      assert result =~ "oklch("
    end

    test "injected block contains dark mode override" do
      result = run_install("")
      assert result =~ "@media (prefers-color-scheme: dark)"
    end

    test "injected block contains --radius token" do
      result = run_install("")
      assert result =~ "--radius: 0.625rem"
    end

    test "injected block contains sidebar token" do
      result = run_install("")
      assert result =~ "--color-sidebar-background:"
    end

    test "preserves existing css content" do
      existing = "@import 'tailwindcss';\n\n.my-class { color: red; }\n"
      result = run_install(existing)
      assert result =~ "@import 'tailwindcss';"
      assert result =~ ".my-class { color: red; }"
      assert result =~ "@theme {"
    end

    test "idempotent: does not inject twice on repeated runs" do
      css_path = Path.join(@tmp_dir, "phia_idempotent_#{:erlang.unique_integer([:positive])}.css")
      File.write!(css_path, "")

      Install.inject_theme(css_path)
      Install.inject_theme(css_path)

      result = File.read!(css_path)
      File.rm(css_path)

      # The idempotency marker must appear exactly once
      marker_count = result |> String.split(@theme_marker) |> length()
      assert marker_count == 2, "Expected marker to appear once, found #{marker_count - 1} times"
    end

    test "adds idempotency marker on injection" do
      result = run_install("")
      assert result =~ @theme_marker
    end
  end
end
