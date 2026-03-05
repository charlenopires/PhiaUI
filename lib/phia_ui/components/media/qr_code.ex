defmodule PhiaUi.Components.QrCode do
  @moduledoc """
  QrCode component — server-side SVG QR code generation.

  Generates QR codes entirely on the server using the `eqrcode` hex package.
  Renders as an inline SVG — no JavaScript, no CDN, no image requests.

  ## Examples

      <%!-- Basic QR code --%>
      <.qr_code value="https://phiaui.dev" />

      <%!-- With custom size --%>
      <.qr_code value="https://phiaui.dev" size={300} />

      <%!-- With custom colors --%>
      <.qr_code value="https://phiaui.dev" color="#1e3a5f" background="#f0f9ff" />

      <%!-- With caption --%>
      <.qr_code value="https://phiaui.dev" caption="Scan to visit PhiaUI" />

      <%!-- High error correction for logo overlays --%>
      <.qr_code value="https://phiaui.dev" error_correction_level={:high} />
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  attr(:value, :string, required: true, doc: "Content to encode into the QR code")

  attr(:size, :integer,
    default: 200,
    doc: "Width and height of the SVG in pixels (default: 200)"
  )

  attr(:color, :string,
    default: "#000000",
    doc: "Fill color for dark QR modules (default: black)"
  )

  attr(:background, :string,
    default: "#ffffff",
    doc: "Background fill color (default: white)"
  )

  attr(:error_correction_level, :atom,
    values: [:low, :medium, :quartile, :high],
    default: :medium,
    doc: "Error correction level: :low, :medium, :quartile, :high"
  )

  attr(:aria_label, :string,
    default: nil,
    doc: "Accessible label for the QR code. Defaults to \"QR code for <value>\"."
  )

  attr(:caption, :string, default: nil, doc: "Optional caption rendered below the QR code")

  attr(:class, :string, default: nil, doc: "Additional CSS classes on the wrapper element")

  attr(:rest, :global, doc: "HTML attributes forwarded to the wrapper element")

  @doc """
  Renders an inline SVG QR code generated server-side.

  Uses the `eqrcode` hex package under the hood. The SVG is emitted
  as raw HTML — no JavaScript or external requests required.

  ## Examples

      <.qr_code value="https://phiaui.dev" size={256} />

      <.qr_code
        value={@profile_url}
        caption="Scan to view profile"
        error_correction_level={:high}
      />
  """
  def qr_code(assigns) do
    assigns =
      assign_new(assigns, :resolved_aria_label, fn ->
        assigns.aria_label || "QR code for #{assigns.value}"
      end)

    assigns =
      assign_new(assigns, :svg_content, fn ->
        ecl = ecl_atom(assigns.error_correction_level)

        qr = EQRCode.encode(assigns.value, ecl)

        EQRCode.svg(qr,
          width: assigns.size,
          color: assigns.color,
          background_color: assigns.background
        )
        |> IO.iodata_to_binary()
        |> strip_xml_declaration()
      end)

    ~H"""
    <figure
      role="img"
      aria-label={@resolved_aria_label}
      class={cn(["inline-block", @class])}
      {@rest}
    >
      {Phoenix.HTML.raw(@svg_content)}
      <%= if @caption do %>
        <figcaption class="mt-1 text-center text-sm text-muted-foreground">
          {@caption}
        </figcaption>
      <% end %>
    </figure>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  defp ecl_atom(:low), do: :l
  defp ecl_atom(:medium), do: :m
  defp ecl_atom(:quartile), do: :q
  defp ecl_atom(:high), do: :h

  defp strip_xml_declaration(svg) do
    case String.split(svg, "\n", parts: 2) do
      [first_line, rest] ->
        if String.starts_with?(String.trim_leading(first_line), "<?xml") do
          String.trim_leading(rest)
        else
          svg
        end

      _ ->
        svg
    end
  end
end
