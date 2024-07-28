defmodule Neurotick.Example.SimpleActuator do

  use Neurotick.Base.NeuronActuator
  
  @behaviour Neurotick.Base.NeuronActuator
  
    
  @impl Neurotick.Base.NeuronActuator
  def activated(signals_array) do
    [
      "activated(signals_array) => ",
      signals_array 
    ]
      |> IO.inspect()
  end
      
    
end