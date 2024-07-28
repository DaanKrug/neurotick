defmodule Neurotick.Base.Neuron do

  defmacro __using__(_opts) do
  
    quote do
      
      use Neurotick.Base.NeuronLogger
      
      alias Neurotick.Base.NeuronStorage
      alias Neurotick.Base.NeuronProcessor
      alias Neurotick.Base.NeuronMetadata
      alias Krug.EtsUtil
      
      @tablename_config :neurotick_ets_config
      @tablename_activation_functions :neurotick_ets_activation_functions
      
      
      def new(name,layer,activation_functions,bias,operation,debugg) do
	    pid = Process.spawn(__MODULE__,:axion_receptor,[],[])  
	    EtsUtil.store_in_cache(@tablename_config,pid,[bias,operation,debugg])
	    EtsUtil.store_in_cache(@tablename_activation_functions,pid,activation_functions)
	    NeuronMetadata.store_metadata(pid,name,__MODULE__,layer,activation_functions,bias,operation)
	    pid
	  end
      
      def axion_receptor() do
        receive do
          ({:config,params_array})
            -> params_array
                 |> config_params()
          ({:signal_array,signal_array})
            -> signal_array
                 |> received_signal()
          ({:terminate})
            -> Kernel.self()
                 |> debugg_info(["Terminated Neuron => ",Kernel.self()])
        end
      end
      
      defp config_params(params_array) do
        params_array
          |> NeuronStorage.config_neuron(Kernel.self())
        axion_receptor()
      end
      
      defp received_signal(signal_array) do
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
      
    end
  
  end
  
end
