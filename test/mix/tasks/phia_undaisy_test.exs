defmodule Mix.Tasks.Phia.UndaisyTest do
  use ExUnit.Case, async: false

  alias Mix.Tasks.Phia.Undaisy

  @tmp System.tmp_dir!()

  defp tmp_dir, do: Path.join(@tmp, "undaisy_#{:erlang.unique_integer([:positive])}")

  defp write!(dir, rel, content) do
    path = Path.join(dir, rel)
    File.mkdir_p!(Path.dirname(path))
    File.write!(path, content)
    path
  end

  # ---------------------------------------------------------------------------
  # clean_package_json/1
  # ---------------------------------------------------------------------------

  describe "clean_package_json/1" do
    test "removes daisyui from dependencies" do
      json = """
      {
        "dependencies": {
          "topbar": "^3.0.0",
          "daisyui": "^4.12.0"
        }
      }
      """

      assert {:changed, result} = Undaisy.clean_package_json(json)
      refute String.contains?(result, "daisyui")
      assert String.contains?(result, "topbar")
    end

    test "removes daisyui from devDependencies" do
      json = """
      {
        "devDependencies": {
          "daisyui": "^4.12.0",
          "esbuild": "^0.24.0"
        }
      }
      """

      assert {:changed, result} = Undaisy.clean_package_json(json)
      refute String.contains?(result, "daisyui")
      assert String.contains?(result, "esbuild")
    end

    test "removes daisyui when it is the sole dependency" do
      json = ~s({\n  "dependencies": {\n    "daisyui": "^4.0.0"\n  }\n}\n)
      assert {:changed, result} = Undaisy.clean_package_json(json)
      refute String.contains?(result, "daisyui")
    end

    test "removes daisyui from both sections when present in both" do
      json = """
      {
        "dependencies": {"daisyui": "^4.0.0"},
        "devDependencies": {"daisyui": "^4.0.0"}
      }
      """

      assert {:changed, result} = Undaisy.clean_package_json(json)
      refute String.contains?(result, "daisyui")
    end

    test "returns :unchanged when daisyui is absent" do
      json = ~s({\n  "dependencies": {\n    "topbar": "^3.0.0"\n  }\n}\n)
      assert {:unchanged, ^json} = Undaisy.clean_package_json(json)
    end

    test "preserves other dependencies" do
      json = """
      {
        "dependencies": {
          "phoenix": "^1.7.0",
          "daisyui": "^4.12.0",
          "topbar": "^3.0.0"
        }
      }
      """

      assert {:changed, result} = Undaisy.clean_package_json(json)
      refute String.contains?(result, "daisyui")
      assert String.contains?(result, "phoenix")
      assert String.contains?(result, "topbar")
    end
  end

  # ---------------------------------------------------------------------------
  # clean_css/1
  # ---------------------------------------------------------------------------

  describe "clean_css/1" do
    test "removes @plugin daisyui; (Tailwind v4)" do
      css = ~s(@plugin "daisyui";\n@import "tailwindcss";\n)
      assert {:changed, result} = Undaisy.clean_css(css)
      refute String.contains?(result, "daisyui")
      assert String.contains?(result, "tailwindcss")
    end

    test "removes @plugin with single quotes" do
      css = "@plugin 'daisyui';\n"
      assert {:changed, result} = Undaisy.clean_css(css)
      refute String.contains?(result, "daisyui")
    end

    test "removes @plugin daisyui/full;" do
      css = ~s(@plugin "daisyui/full";\n)
      assert {:changed, result} = Undaisy.clean_css(css)
      refute String.contains?(result, "daisyui")
    end

    test "removes @import daisyui;" do
      css = "@import 'daisyui';\n@import 'tailwindcss';\n"
      assert {:changed, result} = Undaisy.clean_css(css)
      refute String.contains?(result, "daisyui")
      assert String.contains?(result, "tailwindcss")
    end

    test "removes @source node_modules/daisyui" do
      css = ~s(@source "node_modules/daisyui/dist/*.js";\n)
      assert {:changed, result} = Undaisy.clean_css(css)
      refute String.contains?(result, "daisyui")
    end

    test "removes multiple daisyui directives in one pass" do
      css = """
      @import "tailwindcss";
      @plugin "daisyui";
      @source "node_modules/daisyui/dist/*.js";
      """

      assert {:changed, result} = Undaisy.clean_css(css)
      refute String.contains?(result, "daisyui")
      assert String.contains?(result, "tailwindcss")
    end

    test "returns :unchanged when no daisyui directives present" do
      css = "@import 'tailwindcss';\n"
      assert {:unchanged, ^css} = Undaisy.clean_css(css)
    end

    test "handles indented @plugin directive" do
      css = "  @plugin \"daisyui\";\n"
      assert {:changed, result} = Undaisy.clean_css(css)
      refute String.contains?(result, "daisyui")
    end
  end

  # ---------------------------------------------------------------------------
  # clean_tailwind_config/1
  # ---------------------------------------------------------------------------

  describe "clean_tailwind_config/1" do
    test "removes require(daisyui) when sole plugin" do
      config = "module.exports = {\n  plugins: [require(\"daisyui\")]\n}"
      assert {:changed, result} = Undaisy.clean_tailwind_config(config)
      refute String.contains?(result, "daisyui")
    end

    test "removes require(daisyui) with single quotes" do
      config = "module.exports = { plugins: [require('daisyui')] }"
      assert {:changed, result} = Undaisy.clean_tailwind_config(config)
      refute String.contains?(result, "daisyui")
    end

    test "removes daisyui from multi-plugin array — last position" do
      config =
        "module.exports = {\n  plugins: [require(\"autoprefixer\"), require(\"daisyui\")]\n}"

      assert {:changed, result} = Undaisy.clean_tailwind_config(config)
      refute String.contains?(result, "daisyui")
      assert String.contains?(result, "autoprefixer")
    end

    test "removes daisyui from multi-plugin array — first position" do
      config =
        "module.exports = {\n  plugins: [require(\"daisyui\"), require(\"autoprefixer\")]\n}"

      assert {:changed, result} = Undaisy.clean_tailwind_config(config)
      refute String.contains?(result, "daisyui")
      assert String.contains?(result, "autoprefixer")
    end

    test "removes daisyui: config block" do
      config = "module.exports = {\n  content: [],\n  daisyui: { themes: false }\n}"
      assert {:changed, result} = Undaisy.clean_tailwind_config(config)
      refute String.contains?(result, "daisyui")
    end

    test "removes daisyui: config block with trailing comma" do
      config = "module.exports = {\n  daisyui: { themes: [\"light\"] },\n  content: []\n}"
      assert {:changed, result} = Undaisy.clean_tailwind_config(config)
      refute String.contains?(result, "daisyui")
      assert String.contains?(result, "content")
    end

    test "returns :unchanged when no daisyui present" do
      config = "module.exports = {\n  plugins: [require(\"autoprefixer\")]\n}"
      assert {:unchanged, ^config} = Undaisy.clean_tailwind_config(config)
    end
  end

  # ---------------------------------------------------------------------------
  # find_daisy_classes/1
  # ---------------------------------------------------------------------------

  describe "find_daisy_classes/1" do
    test "finds btn-primary" do
      content = ~s(<button class="btn btn-primary">Submit</button>)
      assert "btn-primary" in Undaisy.find_daisy_classes(content)
    end

    test "finds card-body" do
      content = ~s(<div class="card"><div class="card-body">content</div></div>)
      assert "card-body" in Undaisy.find_daisy_classes(content)
    end

    test "finds modal-box" do
      content = ~s(<div class="modal modal-box">content</div>)
      assert "modal-box" in Undaisy.find_daisy_classes(content)
    end

    test "finds multiple daisy classes in one file" do
      content = ~s(<div class="navbar-start card-body badge-primary">)
      classes = Undaisy.find_daisy_classes(content)
      assert "navbar-start" in classes
      assert "card-body" in classes
      assert "badge-primary" in classes
    end

    test "returns empty list for clean PhiaUI content" do
      content = ~s(<.button variant="default" class="px-4 py-2">Save</.button>)
      assert Undaisy.find_daisy_classes(content) == []
    end

    test "returns empty list for plain Tailwind content" do
      content = ~s(<div class="flex items-center gap-4 rounded-lg bg-white p-6">)
      assert Undaisy.find_daisy_classes(content) == []
    end

    test "finds loading-spinner" do
      content = ~s(<span class="loading loading-spinner loading-md"></span>)
      assert "loading-spinner" in Undaisy.find_daisy_classes(content)
    end

    test "finds swap-on and swap-off" do
      content = ~s(<span class="swap-on">🌞</span><span class="swap-off">🌙</span>)
      classes = Undaisy.find_daisy_classes(content)
      assert "swap-on" in classes
      assert "swap-off" in classes
    end
  end

  # ---------------------------------------------------------------------------
  # run/1 integration tests (using temp directories)
  # ---------------------------------------------------------------------------

  describe "run/1 --help" do
    test "prints usage documentation" do
      prev = Mix.shell()
      Mix.shell(Mix.Shell.Process)

      Undaisy.run(["--help"])

      assert_receive {:mix_shell, :info, [content]}
      assert content =~ "mix phia.undaisy"

      Mix.shell(prev)
    end

    test "--help mentions dry-run option" do
      prev = Mix.shell()
      Mix.shell(Mix.Shell.Process)

      Undaisy.run(["--help"])

      assert_receive {:mix_shell, :info, [content]}
      assert content =~ "--dry-run"

      Mix.shell(prev)
    end
  end

  describe "run/1 file processing" do
    test "removes @plugin daisyui from app.css" do
      dir = tmp_dir()
      path = write!(dir, "assets/css/app.css", "@plugin \"daisyui\";\n@import \"tailwindcss\";\n")

      prev = Mix.shell()
      Mix.shell(Mix.Shell.Process)

      File.cd!(dir, fn -> Undaisy.run([]) end)

      result = File.read!(path)
      refute String.contains?(result, "daisyui")
      assert String.contains?(result, "tailwindcss")

      Mix.shell(prev)
      File.rm_rf!(dir)
    end

    test "removes daisyui from package.json" do
      dir = tmp_dir()

      path =
        write!(dir, "assets/package.json", """
        {
          "dependencies": {
            "topbar": "^3.0.0",
            "daisyui": "^4.12.0"
          }
        }
        """)

      prev = Mix.shell()
      Mix.shell(Mix.Shell.Process)

      File.cd!(dir, fn -> Undaisy.run([]) end)

      result = File.read!(path)
      refute String.contains?(result, "daisyui")
      assert String.contains?(result, "topbar")

      Mix.shell(prev)
      File.rm_rf!(dir)
    end

    test "removes require(daisyui) from tailwind.config.js" do
      dir = tmp_dir()

      path =
        write!(
          dir,
          "assets/tailwind.config.js",
          "module.exports = { plugins: [require(\"daisyui\")] }"
        )

      prev = Mix.shell()
      Mix.shell(Mix.Shell.Process)

      File.cd!(dir, fn -> Undaisy.run([]) end)

      result = File.read!(path)
      refute String.contains?(result, "daisyui")

      Mix.shell(prev)
      File.rm_rf!(dir)
    end

    test "dry-run does not modify files" do
      dir = tmp_dir()
      original = "@plugin \"daisyui\";\n@import \"tailwindcss\";\n"
      path = write!(dir, "assets/css/app.css", original)

      prev = Mix.shell()
      Mix.shell(Mix.Shell.Process)

      File.cd!(dir, fn -> Undaisy.run(["--dry-run"]) end)

      result = File.read!(path)
      assert result == original

      Mix.shell(prev)
      File.rm_rf!(dir)
    end

    test "skips missing files gracefully" do
      dir = tmp_dir()
      File.mkdir_p!(dir)

      prev = Mix.shell()
      Mix.shell(Mix.Shell.Process)

      # Should not raise even when none of the expected files exist
      assert :ok == File.cd!(dir, fn -> Undaisy.run([]) end)

      Mix.shell(prev)
      File.rm_rf!(dir)
    end

    test "scans lib/ templates and reports daisy class hits" do
      dir = tmp_dir()
      write!(dir, "assets/css/app.css", "@import \"tailwindcss\";\n")

      write!(dir, "lib/my_app_web/live/page_live.ex", """
      def render(assigns) do
        ~H\"\"\"
        <div class="card-body btn-primary">Hello</div>
        \"\"\"
      end
      """)

      prev = Mix.shell()
      Mix.shell(Mix.Shell.Process)

      File.cd!(dir, fn -> Undaisy.run([]) end)

      messages =
        Enum.reduce_while(1..100, [], fn _, acc ->
          receive do
            {:mix_shell, :info, [msg]} -> {:cont, [msg | acc]}
            {:mix_shell, :error, _} -> {:cont, acc}
          after
            0 -> {:halt, acc}
          end
        end)

      combined = Enum.join(messages, "\n")
      assert combined =~ "card-body" or combined =~ "btn-primary"

      Mix.shell(prev)
      File.rm_rf!(dir)
    end
  end
end
