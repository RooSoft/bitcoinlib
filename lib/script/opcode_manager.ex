defmodule BitcoinLib.Script.OpcodeManager do
  alias BitcoinLib.Script.Opcodes.{Stack, BitwiseLogic}

  @dup Stack.Dup.v()
  @equal BitwiseLogic.Equal.v()

  @doc """
  Extract the opcode on the top of the stack given as an argument
  """
  @spec extract_from_script(bitstring()) ::
          {:empty_script} | {:ok, %Stack.Dup{}, bitstring()} | {:error, binary()}

  def extract_from_script(<<>>), do: {:empty_script}

  def extract_from_script(<<@dup::8, remaining::bitstring>>) do
    {:ok, %Stack.Dup{}, remaining}
  end

  def extract_from_script(<<@equal::8, remaining::bitstring>>) do
    {:ok, %BitwiseLogic.Equal{}, remaining}
  end

  def extract_from_script(<<unknown_upcode::8, remaining::bitstring>>) do
    {:error, "trying to extract an unknown upcode: #{unknown_upcode}", remaining}
  end
end
