defmodule Neurotick.Base.Neuron do

  @moduledoc """
  Implements basic functionality for a Neural Network Neuron element.
  To be used in a "Neurotick.Base.NeuronNetwork".
  
  Constructor: new(params_array) => [name,layer,activation_functions,weight,bias,operation,debugg] = params_array
  
  name: Name/Id of the neuron on neural network (ex: "N1", "N2").
  layer: Number of layer wich this neuron participate.
  activation_functions: Activation functions that will be applied to neuron output, 
  before send the output result forward to next node (neuron/actuator).
  weight: Weight applied to output calculation.
  bias: Bias deviation applied to output calculation.
  operation: Math operation applied to input signals (could be "*", "+", "-" and "/"), default to "*".
  debugg: For write down some processing results.
  
  You should implements read_sensor_data() to collect the sensor data
  (could be a real world dispositive signal input or a simulation/program generated input).
  
  You should implement read_sensor_weight() to collect the sensor weight of sensor data value
   throught the Neural Network signal data processing interations.
  """
  
  defmacro __using__(_opts) do
  
    quote do
      
      use Neurotick.Base.NeuronLogger
      
      alias Neurotick.Base.NeuronStorage
      alias Neurotick.Base.NeuronProcessor
      alias Neurotick.Base.NeuronMetadata
      alias Krug.EtsUtil
      
      @tablename_config :neurotick_ets_config
      @tablename_activation_functions :neurotick_ets_activation_functions
      
      
      def new(params_array) do
        [name,layer,activation_functions,weight,bias,operation,debugg] = params_array
	    pid = Process.spawn(__MODULE__,:axion_receptor,[],[])  
	    EtsUtil.store_in_cache(@tablename_config,pid,[weight,bias,operation,debugg])
	    EtsUtil.store_in_cache(@tablename_activation_functions,pid,activation_functions)
	    NeuronMetadata.store_metadata(pid,name,__MODULE__,layer,activation_functions,weight,bias,operation)
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
