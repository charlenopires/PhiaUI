defmodule PhiaUi.Components.ImageUploadTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  # ---------------------------------------------------------------------------
  # Test helpers
  # ---------------------------------------------------------------------------

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.ImageUpload

    attr(:upload, :any)
    attr(:label, :string, default: nil)
    attr(:class, :string, default: nil)

    def render_image_upload(assigns) do
      ~H"""
      <.image_upload
        upload={@upload}
        label={@label}
        class={@class}
      />
      """
    end

    def render_image_upload_default_label(assigns) do
      ~H"""
      <.image_upload upload={@upload} />
      """
    end
  end

  defp build_upload(attrs \\ []) do
    %Phoenix.LiveView.UploadConfig{
      ref: Keyword.get(attrs, :ref, "phx-abc123"),
      name: Keyword.get(attrs, :name, :cover_image),
      entries: Keyword.get(attrs, :entries, []),
      errors: Keyword.get(attrs, :errors, []),
      max_entries: 1,
      max_file_size: 8_000_000,
      accept: :any,
      allowed?: true,
      auto_upload?: false,
      external: nil,
      chunk_size: 64_000,
      chunk_timeout: 10_000,
      cid: nil,
      progress_event: nil,
      writer: nil,
      entry_refs_to_metas: %{},
      client_key: nil,
      entry_refs_to_pids: %{},
      acceptable_types: :any,
      acceptable_exts: :any
    }
  end

  defp build_entry(attrs \\ []) do
    %Phoenix.LiveView.UploadEntry{
      ref: Keyword.get(attrs, :ref, "phx-e0"),
      uuid: Keyword.get(attrs, :uuid, "some-uuid"),
      valid?: Keyword.get(attrs, :valid?, true),
      done?: Keyword.get(attrs, :done?, false),
      cancelled?: Keyword.get(attrs, :cancelled?, false),
      preflighted?: false,
      upload_config: :cover_image,
      upload_ref: "phx-abc123",
      client_name: Keyword.get(attrs, :client_name, "photo.jpg"),
      client_size: Keyword.get(attrs, :client_size, 12_345),
      client_type: Keyword.get(attrs, :client_type, "image/jpeg"),
      client_last_modified: nil,
      client_relative_path: nil,
      client_meta: nil,
      progress: Keyword.get(attrs, :progress, 0)
    }
  end

  # ---------------------------------------------------------------------------
  # Criterion 1: attr :upload (:any, required)
  # ---------------------------------------------------------------------------

  describe "image_upload/1 - :upload attr" do
    test "renders without error with a valid UploadConfig" do
      upload = build_upload()
      html = render_component(&H.render_image_upload/1, %{upload: upload})
      assert html =~ "<"
    end

    test "uses upload.ref in label for attribute" do
      upload = build_upload(ref: "phx-xyz999")
      html = render_component(&H.render_image_upload/1, %{upload: upload})
      assert html =~ ~s(for="phx-xyz999")
    end
  end

  # ---------------------------------------------------------------------------
  # Criterion 2: attr :label, default: "Imagem de capa"
  # ---------------------------------------------------------------------------

  describe "image_upload/1 - :label attr" do
    test "renders default label 'Imagem de capa' when :label is nil" do
      upload = build_upload()
      html = render_component(&H.render_image_upload_default_label/1, %{upload: upload})
      assert html =~ "Imagem de capa"
    end

    test "renders custom label when :label is set" do
      upload = build_upload()

      html =
        render_component(&H.render_image_upload/1, %{upload: upload, label: "Upload de foto"})

      assert html =~ "Upload de foto"
    end
  end

  # ---------------------------------------------------------------------------
  # Criterion 3: attr :class, default: nil
  # ---------------------------------------------------------------------------

  describe "image_upload/1 - :class attr" do
    test "applies additional class when :class is set" do
      upload = build_upload()
      html = render_component(&H.render_image_upload/1, %{upload: upload, class: "my-custom"})
      assert html =~ "my-custom"
    end
  end

  # ---------------------------------------------------------------------------
  # Criterion 4: zona de drop com <label for=ref> + ícone upload-cloud
  # ---------------------------------------------------------------------------

  describe "image_upload/1 - drop zone" do
    test "renders a <label> element" do
      upload = build_upload()
      html = render_component(&H.render_image_upload/1, %{upload: upload})
      assert html =~ "<label"
    end

    test "label for links to upload.ref" do
      upload = build_upload(ref: "phx-abc123")
      html = render_component(&H.render_image_upload/1, %{upload: upload})
      assert html =~ ~s(for="phx-abc123")
    end

    test "renders upload-cloud icon in drop zone" do
      upload = build_upload()
      html = render_component(&H.render_image_upload/1, %{upload: upload})
      assert html =~ "upload-cloud"
    end
  end

  # ---------------------------------------------------------------------------
  # Criterion 5: live_file_input com sr-only
  # ---------------------------------------------------------------------------

  describe "image_upload/1 - live_file_input" do
    test "renders an input element" do
      upload = build_upload()
      html = render_component(&H.render_image_upload/1, %{upload: upload})
      assert html =~ "<input"
    end

    test "input has sr-only class" do
      upload = build_upload()
      html = render_component(&H.render_image_upload/1, %{upload: upload})
      assert html =~ "sr-only"
    end
  end

  # ---------------------------------------------------------------------------
  # Criterion 6: preview por entrada — nome, progress, botão remover
  # ---------------------------------------------------------------------------

  describe "image_upload/1 - entry previews" do
    test "renders filename for each entry" do
      entry = build_entry(client_name: "landscape.jpg")
      upload = build_upload(entries: [entry])
      html = render_component(&H.render_image_upload/1, %{upload: upload})
      assert html =~ "landscape.jpg"
    end

    test "renders progress element with entry.progress as value" do
      entry = build_entry(progress: 65)
      upload = build_upload(entries: [entry])
      html = render_component(&H.render_image_upload/1, %{upload: upload})
      assert html =~ ~s(<progress)
      assert html =~ ~s(value="65")
      assert html =~ ~s(max="100")
    end

    test "renders cancel button with phx-click=cancel_upload" do
      entry = build_entry(ref: "phx-e0")
      upload = build_upload(entries: [entry])
      html = render_component(&H.render_image_upload/1, %{upload: upload})
      assert html =~ ~s(phx-click="cancel_upload")
    end

    test "cancel button has phx-value-ref matching entry.ref" do
      entry = build_entry(ref: "phx-e0")
      upload = build_upload(entries: [entry])
      html = render_component(&H.render_image_upload/1, %{upload: upload})
      assert html =~ ~s(phx-value-ref="phx-e0")
    end

    test "renders multiple entries" do
      entries = [
        build_entry(ref: "phx-e0", client_name: "photo1.jpg"),
        build_entry(ref: "phx-e1", client_name: "photo2.jpg")
      ]

      upload = build_upload(entries: entries)
      html = render_component(&H.render_image_upload/1, %{upload: upload})
      assert html =~ "photo1.jpg"
      assert html =~ "photo2.jpg"
      assert html =~ "phx-e0"
      assert html =~ "phx-e1"
    end
  end

  # ---------------------------------------------------------------------------
  # Criterion 7: erros por entrada
  # ---------------------------------------------------------------------------

  describe "image_upload/1 - entry errors" do
    test "renders 'Arquivo muito grande' for :too_large error" do
      entry = build_entry(ref: "phx-e0")
      upload = build_upload(entries: [entry], errors: [{"phx-e0", :too_large}])
      html = render_component(&H.render_image_upload/1, %{upload: upload})
      assert html =~ "Arquivo muito grande"
    end

    test "renders 'Formato não suportado' for :not_accepted error" do
      entry = build_entry(ref: "phx-e0")
      upload = build_upload(entries: [entry], errors: [{"phx-e0", :not_accepted}])
      html = render_component(&H.render_image_upload/1, %{upload: upload})
      assert html =~ "Formato não suportado"
    end

    test "renders 'Limite de arquivos atingido' for :too_many_files error" do
      entry = build_entry(ref: "phx-e0")
      upload = build_upload(entries: [entry], errors: [{"phx-e0", :too_many_files}])
      html = render_component(&H.render_image_upload/1, %{upload: upload})
      assert html =~ "Limite de arquivos atingido"
    end

    test "renders no error text when entry has no errors" do
      entry = build_entry(ref: "phx-e0")
      upload = build_upload(entries: [entry], errors: [])
      html = render_component(&H.render_image_upload/1, %{upload: upload})
      refute html =~ "Arquivo muito grande"
      refute html =~ "Formato não suportado"
      refute html =~ "Limite de arquivos atingido"
    end
  end

  # ---------------------------------------------------------------------------
  # Criterion 8: estado vazio — apenas zona de drop, sem lista de entradas
  # ---------------------------------------------------------------------------

  describe "image_upload/1 - estado vazio" do
    test "renders drop zone when entries is empty" do
      upload = build_upload(entries: [])
      html = render_component(&H.render_image_upload/1, %{upload: upload})
      assert html =~ "<label"
      assert html =~ "upload-cloud"
    end

    test "does not render progress when entries is empty" do
      upload = build_upload(entries: [])
      html = render_component(&H.render_image_upload/1, %{upload: upload})
      refute html =~ "<progress"
    end

    test "does not render cancel button when entries is empty" do
      upload = build_upload(entries: [])
      html = render_component(&H.render_image_upload/1, %{upload: upload})
      refute html =~ "cancel_upload"
    end
  end

  # ---------------------------------------------------------------------------
  # Criterion 10: estilo — border-dashed, rounded-lg, bg-muted/50, hover:bg-muted
  # ---------------------------------------------------------------------------

  describe "image_upload/1 - estilo da zona de drop" do
    test "applies border-dashed class" do
      upload = build_upload()
      html = render_component(&H.render_image_upload/1, %{upload: upload})
      assert html =~ "border-dashed"
    end

    test "applies rounded-lg class" do
      upload = build_upload()
      html = render_component(&H.render_image_upload/1, %{upload: upload})
      assert html =~ "rounded-lg"
    end

    test "applies bg-muted/50 class" do
      upload = build_upload()
      html = render_component(&H.render_image_upload/1, %{upload: upload})
      assert html =~ "bg-muted"
    end
  end

  # ---------------------------------------------------------------------------
  # Smoke test — uso esperado completo
  # ---------------------------------------------------------------------------

  describe "image_upload/1 - smoke test" do
    test "renders completo com entries e erros" do
      entry1 = build_entry(ref: "phx-e0", client_name: "capa.jpg", progress: 80)
      entry2 = build_entry(ref: "phx-e1", client_name: "logo.png", progress: 30)

      upload =
        build_upload(
          ref: "phx-abc123",
          entries: [entry1, entry2],
          errors: [{"phx-e1", :too_large}]
        )

      html =
        render_component(&H.render_image_upload/1, %{
          upload: upload,
          label: "Imagem de capa",
          class: "mt-4"
        })

      assert html =~ ~s(for="phx-abc123")
      assert html =~ "Imagem de capa"
      assert html =~ "upload-cloud"
      assert html =~ "sr-only"
      assert html =~ "capa.jpg"
      assert html =~ "logo.png"
      assert html =~ ~s(value="80")
      assert html =~ ~s(value="30")
      assert html =~ "phx-e0"
      assert html =~ "phx-e1"
      assert html =~ "cancel_upload"
      assert html =~ "Arquivo muito grande"
      assert html =~ "mt-4"
    end
  end
end
