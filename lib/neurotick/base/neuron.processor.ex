defmodule Neurotick.Base.NeuronProcessor do

  @moduledoc false

  use Neurotick.Base.NeuronLogger

  alias Neurotick.Base.NeuronOperationParam
  alias Neurotick.Base.NeuronStorage
  alias Neurotick.Base.NeuronMetadata
      

  def process_signals(signals_array,pid) do
    [weight,bias,operation,_] = NeuronStorage.get_config(pid)
    debugg_info(
      pid,
      ["process_signals => ",signals_array,bias]
    )   
    NeuronStorage.clear_sensor_data(pid)
    operation_params = NeuronOperationParam.add_all_operations(signals_array,operation)
    inputs = NeuronOperationParam.extract_inputs(signals_array)
    result = NeuronOperationParam.calculate_inputs(inputs,operation_params)
    debugg_info(
      pid,
      ["result => ",result,"result + bias => ",result + bias]
    )
    result = NeuronStorage.get_activation_functions(pid)
               |> process_activations(result + bias)
    actuators = NeuronStorage.get_actuator_pids(pid)
    debugg_info(
      pid,
      ["result => ",result,"actuators => ",actuators]
    )
    pid
      |> NeuronMetadata.update_metadata(inputs,[result])
    actuators
      |> call_actuators(result,weight)
    result
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
  
  defp call_actuators(actuators,result,weight) do
    cond do
      (Enum.empty?(actuators))
        -> :ok
      true
        -> actuators
             |> call_actuator(result,weight)
    end
  end
  
  defp call_actuator(actuators,result,weight) do
    actuators
      |> hd()
      |> Process.send({:signal_array,[result,weight]},[:noconnect])
    actuators
      |> tl()
      |> call_actuators(result,weight)
  end
  
  def terminate_all(pids) do
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
      |> terminate_all()
  end
	
end