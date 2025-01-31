defmodule Burnex do
  @moduledoc """
  Elixir burner email (temporary address) detector.
  List from https://github.com/wesbos/burner-email-providers/blob/master/emails.txt
  """

  @dialyzer {:nowarn_function, is_burner_domain?: 1}

  @external_resource "priv/burner-email-providers/emails.txt"

  @providers @external_resource
             |> File.read!()
             |> String.split("\n")
             |> Enum.filter(fn str -> str != "" end)
             |> MapSet.new()

  @doc """
  Check if email is a temporary / burner address.

  ## Examples

      iex> Burnex.is_burner?("my-email@gmail.com")
      false
      iex> Burnex.is_burner?("my-email@yopmail.fr")
      true
      iex> Burnex.is_burner? "invalid.format.yopmail.fr"
      false
  """
  @spec is_burner?(binary()) :: boolean()
  def is_burner?(email) do
    case Regex.run(~r/@([^@]+)$/, String.downcase(email)) do
      [_ | [domain]] ->
        is_burner_domain?(domain)

      _ ->
        # Bad email format
        false
    end
  end

  @doc """
  Check a domain

  ## Examples

      iex> Burnex.is_burner_domain?("yopmail.fr")
      true
      iex> Burnex.is_burner_domain?("")
      false
      iex> Burnex.is_burner_domain?("gmail.com")
      false
  """
  @spec is_burner_domain?(binary()) :: boolean()
  def is_burner_domain?(domain) do
    case MapSet.member?(@providers, domain) do
      false ->
        case Regex.run(~r/^[^.]+[.](.*)$/, domain) do
          [_ | [higher_domain]] ->
            is_burner_domain?(higher_domain)

          nil ->
            false
        end

      true ->
        true
    end
  end

  @doc """
  Returns the list of all blacklisted domains providers
  """
  def providers do
    @providers
  end
end
