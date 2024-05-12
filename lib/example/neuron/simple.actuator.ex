defmodule Neurotick.Example.SimpleActuator do

  use Neurotick.Base.NeuronActuator
  
  @behaviour Neurotick.Base.NeuronActuator
  
  def new() do
    Process.spawn(__MODULE__,:actuate,[],[])
  end
    
  @impl Neurotick.Base.NeuronActuator
  def activated(signals_array) do
    [
      "activated(signals_array) => ",
      signals_array 
    ]
      |> IO.inspect()
  end
      
    
end