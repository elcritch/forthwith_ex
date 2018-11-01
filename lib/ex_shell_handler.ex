
defmodule ForthwithEx.ShellHandler.Example do
  use IExSshShell.ShellHandler
  use GenServer
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

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  def on_shell(_username, _pubkey, _ip, _port) do
    on_shell()
  end

  def on_shell() do
    :ok = IO.puts "Interactive example SSH shell - type exit ENTER to quit"
    loop(run_state([]))
  end


  def on_connect(username, ip, port, method) do
    Logger.debug fn ->
      """
      Incoming SSH shell #{inspect self()} requested for #{username} from #{inspect ip}:#{inspect port} using #{inspect method}
      """
    end
  end

  def on_disconnect(username, ip, port) do
    Logger.debug fn ->
      "Disconnecting SSH shell for #{username} from #{inspect ip}:#{inspect port}"
    end
  end

  defp loop(state) do
    self_pid = self()
    counter  = state.counter
    prefix   = state.prefix

    input = spawn(fn -> io_get(self_pid, prefix, counter) end)
    wait_input state, input
  end

  defp wait_input(state, input) do
    receive do
      {:input, ^input, msg} when is_list(msg) -> handle_input(state, to_string(msg))
      {:input, ^input, msg} -> handle_input(state, msg)
      msg -> Logger.error("Unable to handle unknown input: #{inspect msg}")
    end
  end

  defp handle_input(state, "exit\n") do
    IO.puts "Exiting..."
  end

  defp handle_input(state, code) when is_binary(code) do
    code = String.trim(code)

    IO.puts "Received shell command: #{inspect code}"

    loop(%{state | counter: state.counter + 1})
  end

  defp handle_input(state, {:error, :interrupted}) do
    IO.puts "Caught Ctrl+C..."
    IO.puts "Exiting..."
  end

  defp handle_input(state, msg) do
    :ok = Logger.warn "received unknown message: #{inspect msg}"
    loop(%{state | counter: state.counter + 1})
  end

  # defp handle_input(state, input) do
  #     {:input, ^input, 'exit\n'} ->

  #     {:input, ^input, code} when is_binary(code) ->

  #     {:input, ^input, {:error, :interrupted}} ->
  #       # loop(%{state | counter: state.counter + 1})

  #     {:input, ^input, msg} ->
  #       :ok = Logger.warn "received unknown message: #{inspect msg}"
  #       loop(%{state | counter: state.counter + 1})
  #   end
  # end

  defp run_state(opts) do
    prefix = Keyword.get(opts, :prefix, "")

    %{prefix: prefix, counter: 1}
  end

  defp io_get(pid, prefix, counter) do
    prompt = prompt(prefix, counter)
    send pid, {:input, self(), IO.gets(:stdio, prompt)}
  end

  defp prompt(prefix, counter) do
    prompt = "(%node)%counter>"
      |> String.replace("%counter", to_string(counter))
      |> String.replace("%prefix", to_string(prefix))
      |> String.replace("%node", to_string(node()))

    prompt <> " "
  end
end
