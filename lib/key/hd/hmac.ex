defmodule BitcoinLib.Key.HD.Hmac do
  alias BitcoinLib.Crypto
  alias BitcoinLib.Key.HD.{ExtendedPublic, ExtendedPrivate}

  def get_input(%ExtendedPrivate{} = private_key, index, _hardened? = true)
      when is_integer(index) do
    binary_private_key = Binary.from_integer(private_key.key)

    <<(<<0>>), binary_private_key::bitstring, index::size(32)>>
  end

  def get_input(%ExtendedPublic{} = public_key, index, _hardened? = false)
      when is_integer(index) do
    binary_public_key = Binary.from_integer(public_key.key)

    <<binary_public_key::bitstring, index::size(32)>>
  end

  def compute(hmac_input, chain_code) do
    <<derived_key::256, child_chain::binary>> =
      hmac_input
      |> Crypto.hmac_bitstring(chain_code |> Binary.from_integer())

    {derived_key, child_chain}
  end
end
