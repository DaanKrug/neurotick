defmodule Neurotick.Base.ActivationFunctionBehaviour do

  @moduledoc """
  Activation function behaviour that should be implemented in your 
  Activation function modules intended to be used in "Neurotick.Base.NeuronNetwork"
  """

  @callback process_activation(Float.t()) :: Float.t()
  
end