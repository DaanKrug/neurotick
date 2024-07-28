defmodule Neurotick.Base.NeuronNetwork do

  alias Krug.SanitizerUtil
  alias Neurotick.Base.NeuronStorage
  alias Neurotick.Base.NeuronLayer
  alias Neurotick.Base.NeuronUtil
  alias Neurotick.Base.NeuronCortex
  alias Neurotick.Base.NeuronMetadata
  
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
  
  def config_sensors(network_id,sensors_array) do
    NeuronStorage.store_network_element(network_id,@sensors_id,sensors_array)
  end
  
  def config_actuators(network_id,actuators_array) do
    NeuronStorage.store_network_element(network_id,@actuators_id,actuators_array)
  end
  
  def config_neurons(network_id,neurons_array_layers) do
    network_id
      |> NeuronLayer.add_neuron_layers(neurons_array_layers)
  end
  
  def process_signals(network_id) do
    network_id
      |> NeuronCortex.process_signals()
  end
  
  def debugg(network_id) do
    sensors = network_id
                |> NeuronStorage.get_network_element(@sensors_id)
    actuators = network_id
                  |> NeuronStorage.get_network_element(@actuators_id) 
    sensors 
      |> NeuronMetadata.debugg_pids()
    network_id
      |> NeuronLayer.debugg_layers()
    actuators
      |> NeuronMetadata.debugg_pids()
  end
    
end

