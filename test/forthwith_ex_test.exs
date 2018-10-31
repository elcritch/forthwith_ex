defmodule ForthwithExTest do
  use ExUnit.Case
  doctest ForthwithEx

  test "greets the world" do
    assert ForthwithEx.hello() == :world
  end
end
