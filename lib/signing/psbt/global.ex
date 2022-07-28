defmodule BitcoinLib.Signing.Psbt.Global do
  defstruct [:unsigned_tx, tx_version: 0, xpubs: [], unknowns: []]

  alias BitcoinLib.Signing.Psbt.Global.{Xpub}
  alias BitcoinLib.Signing.Psbt.{Keypair, KeypairList, Global}
  alias BitcoinLib.Transaction

  @unsigned_tx 0
  @xpub 1
  @tx_version 2

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

  defp dispatch_keypair(%Keypair{key: key, value: value}, input) do
    case key.type do
      @unsigned_tx -> add_unsigned_tx(input, value)
      @xpub -> add_xpub(input, value)
      @tx_version -> add_tx_version(input, value)
      _ -> add_unknown(input, key, value)
    end
  end

  defp add_unsigned_tx(input, value) do
    unsigned_tx = Transaction.decode(value.data)

    case Transaction.check_if_unsigned(unsigned_tx) do
      true ->
        input
        |> Map.put(:unsigned_tx, unsigned_tx)

      false ->
        input
        |> Map.put(:error, "the supposedly unsigned transaction has already been signed")
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

  defp add_unknown(input, key, value) do
    input
    |> Map.put(:unknowns, [{key, value} | input.unknowns])
  end
end
