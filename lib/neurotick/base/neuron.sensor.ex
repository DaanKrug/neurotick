defmodule Neurotick.Base.NeuronSensor do

  @moduledoc """
  Implements basic functionality for a Neural Network Sensor element.
  To be used in a "Neurotick.Base.NeuronNetwork".
  
  Constructor: new(params_array) => [name,debugg] = params_array
  
  name: Name/Id of the sensor on neural network (ex: "S1", "S2").
  debugg: For write down some processing results.
  
  You should implements read_sensor_data() to collect the sensor data
  (could be a real world dispositive signal input or a simulation/program generated input).
  
  You should implement read_sensor_weight() to collect the sensor weight of sensor data value
   throught the Neural Network signal data processing interations.
  """
  
  @callback read_sensor_data() :: Float.t()
      
  @callback read_sensor_weight() :: Float.t()
    
  defmacro __using__(_opts) do
  
    quote do
    
      use Neurotick.Base.NeuronLogger
      
      alias Neurotick.Base.NeuronStorage
      alias Neurotick.Base.NeuronMetadata
      alias Krug.EtsUtil
      
      @tablename_config :neurotick_ets_config
      
      def new(params_array) do
        [name,debugg] = params_array
	    pid = Process.spawn(__MODULE__,:sense,[],[])
	    EtsUtil.store_in_cache(@tablename_config,pid,[0,0,nil,debugg])
	    NeuronMetadata.store_metadata(pid,name,__MODULE__)
	    pid
	  end
        
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
        sensor_signals = read_sensor_signals()
        Kernel.self()
          |> NeuronMetadata.update_metadata([],sensor_signals)
        Kernel.self()
          |> NeuronStorage.get_neuron_pids()
          |> send_signal_to_neurons(sensor_signals)
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
