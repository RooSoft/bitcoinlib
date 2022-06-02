compressed_public_key = "020f69ef8f2feb09b29393eef514761f22636b90d8e4d3f2138b2373bd37523053"

address =
  compressed_public_key
  |> BitcoinLib.generate_p2pkh_address()
