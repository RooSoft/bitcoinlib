defmodule BitcoinLib.Transaction.BetterSigner do
  @moduledoc """
  Signs transactions
  """

  alias BitcoinLib.Transaction
  alias BitcoinLib.Transaction.BetterSigner.{Validator, Inputs}

  @doc """
  Takes a transaction and signs it with the private key that's in the second parameter

  ## Examples
  # testnet transaction id: 838935b6bf2a16966fe261f23f28a88482f3b3d24c9847b68a56abe90d41ca97

  iex>  private_key = BitcoinLib.Key.PrivateKey.from_seed_phrase(
  ...>    "rally celery split order almost twenty ignore record legend learn chaos decade"
  ...>  )
  ...>  %BitcoinLib.Transaction{
  ...>    version: 1,
  ...>    inputs: [
  ...>      %BitcoinLib.Transaction.Input{
  ...>        txid: "e4c226432a9319d603b2ed1fa609bffe4cd91f89b3176a9e73b19f7891a92bb6",
  ...>        vout: 0,
  ...>        sequence: 0xFFFFFFFF,
  ...>        script_sig: <<0x76A914AFC3E518577316386188AF748A816CD14CE333F288AC::200>> |> BitcoinLib.Script.parse!()
  ...>      }
  ...>    ],
  ...>    outputs: [%BitcoinLib.Transaction.Output{
  ...>       script_pub_key: <<0x76a9283265393261373463333431393661303236653839653061643561633431386366393430613361663288ac::360>> |> BitcoinLib.Script.parse!(),
  ...>       value: 10_000}
  ...>    ],
  ...>    locktime: 0
  ...>  }
  ...>  |> BitcoinLib.Transaction.BetterSigner.sign([private_key])
  ...>  |> Map.get(:inputs)
  [
    %BitcoinLib.Transaction.Input{
      txid: "e4c226432a9319d603b2ed1fa609bffe4cd91f89b3176a9e73b19f7891a92bb6",
      vout: 0,
      script_sig: [
        %BitcoinLib.Script.Opcodes.Stack.Dup{},
        %BitcoinLib.Script.Opcodes.Crypto.Hash160{},
        %BitcoinLib.Script.Opcodes.Data{
          value: <<0xAFC3E518577316386188AF748A816CD14CE333F2::160>>
        },
        %BitcoinLib.Script.Opcodes.BitwiseLogic.EqualVerify{},
        %BitcoinLib.Script.Opcodes.Crypto.CheckSig{
          script: <<0x76A914AFC3E518577316386188AF748A816CD14CE333F288AC::200>>
        }
      ],
      sequence: 4_294_967_295
    }
  ]
  """
  @spec sign(Transaction.t(), list(PrivateKey.t())) :: Transaction.t()
  def sign(%Transaction{} = transaction, private_keys) do
    with :ok <- Validator.validate(transaction, private_keys),
         signed_transaction <- Inputs.sign(transaction, private_keys) do
      {:ok, signed_transaction}
    else
      {:error, message} -> {:error, message}
    end
  end
end
