defmodule PhiaUi.TemplateLinterTest do
  use ExUnit.Case, async: true

  alias PhiaUi.TemplateLinter

  # ── Unit tests for check_content/1 ─────────────────────────────────────────

  describe "check_content/1 — passes clean token-based classes" do
    test "bg-primary is allowed" do
      assert TemplateLinter.check_content(~s(class="bg-primary text-primary-foreground")) == :ok
    end

    test "text-foreground is allowed" do
      assert TemplateLinter.check_content(~s(class="text-foreground")) == :ok
    end

    test "border-border is allowed" do
      assert TemplateLinter.check_content(~s(class="border border-border")) == :ok
    end

    test "arbitrary non-color values are allowed" do
      assert TemplateLinter.check_content(~s(class="w-[320px] h-[48px] p-4")) == :ok
    end

    test "empty string passes" do
      assert TemplateLinter.check_content("") == :ok
    end
  end

  describe "check_content/1 — rejects hardcoded hex arbitrary colors" do
    test "rejects bg-[#000000]" do
      assert {:error, violations} = TemplateLinter.check_content(~s(class="bg-[#000000]"))
      assert violations != []
    end

    test "rejects text-[#fff]" do
      assert {:error, violations} = TemplateLinter.check_content(~s(class="text-[#fff]"))
      assert violations != []
    end

    test "rejects border-[#1a2b3c]" do
      assert {:error, violations} = TemplateLinter.check_content(~s(class="border-[#1a2b3c]"))
      assert violations != []
    end
  end

  describe "check_content/1 — rejects hardcoded Tailwind palette classes" do
    test "rejects text-zinc-900" do
      assert {:error, violations} = TemplateLinter.check_content(~s(class="text-zinc-900"))
      assert violations != []
    end

    test "rejects bg-slate-100" do
      assert {:error, violations} = TemplateLinter.check_content(~s(class="bg-slate-100"))
      assert violations != []
    end

    test "rejects text-gray-500" do
      assert {:error, violations} = TemplateLinter.check_content(~s(class="text-gray-500"))
      assert violations != []
    end

    test "rejects bg-red-500" do
      assert {:error, violations} = TemplateLinter.check_content(~s(class="bg-red-500"))
      assert violations != []
    end

    test "rejects border-blue-200" do
      assert {:error, violations} = TemplateLinter.check_content(~s(class="border-blue-200"))
      assert violations != []
    end

    test "rejects ring-emerald-400" do
      assert {:error, violations} = TemplateLinter.check_content(~s(class="ring-emerald-400"))
      assert violations != []
    end
  end

  describe "check_content/1 — violation messages" do
    test "violation includes the offending class" do
      {:error, [violation | _]} = TemplateLinter.check_content(~s(class="text-zinc-900"))
      assert violation =~ "text-zinc-900"
    end

    test "multiple violations are all reported" do
      {:error, violations} =
        TemplateLinter.check_content(~s(class="bg-[#000] text-zinc-900 border-slate-200"))

      assert length(violations) >= 3
    end
  end

  # ── Integration: scan actual template files ─────────────────────────────────

  describe "scan_templates/0 — actual priv/templates/components/" do
    test "all existing component templates pass the linter" do
      result = TemplateLinter.scan_templates()

      case result do
        :ok ->
          :ok

        {:error, file_violations} ->
          messages =
            Enum.map_join(file_violations, "\n", fn {file, violations} ->
              "  #{file}:\n" <> Enum.map_join(violations, "\n", &"    - #{&1}")
            end)

          flunk("Hardcoded colors found in templates:\n#{messages}")
      end
    end
  end
end
