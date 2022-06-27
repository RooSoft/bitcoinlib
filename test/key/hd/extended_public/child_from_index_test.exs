defmodule BitcoinLib.Key.HD.ExtendedPublic.ChildFromIndexTest do
  use ExUnit.Case, async: true

  doctest BitcoinLib.Key.HD.ExtendedPublic.ChildFromIndex

  alias BitcoinLib.Key.HD.{ExtendedPublic}
  alias BitcoinLib.Key.HD.ExtendedPublic.ChildFromIndex

  test "Get a private key child from a derivation path" do
    public_key = %ExtendedPublic{
      key: 0x252C616D91A2488C1FD1F0F172E98F7D1F6E51F8F389B2F8D632A8B490D5F6DA9,
      chain_code: 0x463223AAC10FB13F291A1BC76BC26003D98DA661CB76DF61E750C139826DEA8B
    }

    index = 0

    {:ok, child_public_key} = ChildFromIndex.get(public_key, index)

    %ExtendedPublic{
      key: 0x951D9004DE141E9DC5FA045A15F3E71AE5592C2E5D74332CB4E034679950D0E1,
      chain_code: 0x05AAE71D7C080474EFAAB01FA79E96F4C6CFE243237780B0DF4BC36106228E31,
      depth: 1,
      index: 0,
      parent_fingerprint: 0x18C1259
    } = child_public_key
  end
end
