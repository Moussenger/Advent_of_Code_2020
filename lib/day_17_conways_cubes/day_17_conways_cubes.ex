defmodule AdventOfCode.Day17ConwaysCubes do
  @active "#"
  @inactive "."

  @doc ~S"""
  ## Examples
    iex> import AdventOfCode.Day17ConwaysCubes
    iex> data = ".#. ..# ###"
    iex> data |> get_active_3d_cubes_after_n_cycles(6, 3)
    112
  """
  def get_active_3d_cubes_after_n_cycles(state, cycles, cube_size) do
    initial_length = 2 * cycles + cube_size
    cycles_length = cycles * 2 + 1

    state
    |> parse_3d_state(cycles, cube_size)
    |> process_3d_n_cycles(cycles, initial_length, cycles_length)
    |> flat_state_3d(initial_length, cycles_length)
    |> List.flatten()
    |> Stream.filter(&(&1 == @active))
    |> Enum.count()
  end

  @doc ~S"""
  ## Examples
    iex> import AdventOfCode.Day17ConwaysCubes
    iex> data = ".#. ..# ###"
    iex> data |> get_active_4d_cubes_after_n_cycles(6, 3)
    848
  """
  def get_active_4d_cubes_after_n_cycles(state, cycles, cube_size) do
    initial_length = 2 * cycles + cube_size
    cycles_length = cycles * 2 + 1

    state
    |> parse_4d_state(cycles, cube_size)
    |> process_4d_n_cycles(cycles, initial_length, cycles_length)
    |> flat_state_4d(initial_length, cycles_length)
    |> List.flatten()
    |> Stream.filter(&(&1 == @active))
    |> Enum.count()
  end

  defp parse_3d_state(state, cycles, cube_size) do
    empty = generate_empty_layer(cycles, cube_size)
    space = String.duplicate(@inactive, cycles)
    vertical_space = String.duplicate(@inactive, cycles * 2 + cube_size)

    vertical_space = Enum.map(1..cycles, fn _ -> vertical_space end)

    state =
      state
      |> String.split()
      |> Enum.map(&"#{space}#{&1}#{space}")

    state = vertical_space ++ state ++ vertical_space

    initial_state =
      state
      |> Enum.map(&String.graphemes/1)
      |> Enum.map(&List.to_tuple/1)
      |> List.to_tuple()

    for z <- -cycles..cycles do
      if z == 0, do: initial_state, else: empty
    end
    |> List.to_tuple()
  end

  defp parse_4d_state(state, cycles, cube_size) do
    empty = generate_empty_layer(cycles, cube_size)
    space = String.duplicate(@inactive, cycles)
    vertical_space = String.duplicate(@inactive, cycles * 2 + cube_size)

    vertical_space = Enum.map(1..cycles, fn _ -> vertical_space end)

    state =
      state
      |> String.split()
      |> Enum.map(&"#{space}#{&1}#{space}")

    state = vertical_space ++ state ++ vertical_space

    initial_state =
      state
      |> Enum.map(&String.graphemes/1)
      |> Enum.map(&List.to_tuple/1)
      |> List.to_tuple()

    for z <- -cycles..cycles do
      for w <- -cycles..cycles do
        if z == 0 and w == 0, do: initial_state, else: empty
      end
      |> List.to_tuple()
    end
    |> List.to_tuple()
  end

  defp generate_empty_layer(cycles, cube_size) do
    side_size = cube_size + cycles * 2

    for _ <- 1..side_size do
      for _ <- 1..side_size do
        @inactive
      end
      |> List.to_tuple()
    end
    |> List.to_tuple()
  end

  defp flat_state_3d(state, initial_length, cycles_length) do
    for x <- 0..(initial_length - 1) do
      for y <- 0..(initial_length - 1) do
        for z <- 0..(cycles_length - 1) do
          get(state, {x, y, z})
        end
      end
    end
  end

  defp flat_state_4d(state, initial_length, cycles_length) do
    for x <- 0..(initial_length - 1) do
      for y <- 0..(initial_length - 1) do
        for z <- 0..(cycles_length - 1) do
          for w <- 0..(cycles_length - 1) do
            get(state, {x, y, z, w})
          end
        end
      end
    end
  end

  defp process_3d_n_cycles(states, 0, _initial_length, _cycles_length), do: states

  defp process_3d_n_cycles(states, cycles, initial_length, cycles_length) do
    states =
      for z <- 0..(cycles_length - 1) do
        for x <- 0..(initial_length - 1) do
          for y <- 0..(initial_length - 1) do
            process_position(states, {x, y, z}, initial_length, cycles_length)
          end
          |> List.flatten()
          |> List.to_tuple()
        end
        |> List.to_tuple()
      end
      |> List.to_tuple()

    process_3d_n_cycles(states, cycles - 1, initial_length, cycles_length)
  end

  defp process_4d_n_cycles(states, 0, _initial_length, _cycles_length), do: states

  defp process_4d_n_cycles(states, cycles, initial_length, cycles_length) do
    states =
      for w <- 0..(cycles_length - 1) do
        for z <- 0..(cycles_length - 1) do
          for x <- 0..(initial_length - 1) do
            for y <- 0..(initial_length - 1) do
              process_position(states, {x, y, z, w}, initial_length, cycles_length)
            end
            |> List.flatten()
            |> List.to_tuple()
          end
          |> List.to_tuple()
        end
        |> List.to_tuple()
      end
      |> List.to_tuple()

    process_4d_n_cycles(states, cycles - 1, initial_length, cycles_length)
  end

  defp process_position(states, {x, y, z}, initial_length, cycles_length) do
    state = get(states, {x, y, z})

    for i <- -1..1, j <- -1..1, k <- -1..1, i != 0 || j != 0 || k != 0 do
      {x + i, y + j, z + k}
    end
    |> Stream.filter(&is_coordinate_valid(&1, initial_length, cycles_length))
    |> Stream.map(&get(states, &1))
    |> Stream.filter(&(&1 == @active))
    |> Enum.count()
    |> process_state(state)
  end

  defp process_position(states, {x, y, z, w}, initial_length, cycles_length) do
    state = get(states, {x, y, z, w})

    for i <- -1..1, j <- -1..1, k <- -1..1, l <- -1..1, i != 0 || j != 0 || k != 0 || l != 0 do
      {x + i, y + j, z + k, w + l}
    end
    |> Stream.filter(&is_coordinate_valid(&1, initial_length, cycles_length))
    |> Stream.map(&get(states, &1))
    |> Stream.filter(&(&1 == @active))
    |> Enum.count()
    |> process_state(state)
  end

  def get(states, {x, y, z}), do: states |> elem(z) |> elem(x) |> elem(y)

  def get(states, {x, y, z, w}), do: states |> elem(z) |> elem(w) |> elem(x) |> elem(y)

  defp process_state(count, @active) when count == 2 or count == 3, do: @active
  defp process_state(count, @inactive) when count == 3, do: @active
  defp process_state(_count, _state), do: @inactive

  defp is_coordinate_valid({x, y, z}, initial_length, cycles_length) do
    cond do
      not (x in 0..(initial_length - 1)) -> false
      not (y in 0..(initial_length - 1)) -> false
      not (z in 0..(cycles_length - 1)) -> false
      true -> true
    end
  end

  defp is_coordinate_valid({x, y, z, w}, initial_length, cycles_length) do
    cond do
      not (x in 0..(initial_length - 1)) -> false
      not (y in 0..(initial_length - 1)) -> false
      not (z in 0..(cycles_length - 1)) -> false
      not (w in 0..(cycles_length - 1)) -> false
      true -> true
    end
  end
end
