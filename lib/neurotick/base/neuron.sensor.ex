defmodule Neurotick.Base.NeuronSensor do

  @callback read_sensor_data() :: Float.t()
      
  @callback read_sensor_weight() :: Float.t()
    
  defmacro __using__(_opts) do
  
    quote do
        
      def sense() do
        receive do
          ({neuron_pid})
            -> Process.send(
                 neuron_pid,
                 {Kernel.self(),read_sensor_signals()},
                 [:noconnect]
               )
        end
        sense()
      end
      
      defp read_sensor_signals() do
        [
          read_sensor_data(),
          read_sensor_weight()
        ]
      end
        
    end
    
  end
  
end
