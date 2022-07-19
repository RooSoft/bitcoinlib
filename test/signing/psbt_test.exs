defmodule BitcoinLib.Signing.PsbtTest do
  use ExUnit.Case, async: true

  doctest BitcoinLib.Signing.Psbt

  alias BitcoinLib.Signing.Psbt
  alias BitcoinLib.Signing.Psbt.{KeypairList, Inputs}

  test "parse a base64 PSBT string into a Psbt struct" do
    psbt_string =
      "cHNidP8BAFUCAAAAASeaIyOl37UfxF8iD6WLD8E+HjNCeSqF1+Ns1jM7XLw5AAAAAAD/////AaBa6gsAAAAAGXapFP/pwAYQl8w7Y28ssEYPpPxCfStFiKwAAAAAAAEBIJVe6gsAAAAAF6kUY0UgD2jRieGtwN8cTRbqjxTA2+uHIgIDsTQcy6doO2r08SOM1ul+cWfVafrEfx5I1HVBhENVvUZGMEMCIAQktY7/qqaU4VWepck7v9SokGQiQFXN8HC2dxRpRC0HAh9cjrD+plFtYLisszrWTt5g6Hhb+zqpS5m9+GFR25qaAQEEIgAgdx/RitRZZm3Unz1WTj28QvTIR3TjYK2haBao7UiNVoEBBUdSIQOxNBzLp2g7avTxI4zW6X5xZ9Vp+sR/HkjUdUGEQ1W9RiED3lXR4drIBeP4pYwfv5uUwC89uq/hJ/78pJlfJvggg71SriIGA7E0HMunaDtq9PEjjNbpfnFn1Wn6xH8eSNR1QYRDVb1GELSmumcAAACAAAAAgAQAAIAiBgPeVdHh2sgF4/iljB+/m5TALz26r+En/vykmV8m+CCDvRC0prpnAAAAgAAAAIAFAACAAAA="

    psbt =
      psbt_string
      |> Psbt.parse()

    assert %KeypairList{} = psbt.global
    assert %Inputs{} = psbt.inputs
    assert %KeypairList{} = psbt.outputs
  end

  test "a PSBT with a non witness UTXO" do
    psbt_string =
      "cHNidP8BAHUCAAAAASaBcTce3/KF6Tet7qSze3gADAVmy7OtZGQXE8pCFxv2AAAAAAD+////AtPf9QUAAAAAGXapFNDFmQPFusKGh2DpD9UhpGZap2UgiKwA4fUFAAAAABepFDVF5uM7gyxHBQ8k0+65PJwDlIvHh7MuEwAAAQD9pQEBAAAAAAECiaPHHqtNIOA3G7ukzGmPopXJRjr6Ljl/hTPMti+VZ+UBAAAAFxYAFL4Y0VKpsBIDna89p95PUzSe7LmF/////4b4qkOnHf8USIk6UwpyN+9rRgi7st0tAXHmOuxqSJC0AQAAABcWABT+Pp7xp0XpdNkCxDVZQ6vLNL1TU/////8CAMLrCwAAAAAZdqkUhc/xCX/Z4Ai7NK9wnGIZeziXikiIrHL++E4sAAAAF6kUM5cluiHv1irHU6m80GfWx6ajnQWHAkcwRAIgJxK+IuAnDzlPVoMR3HyppolwuAJf3TskAinwf4pfOiQCIAGLONfc0xTnNMkna9b7QPZzMlvEuqFEyADS8vAtsnZcASED0uFWdJQbrUqZY3LLh+GFbTZSYG2YVi/jnF6efkE/IQUCSDBFAiEA0SuFLYXc2WHS9fSrZgZU327tzHlMDDPOXMMJ/7X85Y0CIGczio4OFyXBl/saiK9Z9R5E5CVbIBZ8hoQDHAXR8lkqASECI7cr7vCWXRC+B3jv7NYfysb3mk6haTkzgHNEZPhPKrMAAAAAAAAA"

    psbt =
      psbt_string
      |> Psbt.parse()

    assert false == psbt.inputs.witness?
    assert <<1, 0, 0, 0, 0, 1, 2, 137, 163, 199, 30, 171, 77, 32, 224, 55, 27, 187, 164,
      204, 105, 143, 162, 149, 201, 70, 58, 250, 46, 57, 127, 133, 51, 204, 182, 47,
      149, 103, 229, 1, 0, 0, 0, 23, 22, 0, 20, 190, 24, 209, 82, 169, 176, 18, 3,
      157, 175, 61, 167, 222, 79, 83, 52, 158, 236, 185, 133, 255, 255, 255, 255,
      134, 248, 170, 67, 167, 29, 255, 20, 72, 137, 58, 83, 10, 114, 55, 239, 107,
      70, 8, 187, 178, 221, 45, 1, 113, 230, 58, 236, 106, 72, 144, 180, 1, 0, 0, 0,
      23, 22, 0, 20, 254, 62, 158, 241, 167, 69, 233, 116, 217, 2, 196, 53, 89, 67,
      171, 203, 52, 189, 83, 83, 255, 255, 255, 255, 2, 0, 194, 235, 11, 0, 0, 0, 0,
      25, 118, 169, 20, 133, 207, 241, 9, 127, 217, 224, 8, 187, 52, 175, 112, 156,
      98, 25, 123, 56, 151, 138, 72, 136, 172, 114, 254, 248, 78, 44, 0, 0, 0, 23,
      169, 20, 51, 151, 37, 186, 33, 239, 214, 42, 199, 83, 169, 188, 208, 103, 214,
      199, 166, 163, 157, 5, 135, 2, 71, 48, 68, 2, 32, 39, 18, 190, 34, 224, 39,
      15, 57, 79, 86, 131, 17, 220, 124, 169, 166, 137, 112, 184, 2, 95, 221, 59,
      36, 2, 41, 240, 127, 138, 95, 58, 36, 2, 32, 1, 139, 56, 215, 220, 211, 20,
      231, 52, 201, 39, 107, 214, 251, 64, 246, 115, 50, 91, 196, 186, 161, 68, 200,
      0, 210, 242, 240, 45, 178, 118, 92, 1, 33, 3, 210, 225, 86, 116, 148, 27, 173,
      74, 153, 99, 114, 203, 135, 225, 133, 109, 54, 82, 96, 109, 152, 86, 47, 227,
      156, 94, 158, 126, 65, 63, 33, 5, 2, 72, 48, 69, 2, 33, 0, 209, 43, 133, 45,
      133, 220, 217, 97, 210, 245, 244, 171, 102, 6, 84, 223, 110, 237, 204, 121,
      76, 12, 51, 206, 92, 195, 9, 255, 181, 252, 229, 141, 2, 32, 103, 51, 138,
      142, 14, 23, 37, 193, 151, 251, 26, 136, 175, 89, 245, 30, 68, 228, 37, 91,
      32, 22, 124, 134, 132, 3, 28, 5, 209, 242, 89, 42, 1, 33, 2, 35, 183, 43, 238,
      240, 150, 93, 16, 190, 7, 120, 239, 236, 214, 31, 202, 198, 247, 154, 78, 161,
      105, 57, 51, 128, 115, 68, 100, 248, 79, 42, 179, 0, 0, 0, 0>> = psbt.inputs.utxo
  end

  test "a PSBT without any output" do
    psbt_string =
      "cHNidP8BAHUCAAAAASaBcTce3/KF6Tet7qSze3gADAVmy7OtZGQXE8pCFxv2AAAAAAD+////AtPf9QUAAAAAGXapFNDFmQPFusKGh2DpD9UhpGZap2UgiKwA4fUFAAAAABepFDVF5uM7gyxHBQ8k0+65PJwDlIvHh7MuEwAAAQD9pQEBAAAAAAECiaPHHqtNIOA3G7ukzGmPopXJRjr6Ljl/hTPMti+VZ+UBAAAAFxYAFL4Y0VKpsBIDna89p95PUzSe7LmF/////4b4qkOnHf8USIk6UwpyN+9rRgi7st0tAXHmOuxqSJC0AQAAABcWABT+Pp7xp0XpdNkCxDVZQ6vLNL1TU/////8CAMLrCwAAAAAZdqkUhc/xCX/Z4Ai7NK9wnGIZeziXikiIrHL++E4sAAAAF6kUM5cluiHv1irHU6m80GfWx6ajnQWHAkcwRAIgJxK+IuAnDzlPVoMR3HyppolwuAJf3TskAinwf4pfOiQCIAGLONfc0xTnNMkna9b7QPZzMlvEuqFEyADS8vAtsnZcASED0uFWdJQbrUqZY3LLh+GFbTZSYG2YVi/jnF6efkE/IQUCSDBFAiEA0SuFLYXc2WHS9fSrZgZU327tzHlMDDPOXMMJ/7X85Y0CIGczio4OFyXBl/saiK9Z9R5E5CVbIBZ8hoQDHAXR8lkqASECI7cr7vCWXRC+B3jv7NYfysb3mk6haTkzgHNEZPhPKrMAAAAAAAAA"

    psbt =
      psbt_string
      |> Psbt.parse()

    assert 0 == Enum.count(psbt.outputs.keypairs)
  end
end
