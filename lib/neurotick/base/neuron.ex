defmodule Neurotick.Base.Neuron do

  defmacro __using__(_opts) do
  
    quote do
    
      alias Neurotick.Base.NeuronStorage
      alias Neurotick.Base.NeuronProcessor
      
      
      def axion_receptor() do
        receive do
          ({:config,params_array})
            -> params_array
                 |> NeuronStorage.config(Kernel.self())
          ({:read_signals})
            -> read_signals()
          ({sensor_pid,signals_array})
            -> received_signal(sensor_pid,signals_array)
        end
        axion_receptor()  
      end
      
      defp read_signals() do
        pids = NeuronStorage.get_sensor_pids(Kernel.self())
        signals_array = NeuronStorage.get_sensors_data(Kernel.self())
        position = signals_array 
                     |> length()
        cond do
          (position >= length(pids))
            -> signals_array
                 |> Enum.reverse()
                 |> NeuronProcessor.process_signals(Kernel.self())
          true
            -> pids
                 |> Enum.at(position)
                 |> request_signal()
        end
      end
      
      defp request_signal(sensor_pid) do
        Process.send(sensor_pid,{Kernel.self()},[:noconnect])
      end
      
      defp received_signal(sensor_pid,signal_array) do
        NeuronStorage.store_sensor_data(signal_array,Kernel.self())
        read_signals()
      end
      
    end
  
  end
  
end
