defmodule BitcoinLib.Key.HD.ExtendedPublic.ChildFromDerivationPathTest do
  use ExUnit.Case, async: true

  doctest BitcoinLib.Key.HD.ExtendedPublic.ChildFromDerivationPath

  alias BitcoinLib.Key.HD.{DerivationPath, ExtendedPublic}
  alias BitcoinLib.Key.HD.ExtendedPublic.ChildFromDerivationPath

  test "Get a public key child from a derivation path" do
    public_key = %BitcoinLib.Key.HD.ExtendedPublic{
      key: 0x252C616D91A2488C1FD1F0F172E98F7D1F6E51F8F389B2F8D632A8B490D5F6DA9,
      chain_code: 0x463223AAC10FB13F291A1BC76BC26003D98DA661CB76DF61E750C139826DEA8B
    }

    {:ok, child_public_key} =
      ChildFromDerivationPath.get(
        public_key,
        %DerivationPath{type: :public}
      )

    assert %ExtendedPublic{
             key: 0x252C616D91A2488C1FD1F0F172E98F7D1F6E51F8F389B2F8D632A8B490D5F6DA9,
             chain_code: 0x463223AAC10FB13F291A1BC76BC26003D98DA661CB76DF61E750C139826DEA8B,
             depth: 0,
             index: 0,
             parent_fingerprint: 0
           } = child_public_key
  end
end
