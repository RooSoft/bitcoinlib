defmodule BitcoinLib.Script.OpcodeManager do
  alias BitcoinLib.Script.Opcodes.{BitwiseLogic, Crypto, Stack}

  @dup Stack.Dup.v()
  @equal BitwiseLogic.Equal.v()
  @equal_verify BitwiseLogic.EqualVerify.v()
  @hash160 Crypto.Hash160.v()
  @check_sig Crypto.CheckSig.v()

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

  def extract_from_script(<<@equal_verify::8, remaining::bitstring>>) do
    {:ok, %BitwiseLogic.EqualVerify{}, remaining}
  end

  def extract_from_script(<<@hash160::8, remaining::bitstring>>) do
    {:ok, %Crypto.Hash160{}, remaining}
  end

  def extract_from_script(<<@check_sig::8, remaining::bitstring>>) do
    {:ok, %Crypto.CheckSig{}, remaining}
  end

  def extract_from_script(<<unknown_upcode::8, remaining::bitstring>>) do
    {:error, "trying to extract an unknown upcode: #{unknown_upcode}", remaining}
  end
end
