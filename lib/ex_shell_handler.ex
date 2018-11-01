defmodule ForthWithEx.ShellHandler.Example do
  use IExSshShell.ShellHandler
  # use GenServer
  require Logger

  def start(opts \\ []) do
    spawn(fn ->
      case :init.notify_when_started(self()) do
        :started -> :ok
        _ -> :init.wait_until_started()
      end

      __MODULE__.on_shell()
    end)
  end

  # def start_link(opts) do
  # GenServer.start_link(__MODULE__, opts)
  # end

  def on_shell(_username, _pubkey, _ip, _port) do
    on_shell()
  end

  def on_shell() do
    {:ok, _} = Registry.register(Registry.ForthWithEx, ForthClient, "key")
    :ok = IO.puts("\\ Interactive ForthWith Shell - type `%%exit<ENTER>` to quit")
    loop(run_state([]))
  end

  def on_connect(username, ip, port, method) do
    Logger.info(fn ->
      """
      Incoming SSH shell #{inspect(self())} requested for #{username} from #{inspect(ip)}:#{
        inspect(port)
      } using #{inspect(method)}
      """
    end)
  end

  def on_disconnect(username, ip, port) do
    Logger.info(fn ->
      "Disconnecting SSH shell for #{username} from #{inspect(ip)}:#{inspect(port)}"
    end)
  end

  defp loop(state) do
    self_pid = self()
    counter = state.counter
    prefix = state.prefix

    input = spawn(fn -> io_get(self_pid, prefix, counter) end)
    wait_input(state, input)
  end

  defp wait_input(state, input) do
    receive do
      {:nerves_uart, _uart_name, _str_msg} = msg ->
        # IO.puts "uart: #{inspect msg}"
        handle_input(state, msg)

      {:input, ^input, msg} when is_list(msg) ->
        handle_input(state, to_string(msg))

      {item, ^input, msg} ->
        handle_input(state, msg)

      {item, ^input, msg} ->
        Logger.error("Unable to handle unknown msg: #{inspect(item)} -- #{inspect(msg)}")

      other ->
        Logger.error("Unable to handle unknown input: #{inspect(other)}")
    end
  end

  defp handle_input(state, {:nerves_uart, _uart_name, {:partial, msg}}) do
    IO.binwrite(msg)
    loop(%{state | counter: state.counter + 1})
  end

  defp handle_input(state, {:nerves_uart, _uart_name, msg}) do
    # IO.puts("IN: #{inspect msg <> <<0>> }")
    # IO.write(msg |> String.trim("\r\n" <> <<6>>))
    IO.binwrite(msg)
    loop(%{state | counter: state.counter + 1})
  end

  defp handle_input(state, "%%" <> _name = code) when is_binary(code) do
    code = String.trim(code)
    IO.puts("Received shell special command: #{inspect(code)}")

    case code do
      "%%enumerate" ->
        IO.puts("UART: #{inspect(Nerves.UART.enumerate())}")
        loop(%{state | counter: state.counter + 1})

      "%%reconnect" ->
        IO.puts("Restarting UARTs: #{inspect(Application.get_env(:forthwith_ex, :uarts))}")
        Process.whereis(:UARTManager) |> ForthWithEx.UARTManager.reopen()

        loop(%{state | counter: state.counter + 1})

      "%%time" ->
        IO.puts("#{ DateTime.utc_now() |> DateTime.to_iso8601() }")
        loop(%{state | counter: state.counter + 1})

      "%%exit" ->
        IO.puts("Goodbye.")
    end
  end

  defp handle_input(state, code) when is_binary(code) do
    # code = String.trim(code) 
    # IO.puts "Received shell command: #{inspect code}"
    Nerves.UART.write(state.uart_pid, code)

    loop(%{state | counter: state.counter + 1})
  end

  defp handle_input(state, {:error, :interrupted}) do
    IO.puts("Caught Ctrl+C...")
    IO.puts("Exiting...")
  end

  defp run_state(opts) do
    prefix = Keyword.get(opts, :prefix, "")
    uart_pid = Process.whereis(ForthWithEx.UART)
    Nerves.UART.write(uart_pid, "\n")

    %{prefix: prefix, counter: 1, uart_pid: uart_pid}
  end

  defp io_get(pid, prefix, counter) do
    # prompt = prompt(prefix, counter)
    send(pid, {:input, self(), IO.gets(:stdio, " ")})
  end

  defp prompt(prefix, counter) do
    prompt =
      "[%counter]"
      |> String.replace("%counter", to_string(counter))
      |> String.replace("%prefix", to_string(prefix))
      |> String.replace("%node", to_string(node()))

    prompt <> " "
  end
end
