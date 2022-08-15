defmodule BitcoinLib.Script.OpcodeManager do
  alias BitcoinLib.Script.Opcodes.{BitwiseLogic, Crypto, Stack}

  @byte 8

  @dup Stack.Dup.v()
  @equal BitwiseLogic.Equal.v()
  @equal_verify BitwiseLogic.EqualVerify.v()
  @hash160 Crypto.Hash160.v()
  @check_sig Crypto.CheckSig.v()

  alias BitcoinLib.Signing.Psbt.CompactInteger

  @doc """
  Extract the opcode on the top of the stack given as an argument
  """
  @spec extract_from_script(bitstring()) ::
          {:empty_script} | {:ok, %Stack.Dup{}, bitstring()} | {:error, binary()}

  def extract_from_script(<<>>), do: {:empty_script}

  def extract_from_script(<<@dup::8, remaining::bitstring>>) do
    {:opcode, %Stack.Dup{}, remaining}
  end

  def extract_from_script(<<@equal::8, remaining::bitstring>>) do
    {:opcode, %BitwiseLogic.Equal{}, remaining}
  end

  def extract_from_script(<<@equal_verify::8, remaining::bitstring>>) do
    {:opcode, %BitwiseLogic.EqualVerify{}, remaining}
  end

  def extract_from_script(<<@hash160::8, remaining::bitstring>>) do
    {:opcode, %Crypto.Hash160{}, remaining}
  end

  def extract_from_script(<<@check_sig::8, remaining::bitstring>>) do
    {:opcode, %Crypto.CheckSig{}, remaining}
  end

  def extract_from_script(<<unknown_upcode::8, remaining::bitstring>> = script) do
    case unknown_upcode do
      x when x in 0x01..0x4B -> extract_and_return_data(script)
      _ -> {:error, "trying to extract an unknown upcode: #{unknown_upcode}", remaining}
    end
  end

  defp extract_and_return_data(script) do
    %CompactInteger{value: data_length, remaining: remaining} =
      CompactInteger.extract_from(script)

    data_length = data_length * @byte

    <<data::bitstring-size(data_length), remaining::bitstring>> = remaining

    {:data, data, remaining}
  end
end
