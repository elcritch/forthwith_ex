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

  def initialize_uart() do
    separator = Application.get_env(:forthwith_ex, :separator, << "\r", "\n", 6>>)
    Logger.info("Starting UARTs with separator: #{inspect separator}")
    for dev_name <- Application.get_env(:forthwith_ex, :uarts) do
      dev_conf = Application.get_env(:forthwith_ex, dev_name)
      Logger.info("UART: #{inspect dev_name} -- #{inspect dev_conf}")

      pid = Process.whereis(ForthWithEx.UART)

      result = 
        pid |> UART.open(dev_conf[:name], dev_conf)
      Logger.info("UART open: #{inspect result}")

      result = 
        pid |> Nerves.UART.configure(framing:
          {ForthWithEx.UART.Framing, separator: separator })

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
