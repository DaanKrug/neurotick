defmodule Neurotick.Example.SimpleNeuron do

  use Neurotick.Base.Neuron
  
  def new() do
    Process.spawn(__MODULE__,:axion_receptor,[],[])  
  end
  
end