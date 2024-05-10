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
            -> Kernel.self()
                 |> NeuronStorage.get_sensor_pids()
                 |> read_sensor_signals()
          ({sensor_pid,signals_array})
            -> received_signal(sensor_pid,signals_array)
        end
        axion_receptor()  
      end
      
      defp read_sensor_signals(sensor_pids) do
        cond do
          (Enum.empty?(sensor_pids))
            -> :ok
          true
            -> sensor_pids
                 |> request_sensor_data()
        end
      end
      
      defp request_sensor_data(sensor_pids) do
        sensor_pids
          |> hd()
          |> Process.send({Kernel.self()},[:noconnect])
        sensor_pids
          |> tl()
          |> read_sensor_signals()
      end
      
      defp received_signal(sensor_pid,signal_array) do
        NeuronStorage.store_sensor_data(signal_array,Kernel.self())
        [pids,signals_array] = NeuronStorage.get_sensors_and_sensor_signals_received(Kernel.self())
        cond do
          (signals_array |> length() >= length(pids))
            -> signals_array
                 |> Enum.reverse()
                 |> NeuronProcessor.process_signals(Kernel.self())
          true
            -> :waiting_sensor_signal
        end
      end
      
    end
  
  end
  
end
