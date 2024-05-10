defmodule Neurotick.Base.Neuron do

  defmacro __using__(_opts) do
  
    quote do
      
      use Neurotick.Base.NeuronLogger
      
      alias Neurotick.Base.NeuronStorage
      alias Neurotick.Base.NeuronProcessor
      
      
      def axion_receptor() do
        receive do
          ({:config,params_array})
            -> params_array
                 |> config_params()
          ({:read_signals})
            -> request_sensors_data()
          ({sensor_pid,signals_array})
            -> received_signal(sensor_pid,signals_array)
          ({:terminate})
            -> terminate_all()
        end
      end
      
      defp config_params(params_array) do
        params_array
          |> NeuronStorage.config(Kernel.self())
        axion_receptor()
      end
      
      defp request_sensors_data() do
        Kernel.self()
          |> NeuronStorage.get_sensor_pids()
          |> read_sensor_signals()
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
        signal_array
          |> NeuronStorage.store_sensor_data(Kernel.self())
        [pids,signals_array] = Kernel.self()
                                 |> NeuronStorage.get_sensors_and_sensor_signals_received()
        cond do
          (signals_array |> length() >= length(pids))
            -> signals_array
                 |> NeuronProcessor.process_signals(Kernel.self())
          true
            -> :waiting_sensor_signal
        end
        axion_receptor()
      end
      
      defp terminate_all() do
        sensor_pids = Kernel.self()
                        |> NeuronStorage.get_sensor_pids()
        actuactor_pids = Kernel.self()
                           |> NeuronStorage.get_actuator_pids()
        Kernel.self()
          |> NeuronProcessor.terminate_all(sensor_pids)
        Kernel.self()
          |> NeuronProcessor.terminate_all(actuactor_pids)
        Kernel.self()
          |> debugg_info(["Terminated Neuron => ",Kernel.self()])
      end
      
    end
  
  end
  
end
