defmodule Mix.Tasks.Phia.IconsTest do
  use ExUnit.Case, async: false

  alias Mix.Tasks.Phia.Icons

  @tmp_dir System.tmp_dir!()

  @minimum_icons ~w(menu chevron-down chevron-right check x plus search pencil
                    trash-2 upload-cloud image bold italic underline heading list
                    list-ordered quote code-2 link trending-up trending-down minus
                    eye eye-off calendar tag loader-circle)

  # ---------------------------------------------------------------------------
  # Helpers
  # ---------------------------------------------------------------------------

  defp tmp_source do
    dir = Path.join(@tmp_dir, "phia_icons_src_#{:erlang.unique_integer([:positive])}")
    File.mkdir_p!(dir)
    dir
  end

  defp tmp_output do
    dir = Path.join(@tmp_dir, "phia_icons_out_#{:erlang.unique_integer([:positive])}")
    File.mkdir_p!(dir)
    Path.join(dir, "lucide-sprite.svg")
  end

  # Writes a minimal Lucide-style SVG file for the given icon name
  defp write_icon(source_dir, name) do
    svg = """
    <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
      <line x1="4" x2="20" y1="12" y2="12"/>
    </svg>
    """

    File.write!(Path.join(source_dir, "#{name}.svg"), svg)
  end

  defp write_all_minimum_icons(source_dir) do
    Enum.each(@minimum_icons, &write_icon(source_dir, &1))
  end

  # ---------------------------------------------------------------------------
  # generate/2 — sprite content
  # ---------------------------------------------------------------------------

  describe "generate/2 sprite structure" do
    setup do
      src = tmp_source()
      write_all_minimum_icons(src)
      out = tmp_output()
      Icons.generate(src, out)
      sprite = File.read!(out)
      on_exit(fn -> File.rm_rf!(src) end)
      %{sprite: sprite, out: out}
    end

    test "creates the output file", %{out: out} do
      assert File.exists?(out)
    end

    test "output is a valid SVG root element", %{sprite: sprite} do
      assert sprite =~ "<svg"
      assert sprite =~ "</svg>"
    end

    test "root svg has style=display:none for hidden sprite", %{sprite: sprite} do
      assert sprite =~ "display:none"
    end

    test "contains a <symbol> for each minimum icon", %{sprite: sprite} do
      for name <- @minimum_icons do
        assert sprite =~ ~s(id="icon-#{name}"), "missing symbol for #{name}"
      end
    end

    test "symbol viewBox is 0 0 24 24", %{sprite: sprite} do
      assert sprite =~ ~s(viewBox="0 0 24 24")
    end

    test "symbols have stroke=\"currentColor\" for theme inheritance", %{sprite: sprite} do
      assert sprite =~ ~s(stroke="currentColor")
    end

    test "symbols contain inner SVG elements (no outer svg wrapper)", %{sprite: sprite} do
      assert sprite =~ "<line"
    end

    test "symbols do NOT contain nested <svg> elements", %{sprite: sprite} do
      # The inner svg wrapper must be stripped; only the root <svg> should exist
      [_first | rest] = String.split(sprite, "<svg")
      refute Enum.any?(rest, &String.contains?(&1, "<svg"))
    end
  end

  # ---------------------------------------------------------------------------
  # generate/2 — idempotency
  # ---------------------------------------------------------------------------

  describe "generate/2 idempotency" do
    test "running twice produces the same file content" do
      src = tmp_source()
      write_all_minimum_icons(src)
      out = tmp_output()

      Icons.generate(src, out)
      content_first = File.read!(out)

      Icons.generate(src, out)
      content_second = File.read!(out)

      assert content_first == content_second

      File.rm_rf!(src)
    end
  end

  # ---------------------------------------------------------------------------
  # generate/2 — creates output directories
  # ---------------------------------------------------------------------------

  describe "generate/2 directory creation" do
    test "creates nested output directories if they don't exist" do
      src = tmp_source()
      write_all_minimum_icons(src)

      nested =
        Path.join([
          @tmp_dir,
          "phia_icons_nested_#{:erlang.unique_integer([:positive])}",
          "static",
          "icons",
          "lucide-sprite.svg"
        ])

      Icons.generate(src, nested)
      assert File.exists?(nested)

      File.rm_rf!(Path.dirname(Path.dirname(Path.dirname(nested))))
      File.rm_rf!(src)
    end
  end

  # ---------------------------------------------------------------------------
  # generate/2 — missing icon warnings
  # ---------------------------------------------------------------------------

  describe "generate/2 partial icon set" do
    test "generates sprite with only icons that exist in source dir" do
      src = tmp_source()
      write_icon(src, "menu")
      write_icon(src, "check")
      out = tmp_output()

      prev_shell = Mix.shell()
      Mix.shell(Mix.Shell.Process)

      Icons.generate(src, out)

      Mix.shell(prev_shell)

      sprite = File.read!(out)
      assert sprite =~ ~s(id="icon-menu")
      assert sprite =~ ~s(id="icon-check")

      File.rm_rf!(src)
    end
  end

  # ---------------------------------------------------------------------------
  # run/1 — shell output
  # ---------------------------------------------------------------------------

  describe "run/1 shell output" do
    test "prints green create message on success" do
      src = tmp_source()
      write_all_minimum_icons(src)
      out = tmp_output()

      prev_shell = Mix.shell()
      Mix.shell(Mix.Shell.Process)

      Icons.run(["--source", src, "--output", out])

      assert_receive {:mix_shell, :info, [msg]}
      assert IO.iodata_to_binary(msg) =~ "create"

      Mix.shell(prev_shell)
      File.rm_rf!(src)
    end
  end

  # ---------------------------------------------------------------------------
  # run/1 --help
  # ---------------------------------------------------------------------------

  describe "run/1 --help" do
    test "prints usage documentation" do
      prev_shell = Mix.shell()
      Mix.shell(Mix.Shell.Process)

      Icons.run(["--help"])

      assert_receive {:mix_shell, :info, [content]}
      assert content =~ "mix phia.icons"

      Mix.shell(prev_shell)
    end
  end
end
