defmodule PhiaUi.Components.UploadButtonTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.UploadButton

    def render_default(assigns) do
      ~H"""
      <.upload_button upload={%{ref: "up-ref", entries: [], errors: []}} />
      """
    end

    def render_custom_label(assigns) do
      ~H"""
      <.upload_button upload={%{ref: "up-ref", entries: [], errors: []}} label="Import CSV" />
      """
    end

    def render_outline(assigns) do
      ~H"""
      <.upload_button upload={%{ref: "up-ref", entries: [], errors: []}} variant="outline" />
      """
    end

    def render_ghost(assigns) do
      ~H"""
      <.upload_button upload={%{ref: "up-ref", entries: [], errors: []}} variant="ghost" />
      """
    end

    def render_sm(assigns) do
      ~H"""
      <.upload_button upload={%{ref: "up-ref", entries: [], errors: []}} size="sm" />
      """
    end

    def render_with_entries(assigns) do
      ~H"""
      <.upload_button upload={%{ref: "up-ref", entries: [%{client_name: "data.csv", progress: 50, ref: "e1", errors: []}], errors: []}} on_cancel="cancel" />
      """
    end

    def render_no_list(assigns) do
      ~H"""
      <.upload_button upload={%{ref: "up-ref", entries: [%{client_name: "file.txt", progress: 20, ref: "e2", errors: []}], errors: []}} show_list={false} />
      """
    end

    def render_with_error(assigns) do
      ~H"""
      <.upload_button upload={%{ref: "up-ref", entries: [], errors: [:too_many_files]}} />
      """
    end
  end

  describe "upload_button/1 rendering" do
    test "renders a label element" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "<label"
    end

    test "renders default label text" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "Upload file"
    end

    test "renders custom label" do
      html = render_component(&H.render_custom_label/1, %{})
      assert html =~ "Import CSV"
    end

    test "renders upload icon" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "polyline"
    end

    test "outline variant has border class" do
      html = render_component(&H.render_outline/1, %{})
      assert html =~ "border-input"
    end

    test "ghost variant has no border" do
      html = render_component(&H.render_ghost/1, %{})
      refute html =~ "border-input"
    end

    test "sm size applies h-8" do
      html = render_component(&H.render_sm/1, %{})
      assert html =~ "h-8"
    end

    test "renders entry list when entries present" do
      html = render_component(&H.render_with_entries/1, %{})
      assert html =~ "data.csv"
      assert html =~ "50%"
    end

    test "does not render list when show_list is false" do
      html = render_component(&H.render_no_list/1, %{})
      refute html =~ "file.txt"
    end

    test "renders upload-level error" do
      html = render_component(&H.render_with_error/1, %{})
      assert html =~ "Too many files"
    end
  end
end
