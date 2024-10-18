defmodule Neurotick.Stochastic.StochasticMath do

  @moduledoc false

  alias Krug.MathUtil

  @biggest_diff 1000000
  
  def compare_results(expected_result,current_result,new_result,round_precision) do
    diff_1 = [expected_result]
               |> absolute_diff_array([current_result],round_precision)
    diff_2 = [expected_result]
               |> absolute_diff_array([new_result],round_precision)
    cond do
      (diff_1 < diff_2)
        -> [:current,diff_1]
      true
        -> [:new,diff_2]
    end
  end

  defp absolute_diff_array(array_a,array_b,round_precision) do
    cond do
      (nil == array_a
        or nil == array_b)
          -> @biggest_diff
      (!(:erlang.is_list(array_a))
        or !(:erlang.is_list(array_b)))
          -> @biggest_diff
      (Enum.empty?(array_a)
        or Enum.empty?(array_b))
          -> @biggest_diff
      ((array_a |> length()) != (array_b |> length()))
        -> @biggest_diff
      true
        -> array_a
             |> absolute_diff_array2(array_b,round_precision)
    end
  end
  
  defp absolute_diff_array2(array_a,array_b,round_precision,absolute_diff \\ 0) do
    cond do
      (Enum.empty?(array_a))
        -> absolute_diff
             |> module_diff()
      (array_a |> hd() |> :erlang.is_list())
        -> array_a
             |> tl()
             |> absolute_diff_array2(
                  array_b 
                    |> tl(),
                  round_precision,
                  absolute_diff + (
                    absolute_diff_array(
                      array_a |> hd(),
                      array_b |> hd(),
                      round_precision
                    )
                  )
                )
      true
        -> array_a
             |> tl()
             |> absolute_diff_array2(
                  array_b 
                    |> tl(),
                  round_precision,
                  absolute_diff + calculate_diff(array_a |> hd(),array_b |> hd(),round_precision)
                )
    end
  end
  
  defp calculate_diff(number_a,number_b,round_precision) do
    number_a = number_a
                 |> MathUtil.round_precision(round_precision)
    number_b = number_b
                 |> MathUtil.round_precision(round_precision)
    number_a - number_b
  end
  
  
  defp module_diff(absolute_diff) do
    cond do
      (absolute_diff < 0)
        -> absolute_diff * -1
      true
        -> absolute_diff
    end
  end

end
