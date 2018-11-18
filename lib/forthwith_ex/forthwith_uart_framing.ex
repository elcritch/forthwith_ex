defmodule ForthWithEx.UART.Framing do
  @behaviour Nerves.UART.Framing

  defmodule State do
    @moduledoc false
    defstruct max_length: nil,
              separator: nil,
              sep_length: nil,
              line_split: nil,
              processed: <<>>,
              in_process: <<>>
  end

  def init(args) do
    max_length =
      Keyword.get(args, :max_length, Application.get_env(:forthwith_ex, :buffer_size, 8192))

    separator = Keyword.get(args, :separator, "\n")
    sep_length = byte_size(separator)
    line_split = Keyword.get(args, :line_split, "\n")

    state = %State{
      max_length: max_length,
      separator: separator,
      sep_length: sep_length,
      line_split: line_split
    }

    {:ok, state}
  end

  def add_framing(data, state) do
    {:ok, data <> "\n", state}
  end

  def remove_framing(data, state) do
    {new_processed, new_in_process, lines} = process_data(state, state.in_process <> data, [])

    new_state = %{state | processed: new_processed, in_process: new_in_process}
    rc = if buffer_empty?(new_state), do: :ok, else: :in_frame
    {rc, lines, new_state}
  end

  def frame_timeout(state) do
    partial_line = {:partial, state.processed <> state.in_process}
    new_state = %{state | processed: <<>>, in_process: <<>>}
    {:ok, [partial_line], new_state}
  end

  def flush(direction, state) when direction == :receive or direction == :both do
    %{state | processed: <<>>, in_process: <<>>}
  end

  def flush(:transmit, state) do
    state
  end

  def buffer_empty?(%State{processed: <<>>, in_process: <<>>}), do: true
  def buffer_empty?(_state), do: false

  # Handle not enough data case
  defp process_data(
         %State{
           separator: _sep,
           sep_length: sep_length,
           max_length: _max_length,
           processed: processed
         },
         to_process,
         lines
       )
       when byte_size(to_process) < sep_length do
    {processed, to_process, lines}
  end

  # Process data until separator or next char
  defp process_data(separator, sep_length, max_length, processed, to_process, lines) do
    case to_process do
      # Handle separater
      <<^separator::binary-size(sep_length), rest::binary>> ->
        new_lines = lines ++ String.split(processed, "\n")
        process_data(state, <<>>, rest)

      # Handle line too long case
      to_process when byte_size(processed) == max_length and to_process != <<>> ->
        newlines = processed |> String.split("\n")
        new_lines = lines ++ [{:partial, newlines}]
        process_data(state, to_process, new_lines)

      # Handle next char
      <<next_char::binary-size(1), rest::binary>> ->
        process_data(state, processed <> next_char, rest, lines)
    end
  end
end
