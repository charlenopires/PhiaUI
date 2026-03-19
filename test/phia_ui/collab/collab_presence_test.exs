defmodule PhiaUi.Collab.CollabPresenceTest do
  use ExUnit.Case, async: true

  alias PhiaUi.Collab.CollabPresence

  @moduledoc """
  Tests for CollabPresence module structure and function existence.

  Phoenix.Presence requires a running PubSub server and Presence tracker,
  so these tests verify the module API surface rather than full integration.
  Full integration tests require a Phoenix endpoint with PubSub configured.
  """

  # -------------------------------------------------------------------------
  # Module existence and behaviour
  # -------------------------------------------------------------------------

  describe "module structure" do
    setup do
      Code.ensure_loaded!(CollabPresence)
      :ok
    end

    test "module is defined" do
      assert Code.ensure_loaded?(CollabPresence)
    end

    test "uses Phoenix.Presence" do
      behaviours =
        CollabPresence.__info__(:attributes)
        |> Keyword.get_values(:behaviour)
        |> List.flatten()

      assert Phoenix.Presence in behaviours
    end

    test "exports track_user/3" do
      funcs = CollabPresence.__info__(:functions)
      assert {:track_user, 3} in funcs
    end

    test "exports update_cursor/3" do
      funcs = CollabPresence.__info__(:functions)
      assert {:update_cursor, 3} in funcs
    end

    test "exports update_typing/3" do
      funcs = CollabPresence.__info__(:functions)
      assert {:update_typing, 3} in funcs
    end

    test "exports mark_idle/2" do
      funcs = CollabPresence.__info__(:functions)
      assert {:mark_idle, 2} in funcs
    end

    test "exports online_users/1" do
      funcs = CollabPresence.__info__(:functions)
      assert {:online_users, 1} in funcs
    end

    test "exports typing_users/1" do
      funcs = CollabPresence.__info__(:functions)
      assert {:typing_users, 1} in funcs
    end

    test "exports user_count/1" do
      funcs = CollabPresence.__info__(:functions)
      assert {:user_count, 1} in funcs
    end

    test "exports list/1 from Phoenix.Presence" do
      funcs = CollabPresence.__info__(:functions)
      assert {:list, 1} in funcs
    end

    test "exports track/4 from Phoenix.Presence" do
      funcs = CollabPresence.__info__(:functions)
      assert {:track, 4} in funcs
    end

    test "exports update/4 from Phoenix.Presence" do
      funcs = CollabPresence.__info__(:functions)
      assert {:update, 4} in funcs
    end
  end

  # -------------------------------------------------------------------------
  # Function arity verification
  # -------------------------------------------------------------------------

  describe "function arities" do
    test "track_user accepts topic, user_id, meta" do
      # Verify the function clause head accepts 3 args
      # (calling it would require a running PubSub, so we only check export)
      assert {_, 3} =
               CollabPresence.__info__(:functions)
               |> Enum.find(fn {name, arity} -> name == :track_user and arity == 3 end)
    end

    test "update_cursor accepts topic, user_id, cursor" do
      assert {_, 3} =
               CollabPresence.__info__(:functions)
               |> Enum.find(fn {name, arity} -> name == :update_cursor and arity == 3 end)
    end

    test "update_typing accepts topic, user_id, boolean" do
      assert {_, 3} =
               CollabPresence.__info__(:functions)
               |> Enum.find(fn {name, arity} -> name == :update_typing and arity == 3 end)
    end

    test "mark_idle accepts topic, user_id" do
      assert {_, 2} =
               CollabPresence.__info__(:functions)
               |> Enum.find(fn {name, arity} -> name == :mark_idle and arity == 2 end)
    end

    test "online_users accepts topic" do
      assert {_, 1} =
               CollabPresence.__info__(:functions)
               |> Enum.find(fn {name, arity} -> name == :online_users and arity == 1 end)
    end
  end
end
