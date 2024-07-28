defmodule Neurotick.Base.NeuronLayer do

  alias Neurotick.Base.NeuronUtil
  alias Neurotick.Base.NeuronStorage
  alias Neurotick.Base.NeuronMetadata
  
  @sensors_id "sensors"
  @neurons_id_prefix "neurons"
  @layers_id "layers"
  
  
  def debugg_layers(network_id,file_path) do
    network_id
      |> NeuronStorage.get_network_element(@layers_id)
      |> debugg_layer(network_id,file_path)
  end
  
  def terminate_all_layers(network_id) do
    layers = network_id
               |> NeuronStorage.get_network_element(@layers_id)
    network_id
      |> terminate_layers(layers)
  end
  
  def add_neuron_layers(network_id,neurons_array_layers) do
    max_layer = neurons_array_layers 
                  |> length()
    network_id
      |> add_neuron_layer(neurons_array_layers)  
    network_id
      |> config_neuron_layers(0,max_layer - 1)
  end
  
  defp add_neuron_layer(network_id,neurons_array_layers,current_layer \\ 0) do
    cond do
      (Enum.empty?(neurons_array_layers))
        -> :ok
      true
        -> network_id
             |> add_neurons(neurons_array_layers,current_layer)
    end
  end
  
  defp add_neurons(network_id,neurons_array_layers,layer_number) do
    neurons_array = neurons_array_layers 
                      |> hd()
    neurons_id = "#{@neurons_id_prefix}_#{layer_number}"
    network_id
      |> NeuronStorage.store_network_element(neurons_id,neurons_array)
    layers = network_id
               |> NeuronStorage.get_network_element(@layers_id)
    network_id
      |> NeuronStorage.store_network_element(@layers_id,layers + 1)
    network_id
      |> add_neuron_layer(
           neurons_array_layers
             |> tl(),
           layer_number + 1
         )
  end
  
  defp config_neuron_layers(network_id,layer_number,max_layer) do
    cond do
      (layer_number > max_layer)
        -> :ok
      true
        -> network_id
             |> config_neuron_layer(layer_number,max_layer)
    end
  end
  
  defp config_neuron_layer(network_id,layer_number,max_layer) do
    network_id
      |> config_layer(layer_number)
    network_id
      |> config_neuron_layers(layer_number + 1,max_layer)
  end
  
  defp config_layer(network_id,layer_number) do
    cond do
      (layer_number == 0)
        -> network_id
		     |> NeuronStorage.get_network_element(@sensors_id)
		     |> NeuronUtil.config_sensors_or_neurons(
		          NeuronUtil.get_neurons_from_layer(network_id,0)
		        )
      true
        -> :ok
    end
    network_id
      |> config_layer2(layer_number)
  end
  
  defp config_layer2(network_id,layer_number) do
    params_array_neuron_layer = [
      network_id
        |> NeuronUtil.get_sensors_or_neurons(layer_number),
      network_id
        |> NeuronUtil.get_neurons_or_actuators(layer_number),
      network_id
        |> NeuronUtil.get_actuators_expected_inputs(layer_number)
    ]
    network_id
      |> NeuronUtil.get_neurons_from_layer(layer_number)
      |> NeuronUtil.config_sensors_or_neurons(params_array_neuron_layer)
  end
  
  defp terminate_layers(network_id,layer_number) do
    cond do
      (layer_number < 1)
        -> :ok
      true
        -> network_id
             |> terminate_layer(layer_number)
    end
  end
  
  defp terminate_layer(network_id,layer_number) do
    network_id 
      |> NeuronUtil.get_neurons_from_layer(layer_number - 1)
      |> NeuronUtil.terminate_pids()
    network_id
      |> terminate_layers(layer_number - 1)
  end
  
  defp debugg_layer(max_layer_number,network_id,file_path,current \\ 0) do
    cond do
      (current >= max_layer_number)
        -> :ok
      true
        -> max_layer_number
             |> debugg_layer2(network_id,file_path,current)
    end
  end
  
  defp debugg_layer2(max_layer_number,network_id,file_path,current) do
    network_id 
      |> NeuronUtil.get_neurons_from_layer(current)
      |> NeuronMetadata.debugg_pids(file_path)
    debugg_layer(max_layer_number,network_id,file_path,current + 1)
  end
  
end
