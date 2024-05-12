defmodule Neurotick.Base.NeuronSensor do

  @callback read_sensor_data() :: Float.t()
      
  @callback read_sensor_weight() :: Float.t()
    
  defmacro __using__(_opts) do
  
    quote do
    
      use Neurotick.Base.NeuronLogger
      
      alias Neurotick.Base.NeuronStorage
        
      def sense() do
        receive do
          ({:terminate})
            -> Kernel.self()
                 |> debugg_info(["Terminated Sensor => ",Kernel.self()])
          ({:config,params_array})
            -> params_array
                 |> config_params()
          ({:do_sense})
            -> do_sense()
        end
      end
      
      defp config_params(params_array) do
        params_array
          |> NeuronStorage.config_sensor(Kernel.self())
        sense()
      end
      
      defp do_sense() do
        NeuronStorage.get_neuron_pids(Kernel.self())
          |> send_signal_to_neurons(read_sensor_signals())
        sense()
      end
      
      defp send_signal_to_neurons(neuron_pids,signal_array) do
        cond do
          (Enum.empty?(neuron_pids))
            -> :ok
          true
            -> neuron_pids
                 |> send_signal_to_neuron(signal_array)
        end
      end
      
      defp send_signal_to_neuron(neuron_pids,signal_array) do
        neuron_pids
          |> hd()
          |> Process.send({:signal_array,signal_array},[:noconnect])
        neuron_pids
          |> tl()
          |> send_signal_to_neurons(signal_array)
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
