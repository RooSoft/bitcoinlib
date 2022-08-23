defmodule BitcoinLib.Test.Integration.Secp256k1.SignAndVerivy do
  use ExUnit.Case, async: true

  alias BitcoinLib.Crypto.{Secp256k1}
  alias BitcoinLib.Key.{PrivateKey, Public}
  alias BitcoinLib.Key.HD.{ExtendedPublic, MnemonicSeed}

  test "sign a message and make sure it verifies to true" do
    {pub, prv} =
      :crypto.generate_key(
        :ecdh,
        :secp256k1,
        <<0xD6EAD233E06C068585976B5C8373861D77E7F030EC452E65EE81C85FA6906970::256>>
      )

    message = "76a914725ebac06343111227573d0b5287954ef9b88aae88ac"

    signature = Secp256k1.sign(message, prv)

    assert Secp256k1.validate(signature, message, pub)
  end

  test "verify a signature with a compressed public key" do
    {pub, prv} =
      :crypto.generate_key(
        :ecdh,
        :secp256k1,
        <<0xD6EAD233E06C068585976B5C8373861D77E7F030EC452E65EE81C85FA6906970::256>>
      )

    {uncompressed_pub, compressed_pub} =
      <<0xD6EAD233E06C068585976B5C8373861D77E7F030EC452E65EE81C85FA6906970::256>>
      |> Public.from_private_key()

    assert uncompressed_pub == pub

    message = "76a914725ebac06343111227573d0b5287954ef9b88aae88ac"

    signature = Secp256k1.sign(message, prv)

    assert Secp256k1.validate(signature, message, compressed_pub)
  end

  test "compare public keys from :crypto and BitcoinLib" do
    private_key_in = <<0xD6EAD233E06C068585976B5C8373861D77E7F030EC452E65EE81C85FA6906970::256>>

    {public_key_out, private_key_out} =
      :crypto.generate_key(
        :ecdh,
        :secp256k1,
        private_key_in
      )

    {long_bitcoinlib_pub_key, _short_version} = Public.from_private_key(private_key_out)

    assert public_key_out == long_bitcoinlib_pub_key
    assert private_key_in == private_key_out
  end

  test "secp256k1 issues ever changing signatures" do
    prv = <<0xD6EAD233E06C068585976B5C8373861D77E7F030EC452E65EE81C85FA6906970::256>>
    message = "76a914725ebac06343111227573d0b5287954ef9b88aae88ac"

    sig1 = :crypto.sign(:ecdsa, :sha256, message, [prv, :secp256k1])
    sig2 = :crypto.sign(:ecdsa, :sha256, message, [prv, :secp256k1])
    sig3 = :crypto.sign(:ecdsa, :sha256, message, [prv, :secp256k1])
    sig4 = :crypto.sign(:ecdsa, :sha256, message, [prv, :secp256k1])

    assert sig1 != sig2
    assert sig2 != sig3
    assert sig3 != sig4
  end

  test "sign a message with private key from a mnemonic phrase and make sure it verifies to true" do
    extended_private_key =
      "rally celery split order almost twenty ignore record legend learn chaos decade"
      |> MnemonicSeed.to_seed()
      |> PrivateKey.from_seed()
      |> PrivateKey.from_derivation_path!("m/44'/0'/0'/0/0")

    extended_public_key =
      extended_private_key
      |> ExtendedPublic.from_private_key()

    message = "76a914725ebac06343111227573d0b5287954ef9b88aae88ac"

    signature = Secp256k1.sign(message, extended_private_key.key)

    assert Secp256k1.validate(signature, message, extended_public_key.key)
  end
end
