defmodule Neurotick.Base.NeuronNetwork do

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
  
  
  def start_network() do
    NeuronStorage.config_storage()
    network_id = SanitizerUtil.generate_random(50)
    NeuronStorage.store_network_element(network_id,@layers_id,0)
    network_id
  end
  
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
  
  def config_sensors(network_id,sensors_array_params) do
    sensors_pids = sensors_array_params 
                     |> NeuronStarter.start_pids()
    NeuronStorage.store_network_element(network_id,@sensors_id,sensors_pids)
  end
  
  def config_actuators(network_id,actuators_array_params) do
    actuators_pids = actuators_array_params 
                       |> NeuronStarter.start_pids()
    NeuronStorage.store_network_element(network_id,@actuators_id,actuators_pids)
  end
  
  def config_neurons(network_id,neurons_array_layers) do
    neuron_layer_pids = neurons_array_layers 
                          |> NeuronStarter.start_pid_layers()
    network_id
      |> NeuronLayer.add_neuron_layers(neuron_layer_pids)
  end
  
  def process_signals(network_id) do
    network_id
      |> NeuronCortex.process_signals()
  end
  
  def extract_output(network_id) do
    network_id
      |> NeuronStorage.get_network_element(@actuators_id)
      |> extract_output_actuators()
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
  
  defp calculate_result_weights2(actuator_inputs,result_array \\ []) do
    [value,weight] = actuator_inputs 
                       |> hd() 
    actuator_inputs
      |> tl()
      |> calculate_result_weights([(value * weight) | result_array])
  end
  
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

