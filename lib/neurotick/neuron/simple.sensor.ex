defmodule Neurotick.SimpleSensor do

  use Neurotick.Base.NeuronSensor
  
  @behaviour Neurotick.Base.NeuronSensor
  
  def new() do
    Process.spawn(__MODULE__,:sense,[],[])
  end
    
  @impl Neurotick.Base.NeuronSensor
  def read_sensor_data() do
    (:rand.uniform() * 2) + (:rand.uniform() * 0.1)
  end
      
  @impl Neurotick.Base.NeuronSensor
  def read_sensor_weight() do
    :rand.uniform() - 0.5
  end
    
end