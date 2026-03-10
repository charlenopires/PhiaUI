defmodule PhiaUiDesign.Canvas.History do
  @moduledoc """
  Command-pattern undo/redo stack for scene operations.
  """

  use Agent

  @type command ::
          {:insert, PhiaUiDesign.Canvas.Node.t()}
          | {:delete, PhiaUiDesign.Canvas.Node.t()}
          | {:update, String.t(), map(), map()}
          | {:move, String.t(), String.t() | nil, String.t() | nil, integer()}

  defstruct undo_stack: [], redo_stack: [], max_size: 100

  def start_link(opts \\ []) do
    max_size = Keyword.get(opts, :max_size, 100)
    Agent.start_link(fn -> %__MODULE__{max_size: max_size} end, name: Keyword.get(opts, :name))
  end

  @doc "Push a command onto the undo stack, clearing redo"
  def push(agent, command) do
    Agent.update(agent, fn state ->
      undo = [command | state.undo_stack] |> Enum.take(state.max_size)
      %{state | undo_stack: undo, redo_stack: []}
    end)
  end

  @doc "Pop the last command from undo stack (returns nil if empty)"
  def undo(agent) do
    Agent.get_and_update(agent, fn state ->
      case state.undo_stack do
        [cmd | rest] ->
          {cmd, %{state | undo_stack: rest, redo_stack: [cmd | state.redo_stack]}}

        [] ->
          {nil, state}
      end
    end)
  end

  @doc "Pop the last command from redo stack (returns nil if empty)"
  def redo(agent) do
    Agent.get_and_update(agent, fn state ->
      case state.redo_stack do
        [cmd | rest] ->
          {cmd, %{state | redo_stack: rest, undo_stack: [cmd | state.undo_stack]}}

        [] ->
          {nil, state}
      end
    end)
  end

  @doc "Check if undo is available"
  def can_undo?(agent) do
    Agent.get(agent, fn state -> state.undo_stack != [] end)
  end

  @doc "Check if redo is available"
  def can_redo?(agent) do
    Agent.get(agent, fn state -> state.redo_stack != [] end)
  end

  @doc "Clear all history"
  def clear(agent) do
    Agent.update(agent, fn state -> %{state | undo_stack: [], redo_stack: []} end)
  end
end
