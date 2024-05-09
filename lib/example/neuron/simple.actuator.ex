defmodule Neurotick.Example.SimpleActuator do

  use Neurotick.Base.NeuronActuator
  
  @behaviour Neurotick.Base.NeuronActuator
  
  def new() do
    Process.spawn(__MODULE__,:actuate,[],[])
  end
    
  @impl Neurotick.Base.NeuronActuator
  def activated(source_pid,data) do
    [
      "activated => ",
      source_pid,
      data 
    ]
      |> IO.inspect()
  end
      
    
end