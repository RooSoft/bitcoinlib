defmodule BitcoinLib.Signing.Psbt.Input.NonWitnessUtxoTest do
  use ExUnit.Case, async: true

  doctest BitcoinLib.Signing.Psbt.Input.NonWitnessUtxo

  alias BitcoinLib.Signing.Psbt.Input.NonWitnessUtxo
  alias BitcoinLib.Signing.Psbt.Keypair
  alias BitcoinLib.Signing.Psbt.Keypair.{Key, Value}
  alias BitcoinLib.Transaction

  test "create a non-witness UTXO from a keypair" do
    keypair = %Keypair{
      key: %Key{data: "", length: 1, type: 0},
      value: %Value{
        data:
          <<0x0200000001AAD73931018BD25F84AE400B68848BE09DB706EAC2AC18298BABEE71AB656F8B0000000048473044022058F6FC7C6A33E1B31548D481C826C015BD30135AAD42CD67790DAB66D2AD243B02204A1CED2604C6735B6393E5B41691DD78B00F0C5942FB9F751856FAA938157DBA01FEFFFFFF0280F0FA020000000017A9140FB9463421696B82C833AF241C78C17DDBDE493487D0F20A270100000017A91429CA74F8A08F81999428185C97B5D852E4063F618765000000::1496>>,
        length: 187
      }
    }

    %NonWitnessUtxo{
      transaction: %Transaction{
        inputs: inputs,
        outputs: outputs
      }
    } = non_witness_utxo = NonWitnessUtxo.parse(keypair)

    assert nil == Map.get(non_witness_utxo, :error)

    assert 1 == Enum.count(inputs)
    assert 2 == Enum.count(outputs)
  end
end
