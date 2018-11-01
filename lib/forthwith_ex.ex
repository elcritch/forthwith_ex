defmodule ForthWithEx do
  @moduledoc """
  Documentation for ForthWithEx.
  """

  def start(_type, _args) do
    children = [
      {Registry, keys: :unique, name: Registry.ForthWithEx},
    ]
    Supervisor.start_link(children, strategy: :one_for_one)
  end

end
