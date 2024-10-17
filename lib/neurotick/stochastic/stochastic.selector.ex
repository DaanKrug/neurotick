defmodule Neurotick.Stochastic.Selector do

  alias Krug.NumberUtil
  alias Neurotick.Probability.Selector
  
  @meta_pi 314159
  @meta_pi_range (314159 * 2) + 1
  @meta_pi_divider 1000000
  
  def select_elements(elements) do
    probability = 1 / (elements |> length() |> :math.sqrt())
    Selector.select(elements,probability)
  end
  
  # -PI to + PI
  def choose_weight_perturbation() do
    rand = :rand.uniform(@meta_pi_range) - 1 - @meta_pi
    rand / @meta_pi_divider
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