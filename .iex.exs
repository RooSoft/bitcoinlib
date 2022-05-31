pk =
  "f6aaf1e16f0b7457955644eb1d4c92ef1c3995cdc3437a7d99c83ebcec45fd7b"
  |> String.upcase()
  |> Base.decode16!

wif = BitcoinLib.Key.Private.to_wif "6c7ab2f961a1bc3f13cdc08dc41c3f439adebd549a8ef1c089e81a5907376107"

IO.puts wif
