defmodule BitcoinLib.Key.HD.ExtendedPrivate.ChildFromIndexTest do
  use ExUnit.Case, async: true

  doctest BitcoinLib.Key.HD.ExtendedPrivate.ChildFromIndex

  alias BitcoinLib.Key.HD.{ExtendedPrivate}
  alias BitcoinLib.Key.HD.ExtendedPrivate.ChildFromIndex

  test "Get a private key child from a derivation path" do
    private_key = %ExtendedPrivate{
      key: 0xF79BB0D317B310B261A55A8AB393B4C8A1ABA6FA4D08AEF379CABA502D5D67F9,
      chain_code: 0x463223AAC10FB13F291A1BC76BC26003D98DA661CB76DF61E750C139826DEA8B
    }

    index = 0

    {:ok, child_private_key} = ChildFromIndex.get(private_key, index)

    %ExtendedPrivate{
      key: 0x39F329FEDBA2A68E2A804FCD9AEEA4104ACE9080212A52CE8B52C1FB89850C72,
      chain_code: 0x05AAE71D7C080474EFAAB01FA79E96F4C6CFE243237780B0DF4BC36106228E31,
      depth: 0,
      index: 0,
      parent_fingerprint: ""
    } = child_private_key
  end
end
