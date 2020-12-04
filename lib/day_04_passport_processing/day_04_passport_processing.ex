defmodule AdventOfCode.Day04PassportProcessing do
  @passport_required_keys ~w(byr iyr eyr hgt hcl ecl pid)
  @eyes_color_valid ~w(amb blu brn gry grn hzl oth)

  @doc ~S"""
  ## Examples
    iex> import AdventOfCode.Day04PassportProcessing
    iex> passports = "ecl:gry pid:860033327 eyr:2020 hcl:#fffffd\nbyr:1937 iyr:2017 cid:147 hgt:183cm\n\niyr:2013 ecl:amb cid:350 eyr:2023 pid:028048884\nhcl:#cfa07d byr:1929\n\nhcl:#ae17e1 iyr:2013\neyr:2024\necl:brn pid:760753108 byr:1931\nhgt:179cm\n\nhcl:#cfa07d eyr:2025 pid:166559648\niyr:2011 ecl:brn hgt:59in"
    iex> get_passports_valid(passports, &is_simple_passport_valid?/1)
    2

    ## Examples
    iex> import AdventOfCode.Day04PassportProcessing
    iex> passports = "ecl:gry pid:860033327 eyr:2020 hcl:#fffffd\nbyr:1937 iyr:2017 cid:147 hgt:183cm\n\niyr:2013 ecl:amb cid:350 eyr:2023 pid:028048884\nhcl:#cfa07d byr:1929\n\nhcl:#ae17e1 iyr:2013\neyr:2024\necl:brn pid:760753108 byr:1931\nhgt:179cm\n\nhcl:#cfa07d eyr:2025 pid:166559648\niyr:2011 ecl:brn hgt:59in"
    iex> get_passports_valid(passports, &is_passport_valid?/1)
    2
  """
  def get_passports_valid(passports, policy) do
    passports
    |> parse_passports
    |> Stream.filter(policy)
    |> Enum.count()
  end

  def is_simple_passport_valid?(passport), do: Enum.all?(@passport_required_keys, &Map.has_key?(passport, &1))

  def is_passport_valid?(passport) do
    case is_simple_passport_valid?(passport) do
      false ->
        false

      _ ->
        %{passport: passport, valid: true}
        |> is_byr_valid?()
        |> is_iyr_valid?()
        |> is_eyr_valid?()
        |> is_hgt_valid?()
        |> is_hcl_valid?()
        |> is_ecl_valid?()
        |> is_pid_valid?()
        |> Map.get(:valid)
    end
  end

  defp parse_passports(passports) do
    passports
    |> String.split("\n\n")
    |> Stream.map(&String.replace(&1, "\n", " "))
    |> Stream.map(&String.split/1)
    |> Enum.map(&parse_passport/1)
  end

  defp parse_passport(passport) do
    passport
    |> Stream.map(&String.split(&1, ":"))
    |> Stream.map(&List.to_tuple/1)
    |> Enum.into(%{})
  end

  defp is_byr_valid?(%{:passport => %{"byr" => byr}, :valid => valid} = changeset) do
    %{changeset | valid: valid and validate_integer_digits(byr, 4, 1920, 2002)}
  end

  defp is_iyr_valid?(%{:passport => %{"iyr" => iyr}, :valid => valid} = changeset) do
    %{changeset | valid: valid and validate_integer_digits(iyr, 4, 2010, 2020)}
  end

  defp is_eyr_valid?(%{:passport => %{"eyr" => eyr}, :valid => valid} = changeset) do
    %{changeset | valid: valid and validate_integer_digits(eyr, 4, 2020, 2030)}
  end

  defp is_hgt_valid?(%{:passport => %{"hgt" => <<hgt::binary-size(3)>> <> "cm"}, :valid => valid} = changeset) do
    %{changeset | valid: valid and validate_integer_digits(hgt, 3, 150, 193)}
  end

  defp is_hgt_valid?(%{:passport => %{"hgt" => <<hgt::binary-size(2)>> <> "in"}, :valid => valid} = changeset) do
    %{changeset | valid: valid and validate_integer_digits(hgt, 2, 59, 76)}
  end

  defp is_hgt_valid?(changeset) do
    %{changeset | valid: false}
  end

  defp is_hcl_valid?(%{:passport => %{"hcl" => hcl}, :valid => valid} = changeset) do
    %{changeset | valid: valid and String.match?(hcl, ~r/^#([0-9a-f]{6})$/i)}
  end

  defp is_ecl_valid?(%{:passport => %{"ecl" => ecl}, :valid => valid} = changeset) do
    %{changeset | valid: valid and ecl in @eyes_color_valid}
  end

  defp is_pid_valid?(%{:passport => %{"pid" => pid}, :valid => valid} = changeset) do
    %{changeset | valid: valid and String.match?(pid, ~r/^([0-9]{9})$/i)}
  end

  defp validate_integer_digits(field, digits_count, min_value, max_value) do
    count = String.length(field)
    field = String.to_integer(field)

    count == digits_count and min_value <= field and field <= max_value
  end
end
