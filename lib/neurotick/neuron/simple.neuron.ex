defmodule Neurotick.SimpleNeuron do

  use Neurotick.Base.NeuronAxion
  
  def new() do
    Process.spawn(__MODULE__,:sensor_receptor,[],[])  
  end
  
end