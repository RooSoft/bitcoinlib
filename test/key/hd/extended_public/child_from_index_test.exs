defmodule BitcoinLib.Key.HD.ExtendedPublic.ChildFromIndexTest do
  use ExUnit.Case, async: true

  doctest BitcoinLib.Key.HD.ExtendedPublic.ChildFromIndex

#  alias BitcoinLib.Key.HD.{ExtendedPublic}
#  alias BitcoinLib.Key.HD.ExtendedPublic.ChildFromIndex

  # test "Get a private key child from a derivation path" do
  #   public_key = %ExtendedPublic{
  #     key: 0x2702DED1CCA9816FA1A94787FFC6F3ACE62CD3B63164F76D227D0935A33EE48C3,
  #     chain_code: 0xA17100DD000D9D4A37034F7CEE0D46F5AE97B570BE065E57A00546FAE014A8A2
  #   }

  #   index = 0

  #   {:ok, child_public_key} = ChildFromIndex.get(public_key, index)

  #   assert %ExtendedPublic{
  #            key: 0x2FC5BA55A539899D67EE66E99EE50AB59DCCBB122025D18C5EB9446D380A9EC0A,
  #            chain_code: 0x5066E8401D08A0DED8EB3E81E17822B7DD026CE5782E30287133D1BC79A78893,
  #            depth: 1,
  #            index: 0,
  #            parent_fingerprint: 0x18C1259
  #          } == child_public_key
  # end
end
