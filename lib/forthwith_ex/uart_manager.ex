defmodule ForthWithEx.UARTManager do
  use GenServer
  require Logger

  def start_link(opts) do
    Logger.info("ForthWithEx.UARTManager ")
    GenServer.start_link(__MODULE__, [], opts ++ [name: __MODULE__])
  end

  def open(pid) do
    GenServer.cast(pid, :open)
  end

  def close(pid) do
    GenServer.cast(pid, :close)
  end

  def reopen(pid) do
    GenServer.cast(pid, :close)
    GenServer.cast(pid, :open)
  end

  # Callbacks
  @max_timeout 60_000

  @impl true
  def init(_opts \\ []) do
    open(self())
    {:ok, %{manager: true}}
  end

  @impl true
  def handle_cast(:open, state) do
    Application.get_env(:forthwith_ex, :uarts) |> open_uarts(1)

    {:noreply, state}
  end

  @impl true
  def handle_cast({:open, timeout}, state) do
    if timeout < @max_timeout do
      Application.get_env(:forthwith_ex, :uarts) |> open_uarts(timeout)
    end

    {:noreply, state}
  end

  @impl true
  def handle_cast(:close, state) do
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

  defp open_uarts(uarts, timeout) do
    pid = Process.whereis(ForthWithEx.UART)

    for dev_name <- uarts do
      dev_conf = Application.get_env(:forthwith_ex, dev_name)
      Logger.info("Opening UART: #{inspect(dev_name)} -- #{inspect(dev_conf)}")

      result = pid |> Nerves.UART.open(dev_conf[:name], dev_conf)
      Logger.info("UART open result: #{inspect(result)}")

      case result do
        :ok ->
          result =
            pid
            |> Nerves.UART.configure(
              framing: {ForthWithEx.UART.Framing, separator: <<"\r", "\n", 6>>}
            )

          Logger.info("UART configure: #{inspect(result)}")

        {:error, :enoent} ->
          Process.send_after(self(), {:"$gen_cast", :open}, 2 * timeout)
      end
    end
  end

  defp close_uarts(uarts) do
    Logger.warn("Closing UARTs...")

    uart_pids =
      Nerves.UART.find_pids()
      |> Enum.map(fn {x, y} -> {y, x} end)
      |> Map.new()

    for dev_name <- uarts do
      dev_conf = Application.get_env(:forthwith_ex, dev_name)

      result =
        uart_pids
        |> Map.get(dev_conf[:name])
        |> Nerves.UART.close()

      Logger.info("UART close: #{inspect(result)}")
    end
  end
end
