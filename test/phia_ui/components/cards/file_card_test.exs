defmodule PhiaUi.Components.FileCardTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.FileCard

    attr :filename, :string, default: "document.pdf"
    attr :size, :string, default: nil
    attr :uploaded_at, :string, default: nil
    attr :href, :string, default: nil
    attr :variant, :atom, default: :default
    attr :class, :string, default: nil

    def render_file_card(assigns) do
      ~H"""
      <.file_card
        filename={@filename}
        size={@size}
        uploaded_at={@uploaded_at}
        href={@href}
        variant={@variant}
        class={@class}
      />
      """
    end

    def render_with_actions(assigns) do
      ~H"""
      <.file_card filename="report.xlsx">
        <:actions>
          <button class="download-btn">Download</button>
        </:actions>
      </.file_card>
      """
    end
  end

  defp render_file_card(attrs \\ %{}) do
    render_component(&H.render_file_card/1, attrs)
  end

  # ---------------------------------------------------------------------------
  # Basic rendering
  # ---------------------------------------------------------------------------

  describe "file_card/1 basic rendering" do
    test "renders without errors" do
      html = render_file_card()
      assert html =~ "<div"
    end

    test "renders filename" do
      html = render_file_card(%{filename: "presentation.pptx"})
      assert html =~ "presentation.pptx"
    end

    test "renders size when provided" do
      html = render_file_card(%{size: "2.4 MB"})
      assert html =~ "2.4 MB"
    end

    test "does not render size when nil" do
      html = render_file_card(%{size: nil})
      refute html =~ "MB"
    end

    test "renders uploaded_at when provided" do
      html = render_file_card(%{uploaded_at: "Jan 15, 2026"})
      assert html =~ "Jan 15, 2026"
    end

    test "does not render uploaded_at when nil" do
      html = render_file_card(%{uploaded_at: nil})
      refute html =~ "Jan 15"
    end

    test "renders extension badge in uppercase" do
      html = render_file_card(%{filename: "report.xlsx"})
      assert html =~ "XLSX"
    end
  end

  # ---------------------------------------------------------------------------
  # Variants
  # ---------------------------------------------------------------------------

  describe "file_card/1 :default variant" do
    test "renders with default variant classes" do
      html = render_file_card(%{variant: :default})
      assert html =~ "<div"
    end

    test "default variant has flex-col layout" do
      html = render_file_card(%{variant: :default})
      assert html =~ "flex-col"
    end
  end

  describe "file_card/1 :compact variant" do
    test "renders with compact variant" do
      html = render_file_card(%{variant: :compact})
      assert html =~ "<div"
    end

    test "compact variant has items-center layout" do
      html = render_file_card(%{variant: :compact})
      assert html =~ "items-center"
    end

    test "compact variant still shows filename" do
      html = render_file_card(%{filename: "notes.doc", variant: :compact})
      assert html =~ "notes.doc"
    end
  end

  # ---------------------------------------------------------------------------
  # File type detection — icon and colors
  # ---------------------------------------------------------------------------

  describe "file_card/1 PDF file type" do
    test "PDF file shows bg-red-100 color" do
      html = render_file_card(%{filename: "report.pdf"})
      assert html =~ "bg-red-100"
    end

    test "PDF file shows file-text icon" do
      html = render_file_card(%{filename: "report.pdf"})
      assert html =~ "icon-file-text"
    end

    test "PDF extension badge shows PDF" do
      html = render_file_card(%{filename: "report.pdf"})
      assert html =~ "PDF"
    end
  end

  describe "file_card/1 DOC file type" do
    test ".doc file shows bg-blue-100 color" do
      html = render_file_card(%{filename: "letter.doc"})
      assert html =~ "bg-blue-100"
    end

    test ".docx file shows bg-blue-100 color" do
      html = render_file_card(%{filename: "letter.docx"})
      assert html =~ "bg-blue-100"
    end

    test "DOC file shows file-text icon" do
      html = render_file_card(%{filename: "letter.doc"})
      assert html =~ "icon-file-text"
    end
  end

  describe "file_card/1 image file type" do
    test ".jpg file shows bg-violet-100 color" do
      html = render_file_card(%{filename: "photo.jpg"})
      assert html =~ "bg-violet-100"
    end

    test ".png file shows bg-violet-100 color" do
      html = render_file_card(%{filename: "logo.png"})
      assert html =~ "bg-violet-100"
    end

    test ".webp file shows bg-violet-100 color" do
      html = render_file_card(%{filename: "banner.webp"})
      assert html =~ "bg-violet-100"
    end

    test "image file shows image icon" do
      html = render_file_card(%{filename: "photo.jpg"})
      assert html =~ "icon-image"
    end
  end

  describe "file_card/1 archive file type" do
    test ".zip file shows bg-yellow-100 color" do
      html = render_file_card(%{filename: "backup.zip"})
      assert html =~ "bg-yellow-100"
    end

    test ".tar file shows bg-yellow-100 color" do
      html = render_file_card(%{filename: "source.tar"})
      assert html =~ "bg-yellow-100"
    end

    test "archive file shows archive icon" do
      html = render_file_card(%{filename: "backup.zip"})
      assert html =~ "icon-archive"
    end
  end

  describe "file_card/1 XLS file type" do
    test ".xlsx file shows bg-emerald-100 color" do
      html = render_file_card(%{filename: "data.xlsx"})
      assert html =~ "bg-emerald-100"
    end

    test "XLS file shows table icon" do
      html = render_file_card(%{filename: "data.xls"})
      assert html =~ "icon-table"
    end
  end

  describe "file_card/1 media file type" do
    test ".mp4 file shows bg-pink-100 color" do
      html = render_file_card(%{filename: "video.mp4"})
      assert html =~ "bg-pink-100"
    end

    test ".mp3 file shows bg-pink-100 color" do
      html = render_file_card(%{filename: "audio.mp3"})
      assert html =~ "bg-pink-100"
    end

    test "media file shows play-circle icon" do
      html = render_file_card(%{filename: "video.mp4"})
      assert html =~ "icon-play-circle"
    end
  end

  describe "file_card/1 default/unknown file type" do
    test "unknown extension uses bg-muted" do
      html = render_file_card(%{filename: "data.xyz"})
      assert html =~ "bg-muted"
    end

    test "unknown extension shows file icon" do
      html = render_file_card(%{filename: "data.xyz"})
      assert html =~ "icon-file"
    end
  end

  # ---------------------------------------------------------------------------
  # href download link
  # ---------------------------------------------------------------------------

  describe "file_card/1 href download link" do
    test "renders anchor with href when provided" do
      html = render_file_card(%{href: "/files/report.pdf"})
      assert html =~ ~s(href="/files/report.pdf")
    end

    test "anchor has download attribute" do
      html = render_file_card(%{href: "/files/report.pdf"})
      assert html =~ "download"
    end

    test "anchor has hover:underline class" do
      html = render_file_card(%{href: "/files/report.pdf"})
      assert html =~ "hover:underline"
    end

    test "does not render anchor when href is nil" do
      html = render_file_card(%{href: nil})
      refute html =~ "download"
    end
  end

  # ---------------------------------------------------------------------------
  # Actions slot
  # ---------------------------------------------------------------------------

  describe "file_card/1 :actions slot" do
    test "renders actions slot content" do
      html = render_component(&H.render_with_actions/1, %{})
      assert html =~ "Download"
      assert html =~ "download-btn"
    end
  end

  # ---------------------------------------------------------------------------
  # Class forwarding
  # ---------------------------------------------------------------------------

  describe "file_card/1 class forwarding" do
    test "accepts custom class" do
      html = render_file_card(%{class: "my-file-card"})
      assert html =~ "my-file-card"
    end
  end
end
