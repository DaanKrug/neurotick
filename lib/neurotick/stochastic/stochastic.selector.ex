defmodule Neurotick.Stochastic.Selector do

  alias Krug.NumberUtil
  alias Krug.MathUtil
  alias Neurotick.Probability.Selector
  
  @meta_pi 314159
  @meta_pi_range (314159 * 2) + 1
  @meta_pi_divider 100000000
  
  def select_elements(elements) do
    probability = 1 / (elements |> length() |> :math.sqrt())
    Selector.select(elements,probability)
  end
  
  # -PI to + PI
  def choose_weight_perturbation() do
    rand = :rand.uniform(@meta_pi_range) - 1 - @meta_pi
    pow2 = MathUtil.pow(:rand.uniform(8),2)
    rand_pi_divider_multiplier = MathUtil.pow(pow2,2)
    rand / (@meta_pi_divider * rand_pi_divider_multiplier)
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