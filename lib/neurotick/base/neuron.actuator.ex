defmodule Neurotick.Base.NeuronActuator do

  @moduledoc """
  Implements basic functionality for a Neural Network Actuator element.
  To be used in a "Neurotick.Base.NeuronNetwork".
  
  Constructor: new(params_array) => [name,debugg] = params_array
  
  name: Name/Id of the actuator on neural network (ex: "A1", "A2").
  debugg: For write down some processing results.
  
  You should implements activated(signals_array) method to process the final result,
  as example use the result to trigger some action based on value ( real world equipment )
  or to use in a simulated environment( program to display some result ). 
  """

  @callback activated(signals_array :: Float.t()) :: Float.t()
    
  defmacro __using__(_opts) do
  
    quote do
    
      use Neurotick.Base.NeuronLogger

      alias Neurotick.Base.NeuronStorage
      alias Neurotick.Base.NeuronMetadata
      alias Krug.EtsUtil
      
      @tablename_config :neurotick_ets_config
      
      def new(params_array) do
        [name,debugg] = params_array
	    pid = Process.spawn(__MODULE__,:actuate,[],[])
	    EtsUtil.store_in_cache(@tablename_config,pid,[0,0,nil,debugg])
	    NeuronMetadata.store_metadata(pid,name,__MODULE__)
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
          |> NeuronMetadata.update_metadata(signals_array,[])
        Kernel.self()
          |> NeuronStorage.clear_sensor_data()
      end
        
    end
    
  end
  
end
