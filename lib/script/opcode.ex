defmodule BitcoinLib.Script.Opcode do
  alias BitcoinLib.Script.Opcodes.{Stack}

  @dup Stack.Dup.v()

  def extract_from_script(<<>>), do: {:empty_script}

  def extract_from_script(<<@dup::8, remaining::bitstring>>) do
    {:ok, %Stack.Dup{}, remaining}
  end

  def extract_from_script(<<unknown_upcode::8, remaining::bitstring>>) do
    {:error, "trying to extract an unknown upcode: #{unknown_upcode}", remaining}
  end
end
