defmodule Neurotick.Base.NeuronProcessor do

  alias Neurotick.Base.NeuronOperationParam
  alias Neurotick.Base.NeuronStorage
      

  def process_signals(signals_array,pid) do
    [bias,operation,debugg] = NeuronStorage.get_config(pid)
    
    debugg_info(
      ["process_signals => ",signals_array,bias],
      debugg
    )   
    
    NeuronStorage.clear_sensor_data(pid)
    operation_params = NeuronOperationParam.add_all_operations(signals_array,operation)
    inputs = NeuronOperationParam.extract_inputs(signals_array)
    result = NeuronOperationParam.calculate_inputs(inputs,operation_params)
    
    debugg_info(
      ["result => ",result,"result + bias => ",result + bias],
      debugg
    )
    result = NeuronStorage.get_activation_functions(pid)
               |> process_activations(result + bias)
               
    
    actuators = NeuronStorage.get_actuators(pid)
    debugg_info(
      ["result => ",result,"actuators => ",actuators],
      debugg
    )
    
    actuators
      |> call_actuators(result)
    
    result
  end
  
  defp debugg_info(info,debugg) do
    cond do
      (!debugg)
        -> :ok
      true
        -> info
             |> IO.inspect()
    end
  end
  
  defp process_activations(activation_functions,result) do
    cond do
      (Enum.empty?(activation_functions))
        -> result
      true
        -> activation_functions
             |> process_activation(result)
    end
  end
  
  defp process_activation(activation_functions,result) do
    function = activation_functions
                 |> hd()
    activation_result = function.process_activation(result)
    activation_functions
      |> tl()
      |> process_activations(activation_result)
  end
  
  defp call_actuators(actuators,result) do
    cond do
      (Enum.empty?(actuators))
        -> :ok
      true
        -> actuators
             |> call_actuator(result)
    end
  end
  
  defp call_actuator(actuators,result) do
    actuator_pid = actuators
                     |> hd()
    Process.send(actuator_pid,{Kernel.self(),result},[:noconnect])
    actuators
      |> tl()
      |> call_actuators(result)
  end
	
end