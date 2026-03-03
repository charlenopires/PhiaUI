defmodule Mix.Tasks.Phia.ThemeTest do
  use ExUnit.Case, async: false

  setup do
    Mix.shell(Mix.Shell.Process)
    on_exit(fn -> Mix.shell(Mix.Shell.IO) end)
    :ok
  end

  defp flush_messages(acc \\ []) do
    receive do
      {:mix_shell, :info, [msg]} -> flush_messages([{:info, msg} | acc])
      {:mix_shell, :error, [msg]} -> flush_messages([{:error, msg} | acc])
    after
      100 -> Enum.reverse(acc)
    end
  end

  defp info_messages do
    flush_messages() |> Enum.filter(&match?({:info, _}, &1)) |> Enum.map(&elem(&1, 1))
  end

  defp error_messages do
    flush_messages() |> Enum.filter(&match?({:error, _}, &1)) |> Enum.map(&elem(&1, 1))
  end

  # ---------------------------------------------------------------------------
  # list
  # ---------------------------------------------------------------------------

  describe "run/1 list" do
    test "lists all available themes" do
      Mix.Tasks.Phia.Theme.run(["list"])
      combined = info_messages() |> Enum.join("\n")
      assert combined =~ "zinc"
      assert combined =~ "blue"
      assert combined =~ "rose"
    end

    test "list shows theme labels" do
      Mix.Tasks.Phia.Theme.run(["list"])
      combined = info_messages() |> Enum.join("\n")
      assert combined =~ "Zinc" or combined =~ "Enterprise"
    end

    test "list shows primary OKLCH color values" do
      Mix.Tasks.Phia.Theme.run(["list"])
      combined = info_messages() |> Enum.join("\n")
      assert combined =~ "oklch("
    end

    test "list shows column headers NAME, LABEL, PRIMARY" do
      Mix.Tasks.Phia.Theme.run(["list"])
      combined = info_messages() |> Enum.join("\n")
      assert combined =~ "NAME"
      assert combined =~ "LABEL"
      assert combined =~ "PRIMARY"
    end

    test "list includes all built-in theme keys" do
      Mix.Tasks.Phia.Theme.run(["list"])
      combined = info_messages() |> Enum.join("\n")

      PhiaUi.Theme.list()
      |> Enum.each(fn key ->
        assert combined =~ to_string(key), "expected #{key} in list output"
      end)
    end
  end

  # ---------------------------------------------------------------------------
  # export
  # ---------------------------------------------------------------------------

  describe "run/1 export" do
    test "export zinc produces JSON by default" do
      Mix.Tasks.Phia.Theme.run(["export", "zinc"])
      combined = info_messages() |> Enum.join("\n")
      assert combined =~ "\"name\""
      assert combined =~ "\"zinc\""
    end

    test "export zinc --format json produces JSON" do
      Mix.Tasks.Phia.Theme.run(["export", "zinc", "--format", "json"])
      combined = info_messages() |> Enum.join("\n")
      assert combined =~ "\"name\""
      assert combined =~ "\"zinc\""
    end

    test "export zinc --format css produces CSS with attribute selector" do
      Mix.Tasks.Phia.Theme.run(["export", "zinc", "--format", "css"])
      combined = info_messages() |> Enum.join("\n")
      assert combined =~ ~s([data-phia-theme="zinc"])
    end

    test "export blue --format css includes dark variant selector" do
      Mix.Tasks.Phia.Theme.run(["export", "blue", "--format", "css"])
      combined = info_messages() |> Enum.join("\n")
      assert combined =~ ~s([data-phia-theme="blue"])
      assert combined =~ ".dark"
    end

    test "export unknown theme prints error" do
      Mix.Tasks.Phia.Theme.run(["export", "nonexistent_xyz_theme"])
      errors = error_messages()
      assert errors != []
    end

    test "export unknown theme error message contains the bad name" do
      Mix.Tasks.Phia.Theme.run(["export", "nonexistent_xyz_theme"])
      combined = error_messages() |> Enum.join("\n")
      assert combined =~ "nonexistent_xyz_theme"
    end

    test "export --format json is valid JSON" do
      Mix.Tasks.Phia.Theme.run(["export", "rose", "--format", "json"])
      combined = info_messages() |> Enum.join("\n")
      assert {:ok, _decoded} = Jason.decode(combined)
    end
  end

  # ---------------------------------------------------------------------------
  # install
  # ---------------------------------------------------------------------------

  describe "run/1 install" do
    setup do
      tmp =
        System.tmp_dir!()
        |> Path.join("phia_theme_test_#{:rand.uniform(99_999)}")

      File.mkdir_p!(tmp)
      on_exit(fn -> File.rm_rf!(tmp) end)
      %{tmp: tmp}
    end

    test "install creates phia-themes.css with all theme selectors", %{tmp: tmp} do
      output = Path.join(tmp, "phia-themes.css")
      Mix.Tasks.Phia.Theme.run(["install", "--output", output])
      assert File.exists?(output)
      content = File.read!(output)

      Enum.each(PhiaUi.Theme.list(), fn key ->
        assert content =~ ~s([data-phia-theme="#{key}"]), "missing #{key} selector"
      end)
    end

    test "install --themes zinc,blue only generates those themes", %{tmp: tmp} do
      output = Path.join(tmp, "phia-themes.css")
      Mix.Tasks.Phia.Theme.run(["install", "--output", output, "--themes", "zinc,blue"])
      content = File.read!(output)
      assert content =~ ~s([data-phia-theme="zinc"])
      assert content =~ ~s([data-phia-theme="blue"])
      refute content =~ ~s([data-phia-theme="rose"])
    end

    test "install --themes with whitespace around names is tolerated", %{tmp: tmp} do
      output = Path.join(tmp, "phia-themes.css")
      Mix.Tasks.Phia.Theme.run(["install", "--output", output, "--themes", "zinc, blue"])
      content = File.read!(output)
      assert content =~ ~s([data-phia-theme="zinc"])
      assert content =~ ~s([data-phia-theme="blue"])
    end

    test "install prints success message containing output path", %{tmp: tmp} do
      output = Path.join(tmp, "phia-themes.css")
      Mix.Tasks.Phia.Theme.run(["install", "--output", output])
      combined = info_messages() |> Enum.join("\n")
      assert combined =~ "Generated" or combined =~ output
    end

    test "install prints theme count in success message", %{tmp: tmp} do
      output = Path.join(tmp, "phia-themes.css")
      Mix.Tasks.Phia.Theme.run(["install", "--output", output, "--themes", "zinc,blue"])
      combined = info_messages() |> Enum.join("\n")
      assert combined =~ "2"
    end

    test "install creates parent directories when they do not exist", %{tmp: tmp} do
      output = Path.join([tmp, "nested", "deep", "phia-themes.css"])
      Mix.Tasks.Phia.Theme.run(["install", "--output", output])
      assert File.exists?(output)
    end

    test "install prints tip about data-phia-theme attribute", %{tmp: tmp} do
      output = Path.join(tmp, "phia-themes.css")
      Mix.Tasks.Phia.Theme.run(["install", "--output", output])
      combined = info_messages() |> Enum.join("\n")
      assert combined =~ "data-phia-theme"
    end

    test "install skips @import injection when app.css does not exist", %{tmp: tmp} do
      output = Path.join(tmp, "phia-themes.css")
      # Run from a tmp dir where assets/css/app.css cannot exist
      Mix.Tasks.Phia.Theme.run(["install", "--output", output])
      combined = info_messages() |> Enum.join("\n")
      # Should mention the tip about adding @import manually
      assert combined =~ "Tip:" or combined =~ "@import"
    end

    test "install produced CSS contains header comment", %{tmp: tmp} do
      output = Path.join(tmp, "phia-themes.css")
      Mix.Tasks.Phia.Theme.run(["install", "--output", output])
      content = File.read!(output)
      assert content =~ "PhiaUI Themes"
    end

    test "install with single theme produces correct selector", %{tmp: tmp} do
      output = Path.join(tmp, "phia-themes.css")
      Mix.Tasks.Phia.Theme.run(["install", "--output", output, "--themes", "violet"])
      content = File.read!(output)
      assert content =~ ~s([data-phia-theme="violet"])
    end
  end

  # ---------------------------------------------------------------------------
  # unknown command
  # ---------------------------------------------------------------------------

  describe "run/1 unknown command" do
    test "prints usage for unknown command" do
      Mix.Tasks.Phia.Theme.run(["unknown_cmd"])
      combined = info_messages() |> Enum.join("\n")
      assert byte_size(combined) > 0
    end

    test "prints usage when no arguments given" do
      Mix.Tasks.Phia.Theme.run([])
      combined = info_messages() |> Enum.join("\n")
      assert byte_size(combined) > 0
    end
  end
end
