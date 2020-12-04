defmodule AdventOfCode.Day04PassportProcessing do
  @passport_required_keys Enum.sort(~w(byr iyr eyr hgt hcl ecl pid))

  @doc ~S"""
  ## Examples
    iex> import AdventOfCode.Day04PassportProcessing
    iex> passports = "ecl:gry pid:860033327 eyr:2020 hcl:#fffffd\nbyr:1937 iyr:2017 cid:147 hgt:183cm\n\niyr:2013 ecl:amb cid:350 eyr:2023 pid:028048884\nhcl:#cfa07d byr:1929\n\nhcl:#ae17e1 iyr:2013\neyr:2024\necl:brn pid:760753108 byr:1931\nhgt:179cm\n\nhcl:#cfa07d eyr:2025 pid:166559648\niyr:2011 ecl:brn hgt:59in"
    iex> get_passports_valid(passports)
    2
  """
  def get_passports_valid(passports) do
    passports
    |> parse_passports
    |> Stream.filter(&is_passport_valid?/1)
    |> Enum.count()
  end

  defp is_passport_valid?(passport), do: Enum.sort(passport -- ["cid"]) == @passport_required_keys

  defp parse_passports(passports) do
    passports
    |> String.split("\n\n")
    |> Stream.map(&String.replace(&1, "\n", " "))
    |> Stream.map(&String.split/1)
    |> Enum.map(&Enum.map(&1, fn fields -> fields |> String.split(":") |> Enum.at(0) end))
  end
end
