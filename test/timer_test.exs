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

    test "accepts optional fields" do
      assert %Timer{
               id: "timer_1",
               title: "Very precise timer",
               speaker: "Jose Valim",
               notes: "",
               duration_ms: 0,
               started_at: nil,
               started_from_ms: 0,
               status: :idle
             } = Timer.new(id: "timer_1", title: "Very precise timer", speaker: "Jose Valim")
    end
  end

  describe "start/2" do
    test "transitions idle timer to running and records started_at" do
      now = ~U[2026-05-16 12:00:00Z]
      timer = Timer.new(id: "timer_1", duration_ms: 300_000)

      assert %Timer{
               status: :running,
               started_at: ^now,
               started_from_ms: 0
             } = Timer.start(timer, now)
    end
  end

  describe "resuming from puased keeps started_from_ms" do
    now = ~U[2026-05-16 12:00:00Z]
    paused = %Timer{id: "timer_1", status: :paused, started_from_ms: 10_000}

    assert %Timer{
             status: :running,
             started_at: ^now,
             started_from_ms: 10_000
           } = Timer.start(paused, now)
  end

  describe "starting an already-running timer is a no-op" do
    first_start = ~U[2026-05-16 12:00:00Z]
    later = ~U[2026-05-16 12:00:30Z]

    timer_initial = Timer.new(id: "timer_1")
    timer_running = Timer.start(timer_initial, first_start)

    assert Timer.start(timer_running, later) == timer_running
  end
end
