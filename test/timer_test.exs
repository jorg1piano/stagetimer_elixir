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

    test "resuming from puased keeps started_from_ms" do
      now = ~U[2026-05-16 12:00:00Z]
      paused = %Timer{id: "timer_1", status: :paused, started_from_ms: 10_000}

      assert %Timer{
               status: :running,
               started_at: ^now,
               started_from_ms: 10_000
             } = Timer.start(paused, now)
    end

    test "starting an already-running timer is a no-op" do
      first_start = ~U[2026-05-16 12:00:00Z]
      later = ~U[2026-05-16 12:00:30Z]

      timer_initial = Timer.new(id: "timer_1")
      timer_running = Timer.start(timer_initial, first_start)

      assert Timer.start(timer_running, later) == timer_running
    end
  end

  describe "elapsed_ms/2" do
    test "idle timer has zero elapsed" do
      assert Timer.elapsed_ms(Timer.new(id: "timer_1"), ~U[2026-04-16 12:00:00Z]) == 0
    end

    test "paused timer returns it captured started_from_ms" do
      paused = %Timer{id: "t1", status: :paused, started_from_ms: 30_000}
      assert Timer.elapsed_ms(paused, ~U[2026-05-16 12:00:00Z]) == 30_000
    end

    test "running timer returns wall-clock delta plus offset" do
      started = ~U[2026-05-16 12:00:00Z]
      now = ~U[2026-05-16 12:00:30Z]
      t = Timer.start(Timer.new(id: "t1"), started)

      assert Timer.elapsed_ms(t, now) == 30_000
    end

    test "negative wall-clock diff clamps to the offset" do
      resumed = %Timer{
        id: "t1",
        status: :running,
        started_at: ~U[2026-05-16 12:00:00Z],
        started_from_ms: 30_000
      }

      past = ~U[2026-05-16 11:59:50Z]
      assert Timer.elapsed_ms(resumed, past) == 30_000
    end
  end

  describe "pause/2" do
    test "captures elapsed and flips status to :paused" do
      started = ~U[2026-05-16 12:00:00Z]
      now = ~U[2026-05-16 12:00:30Z]
      running = Timer.start(Timer.new(id: "t1"), started)

      assert %Timer{
               status: :paused,
               started_from_ms: 30_000
             } = Timer.pause(running, now)
    end

    test "accumulates across multiple pause/resume cycles" do
      t = Timer.new(id: "timer_1")
      t = Timer.start(t, ~U[2026-05-16 12:00:00Z])

      # 30s in
      t = Timer.pause(t, ~U[2026-05-16 12:00:30Z])

      # resume
      t = Timer.start(t, ~U[2026-05-16 12:01:00Z])

      # +10s
      t = Timer.pause(t, ~U[2026-05-16 12:01:10Z])

      assert t.started_from_ms == 40_000
      assert t.status == :paused
    end

    test "pausing an already-paused timer is a no-op" do
      paused = %Timer{id: "timer_1", status: :paused, started_from_ms: 30_000}
      assert Timer.pause(paused, ~U[2026-05-16 12:05:00Z]) == paused
    end

    test "pausing an idle timer is a no-op" do
      idle = Timer.new(id: "t1")
      assert Timer.pause(idle, ~U[2026-05-16 12:00:00Z]) == idle
    end
  end
end
