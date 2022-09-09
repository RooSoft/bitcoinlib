defmodule BitcoinLib.Key.HD.DerivationPath.Level do
  @moduledoc """
  A derivation path is composed of levels of childrens, which have integer values and can be hardened

  This is a simple structure defining this concept
  """

  @enforce_keys [:hardened?, :value]
  defstruct hardened?: false, value: 0
end
