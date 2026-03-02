defmodule PhiaUi.TemplateLinter do
  @moduledoc """
  Static linter that enforces the PhiaUI theming contract on component templates.

  ## Rules

  1. **No arbitrary hex colors** — classes like `bg-[#000]` or `text-[#1a2b3c]`
     are forbidden. Use semantic tokens instead (`bg-background`, etc.).

  2. **No hardcoded Tailwind palette classes** — classes like `text-zinc-900`
     or `bg-slate-100` couple components to a specific palette, breaking
     dark-mode and theming. Use `text-foreground`, `bg-card`, etc.

  ## Usage

      # Check a string of class content
      PhiaUi.TemplateLinter.check_content(~s(class="bg-primary text-foreground"))
      # => :ok

      PhiaUi.TemplateLinter.check_content(~s(class="bg-[#000] text-zinc-900"))
      # => {:error, ["Forbidden hardcoded hex: bg-[#000]", ...]}

      # Scan all component templates
      PhiaUi.TemplateLinter.scan_templates()
      # => :ok | {:error, [{file, [violation]}]}
  """

  # Pre-compile the palette violation regex at module load time
  # Matches: bg-red-500, text-zinc-900, border-blue-200, etc.
  @palette_pattern Regex.compile!(
                     "((?:bg|text|border|ring|fill|stroke|outline|shadow|accent|caret)" <>
                       "-(?:slate|gray|zinc|neutral|stone|red|orange|amber|yellow|lime" <>
                       "|green|emerald|teal|cyan|sky|blue|indigo|violet|purple|fuchsia" <>
                       "|pink|rose)-\\d{2,3})"
                   )

  # Arbitrary hex color: bg-[#abc], text-[#001122], border-[#1a2b3c], etc.
  @hex_pattern ~r/((?:bg|text|border|ring|fill|stroke|outline|shadow|accent|caret)-\[#[0-9a-fA-F]{3,8}\])/

  @doc """
  Checks a string of template content for theming violations.

  Returns `:ok` or `{:error, [violation_message]}`.
  """
  @spec check_content(String.t()) :: :ok | {:error, [String.t()]}
  def check_content(content) when is_binary(content) do
    violations = hex_violations(content) ++ palette_violations(content)

    case violations do
      [] -> :ok
      _ -> {:error, violations}
    end
  end

  @doc """
  Scans all `*.ex` files under `priv/templates/components/` and returns
  `:ok` or `{:error, [{file_path, [violation]}]}`.
  """
  @spec scan_templates() :: :ok | {:error, [{Path.t(), [String.t()]}]}
  def scan_templates do
    templates_dir = Path.join([File.cwd!(), "priv/templates/components"])

    file_violations =
      templates_dir
      |> template_files()
      |> Enum.flat_map(&check_file/1)

    case file_violations do
      [] -> :ok
      _ -> {:error, file_violations}
    end
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  defp hex_violations(content) do
    @hex_pattern
    |> Regex.scan(content, capture: :all_but_first)
    |> Enum.map(fn [match] -> "Forbidden hardcoded hex color: #{match}" end)
  end

  defp palette_violations(content) do
    @palette_pattern
    |> Regex.scan(content, capture: :all_but_first)
    |> Enum.map(fn [match] -> "Forbidden hardcoded palette class: #{match}" end)
  end

  defp template_files(dir) do
    if File.dir?(dir) do
      dir
      |> File.ls!()
      |> Enum.filter(&String.ends_with?(&1, ".ex"))
      |> Enum.map(&Path.join(dir, &1))
    else
      []
    end
  end

  defp check_file(path) do
    case path |> File.read!() |> check_content() do
      :ok -> []
      {:error, violations} -> [{path, violations}]
    end
  end
end
