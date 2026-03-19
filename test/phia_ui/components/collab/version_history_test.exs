defmodule PhiaUi.Components.Collab.VersionHistoryTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  # ── Test Helper Module ──────────────────────────────────────────────────

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.Collab.VersionHistory

    # -- version_summary --

    def render_version_summary(assigns) do
      ~H"<.version_summary id={@id} version={@version} />"
    end

    def render_version_summary_active(assigns) do
      ~H"<.version_summary id={@id} version={@version} active={true} />"
    end

    # -- version_list --

    def render_version_list(assigns) do
      ~H"<.version_list id={@id} versions={@versions} />"
    end

    def render_version_list_active(assigns) do
      ~H"<.version_list id={@id} versions={@versions} active_version_id={@active_version_id} />"
    end

    def render_version_list_empty(assigns) do
      ~H"<.version_list id={@id} versions={[]} />"
    end

    # -- version_diff --

    def render_version_diff(assigns) do
      ~H"<.version_diff id={@id} changes={@changes} />"
    end

    def render_version_diff_side(assigns) do
      ~H"<.version_diff id={@id} changes={@changes} mode={:side_by_side} />"
    end

    def render_version_diff_empty(assigns) do
      ~H"<.version_diff id={@id} changes={[]} />"
    end

    # -- version_restore_dialog --

    def render_restore_dialog_open(assigns) do
      ~H"<.version_restore_dialog id={@id} version={@version} open={true} />"
    end

    def render_restore_dialog_closed(assigns) do
      ~H"<.version_restore_dialog id={@id} version={@version} open={false} />"
    end

    # -- version_panel --

    def render_version_panel(assigns) do
      ~H"<.version_panel id={@id} versions={@versions} />"
    end

    def render_version_panel_with_changes(assigns) do
      ~H"<.version_panel id={@id} versions={@versions} active_version_id={@active_version_id} changes={@changes} />"
    end

    # -- version_badge --

    def render_version_badge(assigns) do
      ~H"<.version_badge id={@id} last_saved_at={@last_saved_at} has_unsaved={@has_unsaved} />"
    end

    def render_version_badge_nil(assigns) do
      ~H"<.version_badge id={@id} />"
    end
  end

  # ── Test Data ──────────────────────────────────────────────────────────

  @version_1 %{
    id: "v-1",
    author_name: "Alice Adams",
    author_color: "#3B82F6",
    author_avatar_url: nil,
    created_at: ~U[2026-03-19 10:00:00Z],
    word_count: 1250,
    word_count_delta: "+42",
    label: "Auto-save"
  }

  @version_2 %{
    id: "v-2",
    author_name: "Bob Baker",
    author_color: "#10B981",
    author_avatar_url: "/avatars/bob.jpg",
    created_at: ~U[2026-03-19 12:30:00Z],
    word_count: 1300,
    word_count_delta: "+50",
    label: nil
  }

  @version_3 %{
    id: "v-3",
    author_name: "Carol Chen",
    author_color: "#8B5CF6",
    author_avatar_url: nil,
    created_at: ~U[2026-03-18 09:00:00Z],
    word_count: 1200,
    word_count_delta: "-10",
    label: "Manual save"
  }

  @added_change %{type: :added, path: [1], content: %{"type" => "paragraph", "text" => "New paragraph"}}
  @removed_change %{type: :removed, path: [0], content: %{"type" => "paragraph", "text" => "Old paragraph"}}
  @modified_change %{type: :modified, path: [0], old: %{"type" => "paragraph", "text" => "Before"}, new: %{"type" => "paragraph", "text" => "After"}}

  # ── version_summary/1 ─────────────────────────────────────────────────

  describe "version_summary/1" do
    test "renders version with author info" do
      html = render_component(&H.render_version_summary/1, %{
        id: "vs-test",
        version: @version_1
      })

      assert html =~ "vs-test"
      assert html =~ "Alice Adams"
      assert html =~ "Auto-save"
      assert html =~ "+42"
    end

    test "renders author initials when no avatar" do
      html = render_component(&H.render_version_summary/1, %{
        id: "vs-initials",
        version: @version_1
      })

      assert html =~ "AA"
    end

    test "renders author avatar when provided" do
      html = render_component(&H.render_version_summary/1, %{
        id: "vs-avatar",
        version: @version_2
      })

      assert html =~ "/avatars/bob.jpg"
    end

    test "renders active state" do
      html = render_component(&H.render_version_summary_active/1, %{
        id: "vs-active",
        version: @version_1
      })

      assert html =~ "bg-accent"
      assert html =~ ~s(aria-selected="true")
    end

    test "renders word count delta with appropriate styling" do
      html = render_component(&H.render_version_summary/1, %{
        id: "vs-delta-pos",
        version: @version_1
      })

      assert html =~ "+42"
      assert html =~ "green"
    end

    test "renders negative delta with red styling" do
      html = render_component(&H.render_version_summary/1, %{
        id: "vs-delta-neg",
        version: @version_3
      })

      assert html =~ "-10"
      assert html =~ "red"
    end

    test "renders timeline dot with author color" do
      html = render_component(&H.render_version_summary/1, %{
        id: "vs-dot",
        version: @version_1
      })

      assert html =~ "#3B82F6"
    end
  end

  # ── version_list/1 ────────────────────────────────────────────────────

  describe "version_list/1" do
    test "renders grouped versions by day" do
      html = render_component(&H.render_version_list/1, %{
        id: "vl-test",
        versions: [@version_1, @version_2, @version_3]
      })

      assert html =~ "Alice Adams"
      assert html =~ "Bob Baker"
      assert html =~ "Carol Chen"
      assert html =~ "listbox"
    end

    test "renders day group headers" do
      html = render_component(&H.render_version_list/1, %{
        id: "vl-days",
        versions: [@version_1, @version_3]
      })

      # version_1 is March 19, version_3 is March 18
      # Day headers will show date groupings
      assert html =~ "sticky"
    end

    test "renders empty state" do
      html = render_component(&H.render_version_list_empty/1, %{id: "vl-empty"})
      assert html =~ "No versions yet"
    end

    test "highlights active version" do
      html = render_component(&H.render_version_list_active/1, %{
        id: "vl-active",
        versions: [@version_1, @version_2],
        active_version_id: "v-1"
      })

      assert html =~ ~s(aria-selected="true")
    end
  end

  # ── version_diff/1 ────────────────────────────────────────────────────

  describe "version_diff/1" do
    test "renders inline diff with additions" do
      html = render_component(&H.render_version_diff/1, %{
        id: "vd-add",
        changes: [@added_change]
      })

      assert html =~ "New paragraph"
      assert html =~ "+"
      assert html =~ "1 added"
      assert html =~ "green"
    end

    test "renders inline diff with removals" do
      html = render_component(&H.render_version_diff/1, %{
        id: "vd-remove",
        changes: [@removed_change]
      })

      assert html =~ "Old paragraph"
      assert html =~ "-"
      assert html =~ "red"
    end

    test "renders inline diff with modifications" do
      html = render_component(&H.render_version_diff/1, %{
        id: "vd-modify",
        changes: [@modified_change]
      })

      assert html =~ "Before"
      assert html =~ "After"
      assert html =~ "~"
    end

    test "renders side-by-side mode" do
      html = render_component(&H.render_version_diff_side/1, %{
        id: "vd-side",
        changes: [@modified_change]
      })

      assert html =~ "Before"
      assert html =~ "After"
      assert html =~ "grid-cols-2"
    end

    test "renders empty diff message" do
      html = render_component(&H.render_version_diff_empty/1, %{id: "vd-empty"})
      assert html =~ "No changes between versions"
    end

    test "renders mixed changes summary" do
      html = render_component(&H.render_version_diff/1, %{
        id: "vd-mixed",
        changes: [@added_change, @removed_change, @modified_change]
      })

      assert html =~ "1 added, 1 removed, 1 modified"
    end
  end

  # ── version_restore_dialog/1 ──────────────────────────────────────────

  describe "version_restore_dialog/1" do
    test "renders open dialog with version info" do
      html = render_component(&H.render_restore_dialog_open/1, %{
        id: "vrd-test",
        version: @version_1
      })

      assert html =~ "Restore this version?"
      assert html =~ "Alice Adams"
      assert html =~ "Cancel"
      assert html =~ "Restore version"
      assert html =~ "dialog"
    end

    test "does not render when closed" do
      html = render_component(&H.render_restore_dialog_closed/1, %{
        id: "vrd-closed",
        version: @version_1
      })

      refute html =~ "Restore this version?"
    end

    test "renders confirm and cancel buttons with event names" do
      html = render_component(&H.render_restore_dialog_open/1, %{
        id: "vrd-events",
        version: @version_1
      })

      assert html =~ "collab:version:restore"
      assert html =~ "collab:version:restore:cancel"
    end

    test "renders backup notice" do
      html = render_component(&H.render_restore_dialog_open/1, %{
        id: "vrd-backup",
        version: @version_1
      })

      assert html =~ "backup"
    end
  end

  # ── version_panel/1 ───────────────────────────────────────────────────

  describe "version_panel/1" do
    test "renders panel with header and version list" do
      html = render_component(&H.render_version_panel/1, %{
        id: "vp-test",
        versions: [@version_1, @version_2]
      })

      assert html =~ "Version History"
      assert html =~ "Alice Adams"
      assert html =~ "Bob Baker"
      assert html =~ "Close version history"
    end

    test "renders close button" do
      html = render_component(&H.render_version_panel/1, %{
        id: "vp-close",
        versions: []
      })

      assert html =~ "collab:version:panel:close"
    end

    test "renders diff view when changes present" do
      html = render_component(&H.render_version_panel_with_changes/1, %{
        id: "vp-diff",
        versions: [@version_1],
        active_version_id: "v-1",
        changes: [@added_change]
      })

      assert html =~ "New paragraph"
      assert html =~ "Changes"
    end

    test "hides diff view when no changes" do
      html = render_component(&H.render_version_panel/1, %{
        id: "vp-no-diff",
        versions: [@version_1]
      })

      refute html =~ "No changes between versions"
    end
  end

  # ── version_badge/1 ───────────────────────────────────────────────────

  describe "version_badge/1" do
    test "renders saved state" do
      html = render_component(&H.render_version_badge/1, %{
        id: "vb-saved",
        last_saved_at: ~U[2026-03-19 10:00:00Z],
        has_unsaved: false
      })

      assert html =~ "Saved"
      assert html =~ "bg-green-500"
      assert html =~ "status"
    end

    test "renders unsaved state" do
      html = render_component(&H.render_version_badge/1, %{
        id: "vb-unsaved",
        last_saved_at: ~U[2026-03-19 10:00:00Z],
        has_unsaved: true
      })

      assert html =~ "Unsaved changes"
      assert html =~ "amber"
      assert html =~ "animate-pulse"
    end

    test "renders not saved yet when no timestamp" do
      html = render_component(&H.render_version_badge/1, %{
        id: "vb-nil",
        last_saved_at: nil,
        has_unsaved: false
      })

      assert html =~ "Not saved yet"
    end

    test "renders with default attrs" do
      html = render_component(&H.render_version_badge_nil/1, %{id: "vb-defaults"})
      assert html =~ "Not saved yet"
    end
  end
end
