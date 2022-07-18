defmodule BitcoinLib.Signing.Psbt do
  defstruct [:inputs, :outputs]

  alias BitcoinLib.Signing.{Psbt}
  alias BitcoinLib.Signing.Psbt.{Inputs, Outputs}

  @spec parse(binary()) :: %Psbt{}
  def parse(_base64_psbt) do
    inputs = %Inputs{}
    outputs = %Outputs{}

    %Psbt{inputs: inputs, outputs: outputs}
  end
end
