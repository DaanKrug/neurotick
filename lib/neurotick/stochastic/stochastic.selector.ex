defmodule Neurotick.Stochastic.Selector do

  #alias Krug.NumberUtil
  alias Neurotick.Probability.Selector
  
  def select_elements(elements) do
    probability = 1 / (elements |> length() |> :math.sqrt())
    Selector.select(elements,probability)
  end
  
  def choose_weight_perturbation() do
    # -PI to + PI
  end
  
  def max_attemps(elements) do
    elements 
      |> length() 
      |> :math.sqrt()
  end
  
  
end