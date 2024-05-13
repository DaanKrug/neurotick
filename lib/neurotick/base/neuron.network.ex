defmodule Neurotick.Base.NeuronNetwork do

  alias Krug.SanitizerUtil
  alias Neurotick.Base.NeuronStorage
  
  @sensors_id "sensors"
  @actuators_id "actuators"
  @neurons_id_prefix "neurons_"
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
      |> terminate_pids()
    network_id
      |> NeuronStorage.get_network_element(@actuators_id)
      |> terminate_pids()
    layers = network_id
               |> NeuronStorage.get_network_element(@layers_id)
    network_id
      |> terminate_layers(layers)
  end
  
  def process_signals(network_id) do
    network_id
      |> NeuronStorage.get_network_element(@sensors_id)
      |> handle_signals()
  end
  
  def add_sensors(network_id,sensors_array) do
    NeuronStorage.store_network_element(network_id,@sensors_id,sensors_array)
  end
  
  def add_actuators(network_id,actuators_array) do
    NeuronStorage.store_network_element(network_id,@actuators_id,actuators_array)
  end
  
  def add_neurons(network_id,neurons_array,layer_number) do
    neurons_id = "#{@neurons_id_prefix}_#{layer_number}"
    NeuronStorage.store_network_element(network_id,neurons_id,neurons_array)
    layers = NeuronStorage.get_network_element(network_id,@layers_id)
    NeuronStorage.store_network_element(network_id,@layers_id,layers + 1)
  end
  
  def config_neuron_layer(network_id,layer_number,activation_functions,bias,operation,debugg) do
    cond do
      (layer_number == 0)
        -> add_layer_0(network_id,debugg)
      true
        -> :ok
    end
    network_id
      |> config_neuron_layer2(layer_number,activation_functions,bias,operation,debugg)
  end
  
  defp config_neuron_layer2(network_id,layer_number,activation_functions,bias,operation,debugg) do
    params_array_neuron_layer = [
      network_id
        |> get_sensors_or_neurons(layer_number),
      activation_functions,
      network_id
        |> get_neurons_or_actuators(layer_number),
      bias,
      operation,
      debugg,
      network_id
        |> get_actuators_expected_inputs(layer_number)
    ]
    network_id
      |> get_neurons_from_layer(layer_number)
      |> add_neuron_layer(params_array_neuron_layer)
  end
  
  defp get_actuators_expected_inputs(network_id,layer_number) do
    cond do
      (layer_number == 0)
        -> network_id
             |> NeuronStorage.get_network_element(@sensors_id)
             |> length()
      true
        -> network_id
             |> get_neurons_from_layer(layer_number)
             |> length()
    end
  end
  
  defp get_neurons_or_actuators(network_id,layer_number) do
    layers = NeuronStorage.get_network_element(network_id,@layers_id)
    cond do
      (layer_number < (layers - 1))
        -> network_id
             |> get_neurons_from_layer(layer_number + 1)
      true
        -> network_id
             |> NeuronStorage.get_network_element(@actuators_id)
    end
  end
  
  defp get_sensors_or_neurons(network_id,layer_number) do
    cond do
      (layer_number == 0)
        -> network_id
             |> NeuronStorage.get_network_element(@sensors_id)
      true
        -> network_id
             |> get_neurons_from_layer(layer_number - 1)
    end
  end
  
  defp add_layer_0(network_id,debugg) do
    network_id
      |> NeuronStorage.get_network_element(@sensors_id)
      |> config_sensors_or_neurons(
           [
             get_neurons_from_layer(network_id,0),
             debugg
           ]
         )
  end
  
  defp get_neurons_from_layer(network_id,layer_number) do
    network_id
      |> NeuronStorage.get_network_element(
           "#{@neurons_id_prefix}_#{layer_number}"
         )
  end
  
  defp add_neuron_layer(neurons_array,params_array) do
    neurons_array
      |> config_sensors_or_neurons(params_array)
  end
  
  defp config_sensors_or_neurons(components_array,params_array) do
    cond do
      (Enum.empty?(components_array))
        -> :ok
      true
        -> components_array
             |> config_sensors_or_neurons2(params_array)
    end
  end
  
  defp config_sensors_or_neurons2(components_array,params_array) do
    components_array
      |> hd()
      |> Process.send(
           {:config,params_array},
           [:noconnect]
         )
    components_array
      |> tl()
      |> config_sensors_or_neurons(params_array)
  end
  
  #processing
  defp handle_signals(sensors) do
    cond do
      (Enum.empty?(sensors))
        -> :ok
      true
        -> sensors
             |> handle_signals2()
    end
  end
  
  defp handle_signals2(sensors) do
    sensors
      |> hd()
      |> Process.send({:do_sense},[:noconnect])
    sensors
      |> tl()
      |> handle_signals()
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
      |> get_neurons_from_layer(layer_number - 1)
      |> terminate_pids()
    network_id
      |> terminate_layers(layer_number - 1)
  end
  
  defp terminate_pids(pids) do
    cond do
      (Enum.empty?(pids))
        -> :ok
      true
        -> pids
             |> terminate_pid()
    end
  end
  
  defp terminate_pid(pids) do
    pids
      |> hd()
      |> Process.send({:terminate},[:noconnect])
    pids
      |> tl()
      |> terminate_pids()
  end
  
end

