defmodule Mola.Unicard do
  @moduledoc """
  Convert unicode cards into useable Mola data
  """

  def tomola("🂡"), do: {"A", "s"}
  def tomola("🂱"), do: {"A", "h"}
  def tomola("🃁"), do: {"A", "d"}
  def tomola("🃑"), do: {"A", "c"}
  def tomola("🂮"), do: {"K", "s"}
  def tomola("🂾"), do: {"K", "h"}
  def tomola("🃎"), do: {"K", "d"}
  def tomola("🃞"), do: {"K", "c"}
  def tomola("🂭"), do: {"Q", "s"}
  def tomola("🂽"), do: {"Q", "h"}
  def tomola("🃍"), do: {"Q", "d"}
  def tomola("🃝"), do: {"Q", "c"}
  def tomola("🂫"), do: {"J", "s"}
  def tomola("🂻"), do: {"J", "h"}
  def tomola("🃋"), do: {"J", "d"}
  def tomola("🃛"), do: {"J", "c"}
  def tomola("🂪"), do: {"T", "s"}
  def tomola("🂺"), do: {"T", "h"}
  def tomola("🃊"), do: {"T", "d"}
  def tomola("🃚"), do: {"T", "c"}
  def tomola("🂩"), do: {"9", "s"}
  def tomola("🂹"), do: {"9", "h"}
  def tomola("🃉"), do: {"9", "d"}
  def tomola("🃙"), do: {"9", "c"}
  def tomola("🂨"), do: {"8", "s"}
  def tomola("🂸"), do: {"8", "h"}
  def tomola("🃈"), do: {"8", "d"}
  def tomola("🃘"), do: {"8", "c"}
  def tomola("🂧"), do: {"7", "s"}
  def tomola("🂷"), do: {"7", "h"}
  def tomola("🃇"), do: {"7", "d"}
  def tomola("🃗"), do: {"7", "c"}
  def tomola("🂦"), do: {"6", "s"}
  def tomola("🂶"), do: {"6", "h"}
  def tomola("🃆"), do: {"6", "d"}
  def tomola("🃖"), do: {"6", "c"}
  def tomola("🂥"), do: {"5", "s"}
  def tomola("🂵"), do: {"5", "h"}
  def tomola("🃅"), do: {"5", "d"}
  def tomola("🃕"), do: {"5", "c"}
  def tomola("🂤"), do: {"4", "s"}
  def tomola("🂴"), do: {"4", "h"}
  def tomola("🃄"), do: {"4", "d"}
  def tomola("🃔"), do: {"4", "c"}
  def tomola("🂣"), do: {"3", "s"}
  def tomola("🂳"), do: {"3", "h"}
  def tomola("🃃"), do: {"3", "d"}
  def tomola("🃓"), do: {"3", "c"}
  def tomola("🂢"), do: {"2", "s"}
  def tomola("🂲"), do: {"2", "h"}
  def tomola("🃂"), do: {"2", "d"}
  def tomola("🃒"), do: {"2", "c"}
end
