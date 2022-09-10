defmodule BitcoinLib.Script.OpcodeManager do
  @moduledoc """
  Converts back and forts from script to opcode list
  """

  alias BitcoinLib.Script.Opcodes.{BitwiseLogic, Constants, Crypto, FlowControl, Stack}

  @byte 8

  @zero Constants.Zero.v()
  @one Constants.One.v()
  @two Constants.Two.v()
  @verify FlowControl.Verify.v()
  @return FlowControl.Return.v()
  @dup Stack.Dup.v()
  @equal BitwiseLogic.Equal.v()
  @equal_verify BitwiseLogic.EqualVerify.v()
  @hash160 Crypto.Hash160.v()
  @check_sig Crypto.CheckSig.v()
  @check_sig_verify Crypto.CheckSigVerify.v()
  @check_multi_sig Crypto.CheckMultiSig.v()
  @check_multi_sig_verify Crypto.CheckMultiSigVerify.v()

  alias BitcoinLib.Signing.Psbt.CompactInteger
  alias BitcoinLib.Script.Opcodes.Data

  @doc """
  Encode an opcode into a bitstring
  """
  @spec encode_opcode(any) :: bitstring()
  def encode_opcode(%Constants.Zero{}) do
    Constants.Zero.encode()
  end

  def encode_opcode(%Constants.One{}) do
    Constants.One.encode()
  end

  def encode_opcode(%Constants.Two{}) do
    Constants.Two.encode()
  end

  def encode_opcode(%Stack.Dup{}) do
    Stack.Dup.encode()
  end

  def encode_opcode(%Crypto.Hash160{}) do
    Crypto.Hash160.encode()
  end

  def encode_opcode(%BitwiseLogic.EqualVerify{}) do
    BitwiseLogic.EqualVerify.encode()
  end

  def encode_opcode(%Crypto.CheckSig{}) do
    Crypto.CheckSig.encode()
  end

  def encode_opcode(%Data{} = data) do
    Data.encode(data)
  end

  @doc """
  Extract the opcode on the top of the stack given as an argument
  """
  @spec extract_from_script(bitstring(), bitstring()) ::
          {:empty_script}
          | {:opcode, any(), bitstring()}
          | {:data, bitstring(), bitstring()}
          | {:error, binary(), bitstring()}
  def extract_from_script(<<>>, _whole_script), do: {:empty_script}

  def extract_from_script(<<@zero::8, remaining::bitstring>>, _whole_script) do
    {:opcode, %Constants.Zero{}, remaining}
  end

  def extract_from_script(<<@one::8, remaining::bitstring>>, _whole_script) do
    {:opcode, %Constants.One{}, remaining}
  end

  def extract_from_script(<<@two::8, remaining::bitstring>>, _whole_script) do
    {:opcode, %Constants.Two{}, remaining}
  end

  def extract_from_script(<<@verify::8, remaining::bitstring>>, _whole_script) do
    {:opcode, %FlowControl.Verify{}, remaining}
  end

  def extract_from_script(<<@return::8, remaining::bitstring>>, _whole_script) do
    {:opcode, %FlowControl.Return{}, remaining}
  end

  def extract_from_script(<<@dup::8, remaining::bitstring>>, _whole_script) do
    {:opcode, %Stack.Dup{}, remaining}
  end

  def extract_from_script(<<@equal::8, remaining::bitstring>>, _whole_script) do
    {:opcode, %BitwiseLogic.Equal{}, remaining}
  end

  def extract_from_script(<<@equal_verify::8, remaining::bitstring>>, _whole_script) do
    {:opcode, %BitwiseLogic.EqualVerify{}, remaining}
  end

  def extract_from_script(<<@hash160::8, remaining::bitstring>>, _whole_script) do
    {:opcode, %Crypto.Hash160{}, remaining}
  end

  def extract_from_script(<<@check_sig::8, remaining::bitstring>>, whole_script) do
    {:opcode, %Crypto.CheckSig{script: whole_script}, remaining}
  end

  def extract_from_script(<<@check_sig_verify::8, remaining::bitstring>>, _whole_script) do
    {:opcode, %Crypto.CheckSigVerify{}, remaining}
  end

  def extract_from_script(<<@check_multi_sig::8, remaining::bitstring>>, _whole_script) do
    {:opcode, %Crypto.CheckMultiSig{}, remaining}
  end

  def extract_from_script(<<@check_multi_sig_verify::8, remaining::bitstring>>, _whole_script) do
    {:opcode, %Crypto.CheckMultiSigVerify{}, remaining}
  end

  def extract_from_script(<<unknown_opcode::8, remaining::bitstring>> = script, _whole_script) do
    case unknown_opcode do
      opcode when opcode in 0x01..0x4B -> extract_and_return_data(script)
      _ -> {:error, "trying to extract an unknown upcode: #{unknown_opcode}", remaining}
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
