defmodule Neurotick.Base.NeuronSensor do

  @callback read_sensor_data() :: Float.t()
      
  @callback read_sensor_weight() :: Float.t()
    
  defmacro __using__(_opts) do
  
    quote do
        
      def sense() do
        receive do
          ({axion_pid,signals_array})
            -> Process.send(
                 axion_pid,
                 {Kernel.self(), [read_sensor_signals() | signals_array]},
                 [:noconnect]
               )
          (any)
            -> any |> IO.inspect()
        end
      end
      
      defp read_sensor_signals() do
        
        data = [
          read_sensor_data(),
          read_sensor_weight()
        ]
        ["read_sensor_signals",data]
          |> IO.inspect()
        data
      end
        
    end
    
  end
  
end