defmodule Neurotick.Stochastic.Selector do

  @moduledoc false

  alias Krug.NumberUtil
  alias Krug.MathUtil
  alias Neurotick.Probability.Selector
  
  @meta_pi 314159
  @meta_pi_range (314159 * 2) + 1
  @meta_pi_divider 100000000
  @operations ["+","-","/","*"]
  
  def select_elements(elements) do
    size = elements 
             |> length() 
    cond do
      (size < 4)
        -> elements
             |> Selector.select(1/5)
      true
        -> elements
             |> Selector.select(
                  1/(size |> :math.sqrt())
                )
    end
  end
  
  # -PI to + PI
  def choose_weight_perturbation() do
    rand = :rand.uniform(@meta_pi_range) - 1 - @meta_pi
    pow2 = MathUtil.pow(:rand.uniform(8),2)
    rand_pi_divider_multiplier = MathUtil.pow(pow2,2)
    rand / (@meta_pi_divider * rand_pi_divider_multiplier)
  end
  
  def choose_operation_perturbation(current_operation) do
    rand = :rand.uniform(4) - 1
    operation = @operations
                  |> Enum.at(rand)
    cond do
      (current_operation == operation)
        -> current_operation
             |> choose_operation_perturbation()
      true
        -> operation
    end
  end
  
  def max_attemps(elements) do
    total = elements 
		      |> List.flatten()
		      |> length() 
	cond do
	  (total < 4)
	    -> 1
	  true
	    -> total
	         |> :math.sqrt()
	         |> NumberUtil.to_integer()
	end
  end
  
end