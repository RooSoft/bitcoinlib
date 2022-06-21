defmodule BitcoinLib.Key.HD.ExtendedPrivate.ChildFromIndex do
  alias BitcoinLib.Key.HD.ExtendedPrivate

  @max_index 0x7FFFFFFF
  @hardened 0x80000000

  # this is n, as found here https://en.bitcoin.it/wiki/Secp256k1
  @order_of_the_curve 0xFFFFFFFF_FFFFFFFF_FFFFFFFF_FFFFFFFE_BAAEDCE6_AF48A03B_BFD25E8C_D0364141

  alias BitcoinLib.Crypto
  alias BitcoinLib.Key.HD.{ExtendedPrivate, ExtendedPublic}

  @spec get(%ExtendedPrivate{}, Integer.t(), Integer.t()) ::
          {:ok, %ExtendedPrivate{}} | {:error, String.t()}
  def get(private_key, index, is_hardened \\ false)

  def get(_, index, _) when is_integer(index) and index > @max_index do
    {:error, "#{index} is too large of an index"}
  end

  def get(%ExtendedPrivate{} = private_key, index, is_hardened) when is_integer(index) do
    index =
      case is_hardened do
        true -> @hardened + index
        false -> index
      end

    public_key = ExtendedPublic.from_private_key(private_key)

    %{child_private_key: child_private_key} =
      %{parent_private_key: private_key, index: index}
      |> add_public_key
      |> compute_hmac_input
      |> compute_hmac
      |> compute_parent_fingerprint(public_key)
      |> compute_child_chain_code
      |> compute_child_private_key

    {:ok, child_private_key}
  end

  defp add_public_key(%{parent_private_key: private_key} = hash) do
    public_key =
      private_key
      |> ExtendedPublic.from_private_key()

    hash
    |> Map.put(:public_key, public_key)
  end

  defp compute_hmac_input(%{public_key: public_key, index: index} = hash) do
    binary_public_key = Binary.from_integer(public_key.key)

    hmac_input = <<binary_public_key::bitstring, index::size(32)>> |> Binary.to_integer()

    hash
    |> Map.put(:hmac_input, hmac_input)
  end

  # hmac_left_part and hmac_right_part are Il and Ir in slip-0010 as found here
  # https://github.com/satoshilabs/slips/blob/master/slip-0010.md#master-key-generation
  defp compute_hmac(
         %{hmac_input: hmac_input, parent_private_key: %ExtendedPrivate{chain_code: chain_code}} =
           hash
       ) do
    {hmac_left_part, hmac_right_part} =
      hmac_input
      |> Binary.from_integer()
      |> Crypto.hmac_bitstring(chain_code |> Binary.from_integer())
      |> String.split_at(32)

    hash
    |> Map.put(:hmac_left_part, hmac_left_part)
    |> Map.put(:hmac_right_part, hmac_right_part)
  end

  defp compute_parent_fingerprint(hash, %ExtendedPublic{} = public_key) do
    parent_fingerprint =
      public_key
      |> ExtendedPublic.get_hash()
      |> Integer.to_string(16)
      |> String.slice(0, 4)
      |> Integer.parse(16)
      |> elem(0)

    hash
    |> Map.put(:parent_fingerprint, parent_fingerprint)
  end

  defp compute_child_chain_code(%{hmac_right_part: hmac_right_part} = hash) do
    hash
    |> Map.put(:child_chain_code, hmac_right_part |> Binary.to_integer())
  end

  defp compute_child_private_key(
         %{
           parent_private_key: parent_private_key,
           index: index,
           hmac_left_part: hmac_left_part,
           hmac_right_part: hmac_right_part,
           parent_fingerprint: parent_fingerprint
         } = hash
       ) do
    child_private_key =
      (Binary.to_integer(hmac_left_part) + parent_private_key.key)
      |> rem(@order_of_the_curve)

    hash
    |> Map.put(:child_private_key, %ExtendedPrivate{
      key: child_private_key,
      chain_code: hmac_right_part |> Binary.to_integer(),
      depth: parent_private_key.depth + 1,
      index: index,
      parent_fingerprint: parent_fingerprint
    })
  end
end
