defmodule BitcoinLib.Key.ExtendedPrivate do
  @moduledoc """
  Bitcoin extended private key management module
  """

  @bitcoin_seed_hmac_key "Bitcoin seed"
  @private_key_length 32

  alias BitcoinLib.Crypto

  def from_seed(seed) do
    seed
    |> Crypto.hmac_bitstring(@bitcoin_seed_hmac_key)
    |> split
  end

  defp split(extended_private_key) do
    <<private_key::binary-32, chain_code::binary-32>> = extended_private_key

    %{
      private_key: private_key,
      chain_code: chain_code
    }
  end
end
