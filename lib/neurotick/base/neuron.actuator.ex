defmodule Neurotick.Base.NeuronActuator do

  @callback activated(signals_array :: Float.t()) :: Float.t()
    
  defmacro __using__(_opts) do
  
    quote do
    
      use Neurotick.Base.NeuronLogger

      alias Neurotick.Base.NeuronStorage
      alias Neurotick.Base.NeuronMetadata
      alias Krug.EtsUtil
      
      @tablename_config :neurotick_ets_config
      
      def new(debugg) do
	    pid = Process.spawn(__MODULE__,:actuate,[],[])
	    EtsUtil.store_in_cache(@tablename_config,pid,[0,nil,debugg])
	    NeuronMetadata.store_metadata(pid,__MODULE__)
	    pid
	  end
        
      def actuate() do
        receive do
          ({:terminate})
            -> Kernel.self()
                 |> debugg_info(["Terminated Actuator => ",Kernel.self()]) 
          ({:signal_array,signal_array})
            -> signal_array
                 |> accumulate()
        end
      end
      
      defp accumulate(signal_array) do
        signal_array 
          |> NeuronStorage.store_sensor_data(Kernel.self())
        expected_inputs = Kernel.self()
                            |> NeuronStorage.get_actuator_expected_inputs()
        signals_array = Kernel.self()
                          |> NeuronStorage.get_sensors_data()
        cond do
          (length(signals_array) >= expected_inputs)
            -> signals_array
                 |> do_actuate()
          true
            -> :ok
        end
        actuate()
      end
      
      defp do_actuate(signals_array) do
        signals_array
          |> activated()
        Kernel.self()
          |> NeuronMetadata.store_metadata(signals_array,[])
        Kernel.self()
          |> NeuronStorage.clear_sensor_data()
      end
        
    end
    
  end
  
end
