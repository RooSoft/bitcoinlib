defmodule BitcoinLib.Script.OpcodeManager do
  @moduledoc """
  Converts back and forts from script to opcode list
  """

  alias BitcoinLib.Script.Opcodes.{BitwiseLogic, Constants, Crypto, FlowControl, Stack, Locktime}

  @byte 8

  @zero Constants.Zero.v()
  @one Constants.One.v()
  @two Constants.Two.v()
  @push_data_1 Constants.PushData1.v()
  @nop FlowControl.Nop.v()
  @verify FlowControl.Verify.v()
  @return FlowControl.Return.v()
  @drop Stack.Drop.v()
  @dup Stack.Dup.v()
  @rot Stack.Rot.v()
  @equal BitwiseLogic.Equal.v()
  @equal_verify BitwiseLogic.EqualVerify.v()
  @ripemd160 Crypto.Ripemd160.v()
  @sha256 Crypto.Sha256.v()
  @hash160 Crypto.Hash160.v()
  @code_separator Crypto.CodeSeparator.v()
  @check_sig Crypto.CheckSig.v()
  @check_sig_verify Crypto.CheckSigVerify.v()
  @check_multi_sig Crypto.CheckMultiSig.v()
  @check_multi_sig_verify Crypto.CheckMultiSigVerify.v()
  @check_lock_time_verify Locktime.CheckLockTimeVerify.v()

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

  def encode_opcode(%Constants.PushData1{}) do
    Constants.PushData1.encode()
  end

  def encode_opcode(%Stack.Drop{}) do
    Stack.Drop.encode()
  end

  def encode_opcode(%Stack.Dup{}) do
    Stack.Dup.encode()
  end

  def encode_opcode(%Stack.Rot{}) do
    Stack.Rot.encode()
  end

  def encode_opcode(%Crypto.Sha256{}) do
    Crypto.Sha256.encode()
  end

  def encode_opcode(%Crypto.Ripemd160{}) do
    Crypto.Ripemd160.encode()
  end

  def encode_opcode(%Crypto.CodeSeparator{}) do
    Crypto.CodeSeparator.encode()
  end

  def encode_opcode(%Crypto.Hash160{}) do
    Crypto.Hash160.encode()
  end

  def encode_opcode(%FlowControl.Nop{}) do
    FlowControl.Nop.encode()
  end

  def encode_opcode(%FlowControl.Return{}) do
    FlowControl.Return.encode()
  end

  def encode_opcode(%BitwiseLogic.EqualVerify{}) do
    BitwiseLogic.EqualVerify.encode()
  end

  def encode_opcode(%BitwiseLogic.Equal{}) do
    BitwiseLogic.Equal.encode()
  end

  def encode_opcode(%Crypto.CheckSig{}) do
    Crypto.CheckSig.encode()
  end

  def encode_opcode(%Crypto.CheckMultiSig{}) do
    Crypto.CheckMultiSig.encode()
  end

  def encode_opcode(%Locktime.CheckLockTimeVerify{}) do
    Locktime.CheckLockTimeVerify.encode()
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

  def extract_from_script(
        <<@push_data_1::8, data_length::8, remaining::bitstring>>,
        _whole_script
      ) do
    <<data::bitstring-size(data_length * 8), remaining::bitstring>> = remaining

    {:data, data, remaining}
  end

  def extract_from_script(<<@nop::8, remaining::bitstring>>, _whole_script) do
    {:opcode, %FlowControl.Nop{}, remaining}
  end

  def extract_from_script(<<@verify::8, remaining::bitstring>>, _whole_script) do
    {:opcode, %FlowControl.Verify{}, remaining}
  end

  def extract_from_script(<<@return::8, remaining::bitstring>>, _whole_script) do
    {:opcode, %FlowControl.Return{}, remaining}
  end

  def extract_from_script(<<@drop::8, remaining::bitstring>>, _whole_script) do
    {:opcode, %Stack.Drop{}, remaining}
  end

  def extract_from_script(<<@dup::8, remaining::bitstring>>, _whole_script) do
    {:opcode, %Stack.Dup{}, remaining}
  end

  def extract_from_script(<<@rot::8, remaining::bitstring>>, _whole_script) do
    {:opcode, %Stack.Rot{}, remaining}
  end

  def extract_from_script(<<@equal::8, remaining::bitstring>>, _whole_script) do
    {:opcode, %BitwiseLogic.Equal{}, remaining}
  end

  def extract_from_script(<<@equal_verify::8, remaining::bitstring>>, _whole_script) do
    {:opcode, %BitwiseLogic.EqualVerify{}, remaining}
  end

  def extract_from_script(<<@sha256::8, remaining::bitstring>>, _whole_script) do
    {:opcode, %Crypto.Sha256{}, remaining}
  end

  def extract_from_script(<<@ripemd160::8, remaining::bitstring>>, _whole_script) do
    {:opcode, %Crypto.Ripemd160{}, remaining}
  end

  def extract_from_script(<<@hash160::8, remaining::bitstring>>, _whole_script) do
    {:opcode, %Crypto.Hash160{}, remaining}
  end

  def extract_from_script(<<@code_separator::8, remaining::bitstring>>, _whole_script) do
    {:opcode, %Crypto.CodeSeparator{}, remaining}
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

  def extract_from_script(<<@check_lock_time_verify::8, remaining::bitstring>>, _whole_script) do
    {:opcode, %Locktime.CheckLockTimeVerify{}, remaining}
  end

  def extract_from_script(<<unknown_opcode::8, remaining::bitstring>> = script, _whole_script) do
    case unknown_opcode do
      opcode when opcode in 0x01..0x4B -> extract_and_return_data(script)
      _ -> {:error, "trying to extract an unknown opcode: #{unknown_opcode}", remaining}
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
