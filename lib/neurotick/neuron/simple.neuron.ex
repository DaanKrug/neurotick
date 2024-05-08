defmodule Neurotick.SimpleNeuron do

  use Neurotick.Base.NeuronAxion
  
  @behaviour Neurotick.Base.NeuronAxion
  
  @impl Neurotick.Base.NeuronAxion
  def spawn_sensor_module() do
    Process.spawn(Neurotick.SimpleSensor,:sense,[],[])  
  end
  
  @impl Neurotick.Base.NeuronAxion
  def new() do
    Process.spawn(Neurotick.SimpleNeuron,:sensor_receptor,[],[])  
  end
  
end