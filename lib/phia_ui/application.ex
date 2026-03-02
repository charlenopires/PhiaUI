defmodule PhiaUi.Application do
  @moduledoc """
  OTP Application entry-point for PhiaUi.

  Starts the supervision tree, which includes the native
  `PhiaUi.ClassMerger.Cache` — an ETS-backed GenServer that
  memoises resolved Tailwind class strings (equivalent to
  TwMerge.Cache from the tw_merge library).
  """

  use Application

  @impl Application
  def start(_type, _args) do
    children = [
      PhiaUi.ClassMerger.Cache
    ]

    opts = [strategy: :one_for_one, name: PhiaUi.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
