defmodule BitcoinLib.Test.Integration.Bip174.ValidPsbtsTest do
  @moduledoc """
  These are from the valid PSBT section of this document https://github.com/bitcoin/bips/blob/master/bip-0174.mediawiki#test-vectors
  """
  use ExUnit.Case, async: true

  alias BitcoinLib.Transaction
  alias BitcoinLib.Signing.Psbt
  alias BitcoinLib.Signing.Psbt.{Global, Input, Output, Keypair}

  alias BitcoinLib.Signing.Psbt.Global.{Xpub}

  alias BitcoinLib.Signing.Psbt.GenericProperties.{Bip32Derivation}

  alias BitcoinLib.Signing.Psbt.Input.{
    NonWitnessUtxo,
    WitnessUtxo
    #   SighashType,
  }

  ### CASE THAT https://bip174.org CAN'T EVEN PARSE
  # @doc """
  # based on https://github.com/bitcoin/bips/blob/master/bip-0084.mediawiki#test-vectors
  # """
  # test "Case: PSBT with one P2PKH input. Outputs are empty" do
  #   base_64 =
  #     "cHNidP8BAHUCAAAAASaBcTce3/KF6Tet7qSze3gADAVmy7OtZGQXE8pCFxv2AAAAAAD+////AtPf9QUAAAAAGXapFNDFmQPFusKGh2DpD9UhpGZap2UgiKwA4fUFAAAAABepFDVF5uM7gyxHBQ8k0+65PJwDlIvHh7MuEwAAAQD9pQEBAAAAAAECiaPHHqtNIOA3G7ukzGmPopXJRjr6Ljl/hTPMti+VZ+UBAAAAFxYAFL4Y0VKpsBIDna89p95PUzSe7LmF/////4b4qkOnHf8USIk6UwpyN+9rRgi7st0tAXHmOuxqSJC0AQAAABcWABT+Pp7xp0XpdNkCxDVZQ6vLNL1TU/////8CAMLrCwAAAAAZdqkUhc/xCX/Z4Ai7NK9wnGIZeziXikiIrHL++E4sAAAAF6kUM5cluiHv1irHU6m80GfWx6ajnQWHAkcwRAIgJxK+IuAnDzlPVoMR3HyppolwuAJf3TskAinwf4pfOiQCIAGLONfc0xTnNMkna9b7QPZzMlvEuqFEyADS8vAtsnZcASED0uFWdJQbrUqZY3LLh+GFbTZSYG2YVi/jnF6efkE/IQUCSDBFAiEA0SuFLYXc2WHS9fSrZgZU327tzHlMDDPOXMMJ/7X85Y0CIGczio4OFyXBl/saiK9Z9R5E5CVbIBZ8hoQDHAXR8lkqASECI7cr7vCWXRC+B3jv7NYfysb3mk6haTkzgHNEZPhPKrMAAAAAAAAA"

  #   {:ok, psbt} = base_64 |> Psbt.parse()

  #   assert [%Input{utxo: %BitcoinLib.Signing.Psbt.Input.NonWitnessUtxo{}}] = psbt.inputs
  #   assert [] = psbt.outputs
  # end

  test "Case: PSBT with one P2PKH input and one P2SH-P2WPKH input. First input is signed and finalized. Outputs are empty" do
    base_64 =
      "cHNidP8BAKACAAAAAqsJSaCMWvfEm4IS9Bfi8Vqz9cM9zxU4IagTn4d6W3vkAAAAAAD+////qwlJoIxa98SbghL0F+LxWrP1wz3PFTghqBOfh3pbe+QBAAAAAP7///8CYDvqCwAAAAAZdqkUdopAu9dAy+gdmI5x3ipNXHE5ax2IrI4kAAAAAAAAGXapFG9GILVT+glechue4O/p+gOcykWXiKwAAAAAAAEHakcwRAIgR1lmF5fAGwNrJZKJSGhiGDR9iYZLcZ4ff89X0eURZYcCIFMJ6r9Wqk2Ikf/REf3xM286KdqGbX+EhtdVRs7tr5MZASEDXNxh/HupccC1AaZGoqg7ECy0OIEhfKaC3Ibi1z+ogpIAAQEgAOH1BQAAAAAXqRQ1RebjO4MsRwUPJNPuuTycA5SLx4cBBBYAFIXRNTfy4mVAWjTbr6nj3aAfuCMIAAAA"

    {:ok, psbt} = base_64 |> Psbt.parse()

    assert [
             %Input{
               utxo: nil,
               final_script_sig: [
                 %BitcoinLib.Script.Opcodes.Data{
                   value:
                     <<0x304402204759661797C01B036B25928948686218347D89864B719E1F7FCF57D1E511658702205309EABF56AA4D8891FFD111FDF1336F3A29DA866D7F8486D75546CEEDAF931901::568>>
                 },
                 %BitcoinLib.Script.Opcodes.Data{
                   value:
                     <<0x035CDC61FC7BA971C0B501A646A2A83B102CB43881217CA682DC86E2D73FA88292::264>>
                 }
               ]
             },
             %Input{utxo: %WitnessUtxo{}}
           ] = psbt.inputs

    assert [] = psbt.outputs
  end

  ### CASE THAT https://bip174.org CAN'T EVEN PARSE
  # test "Case: PSBT with one P2PKH input which has a non-final scriptSig and has a sighash type specified. Outputs are empty" do
  #   base_64 =
  #     "cHNidP8BAHUCAAAAASaBcTce3/KF6Tet7qSze3gADAVmy7OtZGQXE8pCFxv2AAAAAAD+////AtPf9QUAAAAAGXapFNDFmQPFusKGh2DpD9UhpGZap2UgiKwA4fUFAAAAABepFDVF5uM7gyxHBQ8k0+65PJwDlIvHh7MuEwAAAQD9pQEBAAAAAAECiaPHHqtNIOA3G7ukzGmPopXJRjr6Ljl/hTPMti+VZ+UBAAAAFxYAFL4Y0VKpsBIDna89p95PUzSe7LmF/////4b4qkOnHf8USIk6UwpyN+9rRgi7st0tAXHmOuxqSJC0AQAAABcWABT+Pp7xp0XpdNkCxDVZQ6vLNL1TU/////8CAMLrCwAAAAAZdqkUhc/xCX/Z4Ai7NK9wnGIZeziXikiIrHL++E4sAAAAF6kUM5cluiHv1irHU6m80GfWx6ajnQWHAkcwRAIgJxK+IuAnDzlPVoMR3HyppolwuAJf3TskAinwf4pfOiQCIAGLONfc0xTnNMkna9b7QPZzMlvEuqFEyADS8vAtsnZcASED0uFWdJQbrUqZY3LLh+GFbTZSYG2YVi/jnF6efkE/IQUCSDBFAiEA0SuFLYXc2WHS9fSrZgZU327tzHlMDDPOXMMJ/7X85Y0CIGczio4OFyXBl/saiK9Z9R5E5CVbIBZ8hoQDHAXR8lkqASECI7cr7vCWXRC+B3jv7NYfysb3mk6haTkzgHNEZPhPKrMAAAAAAQMEAQAAAAAAAA=="

  #   {:ok, psbt} = base_64 |> Psbt.parse()

  #   assert [%Input{utxo: %NonWitnessUtxo{}, sighash_type: %SighashType{}}] = psbt.inputs

  #   assert [] = psbt.outputs
  # end

  test "Case: PSBT with one P2PKH input and one P2SH-P2WPKH input both with non-final scriptSigs. P2SH-P2WPKH input's redeemScript is available. Outputs filled." do
    base_64 =
      "cHNidP8BAKACAAAAAqsJSaCMWvfEm4IS9Bfi8Vqz9cM9zxU4IagTn4d6W3vkAAAAAAD+////qwlJoIxa98SbghL0F+LxWrP1wz3PFTghqBOfh3pbe+QBAAAAAP7///8CYDvqCwAAAAAZdqkUdopAu9dAy+gdmI5x3ipNXHE5ax2IrI4kAAAAAAAAGXapFG9GILVT+glechue4O/p+gOcykWXiKwAAAAAAAEA3wIAAAABJoFxNx7f8oXpN63upLN7eAAMBWbLs61kZBcTykIXG/YAAAAAakcwRAIgcLIkUSPmv0dNYMW1DAQ9TGkaXSQ18Jo0p2YqncJReQoCIAEynKnazygL3zB0DsA5BCJCLIHLRYOUV663b8Eu3ZWzASECZX0RjTNXuOD0ws1G23s59tnDjZpwq8ubLeXcjb/kzjH+////AtPf9QUAAAAAGXapFNDFmQPFusKGh2DpD9UhpGZap2UgiKwA4fUFAAAAABepFDVF5uM7gyxHBQ8k0+65PJwDlIvHh7MuEwAAAQEgAOH1BQAAAAAXqRQ1RebjO4MsRwUPJNPuuTycA5SLx4cBBBYAFIXRNTfy4mVAWjTbr6nj3aAfuCMIACICAurVlmh8qAYEPtw94RbN8p1eklfBls0FXPaYyNAr8k6ZELSmumcAAACAAAAAgAIAAIAAIgIDlPYr6d8ZlSxVh3aK63aYBhrSxKJciU9H2MFitNchPQUQtKa6ZwAAAIABAACAAgAAgAA="

    {:ok, psbt} = base_64 |> Psbt.parse()

    assert [
             %Input{utxo: %NonWitnessUtxo{}},
             %Input{utxo: %WitnessUtxo{}}
           ] = psbt.inputs

    assert [%Output{}, %Output{}] = psbt.outputs
  end

  test "Case: PSBT with one P2SH-P2WSH input of a 2-of-2 multisig, redeemScript, witnessScript, and keypaths are available. Contains one signature." do
    base_64 =
      "cHNidP8BAFUCAAAAASeaIyOl37UfxF8iD6WLD8E+HjNCeSqF1+Ns1jM7XLw5AAAAAAD/////AaBa6gsAAAAAGXapFP/pwAYQl8w7Y28ssEYPpPxCfStFiKwAAAAAAAEBIJVe6gsAAAAAF6kUY0UgD2jRieGtwN8cTRbqjxTA2+uHIgIDsTQcy6doO2r08SOM1ul+cWfVafrEfx5I1HVBhENVvUZGMEMCIAQktY7/qqaU4VWepck7v9SokGQiQFXN8HC2dxRpRC0HAh9cjrD+plFtYLisszrWTt5g6Hhb+zqpS5m9+GFR25qaAQEEIgAgdx/RitRZZm3Unz1WTj28QvTIR3TjYK2haBao7UiNVoEBBUdSIQOxNBzLp2g7avTxI4zW6X5xZ9Vp+sR/HkjUdUGEQ1W9RiED3lXR4drIBeP4pYwfv5uUwC89uq/hJ/78pJlfJvggg71SriIGA7E0HMunaDtq9PEjjNbpfnFn1Wn6xH8eSNR1QYRDVb1GELSmumcAAACAAAAAgAQAAIAiBgPeVdHh2sgF4/iljB+/m5TALz26r+En/vykmV8m+CCDvRC0prpnAAAAgAAAAIAFAACAAAA="

    {:ok, psbt} = base_64 |> Psbt.parse()

    assert [
             %Input{
               utxo: %WitnessUtxo{},
               bip32_derivations: [%Bip32Derivation{}, %Bip32Derivation{}],
               redeem_script: [
                 %BitcoinLib.Script.Opcodes.Constants.Zero{},
                 %BitcoinLib.Script.Opcodes.Data{
                   value:
                     <<0x771FD18AD459666DD49F3D564E3DBC42F4C84774E360ADA16816A8ED488D5681::256>>
                 }
               ],
               witness_script: [
                 %BitcoinLib.Script.Opcodes.Constants.Two{},
                 %BitcoinLib.Script.Opcodes.Data{
                   value:
                     <<0x03B1341CCBA7683B6AF4F1238CD6E97E7167D569FAC47F1E48D47541844355BD46::264>>
                 },
                 %BitcoinLib.Script.Opcodes.Data{
                   value:
                     <<0x03DE55D1E1DAC805E3F8A58C1FBF9B94C02F3DBAAFE127FEFCA4995F26F82083BD::264>>
                 },
                 %BitcoinLib.Script.Opcodes.Constants.Two{},
                 %BitcoinLib.Script.Opcodes.Crypto.CheckMultiSig{}
               ]
             }
           ] = psbt.inputs
  end

  test "Case: PSBT with one P2WSH input of a 2-of-2 multisig. witnessScript, keypaths, and global xpubs are available. Contains no signatures. Outputs filled." do
    base_64 =
      "cHNidP8BAFICAAAAAZ38ZijCbFiZ/hvT3DOGZb/VXXraEPYiCXPfLTht7BJ2AQAAAAD/////AfA9zR0AAAAAFgAUezoAv9wU0neVwrdJAdCdpu8TNXkAAAAATwEENYfPAto/0AiAAAAAlwSLGtBEWx7IJ1UXcnyHtOTrwYogP/oPlMAVZr046QADUbdDiH7h1A3DKmBDck8tZFmztaTXPa7I+64EcvO8Q+IM2QxqT64AAIAAAACATwEENYfPAto/0AiAAAABuQRSQnE5zXjCz/JES+NTzVhgXj5RMoXlKLQH+uP2FzUD0wpel8itvFV9rCrZp+OcFyLrrGnmaLbyZnzB1nHIPKsM2QxqT64AAIABAACAAAEBKwBlzR0AAAAAIgAgLFSGEmxJeAeagU4TcV1l82RZ5NbMre0mbQUIZFuvpjIBBUdSIQKdoSzbWyNWkrkVNq/v5ckcOrlHPY5DtTODarRWKZyIcSEDNys0I07Xz5wf6l0F1EFVeSe+lUKxYusC4ass6AIkwAtSriIGAp2hLNtbI1aSuRU2r+/lyRw6uUc9jkO1M4NqtFYpnIhxENkMak+uAACAAAAAgAAAAAAiBgM3KzQjTtfPnB/qXQXUQVV5J76VQrFi6wLhqyzoAiTACxDZDGpPrgAAgAEAAIAAAAAAACICA57/H1R6HV+S36K6evaslxpL0DukpzSwMVaiVritOh75EO3kXMUAAACAAAAAgAEAAIAA"

    {:ok, psbt} = base_64 |> Psbt.parse()

    assert %Global{
             xpubs: [%Xpub{}, %Xpub{}]
           } = psbt.global

    assert [
             %Input{
               utxo: %WitnessUtxo{},
               bip32_derivations: [%Bip32Derivation{}, %Bip32Derivation{}],
               witness_script: [
                 %BitcoinLib.Script.Opcodes.Constants.Two{},
                 %BitcoinLib.Script.Opcodes.Data{
                   value:
                     <<0x029DA12CDB5B235692B91536AFEFE5C91C3AB9473D8E43B533836AB456299C8871::264>>
                 },
                 %BitcoinLib.Script.Opcodes.Data{
                   value:
                     <<0x03372B34234ED7CF9C1FEA5D05D441557927BE9542B162EB02E1AB2CE80224C00B::264>>
                 },
                 %BitcoinLib.Script.Opcodes.Constants.Two{},
                 %BitcoinLib.Script.Opcodes.Crypto.CheckMultiSig{}
               ]
             }
           ] = psbt.inputs

    assert [%Output{}] = psbt.outputs
  end

  test "Case: PSBT with unknown types in the inputs." do
    base_64 =
      "cHNidP8BAD8CAAAAAf//////////////////////////////////////////AAAAAAD/////AQAAAAAAAAAAA2oBAAAAAAAACvABAgMEBQYHCAkPAQIDBAUGBwgJCgsMDQ4PAAA="

    {:ok, psbt} = base_64 |> Psbt.parse()

    assert [%Input{unknowns: [%Keypair{}]}] = psbt.inputs

    assert [] = psbt.outputs
  end

  # test "Case: PSBT with `PSBT_GLOBAL_XPUB`" do
  #   base_64 =
  #     "cHNidP8BAJ0BAAAAAnEOp2q0XFy2Q45gflnMA3YmmBgFrp4N/ZCJASq7C+U1AQAAAAD/////GQmU1qizyMgsy8+y+6QQaqBmObhyqNRHRlwNQliNbWcAAAAAAP////8CAOH1BQAAAAAZdqkUtrwsDuVlWoQ9ea/t0MzD991kNAmIrGBa9AUAAAAAFgAUEYjvjkzgRJ6qyPsUHL9aEXbmoIgAAAAATwEEiLIeA55TDKyAAAAAPbyKXJdp8DGxfnf+oVGGAyIaGP0Y8rmlTGyMGsdcvDUC8jBYSxVdHH8c1FEgplPEjWULQxtnxbLBPyfXFCA3wWkQJ1acUDEAAIAAAACAAAAAgAABAR8A4fUFAAAAABYAFDO5gvkbKPFgySC0q5XljOUN2jpKIgIDMJaA8zx9446mpHzU7NZvH1pJdHxv+4gI7QkDkkPjrVxHMEQCIC1wTO2DDFapCTRL10K2hS3M0QPpY7rpLTjnUlTSu0JFAiAthsQ3GV30bAztoITyopHD2i1kBw92v5uQsZXn7yj3cgEiBgMwloDzPH3jjqakfNTs1m8fWkl0fG/7iAjtCQOSQ+OtXBgnVpxQMQAAgAAAAIAAAACAAAAAAAEAAAAAAQEfAOH1BQAAAAAWABQ4j7lEMH63fvRRl9CwskXgefAR3iICAsd3Fh9z0LfHK57nveZQKT0T8JW8dlatH1Jdpf0uELEQRzBEAiBMsftfhpyULg4mEAV2ElQ5F5rojcqKncO6CPeVOYj6pgIgUh9JynkcJ9cOJzybFGFphZCTYeJb4nTqIA1+CIJ+UU0BIgYCx3cWH3PQt8crnue95lApPRPwlbx2Vq0fUl2l/S4QsRAYJ1acUDEAAIAAAACAAAAAgAAAAAAAAAAAAAAiAgLSDKUC7iiWhtIYFb1DqAY3sGmOH7zb5MrtRF9sGgqQ7xgnVpxQMQAAgAAAAIAAAACAAAAAAAQAAAAA"

  #   {:ok, psbt} = base_64 |> Psbt.parse() |> IO.inspect()

  #   assert %Global{xpubs: [%Xpub{}]} = psbt.global
  # end

  test "Case: PSBT with global unsigned tx that has 0 inputs and 0 outputs" do
    base_64 =
      "cHNidP8BAEwCAAAAAALT3/UFAAAAABl2qRTQxZkDxbrChodg6Q/VIaRmWqdlIIisAOH1BQAAAAAXqRQ1RebjO4MsRwUPJNPuuTycA5SLx4ezLhMAAAAA"

    {:ok, psbt} = base_64 |> Psbt.parse()

    assert %Global{unsigned_tx: %Transaction{}} = psbt.global
    assert [] = psbt.inputs
    assert [] = psbt.outputs
  end

  test "Case: PSBT with 0 inputs" do
    base_64 =
      "cHNidP8BAEwCAAAAAALT3/UFAAAAABl2qRTQxZkDxbrChodg6Q/VIaRmWqdlIIisAOH1BQAAAAAXqRQ1RebjO4MsRwUPJNPuuTycA5SLx4ezLhMAAAAA"

    {:ok, psbt} = base_64 |> Psbt.parse()

    assert [] = psbt.inputs
  end
end
