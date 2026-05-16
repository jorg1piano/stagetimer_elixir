defmodule Stagetimer.TimerTest do
  use ExUnit.Case, async: true
  doctest Stagetimer.Timer

  alias Stagetimer.Timer

  describe "new/1" do
    test "builds an idle timer with id + defaults" do
      assert %Timer{
               id: "timer_1",
               title: "",
               speaker: "",
               notes: "",
               duration_ms: 0,
               started_at: nil,
               started_from_ms: 0,
               status: :idle
             } = Timer.new(id: "timer_1")
    end
  end
end
