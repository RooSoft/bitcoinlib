defmodule BitcoinLib.Key.PublicKey.ChildFromDerivationPathTest do
  use ExUnit.Case, async: true

  doctest BitcoinLib.Key.PublicKey.ChildFromDerivationPath

  alias BitcoinLib.Key.PublicKey
  alias BitcoinLib.Key.PublicKey.ChildFromDerivationPath
  alias BitcoinLib.Key.HD.{DerivationPath}

  test "Get a public key child from a derivation path" do
    public_key = %PublicKey{
      key: <<0x252C616D91A2488C1FD1F0F172E98F7D1F6E51F8F389B2F8D632A8B490D5F6DA9::264>>,
      chain_code: <<0x463223AAC10FB13F291A1BC76BC26003D98DA661CB76DF61E750C139826DEA8B::256>>
    }

    {:ok, child_public_key} =
      ChildFromDerivationPath.get(
        public_key,
        %DerivationPath{type: :public}
      )

    assert %PublicKey{
             key: <<0x252C616D91A2488C1FD1F0F172E98F7D1F6E51F8F389B2F8D632A8B490D5F6DA9::264>>,
             chain_code:
               <<0x463223AAC10FB13F291A1BC76BC26003D98DA661CB76DF61E750C139826DEA8B::256>>,
             depth: 0,
             index: 0
           } = child_public_key
  end
end
