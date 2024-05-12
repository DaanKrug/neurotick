defmodule Neurotick.Base.NeuronStorage do

  alias Krug.EtsUtil
  
  @tablename_sensors :neurotick_ets_sensors
  @tablename_neurons :neurotick_ets_neurons
  @tablename_sensors_data :neurotick_ets_sensors_data
  @tablename_activation_functions :neurotick_ets_activation_functions
  @tablename_actuators :neurotick_ets_actuators
  @tablename_actuators_expected_inputs :neurotick_ets_actuators_expected_inputs
  @tablename_config :neurotick_ets_config

  def config_storage() do
    EtsUtil.new(@tablename_sensors)
    EtsUtil.new(@tablename_neurons)
    EtsUtil.new(@tablename_sensors_data)
    EtsUtil.new(@tablename_activation_functions)
    EtsUtil.new(@tablename_actuators)
    EtsUtil.new(@tablename_actuators_expected_inputs)
    EtsUtil.new(@tablename_config)
  end
  
  def config_sensor(params_array,pid) do
    [neurons_array,debugg] = params_array
    EtsUtil.store_in_cache(@tablename_neurons,pid,neurons_array)  
    EtsUtil.store_in_cache(@tablename_config,pid,[nil,nil,debugg])           
  end
  
  def config_neuron(params_array,pid) do
    [
      sensors_array,
      activation_functions_array,
      actuators_array,
      bias,
      operation,
      debugg
    ] = params_array
    EtsUtil.store_in_cache(@tablename_sensors,pid,sensors_array)
    EtsUtil.store_in_cache(@tablename_activation_functions,pid,activation_functions_array)
    EtsUtil.store_in_cache(@tablename_actuators,pid,actuators_array)
    EtsUtil.store_in_cache(@tablename_config,pid,[bias,operation,debugg])   
    config_actuators(actuators_array,debugg)          
  end
  
  defp config_actuators(pids,debugg) do
    cond do
      (Enum.empty?(pids))
        -> :ok
      true
        -> pids
             |> config_actuator(debugg)
    end           
  end
  
  defp config_actuator(pids,debugg) do
    pid = pids 
            |> hd()
    EtsUtil.store_in_cache(@tablename_config,pid,[nil,nil,debugg])  
    EtsUtil.store_in_cache(
      @tablename_actuators_expected_inputs,
      pid,
      (pid |> get_actuator_expected_inputs()) + 1
    )
    pids
      |> tl()
      |> config_actuators(debugg)    
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
