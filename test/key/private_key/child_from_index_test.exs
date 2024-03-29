defmodule BitcoinLib.Key.PrivateKey.ChildFromIndexTest do
  use ExUnit.Case, async: true

  doctest BitcoinLib.Key.PrivateKey.ChildFromIndex

  alias BitcoinLib.Key.{PrivateKey}
  alias BitcoinLib.Key.PrivateKey.ChildFromIndex

  test "Get a private key child from a derivation path" do
    private_key = %PrivateKey{
      key: <<0xF79BB0D317B310B261A55A8AB393B4C8A1ABA6FA4D08AEF379CABA502D5D67F9::256>>,
      chain_code: <<0x463223AAC10FB13F291A1BC76BC26003D98DA661CB76DF61E750C139826DEA8B::256>>
    }

    index = 0

    {:ok, child_private_key} = ChildFromIndex.get(private_key, index)

    %PrivateKey{
      key: <<0x39F329FEDBA2A68E2A804FCD9AEEA4104ACE9080212A52CE8B52C1FB89850C72::256>>,
      chain_code: <<0x05AAE71D7C080474EFAAB01FA79E96F4C6CFE243237780B0DF4BC36106228E31::256>>,
      depth: 1,
      index: 0,
      parent_fingerprint: <<0x18C1259::32>>
    } = child_private_key
  end
end
