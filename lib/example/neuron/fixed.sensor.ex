defmodule Neurotick.Example.FixedSensor do

  @moduledoc false

  use Neurotick.Base.NeuronSensor
  
  @behaviour Neurotick.Base.NeuronSensor
  
    
  @impl Neurotick.Base.NeuronSensor
  def read_sensor_data() do
    1
  end
      
  @impl Neurotick.Base.NeuronSensor
  def read_sensor_weight() do
    0.5
  end
    
end