defmodule BitcoinLib.Key.HD.DerivationPath.Level do
  @enforce_keys [:hardened?, :value]
  defstruct hardened?: false, value: 0
end
