defmodule ForthWithEx do
  require Logger
  alias Nerves.UART

  @moduledoc """
  Documentation for ForthWithEx.
  """

  def start(_type, _args) do
    children = [
      {Registry, keys: :unique, name: Registry.ForthWithEx},
      {Nerves.UART, name: ForthWithEx.UART},
      {Task, &initialize_uart/0},
    ]
    Supervisor.start_link(children, strategy: :one_for_one)
  end

  def initialize_uart() do
    Logger.info("Starting UARTs...")
    separator = Application.get_env(:forthwith_ex, :separator, << "\r", "\n", 6>>)
    Logger.info("Framing UARTs using separator #{inspect separator}")

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

      Logger.info("UART configure: #{inspect result}")
    end

    loop_uarts()
  end

  def loop_uarts() do
    receive do
      msg ->
        publish_uart(msg)
    end
    loop_uarts()
  end

  def publish_uart(msg) do
    Registry.dispatch(Registry.ForthWithEx, ForthClient, fn entries ->
      for {pid, _} <- entries, do: send(pid, msg)
    end)
  end
end

