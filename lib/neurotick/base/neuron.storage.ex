defmodule Neurotick.Base.NeuronStorage do

  alias Krug.EtsUtil
  alias Neurotick.Base.NeuronMetadata
  
  @tablename_metadata :neurotick_ets_metadata
  @tablename_sensors :neurotick_ets_sensors
  @tablename_neurons :neurotick_ets_neurons
  @tablename_sensors_data :neurotick_ets_sensors_data
  @tablename_activation_functions :neurotick_ets_activation_functions
  @tablename_actuators :neurotick_ets_actuators
  @tablename_actuators_expected_inputs :neurotick_ets_actuators_expected_inputs
  @tablename_config :neurotick_ets_config
  @tablename_neural_network :neurotick_ets_neural_network


  def config_storage() do
    EtsUtil.new(@tablename_metadata)
    EtsUtil.new(@tablename_sensors)
    EtsUtil.new(@tablename_neurons)
    EtsUtil.new(@tablename_sensors_data)
    EtsUtil.new(@tablename_activation_functions)
    EtsUtil.new(@tablename_actuators)
    EtsUtil.new(@tablename_actuators_expected_inputs)
    EtsUtil.new(@tablename_config)
    EtsUtil.new(@tablename_neural_network)
  end
  
  def config_sensor(neurons_array,pid) do
    EtsUtil.store_in_cache(@tablename_neurons,pid,neurons_array)     
    NeuronMetadata.update_metadata_bindings(pid,[],neurons_array)        
  end
  
  def config_neuron(params_array,pid) do
    [
      sensors_array,
      actuators_array,
      actuators_expected_inputs
    ] = params_array
    EtsUtil.store_in_cache(@tablename_sensors,pid,sensors_array)
    EtsUtil.store_in_cache(@tablename_actuators,pid,actuators_array)
    NeuronMetadata.update_metadata_bindings(pid,sensors_array,actuators_array)
    actuators_array
      |> config_actuators(actuators_expected_inputs)          
  end
  
  defp config_actuators(pids,expected_inputs) do
    cond do
      (Enum.empty?(pids))
        -> :ok
      true
        -> pids
             |> config_actuator(expected_inputs)
    end           
  end
  
  defp config_actuator(pids,expected_inputs) do
    pid = pids 
            |> hd()
    EtsUtil.store_in_cache(
      @tablename_actuators_expected_inputs,
      pid,
      expected_inputs
    )
    pids
      |> tl()
      |> config_actuators(expected_inputs)    
  end
  
  def get_actuator_expected_inputs(pid) do
    actuator_expected_inputs = EtsUtil.read_from_cache(@tablename_actuators_expected_inputs,pid)
    cond do
      (nil == actuator_expected_inputs)
        -> 0
      true
        -> actuator_expected_inputs
    end
  end
  
  def get_neuron_pids(pid) do
    children = EtsUtil.read_from_cache(@tablename_neurons,pid)
    cond do
      (nil == children)
        -> []
      true
        -> children
    end
  end
  
  def get_sensor_pids(pid) do
    children = EtsUtil.read_from_cache(@tablename_sensors,pid)
    cond do
      (nil == children)
        -> []
      true
        -> children
    end
  end
  
  def store_sensor_data(data,pid) do
    EtsUtil.store_in_cache(@tablename_sensors_data,pid,[data | get_sensors_data(pid)])
  end
  
  def get_sensors_data(pid) do
    data = EtsUtil.read_from_cache(@tablename_sensors_data,pid)
    cond do
      (nil == data)
        -> []
      true
        -> data
    end
  end
  
  def store_network_element(network_id,element_id,element) do
    id = "#{network_id}_#{element_id}"
    EtsUtil.store_in_cache(@tablename_neural_network,id,element)
  end
  
  def get_network_element(network_id,element_id) do
    id = "#{network_id}_#{element_id}"
    EtsUtil.read_from_cache(@tablename_neural_network,id)
  end
  
  def get_activation_functions(pid) do
    functions = EtsUtil.read_from_cache(@tablename_activation_functions,pid)
    cond do
      (nil == functions)
        -> []
      true
        -> functions
    end
  end
  
  def get_actuator_pids(pid) do
    actuators = EtsUtil.read_from_cache(@tablename_actuators,pid)
    cond do
      (nil == actuators)
        -> []
      true
        -> actuators
    end
  end
  
  def get_config(pid) do
    EtsUtil.read_from_cache(@tablename_config,pid)
  end
  
  def clear_sensor_data(pid) do
    EtsUtil.remove_from_cache(@tablename_sensors_data,pid)
  end
  
  def get_sensors_and_sensor_signals_received(pid) do
    [
      get_sensor_pids(pid),
      get_sensors_data(pid)
    ]         
  end
  	
end
