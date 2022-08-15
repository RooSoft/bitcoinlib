defmodule BitcoinLib.Test.Integration.Secp256k1.SignAndVerivy do
  use ExUnit.Case, async: true

  test "sign a message and make sure it verifies to true" do
    {pub, prv} =
      :crypto.generate_key(
        :ecdh,
        :secp256k1,
        <<0xD6EAD233E06C068585976B5C8373861D77E7F030EC452E65EE81C85FA6906970::256>>
      )

    message = "this is the message to be signed"

    signature = :crypto.sign(:ecdsa, :sha256, message, [prv, :secp256k1])

    assert :crypto.verify(:ecdsa, :sha256, message, signature, [pub, :secp256k1])
  end

  test "compare public keys from :crypto and BitcoinLib" do
    private_key_in = <<0xD6EAD233E06C068585976B5C8373861D77E7F030EC452E65EE81C85FA6906970::256>>

    {public_key_out, private_key_out} =
      :crypto.generate_key(
        :ecdh,
        :secp256k1,
        private_key_in
      )

    {long_bitcoinlib_pub_key, _short_version} = BitcoinLib.Key.Public.from_private_key(private_key_out)

    assert public_key_out == long_bitcoinlib_pub_key
    assert private_key_in == private_key_out
  end
end
