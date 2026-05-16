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
end
