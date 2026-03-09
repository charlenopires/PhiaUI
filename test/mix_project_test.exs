defmodule PhiaUi.MixProjectTest do
  use ExUnit.Case, async: true

  @config Mix.Project.config()

  test "app name is :phia_ui" do
    assert @config[:app] == :phia_ui
  end

  test "version is 0.1.15" do
    assert @config[:version] == "0.1.15"
  end

  test "elixir requirement is ~> 1.17" do
    assert @config[:elixir] == "~> 1.17"
  end

  describe "docs/0" do
    setup do
      {:ok, docs: @config[:docs]}
    end

    test "extras includes README.md", %{docs: docs} do
      assert "README.md" in docs[:extras]
    end

    test "extras includes CHANGELOG.md", %{docs: docs} do
      assert "CHANGELOG.md" in docs[:extras]
    end
  end

  describe "package/0" do
    setup do
      {:ok, pkg: @config[:package]}
    end

    test "has a name", %{pkg: pkg} do
      assert is_binary(pkg[:name]) and pkg[:name] != ""
    end

    test "has a description", %{pkg: pkg} do
      assert is_binary(pkg[:description]) and pkg[:description] != ""
    end

    test "has MIT license", %{pkg: pkg} do
      assert pkg[:licenses] == ["MIT"]
    end

    test "has GitHub link", %{pkg: pkg} do
      assert is_map(pkg[:links])
      assert Map.has_key?(pkg[:links], "GitHub")
      assert String.starts_with?(pkg[:links]["GitHub"], "https://github.com/")
    end

    test "files include priv/ and lib/", %{pkg: pkg} do
      files = pkg[:files]
      assert is_list(files)
      assert Enum.any?(files, &String.starts_with?(&1, "priv"))
      assert Enum.any?(files, &String.starts_with?(&1, "lib"))
    end
  end
end
