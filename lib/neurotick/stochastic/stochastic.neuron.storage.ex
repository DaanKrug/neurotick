defmodule Neurotick.Stochastic.NeuronStorage do

  alias Krug.EtsUtil
  alias Neurotick.Stochastic.Selector
  
  
  @tablename_sensors_layer "table_sensors_layer_"
  @tablename_neuron_layers "table_neuron_layer_"
  @tablename_actuators_layer "table_actuators_layer_"
  
  
  # config
  def config(id,sensors_array,neurons_array,actuators_array) do
  	EtsUtil.new(:"#{@tablename_sensors_layer <> id}")
  	EtsUtil.new(:"#{@tablename_neuron_layers <> id}")
    EtsUtil.new(:"#{@tablename_actuators_layer <> id}")
    id 
      |> init_sensors(sensors_array)
    id
      |> init_actuators(actuators_array)
    id
      |> init_neurons(neurons_array)
  end
  
  # lef attemps
  def left_sensors_attemps(id) do
    tablename = :"#{@tablename_sensors_layer <> id}"
    max = tablename
            |> EtsUtil.read_from_cache("sensors_array_max_attemps")
    current = tablename
                |> EtsUtil.read_from_cache("sensors_array_current_attemps")
    current < max
  end
  
  def left_actuators_attemps(id) do
    tablename = :"#{@tablename_actuators_layer <> id}"
    max = tablename
            |> EtsUtil.read_from_cache("actuators_array_max_attemps")
    current = tablename
                |> EtsUtil.read_from_cache("actuators_array_current_attemps")
    current < max
  end
  
  def left_neurons_attemps(id) do
    tablename = :"#{@tablename_neuron_layers <> id}"
    max = tablename
            |> EtsUtil.read_from_cache("neurons_array_max_attemps")
    current = tablename
                |> EtsUtil.read_from_cache("neurons_array_current_attemps")
    current < max
  end
  
  # get current values
  def get_sensors(id) do
    :"#{@tablename_sensors_layer <> id}"
      |> EtsUtil.read_from_cache("sensors_array")
  end
  
  def get_actuators(id) do
    :"#{@tablename_actuators_layer <> id}"
      |> EtsUtil.read_from_cache("actuators_array")
  end
  
  def get_neurons(id) do
    :"#{@tablename_neuron_layers <> id}"
      |> EtsUtil.read_from_cache("neurons_array")
  end
  
  # set new values
  def set_sensors(id,sensors_array) do
    tablename = :"#{@tablename_sensors_layer <> id}"
    tablename
      |> EtsUtil.store_in_cache("sensors_array",sensors_array)
    tablename
      |> EtsUtil.store_in_cache(
	       "sensors_array_bkp",
	       EtsUtil.read_from_cache(tablename,"sensors_array")
	     )
    tablename
      |> increment_current_attemps("sensors_array_current_attemps")
  end
  
  def set_actuators(id,actuators_array) do
    tablename = :"#{@tablename_actuators_layer <> id}"
    tablename
      |> EtsUtil.store_in_cache("actuators_array",actuators_array)
    tablename
      |> EtsUtil.store_in_cache(
	       "actuators_array_bkp",
	       EtsUtil.read_from_cache(tablename,"actuators_array")
	     )
    tablename
      |> increment_current_attemps("actuators_array_current_attemps")
  end
  
  def set_neurons(id,neurons_array) do
    tablename = :"#{@tablename_neuron_layers <> id}"
    tablename
      |> EtsUtil.store_in_cache("neurons_array",neurons_array)
    tablename
      |> EtsUtil.store_in_cache(
	       "neurons_array_bkp",
	       EtsUtil.read_from_cache(tablename,"neurons_array")
	     )
    tablename
      |> increment_current_attemps("neurons_array_current_attemps")
  end
  
  #rollback
  def rollback_sensors(id) do
    tablename = :"#{@tablename_sensors_layer <> id}"
    tablename
      |> EtsUtil.store_in_cache(
	       "sensors_array",
	       EtsUtil.read_from_cache(tablename,"sensors_array_bkp")
	     )
	tablename
      |> increment_current_attemps("sensors_array_current_attemps")
  end
  
  def rollback_actuators(id) do
    tablename = :"#{@tablename_actuators_layer <> id}"
    tablename
      |> EtsUtil.store_in_cache(
	       "actuators_array",
	       EtsUtil.read_from_cache(tablename,"actuators_array_bkp")
	     )
	tablename
      |> increment_current_attemps("actuators_array_current_attemps")
  end
  
  def rollback_neurons(id) do
    tablename = :"#{@tablename_neuron_layers <> id}"
    tablename
      |> EtsUtil.store_in_cache(
	       "neurons_array",
	       EtsUtil.read_from_cache(tablename,"neurons_array_bkp")
	     )
	tablename
      |> increment_current_attemps("neurons_array_current_attemps")
  end
  
  # initialization
  defp init_sensors(id,sensors_array) do
    tablename = :"#{@tablename_sensors_layer <> id}" 
    tablename
      |> EtsUtil.store_in_cache("sensors_array",sensors_array)
    tablename
      |> EtsUtil.store_in_cache("sensors_array_bkp",sensors_array)
    tablename
      |> EtsUtil.store_in_cache("sensors_array_max_attemps",sensors_array |> Selector.max_attemps())
    tablename
      |> increment_current_attemps("sensors_array_current_attemps")
  end
  
  defp init_actuators(id,actuators_array) do
    tablename = :"#{@tablename_actuators_layer <> id}"
    tablename
      |> EtsUtil.store_in_cache("actuators_array",actuators_array)
    tablename
      |> EtsUtil.store_in_cache("actuators_array_bkp",actuators_array)
    tablename
      |> EtsUtil.store_in_cache("actuators_array_max_attemps",actuators_array |> Selector.max_attemps())
    tablename
      |> increment_current_attemps("actuators_array_current_attemps")
  end
  
  defp init_neurons(id,neurons_array) do
    tablename = :"#{@tablename_neuron_layers <> id}"
    tablename
      |> EtsUtil.store_in_cache("neurons_array",neurons_array)
    tablename
      |> EtsUtil.store_in_cache("neurons_array_bkp",neurons_array)
    tablename
      |> EtsUtil.store_in_cache("neurons_array_max_attemps",neurons_array |> Selector.max_attemps())
    tablename
      |> increment_current_attemps("neurons_array_current_attemps")
  end
  
  # attemps
  defp increment_current_attemps(tablename,identifier) do
    current = tablename
                |> EtsUtil.read_from_cache(identifier)
    cond do
      (nil == current)
        -> tablename
             |> EtsUtil.store_in_cache(identifier,0) 
      true
        -> tablename
             |> EtsUtil.store_in_cache(identifier,current + 1)
    end
  end
  
end
