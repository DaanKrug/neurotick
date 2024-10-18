defmodule Neurotick.Stochastic.NeuronStorage do

  @moduledoc false

  alias Krug.EtsUtil
  alias Neurotick.Stochastic.Selector
  
  
  @tablename_sensors_layer "table_sensors_layer_"
  @tablename_neuron_layers "table_neuron_layer_"
  @tablename_actuators_layer "table_actuators_layer_"
  @tablename_math_params "table_math_params_"
  
  
  # config
  def config(id,sensors_array,neurons_array,actuators_array,max_attemps,round_precision) do
  	EtsUtil.new(:"#{@tablename_sensors_layer <> id}")
  	EtsUtil.new(:"#{@tablename_neuron_layers <> id}")
    EtsUtil.new(:"#{@tablename_actuators_layer <> id}")
    EtsUtil.new(:"#{@tablename_math_params <> id}")
    :"#{@tablename_math_params <> id}"
      |> EtsUtil.store_in_cache("round_precision",round_precision)
    id 
      |> init_sensors(sensors_array,max_attemps)
    id
      |> init_actuators(actuators_array,max_attemps)
    id
      |> init_neurons(neurons_array,max_attemps)
  end
  
  # math params
  def get_round_precision(id) do
    :"#{@tablename_math_params <> id}"
      |> EtsUtil.read_from_cache("round_precision")
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
	current_sensors_array = tablename
                              |> EtsUtil.read_from_cache("sensors_array")
    tablename
      |> EtsUtil.remove_from_cache("sensors_array")
    tablename
      |> EtsUtil.remove_from_cache("sensors_array_bkp")
    tablename
      |> EtsUtil.store_in_cache("sensors_array",sensors_array)
    tablename
      |> EtsUtil.store_in_cache("sensors_array_bkp",current_sensors_array)
    tablename
      |> increment_current_attemps("sensors_array_current_attemps")
  end
  
  def set_actuators(id,actuators_array) do
    tablename = :"#{@tablename_actuators_layer <> id}"
	current_actuators_array = tablename
                                |> EtsUtil.read_from_cache("actuators_array")
    tablename
      |> EtsUtil.remove_from_cache("actuators_array")
    tablename
      |> EtsUtil.remove_from_cache("actuators_array_bkp")
    tablename
      |> EtsUtil.store_in_cache("actuators_array",actuators_array)
    tablename
      |> EtsUtil.store_in_cache("actuators_array_bkp",current_actuators_array)
    tablename
      |> increment_current_attemps("actuators_array_current_attemps")
  end
  
  def set_neurons(id,neurons_array) do
    tablename = :"#{@tablename_neuron_layers <> id}"
    current_neurons_array = tablename
                              |> EtsUtil.read_from_cache("neurons_array")
    tablename
      |> EtsUtil.remove_from_cache("neurons_array")
    tablename
      |> EtsUtil.remove_from_cache("neurons_array_bkp")
    tablename
      |> EtsUtil.store_in_cache("neurons_array",neurons_array)
    tablename
      |> EtsUtil.store_in_cache("neurons_array_bkp",current_neurons_array)
    tablename
      |> increment_current_attemps("neurons_array_current_attemps")
  end
  
  #rollback
  def rollback_sensors(id) do
    tablename = :"#{@tablename_sensors_layer <> id}"
    tablename
      |> EtsUtil.remove_from_cache("sensors_array")
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
      |> EtsUtil.remove_from_cache("actuators_array")
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
      |> EtsUtil.remove_from_cache("neurons_array")
    tablename
      |> EtsUtil.store_in_cache(
	       "neurons_array",
	       EtsUtil.read_from_cache(tablename,"neurons_array_bkp")
	     )
	tablename
      |> increment_current_attemps("neurons_array_current_attemps")
  end
  
  # initialization
  defp init_sensors(id,sensors_array,max_attemps) do
    tablename = :"#{@tablename_sensors_layer <> id}" 
    tablename
      |> EtsUtil.remove_from_cache("sensors_array")
    tablename
      |> EtsUtil.remove_from_cache("sensors_array_bkp")
    tablename
      |> EtsUtil.remove_from_cache("sensors_array_max_attemps")
    tablename
      |> EtsUtil.store_in_cache("sensors_array",sensors_array)
    tablename
      |> EtsUtil.store_in_cache("sensors_array_bkp",sensors_array)
    cond do
      (nil == max_attemps)
        -> tablename
             |> EtsUtil.store_in_cache("sensors_array_max_attemps",sensors_array |> Selector.max_attemps())
      true
        -> tablename
             |> EtsUtil.store_in_cache("sensors_array_max_attemps",max_attemps)
    end
    tablename
      |> increment_current_attemps("sensors_array_current_attemps")
  end
  
  defp init_actuators(id,actuators_array,max_attemps) do
    tablename = :"#{@tablename_actuators_layer <> id}"
    tablename
      |> EtsUtil.remove_from_cache("actuators_array")
    tablename
      |> EtsUtil.remove_from_cache("actuators_array_bkp")
    tablename
      |> EtsUtil.remove_from_cache("actuators_array_max_attemps")
    tablename
      |> EtsUtil.store_in_cache("actuators_array",actuators_array)
    tablename
      |> EtsUtil.store_in_cache("actuators_array_bkp",actuators_array)
    cond do
      (nil == max_attemps)
        -> tablename
             |> EtsUtil.store_in_cache("actuators_array_max_attemps",actuators_array |> Selector.max_attemps())
      true
        -> tablename
             |> EtsUtil.store_in_cache("actuators_array_max_attemps",max_attemps)
    end
    tablename
      |> increment_current_attemps("actuators_array_current_attemps")
  end
  
  defp init_neurons(id,neurons_array,max_attemps) do
    tablename = :"#{@tablename_neuron_layers <> id}"
    tablename
      |> EtsUtil.remove_from_cache("neurons_array")
    tablename
      |> EtsUtil.remove_from_cache("neurons_array_bkp")
    tablename
      |> EtsUtil.remove_from_cache("neurons_array_max_attemps")
    tablename
      |> EtsUtil.store_in_cache("neurons_array",neurons_array)
    tablename
      |> EtsUtil.store_in_cache("neurons_array_bkp",neurons_array)
    cond do
      (nil == max_attemps)
        -> tablename
             |> EtsUtil.store_in_cache("neurons_array_max_attemps",neurons_array |> Selector.max_attemps())
      true
        -> tablename
             |> EtsUtil.store_in_cache("neurons_array_max_attemps",max_attemps)
    end
    tablename
      |> increment_current_attemps("neurons_array_current_attemps")
  end
  
  # attemps
  defp increment_current_attemps(tablename,identifier) do
    current = tablename
                |> EtsUtil.read_from_cache(identifier)
    tablename
      |> EtsUtil.remove_from_cache(identifier)
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
