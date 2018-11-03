defmodule ForthWithEx do
  require Logger

  @moduledoc """
  Documentation for ForthWithEx.
  """

  def start(_type, _args) do
    Logger.warn("starting forthwith_ex")

    children = [
      {Registry, keys: :duplicate, name: Registry.ForthWithEx},
      {Nerves.UART, name: ForthWithEx.UART},
      # {Task, &initialize_uart/0},
      {ForthWithEx.UARTManager, []}
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
