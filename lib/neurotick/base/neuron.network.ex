defmodule Neurotick.Base.NeuronNetwork do

  @moduledoc """
  A module to put a Neural Network elements work together creating
  a functional Neural Network.
  
  ## Examples
  
  ```elixir
  activation_functions = [
    TanhFunction
  ]
    
  # neuron module, neuron name,layer,activation_functions,weight,bias,operation,debugg
  neurons_array_0 = [
    [SimpleNeuron,"N1",0,activation_functions,1,2.5,"*",false], 
    ... (other neurons definitions)
  ]
    
  ... (other neuron layers)
   
  neurons_array_3 = [
    ...
    [SimpleNeuron,"N13",3,[],1,0,"*",false]
  ]
    
  # module, name,debugg
  sensors_array = [
    [SimpleSensor,"S1",false],
    ... (other sensor definitions)
  ]
   
  # module, name,debugg   
  actuators_array = [
    [SimpleActuator,"A1",false],
    ... (other actuator definitions)  
  ]
    
  neurons_array_layers = [
    neurons_array_0,
    ...
  ]
  
  # initialize
  network_id = NeuronNetwork.start_network()
  # config sensors
  NeuronNetwork.config_sensors(network_id,sensors_array)
  # config actuators
  NeuronNetwork.config_actuators(network_id,actuators_array)
  # config neuron layers
  NeuronNetwork.config_neurons(network_id,neurons_array_layers)
  # read inputs from sensors, process throught the neuron layers and push the results to actuators do something
  network_id
      |> NeuronNetwork.process_signals()
  :timer.sleep(100)
  # capture the results that were sent to actuators, for inspect something, or compare the results with other NN results.
  results = network_id 
              |> NeuronNetwork.extract_output()
 
  ```  
  """

  alias Krug.SanitizerUtil
  alias Krug.MapUtil
  alias Neurotick.Base.NeuronStorage
  alias Neurotick.Base.NeuronLayer
  alias Neurotick.Base.NeuronUtil
  alias Neurotick.Base.NeuronCortex
  alias Neurotick.Base.NeuronMetadata
  alias Neurotick.Base.NeuronStarter
  
  @sensors_id "sensors"
  @actuators_id "actuators"
  @layers_id "layers"
  
  
  
  @doc """
  Initializes the Neural Network
  """
  def start_network() do
    NeuronStorage.config_storage()
    network_id = SanitizerUtil.generate_random(50)
    NeuronStorage.store_network_element(network_id,@layers_id,0)
    network_id
  end
  
  
  
  @doc """
  Terminates the Neural Network
  """
  def stop_network(network_id) do
    network_id
      |> NeuronStorage.get_network_element(@sensors_id)
      |> NeuronUtil.terminate_pids()
    network_id
      |> NeuronStorage.get_network_element(@actuators_id)
      |> NeuronUtil.terminate_pids()
    network_id
      |> NeuronLayer.terminate_all_layers()
  end
  
  
  
  @doc """
  Configure the Neural Network sensors.
  """
  def config_sensors(network_id,sensors_array_params) do
    sensors_pids = sensors_array_params 
                     |> NeuronStarter.start_pids()
    NeuronStorage.store_network_element(network_id,@sensors_id,sensors_pids)
  end
  
  
  
  @doc """
  Configure the Neural Network actuators.
  """
  def config_actuators(network_id,actuators_array_params) do
    actuators_pids = actuators_array_params 
                       |> NeuronStarter.start_pids()
    NeuronStorage.store_network_element(network_id,@actuators_id,actuators_pids)
  end
  
  
  
  @doc """
  Configure the Neural Network neurons layers.
  """
  def config_neurons(network_id,neurons_array_layers) do
    neuron_layer_pids = neurons_array_layers 
                          |> NeuronStarter.start_pid_layers()
    network_id
      |> NeuronLayer.add_neuron_layers(neuron_layer_pids)
  end
  
  
  
  @doc """
  Runs the Neural Network, to process the sensors inputs, process the result 
  by neurons layers and output results to actuators.
  """
  def process_signals(network_id) do
    network_id
      |> NeuronCortex.process_signals()
  end
  
  
  
  @doc """
  Extract final output result that was send to actuators layer.
  """
  def extract_output(network_id) do
    try do
      network_id
        |> NeuronStorage.get_network_element(@actuators_id)
        |> extract_output_actuators()
    rescue
      _-> network_id
            |> retry_extract_output()
    end
  end
  
  defp retry_extract_output(network_id) do
    ["retry_extract_output => ",network_id]
      |> IO.inspect()
    :timer.sleep(10)
    network_id
      |> extract_output()
  end
  
  defp extract_output_actuators(actuator_pids,results \\ []) do
    cond do
      (Enum.empty?(actuator_pids))
        -> results
             |> Enum.reverse()
      true
        -> actuator_pids
             |> tl()
             |> extract_output_actuators(
                  [
                    actuator_pids 
                      |> hd() 
                      |> NeuronMetadata.read_metadata() 
                      |> MapUtil.get(:input)
                      |> calculate_result_weights()
                      | results
                  ]
                )
    end
  end
  
  
  
  defp calculate_result_weights(actuator_inputs,result_array \\ []) do
    cond do
      (Enum.empty?(actuator_inputs))
        -> result_array
             |> Enum.reverse()
      true
        -> actuator_inputs
             |> calculate_result_weights2(result_array)
    end
  end
  
  
  
  defp calculate_result_weights2(actuator_inputs,result_array) do
    [value,weight] = actuator_inputs 
                       |> hd() 
    actuator_inputs
      |> tl()
      |> calculate_result_weights([(value * weight) | result_array])
  end
  
  
  @doc """
  Output the Neural Network results from sensors layer to neurons layers to actuators layer.
  """  
  def debugg(network_id,file_path \\ nil) do
    sensors = network_id
                |> NeuronStorage.get_network_element(@sensors_id)
    actuators = network_id
                  |> NeuronStorage.get_network_element(@actuators_id) 
    sensors 
      |> NeuronMetadata.debugg_pids(file_path)
    network_id
      |> NeuronLayer.debugg_layers(file_path)
    actuators
      |> NeuronMetadata.debugg_pids(file_path)
  end
    
end

