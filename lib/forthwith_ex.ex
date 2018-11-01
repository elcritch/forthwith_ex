defmodule ForthWithEx do
  require Logger
  alias Nerves.UART

  @moduledoc """
  Documentation for ForthWithEx.
  """

  def start(_type, _args) do
    Logger.warn("starting forthwith_ex")
    children = [
      {Registry, keys: :unique, name: Registry.ForthWithEx},
      {Nerves.UART, name: ForthWithEx.UART},
      # {Task, &initialize_uart/0},
      {ForthWithEx.UARTManager, name: UARTManager },
    ]
    Supervisor.start_link(children, strategy: :one_for_one)
  end

end

