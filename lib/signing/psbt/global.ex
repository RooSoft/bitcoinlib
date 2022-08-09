defmodule BitcoinLib.Signing.Psbt.Global do
  defstruct [:unsigned_tx, tx_version: 0, xpubs: [], unknowns: []]

  alias BitcoinLib.Signing.Psbt.Global.{Xpub, UnsignedTx, Version}
  alias BitcoinLib.Signing.Psbt.{Keypair, KeypairList, Global}

  @unsigned_tx 0
  @xpub 1
  @tx_version 2
  @version 0xFB

  def from_keypair_list(nil) do
    {:ok, %Global{}}
  end

  def from_keypair_list(%KeypairList{} = keypair_list) do
    data =
      keypair_list.keypairs
      |> Enum.reduce(%{xpubs: [], unknowns: []}, &dispatch_keypair/2)

    case Map.get(data, :error) do
      nil ->
        {:ok,
         %Global{
           unsigned_tx: data |> Map.get(:unsigned_tx),
           tx_version: data |> Map.get(:tx_version),
           xpubs: data |> Map.get(:xpubs),
           unknowns: data |> Map.get(:unknowns)
         }}

      message ->
        {:error, message}
    end
  end

  defp dispatch_keypair(%Keypair{key: key, value: value} = keypair, input) do
    case key.type do
      @unsigned_tx -> add_unsigned_tx(input, keypair)
      @xpub -> add_xpub(input, value)
      @tx_version -> add_tx_version(input, value)
      @version -> add_version(input, value)
      _ -> add_unknown(input, key, value)
    end
  end

  defp add_unsigned_tx(input, keypair) do
    case UnsignedTx.parse(keypair) do
      {:ok, unsigned_tx} ->
        input
        |> Map.put(:unsigned_tx, unsigned_tx)

      {:error, message} ->
        input
        |> Map.put(:error, message)
    end
  end

  defp add_xpub(%{xpubs: xpubs} = input, value) do
    {new_xpub, _remaining} = Xpub.parse(value.data)

    input
    |> Map.put(:xpubs, [new_xpub | xpubs])
  end

  defp add_tx_version(input, value) do
    input
    |> Map.put(:tx_version, value.data)
  end

  defp add_version(input, value) do
    version = Version.parse(value.data)

    case Map.get(version, :error) do
      nil ->
        input
        |> Map.put(:version, version)

      message ->
        input
        |> Map.put(:error, message)
    end
  end

  defp add_unknown(input, key, value) do
    input
    |> Map.put(:unknowns, [{key, value} | input.unknowns])
  end
end
