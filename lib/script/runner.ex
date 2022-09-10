defmodule BitcoinLib.Script.Runner do
  @moduledoc """
  Script execution outcomes are based on this
  https://learnmeabitcoin.com/technical/script#what-makes-a-script-valid
  """
  alias BitcoinLib.Script.{Opcode}

  @doc """
  Executes a script and returns the result upon successful execution, or an error message

  ## Examples
      iex> opcodes = [%BitcoinLib.Script.Opcodes.Stack.Dup{},
      ...>   %BitcoinLib.Script.Opcodes.Crypto.Hash160{},
      ...>   %BitcoinLib.Script.Opcodes.Data{value: <<0x842c9a57d0580a45cb91912b63ced8866c8f7b28::160>>},
      ...>   %BitcoinLib.Script.Opcodes.BitwiseLogic.EqualVerify{},
      ...>   %BitcoinLib.Script.Opcodes.Crypto.CheckSig{script: <<0x76a914842c9a57d0580a45cb91912b63ced8866c8f7b2888ac::200>>}
      ...> ]
      ...> stack = [
      ...>   <<0x0253df833b37c1690234118d29fcff7c9f2f7ecc044d5b0ca6f1de76952f3f6463::264>>,
      ...>   <<0x3044022053646a4c2ea586024baa2c640246694e168da673ba96526aa82fc40e9508e993022056872566b2c39fd6a95613558278987acfb084fbdc8d3f2ef8d50ca58d570f05::560>>
      ...> ]
      ...> BitcoinLib.Script.Runner.execute(opcodes, stack)
      {:ok, true}
  """
  @spec execute(list(), list()) :: {:ok, boolean()} | {:error, binary()}
  def execute(opcodes, stack) when is_list(opcodes) do
    {stack, opcodes}
    |> execute_next_opcode
  end

  defp execute_next_opcode({[0], []}), do: {:ok, false}
  defp execute_next_opcode({[], []}), do: {:ok, false}
  defp execute_next_opcode({[_, _], []}), do: {:ok, false}
  defp execute_next_opcode({_, []}), do: {:ok, true}

  defp execute_next_opcode({stack, opcodes}) do
    [opcode | remaining_opcodes] = opcodes

    case Opcode.execute(opcode, stack) do
      {:ok, stack} -> execute_next_opcode({stack, remaining_opcodes})
    end
  end
end
