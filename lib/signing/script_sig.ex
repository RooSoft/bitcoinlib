defmodule BitcoinLib.Signing.ScriptSig do
  @byte 8

  @doc """
  Extracts the signature, the public key and the remaining data from a script_sig

  ## Examples
      iex> script_sig = <<0x49304602210096b0685ed376e4841443b51b183fc1bd9e8df6bce219b192d488faf8f1d58429022100a175822c319aa494f349f725654d54be5a8bf59147b02d80782abda5880f6f0a014104f0e5a53db9f85e5b2eecf677925ffe21dd1409bcfe9a0730404053599b0901e505f9f974e41c436248aa19a74dc2a85fd0f4d4d6ba40d635ccdc95458da645b3::1120>>
      ...> BitcoinLib.Signing.ScriptSig.decode(script_sig)
      %{
        signature: <<0x304602210096b0685ed376e4841443b51b183fc1bd9e8df6bce219b192d488faf8f1d58429022100a175822c319aa494f349f725654d54be5a8bf59147b02d80782abda5880f6f0a::576>>,
        public_key: <<0x04f0e5a53db9f85e5b2eecf677925ffe21dd1409bcfe9a0730404053599b0901e505f9f974e41c436248aa19a74dc2a85fd0f4d4d6ba40d635ccdc95458da645b3::520>>,
        remaining: <<>>
      }
  """
  def decode(script_sig) do
    <<signature_size::8, remaining::bitstring>> = script_sig

    signature_bit_size = (signature_size - 1) * @byte

    <<signature::bitstring-size(signature_bit_size), 1::8, _::8, public_key::bitstring-520,
      remaining::bitstring>> = remaining

    %{
      signature: signature,
      public_key: public_key,
      remaining: remaining
    }
  end
end
