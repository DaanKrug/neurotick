defmodule Neurotick.Base.ActivationFunctionBehaviour do

  @callback process_activation(Float.t()) :: Float.t()
  
end