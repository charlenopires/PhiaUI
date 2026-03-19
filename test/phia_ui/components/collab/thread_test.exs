defmodule PhiaUi.Components.Collab.ThreadTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  # ---------------------------------------------------------------------------
  # Test helpers — all render functions live inside module H
  # ---------------------------------------------------------------------------

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.Collab.Thread

    # collab_thread
    def render_collab_thread(assigns) do
      thread = assigns[:thread] || default_thread()

      assigns =
        assigns
        |> Map.put_new(:id, "thread-1")
        |> Map.put(:thread, thread)
        |> Map.put_new(:current_user_id, nil)
        |> Map.put_new(:on_resolve, "collab:thread:resolve")
        |> Map.put_new(:on_reopen, "collab:thread:reopen")
        |> Map.put_new(:class, nil)

      ~H"""
      <.collab_thread
        id={@id}
        thread={@thread}
        current_user_id={@current_user_id}
        on_resolve={@on_resolve}
        on_reopen={@on_reopen}
        class={@class}
      />
      """
    end

    # collab_thread_header
    def render_collab_thread_header(assigns) do
      assigns =
        assigns
        |> Map.put_new(:id, "header-1")
        |> Map.put_new(:thread_id, "t1")
        |> Map.put_new(:resolved, false)
        |> Map.put_new(:reply_count, 0)
        |> Map.put_new(:on_resolve, "collab:thread:resolve")
        |> Map.put_new(:on_reopen, "collab:thread:reopen")
        |> Map.put_new(:on_close, "collab:thread:close")
        |> Map.put_new(:class, nil)

      ~H"""
      <.collab_thread_header
        id={@id}
        thread_id={@thread_id}
        resolved={@resolved}
        reply_count={@reply_count}
        on_resolve={@on_resolve}
        on_reopen={@on_reopen}
        on_close={@on_close}
        class={@class}
      />
      """
    end

    # collab_thread_list
    def render_collab_thread_list(assigns) do
      assigns =
        assigns
        |> Map.put_new(:id, "list-1")
        |> Map.put_new(:threads, [])
        |> Map.put_new(:current_user_id, nil)
        |> Map.put_new(:sort_by, :activity)
        |> Map.put_new(:show_resolved, true)
        |> Map.put_new(:class, nil)

      ~H"""
      <.collab_thread_list
        id={@id}
        threads={@threads}
        current_user_id={@current_user_id}
        sort_by={@sort_by}
        show_resolved={@show_resolved}
        class={@class}
      />
      """
    end

    # collab_floating_thread
    def render_collab_floating_thread(assigns) do
      thread = assigns[:thread] || default_thread()

      assigns =
        assigns
        |> Map.put_new(:id, "float-1")
        |> Map.put(:thread, thread)
        |> Map.put_new(:x, 100)
        |> Map.put_new(:y, 200)
        |> Map.put_new(:current_user_id, nil)
        |> Map.put_new(:class, nil)

      ~H"""
      <.collab_floating_thread
        id={@id}
        thread={@thread}
        x={@x}
        y={@y}
        current_user_id={@current_user_id}
        class={@class}
      />
      """
    end

    # collab_thread_resolved
    def render_collab_thread_resolved(assigns) do
      thread =
        assigns[:thread] ||
          %{
            id: "t-resolved",
            resolved: true,
            created_at: DateTime.utc_now(),
            comments: [
              %{
                id: "c1",
                user_id: "user-1",
                user_name: "Alice",
                user_color: nil,
                user_avatar_url: nil,
                body: "This was resolved",
                created_at: DateTime.utc_now(),
                edited_at: nil,
                reactions: [],
                thread_id: "t-resolved"
              }
            ]
          }

      assigns =
        assigns
        |> Map.put_new(:id, "resolved-1")
        |> Map.put(:thread, thread)
        |> Map.put_new(:on_reopen, "collab:thread:reopen")
        |> Map.put_new(:class, nil)

      ~H"""
      <.collab_thread_resolved
        id={@id}
        thread={@thread}
        on_reopen={@on_reopen}
        class={@class}
      />
      """
    end

    defp default_thread do
      now = DateTime.utc_now()

      %{
        id: "t1",
        resolved: false,
        created_at: now,
        comments: [
          %{
            id: "c1",
            user_id: "user-1",
            user_name: "Alice",
            user_color: nil,
            user_avatar_url: nil,
            body: "Root comment",
            created_at: now,
            edited_at: nil,
            reactions: [],
            thread_id: "t1"
          },
          %{
            id: "c2",
            user_id: "user-2",
            user_name: "Bob",
            user_color: nil,
            user_avatar_url: nil,
            body: "Reply comment",
            created_at: DateTime.add(now, 60, :second),
            edited_at: nil,
            reactions: [],
            thread_id: "t1"
          }
        ]
      }
    end
  end

  # ===========================================================================
  # collab_thread/1
  # ===========================================================================

  describe "collab_thread/1" do
    test "renders thread with comments" do
      html = render_component(&H.render_collab_thread/1, %{})
      assert html =~ "Root comment"
      assert html =~ "Reply comment"
    end

    test "renders thread header" do
      html = render_component(&H.render_collab_thread/1, %{})
      assert html =~ "1 reply"
    end

    test "sets data-thread-id" do
      html = render_component(&H.render_collab_thread/1, %{})
      assert html =~ ~s(data-thread-id="t1")
    end

    test "renders role=article" do
      html = render_component(&H.render_collab_thread/1, %{})
      assert html =~ ~s(role="article")
    end

    test "applies custom class" do
      html = render_component(&H.render_collab_thread/1, %{class: "my-thread"})
      assert html =~ "my-thread"
    end
  end

  # ===========================================================================
  # collab_thread_header/1
  # ===========================================================================

  describe "collab_thread_header/1" do
    test "renders reply count" do
      html = render_component(&H.render_collab_thread_header/1, %{reply_count: 5})
      assert html =~ "5 replies"
    end

    test "renders singular reply" do
      html = render_component(&H.render_collab_thread_header/1, %{reply_count: 1})
      assert html =~ "1 reply"
    end

    test "renders Resolve button when not resolved" do
      html = render_component(&H.render_collab_thread_header/1, %{resolved: false})
      assert html =~ "Resolve"
      refute html =~ "Reopen"
    end

    test "renders Reopen button when resolved" do
      html = render_component(&H.render_collab_thread_header/1, %{resolved: true})
      assert html =~ "Reopen"
      assert html =~ "Resolved"
    end

    test "renders close button" do
      html = render_component(&H.render_collab_thread_header/1, %{})
      assert html =~ "Close thread"
    end

    test "renders data-thread-drag-handle" do
      html = render_component(&H.render_collab_thread_header/1, %{})
      assert html =~ "data-thread-drag-handle"
    end
  end

  # ===========================================================================
  # collab_thread_list/1
  # ===========================================================================

  describe "collab_thread_list/1" do
    test "renders empty state" do
      html = render_component(&H.render_collab_thread_list/1, %{threads: []})
      assert html =~ "No threads yet"
    end

    test "renders threads" do
      now = DateTime.utc_now()

      threads = [
        %{
          id: "t1",
          resolved: false,
          created_at: now,
          comments: [
            %{
              id: "c1",
              user_id: "u1",
              user_name: "Alice",
              body: "First thread",
              created_at: now
            }
          ]
        }
      ]

      html = render_component(&H.render_collab_thread_list/1, %{threads: threads})
      assert html =~ "First thread"
    end

    test "renders role=list" do
      html = render_component(&H.render_collab_thread_list/1, %{})
      assert html =~ ~s(role="list")
    end

    test "hides resolved threads when show_resolved is false" do
      now = DateTime.utc_now()

      threads = [
        %{
          id: "t1",
          resolved: false,
          created_at: now,
          comments: [%{id: "c1", user_id: "u1", body: "Open thread", created_at: now}]
        },
        %{
          id: "t2",
          resolved: true,
          created_at: now,
          comments: [%{id: "c2", user_id: "u2", body: "Closed thread", created_at: now}]
        }
      ]

      html =
        render_component(&H.render_collab_thread_list/1, %{
          threads: threads,
          show_resolved: false
        })

      assert html =~ "Open thread"
      refute html =~ "Closed thread"
    end

    test "shows Resolved label for resolved threads" do
      now = DateTime.utc_now()

      threads = [
        %{
          id: "t1",
          resolved: true,
          created_at: now,
          comments: [%{id: "c1", user_id: "u1", body: "Done", created_at: now}]
        }
      ]

      html = render_component(&H.render_collab_thread_list/1, %{threads: threads})
      assert html =~ "Resolved"
    end
  end

  # ===========================================================================
  # collab_floating_thread/1
  # ===========================================================================

  describe "collab_floating_thread/1" do
    test "renders with position style" do
      html = render_component(&H.render_collab_floating_thread/1, %{x: 150, y: 250})
      assert html =~ "left: 150px"
      assert html =~ "top: 250px"
    end

    test "renders phx-hook" do
      html = render_component(&H.render_collab_floating_thread/1, %{})
      assert html =~ "PhiaFloatingThread"
    end

    test "renders data attributes for position" do
      html = render_component(&H.render_collab_floating_thread/1, %{x: 100, y: 200})
      assert html =~ ~s(data-x="100")
      assert html =~ ~s(data-y="200")
    end

    test "renders nested thread content" do
      html = render_component(&H.render_collab_floating_thread/1, %{})
      assert html =~ "Root comment"
    end
  end

  # ===========================================================================
  # collab_thread_resolved/1
  # ===========================================================================

  describe "collab_thread_resolved/1" do
    test "renders check mark icon" do
      html = render_component(&H.render_collab_thread_resolved/1, %{})
      assert html =~ "text-green-600"
    end

    test "renders preview of root comment" do
      html = render_component(&H.render_collab_thread_resolved/1, %{})
      assert html =~ "This was resolved"
    end

    test "renders reopen button" do
      html = render_component(&H.render_collab_thread_resolved/1, %{})
      assert html =~ "Reopen"
    end

    test "renders data-thread-id" do
      html = render_component(&H.render_collab_thread_resolved/1, %{})
      assert html =~ ~s(data-thread-id="t-resolved")
    end

    test "applies custom class" do
      html = render_component(&H.render_collab_thread_resolved/1, %{class: "my-resolved"})
      assert html =~ "my-resolved"
    end
  end
end
