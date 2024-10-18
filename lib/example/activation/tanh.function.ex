defmodule Neurotick.Example.TanhFunction do

  @moduledoc false

  @behaviour Neurotick.Base.ActivationFunctionBehaviour
  
  @impl Neurotick.Base.ActivationFunctionBehaviour
  def process_activation(input) do
    :math.tanh(input)
  end
  
end