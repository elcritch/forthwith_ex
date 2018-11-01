[1mdiff --git a/lib/ex_shell_handler.ex b/lib/ex_shell_handler.ex[m
[1mindex 1fcb659..0e17944 100644[m
[1m--- a/lib/ex_shell_handler.ex[m
[1m+++ b/lib/ex_shell_handler.ex[m
[36m@@ -70,14 +70,14 @@[m [mdefmodule ForthWithEx.ShellHandler.Example do[m
   end[m
 [m
   defp handle_input(state, {:nerves_uart, _uart_name, {:partial, msg}}) do[m
[31m-    IO.write(msg)[m
[32m+[m[32m    IO.binwrite(msg)[m
     loop(%{state | counter: state.counter + 1})[m
   end[m
 [m
   defp handle_input(state, {:nerves_uart, _uart_name, msg}) do[m
     # IO.puts("IN: #{inspect msg <> <<0>> }")[m
     # IO.write(msg |> String.trim("\r\n" <> <<6>>))[m
[31m-    IO.write(msg)[m
[32m+[m[32m    IO.binwrite(msg)[m
     loop(%{state | counter: state.counter + 1})[m
   end[m
 [m
[36m@@ -87,7 +87,11 @@[m [mdefmodule ForthWithEx.ShellHandler.Example do[m
 [m
     case code do[m
       "%%enumerate" ->[m
[31m-        IO.puts("#{inspect Nerves.UART.enumerate}")[m
[32m+[m[32m        IO.puts("UART: #{inspect Nerves.UART.enumerate}")[m
[32m+[m[32m        loop(%{state | counter: state.counter + 1})[m
[32m+[m[32m      "%%reconnect" ->[m
[32m+[m[32m        IO.puts("Restarting UARTs: #{inspect Application.get_env(:forthwith_ex, :uarts)}")[m
[32m+[m[32m        for uart[m[41m [m
         loop(%{state | counter: state.counter + 1})[m
       "%%time" ->[m
         IO.puts("#{inspect Nerves.UART.enumerate}")[m
[36m@@ -110,6 +114,25 @@[m [mdefmodule ForthWithEx.ShellHandler.Example do[m
     IO.puts "Exiting..."[m
   end[m
 [m
[32m+[m[32m  def restart_uarts() do[m
[32m+[m[32m    for dev_name <- Application.get_env(:forthwith_ex, :uarts) do[m
[32m+[m[32m      dev_conf = Application.get_env(:forthwith_ex, dev_name)[m
[32m+[m[32m      Logger.info("UART: #{inspect dev_name} -- #{inspect dev_conf}")[m
[32m+[m
[32m+[m[32m      pid = Process.whereis(ForthWithEx.UART)[m
[32m+[m
[32m+[m[32m      result =[m[41m [m
[32m+[m[32m        pid |> UART.open(dev_conf[:name], dev_conf)[m
[32m+[m[32m      Logger.info("UART open: #{inspect result}")[m
[32m+[m
[32m+[m[32m      result =[m[41m [m
[32m+[m[32m        pid |> Nerves.UART.configure(framing:[m
[32m+[m[32m        {ForthWithEx.UART.Framing, separator: <<"\r", "\n", 6>> })[m
[32m+[m
[32m+[m[32m      Logger.info("UART configure: #{inspect result}")[m
[32m+[m[32m    end[m
[32m+[m[32m  end[m
[32m+[m
   defp run_state(opts) do[m
     prefix = Keyword.get(opts, :prefix, "")[m
     uart_pid = Process.whereis(ForthWithEx.UART)[m
[1mdiff --git a/lib/forthwith_ex.ex b/lib/forthwith_ex.ex[m
[1mindex 57da00d..06e480b 100644[m
[1m--- a/lib/forthwith_ex.ex[m
[1m+++ b/lib/forthwith_ex.ex[m
[36m@@ -11,45 +11,11 @@[m [mdefmodule ForthWithEx do[m
     children = [[m
       {Registry, keys: :unique, name: Registry.ForthWithEx},[m
       {Nerves.UART, name: ForthWithEx.UART},[m
[31m-      {Task, &initialize_uart/0},[m
[32m+[m[32m      # {Task, &initialize_uart/0},[m
[32m+[m[32m      {ForthWithEx.UARTManager, name: UARTManager },[m
     ][m
     Supervisor.start_link(children, strategy: :one_for_one)[m
   end[m
 [m
[31m-  def initialize_uart() do[m
[31m-    Logger.warn("Starting UARTs...")[m
[31m-    for dev_name <- Application.get_env(:forthwith_ex, :uarts) do[m
[31m-      dev_conf = Application.get_env(:forthwith_ex, dev_name)[m
[31m-      Logger.info("UART: #{inspect dev_name} -- #{inspect dev_conf}")[m
[31m-[m
[31m-      pid = Process.whereis(ForthWithEx.UART)[m
[31m-[m
[31m-      result = [m
[31m-        pid |> UART.open(dev_conf[:name], dev_conf)[m
[31m-      Logger.info("UART open: #{inspect result}")[m
[31m-[m
[31m-      result = [m
[31m-        pid |> Nerves.UART.configure(framing:[m
[31m-          {ForthWithEx.UART.Framing, separator: <<"\r", "\n", 6>> })[m
[31m-[m
[31m-      Logger.info("UART configure: #{inspect result}")[m
[31m-    end[m
[31m-[m
[31m-    loop_uarts()[m
[31m-  end[m
[31m-[m
[31m-  def loop_uarts() do[m
[31m-    receive do[m
[31m-      msg ->[m
[31m-        publish_uart(msg)[m
[31m-    end[m
[31m-    loop_uarts()[m
[31m-  end[m
[31m-[m
[31m-  def publish_uart(msg) do[m
[31m-    Registry.dispatch(Registry.ForthWithEx, ForthClient, fn entries ->[m
[31m-      for {pid, _} <- entries, do: send(pid, msg)[m
[31m-    end)[m
[31m-  end[m
 end[m
 [m
