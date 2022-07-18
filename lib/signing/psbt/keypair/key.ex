# defmodule BitcoinLib.Signing.Psbt.Keypair.Key do
#   @moduledoc """
#   Extracts a keypair's key from a binary
#   """
#   defstruct [:keylen, :keytype, :keydata]

#   alias BitcoinLib.Signing.Psbt.CompactInteger

#   defp extract_from(data) do
#     {keylen, data} = extract_keylen(data)
#     {keytype, data} = extract_keytype(data)
#     {keydata, data} = extract_keydata(data)

#   end

#   defp extract_keylen(data) do
#     {keylen, data} = CompactInteger.extract_from(data)
#     {keytype, data} = CompactInteger.extract_from(data)

#     keydata_length =

#     {keydata, data} =
#   end

#   defp extract_keytype(data) do

#   end

#   defp extract_keydata(data) do

#   end
# end
