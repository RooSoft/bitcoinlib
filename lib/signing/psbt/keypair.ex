# defmodule BitcoinLib.Signing.Psbt.Keypair do
#   @moduledoc """
#   Extracts a keypair from a binary
#   """
#   defstruct [:key, :value]

#   alias BitcoinLib.Signing.Psbt.Keypair
#   alias BitcoinLib.Signing.Psbt.Keypair.{Key, Value}

#   def extract_from(data) do
#     {key, data} = extract_key(data)
#     {value, data} = extract_value(data)

#     %Keypair{key: key, value: value}
#   end

#   defp extract_key(data) do
#     {keylen, data} = extract_keylen(data)
#     {keytype, data} = extract_keytype(data)
#     {keydata, data} = extract_keydata(data)

#   end

#   defp extract_value(data) do

#   end
# end
