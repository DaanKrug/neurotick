defmodule Neurotick.Base.NeuronUtil do

  @moduledoc false

  alias Neurotick.Base.NeuronStorage
  
  @sensors_id "sensors"
  @actuators_id "actuators"
  @neurons_id_prefix "neurons"
  @layers_id "layers"
  

  def config_sensors_or_neurons(components_array,params_array) do
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
  
  def get_actuators_expected_inputs(network_id,layer_number) do
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
  
  def get_neurons_or_actuators(network_id,layer_number) do
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
  
  def get_sensors_or_neurons(network_id,layer_number) do
    cond do
      (layer_number == 0)
        -> network_id
             |> NeuronStorage.get_network_element(@sensors_id)
      true
        -> network_id
             |> get_neurons_from_layer(layer_number - 1)
    end
  end
  
  def get_neurons_from_layer(network_id,layer_number) do
    network_id
      |> NeuronStorage.get_network_element(
           "#{@neurons_id_prefix}_#{layer_number}"
         )
  end
  
  def terminate_pids(pids) do
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