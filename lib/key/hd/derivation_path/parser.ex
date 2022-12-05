defmodule BitcoinLib.Key.HD.DerivationPath.Parser do
  @moduledoc """
  Single purpose module that aims to simplify DerivationPath by isolating string parsing business
  logic
  """

  alias BitcoinLib.Key.HD.DerivationPath
  alias BitcoinLib.Key.HD.DerivationPath.Parser.{Type, Purpose, CoinType, Account, Change, Index}

  @doc """
  Single purpose function that's being called by DerivationPath.parse/1, returning a DerivationPath
  out of a string if the tuple starts by :ok

  ## Examples
      iex> "m/44'/0'/0'/1/0"
      ...> |> BitcoinLib.Key.HD.DerivationPath.Parser.parse_valid_derivation_path
      {
        :ok,
        %BitcoinLib.Key.HD.DerivationPath{
          type: :private,
          purpose: :bip44,
          coin_type: :bitcoin,
          account: 0,
          change: :change_chain,
          address_index: 0
        }
      }
  """
  @spec parse_valid_derivation_path(binary()) ::
          {:ok, DerivationPath.t()} | {:error, binary()}
  def parse_valid_derivation_path(derivation_path) do
    with {:ok, derivation_path} <- validate(derivation_path),
         tokens <- split_path(derivation_path),
         {:ok, type, tokens} <- Type.extract(tokens),
         {:ok, purpose, tokens} <- Purpose.extract(tokens),
         {:ok, coin_type, tokens} <- CoinType.extract(tokens),
         {:ok, account, tokens} <- Account.extract(tokens),
         {:ok, change, tokens} <- Change.extract(tokens),
         {:ok, index} <- Index.extract(tokens) do
      {
        :ok,
        %DerivationPath{
          type: type,
          purpose: purpose,
          coin_type: coin_type,
          account: account,
          change: change,
          address_index: index
        }
      }
    else
      {:error, message} -> {:error, message}
    end
  end

  defp validate(derivation_path) do
    trimmed_path =
      derivation_path
      |> String.replace(" ", "")

    case Regex.match?(~r/^(m|M)((\/(\d+\'?)*){0,5})$/, trimmed_path) do
      true -> {:ok, trimmed_path}
      false -> {:error, "Invalid derivation path"}
    end
  end

  defp split_path(derivation_path) do
    String.split(derivation_path, "/")
  end
end
