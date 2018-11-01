defmodule ForthWithEx.UARTManager do
  use GenServer

  # Callbacks

  @impl true
  def init(opts \\ []) do
    {:ok, %{}}
  end

  @impl true
  def handle_cast(:open, state) do
    Application.get_env(:forthwith_ex, :uarts)
    |> open_uarts()

    {:noreply, state}
  end

  @impl true
  def handle_cast(:restart, state) do
    Application.get_env(:forthwith_ex, :uarts)
    |> close_uarts()

    {:noreply, state}
  end

  @impl true
  def handle_info(msg, state) do
    publish_uart(msg)

    {:noreply, state}
  end

  defp publish_uart(msg) do
    Registry.dispatch(Registry.ForthWithEx, ForthClient, fn entries ->
      for {pid, _} <- entries, do: send(pid, msg)
    end)
  end

  defp open_uarts() do
    Logger.warn("Starting UARTs...")
    pid = Process.whereis(ForthWithEx.UART)

    for dev_name <- uarts do
      dev_conf = Application.get_env(:forthwith_ex, dev_name)
      Logger.info("UART: #{inspect(dev_name)} -- #{inspect(dev_conf)}")

      result = pid |> UART.open(dev_conf[:name], dev_conf)
      Logger.info("UART open: #{inspect(result)}")

      result =
        pid
        |> Nerves.UART.configure(
          framing: {ForthWithEx.UART.Framing, separator: <<"\r", "\n", 6>>}
        )

      Logger.info("UART configure: #{inspect(result)}")
    end
  end

  defp open_uarts(uarts) do
    Logger.warn("Closing UARTs...")
    pid = Process.whereis(ForthWithEx.UART)

    for dev_name <- uarts do
      dev_conf = Application.get_env(:forthwith_ex, dev_name)

      result = pid |> UART.open(dev_conf[:name], dev_conf)
      Logger.info("UART close: #{inspect(result)}")
    end

    loop_uarts()
  end
end
