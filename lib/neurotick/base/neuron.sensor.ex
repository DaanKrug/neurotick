defmodule Neurotick.Base.NeuronSensor do

  @callback read_sensor_data() :: Float.t()
      
  @callback read_sensor_weight() :: Float.t()
    
  defmacro __using__(_opts) do
  
    quote do
    
      use Neurotick.Base.NeuronLogger
        
      def sense() do
        receive do
          ({neuron_pid,:terminate})
            -> neuron_pid
                 |> debugg_info(["Terminated Sensor => ",Kernel.self()])
          ({neuron_pid})
            -> neuron_pid
                 |> do_sense()
        end
      end
      
      defp do_sense(neuron_pid) do
        neuron_pid
          |> Process.send({Kernel.self(),read_sensor_signals()},[:noconnect])
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
