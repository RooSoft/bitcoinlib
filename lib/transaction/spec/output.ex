defmodule BitcoinLib.Transaction.Spec.Output do
  @moduledoc """
  A simplified version of a %BitcoinLib.Transaction.Output that can be filled with human readable formats
  """

  defstruct [:script_pub_key, :value]

  alias BitcoinLib.Transaction.Spec
  alias BitcoinLib.Transaction
  alias BitcoinLib.Transaction.Spec.Output

  @type t :: Output

  @doc """
  Converts a human readable output into a %Transaction.Output{}

  ## Examples
      iex> %BitcoinLib.Transaction.Spec.Output{
      ...>   script_pub_key: BitcoinLib.Script.Types.P2pkh.create(<<0xfc8ca28ea75e45f538242c257e1f07fe19baa0f3::160>>),
      ...>   value: 1000
      ...> }
      ...> |> BitcoinLib.Transaction.Spec.Output.to_transaction_output()
      %BitcoinLib.Transaction.Output{
        script_pub_key: [
          %BitcoinLib.Script.Opcodes.Stack.Dup{},
          %BitcoinLib.Script.Opcodes.Crypto.Hash160{},
          %BitcoinLib.Script.Opcodes.Data{value: <<0xfc8ca28ea75e45f538242c257e1f07fe19baa0f3::160>>},
          %BitcoinLib.Script.Opcodes.BitwiseLogic.EqualVerify{},
          %BitcoinLib.Script.Opcodes.Crypto.CheckSig{script: <<0x76a914fc8ca28ea75e45f538242c257e1f07fe19baa0f388ac::200>>}
        ],
        value: 1000
      }
  """
  @spec to_transaction_output(Spec.Output.t()) :: Transaction.Output.t()
  def to_transaction_output(%Spec.Output{script_pub_key: script_pub_key, value: value}) do
    %Transaction.Output{
      script_pub_key: script_pub_key,
      value: value
    }
  end
end
