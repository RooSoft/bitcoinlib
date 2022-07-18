defmodule BitcoinLib.Signing.Psbt do
  defstruct [:global, :inputs, :outputs]

  alias BitcoinLib.Signing.{Psbt}
  alias BitcoinLib.Signing.Psbt.{Global, Inputs, Outputs}

  @magic 0x70736274
  @separator 0xFF

  @spec parse(binary()) :: %Psbt{}
  def parse(encoded) do
    map =
      %{encoded: encoded}
      |> base64_decode()
      |> extract_data()
      |> extract_global()
      |> extract_inputs()
      |> extract_outputs()

    %Psbt{global: map.global, inputs: map.inputs, outputs: map.outputs}
  end

  def base64_decode(%{encoded: encoded} = map) do
    map
    |> Map.put(:decoded, Base.decode64!(encoded))
  end

  def extract_data(%{decoded: <<@magic::32, @separator::8, data::binary>>} = map) do
    map
    |> Map.put(:data, data)
  end

  def extract_global(map) do
    map
    |> Map.put(:global, Global.from_data(map.data))
  end

  def extract_inputs(map) do
    map
    |> Map.put(:inputs, Inputs.from_data(map.data))
  end

  def extract_outputs(map) do
    map
    |> Map.put(:outputs, Outputs.from_data(map.data))
  end
end
