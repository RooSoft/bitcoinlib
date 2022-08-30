defmodule BitcoinLib.Script.Opcodes.Constants.Zero do
  @behaviour BitcoinLib.Script.Opcode

  defstruct []

  alias BitcoinLib.Script.Opcodes.Constants.Zero

  @value 0x00

  def v do
    @value
  end

  def encode() do
    <<@value::8>>
  end

  def execute(%Zero{}, remaining) do
    {:ok, remaining}
  end
end
