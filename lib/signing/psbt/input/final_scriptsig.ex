defmodule BitcoinLib.Signing.Psbt.Input.FinalScriptSig do
  defstruct [:script_sig]

  alias BitcoinLib.Signing.Psbt.Input.FinalScriptSig

  def parse(binary_script_sig) do
    script_sig = Binary.to_hex(binary_script_sig)

    %FinalScriptSig{script_sig: script_sig}
  end
end
