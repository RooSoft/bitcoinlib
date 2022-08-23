defmodule BitcoinLib.Key.HD.ExtendedPrivate.ChildFromDerivationPathTest do
  use ExUnit.Case, async: true

  doctest BitcoinLib.Key.HD.ExtendedPrivate.ChildFromDerivationPath

  alias BitcoinLib.Key.{PrivateKey}
  alias BitcoinLib.Key.HD.{DerivationPath}
  alias BitcoinLib.Key.HD.ExtendedPrivate.ChildFromDerivationPath

  test "Get a private key child from a derivation path" do
    private_key = %PrivateKey{
      key: 0xF79BB0D317B310B261A55A8AB393B4C8A1ABA6FA4D08AEF379CABA502D5D67F9,
      chain_code: 0x463223AAC10FB13F291A1BC76BC26003D98DA661CB76DF61E750C139826DEA8B
    }

    {:ok, child_private_key} =
      ChildFromDerivationPath.get(
        private_key,
        %DerivationPath{type: :private}
      )

    assert %PrivateKey{
             key: 0xF79BB0D317B310B261A55A8AB393B4C8A1ABA6FA4D08AEF379CABA502D5D67F9,
             chain_code: 0x463223AAC10FB13F291A1BC76BC26003D98DA661CB76DF61E750C139826DEA8B,
             depth: 0,
             index: 0
           } = child_private_key
  end
end
