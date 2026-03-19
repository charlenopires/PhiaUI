defmodule PhiaUi.Editor.CitationHelpers do
  @moduledoc """
  Pure Elixir utilities for formatting citations and parsing BibTeX.

  Provides server-side citation formatting in six academic styles (APA, MLA,
  Chicago, Harvard, IEEE, ABNT) and a basic BibTeX parser for importing
  reference libraries.

  ## Entry Format

  Citation entries are maps with the following keys (all optional except `:author`
  and `:title`):

      %{
        author: "Smith, J.",
        title: "Example Article",
        year: "2024",
        source: "Nature",
        url: "https://doi.org/...",
        volume: "42",
        pages: "1-20"
      }

  ## Usage

      alias PhiaUi.Editor.CitationHelpers

      # Format a single citation
      CitationHelpers.format_citation(entry, :apa)
      #=> "Smith, J. (2024). Example Article. Nature."

      # Format a numbered bibliography
      CitationHelpers.format_bibliography([entry1, entry2], :mla)
      #=> [{1, "Smith, J. \\"Example.\\" ..."}, ...]

      # Parse BibTeX
      CitationHelpers.parse_bibtex(bibtex_string)
      #=> [%{key: "smith2024", type: "article", author: "Smith, J.", ...}]
  """

  # ---------------------------------------------------------------------------
  # format_citation/2
  # ---------------------------------------------------------------------------

  @doc """
  Formats a single citation entry in the given academic style.

  ## Supported Styles

  - `:apa`     — Author (Year). Title. Source.
  - `:mla`     — Author. "Title." Source, Year.
  - `:chicago` — Author. "Title." Source (Year).
  - `:harvard` — Author (Year) 'Title', Source.
  - `:ieee`    — Author, "Title," Source, vol. Volume, pp. Pages, Year.
  - `:abnt`    — AUTHOR. Title. Source, v. Volume, p. Pages, Year.

  ## Examples

      iex> entry = %{author: "Smith, J.", title: "My Article", year: "2024", source: "Nature"}
      iex> PhiaUi.Editor.CitationHelpers.format_citation(entry, :apa)
      "Smith, J. (2024). My Article. Nature."
  """
  @spec format_citation(map(), atom()) :: String.t()
  def format_citation(entry, style \\ :apa) do
    author = get_field(entry, :author)
    title = get_field(entry, :title)
    year = get_field(entry, :year)
    source = get_field(entry, :source)
    volume = get_field(entry, :volume)
    pages = get_field(entry, :pages)
    url = get_field(entry, :url)

    base =
      case style do
        :apa ->
          parts = ["#{author} (#{year}). #{title}."]
          parts = if source != "", do: parts ++ [" #{source}"], else: parts
          parts = if volume != "", do: parts ++ [", #{volume}"], else: parts
          parts = if pages != "", do: parts ++ [", #{pages}"], else: parts
          parts = parts ++ ["."]
          Enum.join(parts)

        :mla ->
          parts = [~s(#{author}. "#{title}.")]
          parts = if source != "", do: parts ++ [" #{source}"], else: parts
          parts = if volume != "", do: parts ++ [", vol. #{volume}"], else: parts
          parts = if pages != "", do: parts ++ [", pp. #{pages}"], else: parts
          parts = if year != "", do: parts ++ [", #{year}"], else: parts
          parts = parts ++ ["."]
          Enum.join(parts)

        :chicago ->
          parts = [~s(#{author}. "#{title}.")]
          parts = if source != "", do: parts ++ [" #{source}"], else: parts
          parts = if volume != "", do: parts ++ [" #{volume}"], else: parts
          parts = if pages != "", do: parts ++ [": #{pages}"], else: parts
          parts = if year != "", do: parts ++ [" (#{year})"], else: parts
          parts = parts ++ ["."]
          Enum.join(parts)

        :harvard ->
          parts = ["#{author} (#{year}) '#{title}'"]
          parts = if source != "", do: parts ++ [", #{source}"], else: parts
          parts = if volume != "", do: parts ++ [", #{volume}"], else: parts
          parts = if pages != "", do: parts ++ [", pp. #{pages}"], else: parts
          parts = parts ++ ["."]
          Enum.join(parts)

        :ieee ->
          parts = [~s(#{author}, "#{title},")]
          parts = if source != "", do: parts ++ [" #{source}"], else: parts
          parts = if volume != "", do: parts ++ [", vol. #{volume}"], else: parts
          parts = if pages != "", do: parts ++ [", pp. #{pages}"], else: parts
          parts = if year != "", do: parts ++ [", #{year}"], else: parts
          parts = parts ++ ["."]
          Enum.join(parts)

        :abnt ->
          upcased = String.upcase(author)
          parts = ["#{upcased}. #{title}."]
          parts = if source != "", do: parts ++ [" #{source}"], else: parts
          parts = if volume != "", do: parts ++ [", v. #{volume}"], else: parts
          parts = if pages != "", do: parts ++ [", p. #{pages}"], else: parts
          parts = if year != "", do: parts ++ [", #{year}"], else: parts
          parts = parts ++ ["."]
          Enum.join(parts)

        _ ->
          "#{author} (#{year}). #{title}. #{source}."
      end

    if url != "" do
      base <> " Retrieved from #{url}"
    else
      base
    end
  end

  # ---------------------------------------------------------------------------
  # format_bibliography/2
  # ---------------------------------------------------------------------------

  @doc """
  Formats a list of citation entries into a numbered bibliography.

  Returns a list of `{index, formatted_string}` tuples, numbered starting at 1.

  ## Examples

      iex> entries = [
      ...>   %{author: "Smith, J.", title: "First", year: "2024", source: "Nature"},
      ...>   %{author: "Doe, A.", title: "Second", year: "2023", source: "Science"}
      ...> ]
      iex> PhiaUi.Editor.CitationHelpers.format_bibliography(entries, :apa)
      [{1, "Smith, J. (2024). First. Nature."}, {2, "Doe, A. (2023). Second. Science."}]
  """
  @spec format_bibliography(list(map()), atom()) :: list({pos_integer(), String.t()})
  def format_bibliography(entries, style \\ :apa) when is_list(entries) do
    entries
    |> Enum.with_index(1)
    |> Enum.map(fn {entry, idx} ->
      {idx, format_citation(entry, style)}
    end)
  end

  # ---------------------------------------------------------------------------
  # parse_bibtex/1
  # ---------------------------------------------------------------------------

  @doc """
  Parses a BibTeX string and extracts entries as a list of maps.

  Handles the common `@type{key, field={value}, ...}` format. Supports
  `@article`, `@book`, `@inproceedings`, `@misc`, and other standard types.

  Fields are lowercased and returned as string-keyed atoms. Unknown fields
  are preserved as-is.

  ## Examples

      iex> bibtex = ~s(@article{smith2024,
      ...>   author = {Smith, John},
      ...>   title = {A Great Paper},
      ...>   year = {2024},
      ...>   journal = {Nature}
      ...> })
      iex> [entry] = PhiaUi.Editor.CitationHelpers.parse_bibtex(bibtex)
      iex> entry.key
      "smith2024"
      iex> entry.author
      "Smith, John"
  """
  @spec parse_bibtex(String.t()) :: list(map())
  def parse_bibtex(bibtex_string) when is_binary(bibtex_string) do
    # Match each @type{key, ... } entry block
    ~r/@(\w+)\s*\{\s*([^,\s]+)\s*,([^@]*)\}/s
    |> Regex.scan(bibtex_string)
    |> Enum.map(&parse_bibtex_entry/1)
  end

  def parse_bibtex(_), do: []

  defp parse_bibtex_entry([_full, type, key, body]) do
    fields = parse_bibtex_fields(body)

    base = %{
      key: String.trim(key),
      type: String.downcase(type),
      author: Map.get(fields, "author", ""),
      title: Map.get(fields, "title", ""),
      year: Map.get(fields, "year", ""),
      source: Map.get(fields, "journal", Map.get(fields, "booktitle", "")),
      url: Map.get(fields, "url", Map.get(fields, "doi", "")),
      volume: Map.get(fields, "volume", ""),
      pages: Map.get(fields, "pages", "")
    }

    # Merge any extra fields not in the standard set
    standard_keys = ~w(author title year journal booktitle url doi volume pages)
    extras = Map.drop(fields, standard_keys)

    Map.merge(base, extras |> Enum.into(%{}, fn {k, v} -> {String.to_atom(k), v} end))
  end

  defp parse_bibtex_fields(body) do
    ~r/(\w+)\s*=\s*\{([^}]*)\}/
    |> Regex.scan(body)
    |> Enum.into(%{}, fn [_full, field, value] ->
      {String.downcase(String.trim(field)), String.trim(value)}
    end)
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  defp get_field(entry, key) do
    case Map.get(entry, key) do
      nil -> ""
      val when is_binary(val) -> val
      val -> to_string(val)
    end
  end
end
