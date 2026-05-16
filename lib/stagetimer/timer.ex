defmodule Stagetimer.Timer do
  @moduledoc """
  A countdown timer.
  `started_at` is the wall-clock of the current running interval
  `started_from_ms` is the elapsed-so-far at the moment of restart

  Current elapsed time is always computed, never stored.
  """

  @enforce_keys [:id]

  defstruct id: nil,
            title: "",
            speaker: "",
            notes: "",
            duration_ms: 0,
            started_at: nil,
            started_from_ms: 0,
            status: :idle

  @type status :: :idle | :running | :paused

  @type t :: %__MODULE__{
          id: String.t(),
          title: String.t(),
          speaker: String.t(),
          notes: String.t(),
          duration_ms: non_neg_integer(),
          started_at: DateTime.t() | nil,
          started_from_ms: non_neg_integer(),
          status: status()
        }

  @spec new(keyword()) :: t()
  def new(attrs) do
    struct!(__MODULE__, attrs)
  end

  @doc """
  Start or resume at wall-clock `now`.
  Idempotent, a running timer is unchanged
  """
  @spec start(t(), DateTime.t()) :: t()
  def start(%__MODULE__{status: :running} = t, _now), do: t
  def start(%__MODULE__{} = t, now), do: %{t | started_at: now, status: :running}
end
