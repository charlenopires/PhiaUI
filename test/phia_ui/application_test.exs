defmodule PhiaUi.ApplicationTest do
  use ExUnit.Case, async: false

  test "application module is declared in mix.exs" do
    assert PhiaUi.MixProject.application()[:mod] == {PhiaUi.Application, []}
  end

  test "ClassMerger.Cache process is running" do
    assert Process.whereis(PhiaUi.ClassMerger.Cache) != nil
  end

  test "ClassMerger.Cache is registered under its module name" do
    pid = Process.whereis(PhiaUi.ClassMerger.Cache)
    assert is_pid(pid)
    assert Process.alive?(pid)
  end
end
