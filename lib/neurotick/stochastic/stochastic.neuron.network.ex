defmodule Neurotick.Stochastic.StochasticNeuronNetwork do

  @moduledoc """
  A module to apply the SHC-RR (Stochastic Hill Climb with Random Restart)
  method to a "Neurotick.Base.NeuronNetwork".
  
  
  """
  @moduledoc since: "0.0.4"


  alias Neurotick.Base.NeuronNetwork
  alias Neurotick.Stochastic.NeuronStorage
  alias Neurotick.Stochastic.StochasticMath
  alias Neurotick.Stochastic.StochasticMutator
  
  
  def config(stochastic_id,sensors_array,neurons_array,actuators_array,max_attemps \\ nil,round_precision \\ 2) do
    stochastic_id
      |> NeuronStorage.config(sensors_array,neurons_array,actuators_array,max_attemps,round_precision)
  end
  
  def run_stochastic_neurons_mutation(stochastic_id,expected_result) do
    cond do
      (!(stochastic_id |> NeuronStorage.left_neurons_attemps()))
        -> stochastic_id
             |> stop_mutations()
      true
        -> stochastic_id
             |> run_stochastic_neurons_mutation2(expected_result)
    end
  end
  
  defp run_stochastic_neurons_mutation2(stochastic_id,expected_result) do
    round_precision = stochastic_id
                        |> NeuronStorage.get_round_precision()
    current_result = stochastic_id
                       |> run_network()
    stochastic_id
      |> StochasticMutator.mutate_neurons()
    new_result = stochastic_id
                   |> run_network()  
    [better_result,diff] = expected_result
                             |> StochasticMath.compare_results(current_result,new_result,round_precision)
                      
    cond do
      (diff == 0)
        -> stochastic_id
             |> stop_mutations()
      true
        -> stochastic_id
             |> run_stochastic_neurons_mutation3(expected_result,better_result)
    end
  end
  
  defp stop_mutations(stochastic_id) do
    stochastic_id
      |> NeuronStorage.get_neurons()
  end
  
  defp run_stochastic_neurons_mutation3(stochastic_id,expected_result,:current) do
    stochastic_id
      |> NeuronStorage.rollback_neurons()
  	stochastic_id
      |> run_stochastic_neurons_mutation(expected_result)
  end
  
  defp run_stochastic_neurons_mutation3(stochastic_id,expected_result,:new) do
  	stochastic_id
      |> run_stochastic_neurons_mutation(expected_result)
  end
  
  defp run_network(stochastic_id) do
    network_id = NeuronNetwork.start_network()
    sensors_array = stochastic_id
                      |> NeuronStorage.get_sensors()
    actuators_array = stochastic_id
                        |> NeuronStorage.get_actuators()
    neurons_array_layers = stochastic_id
                             |> NeuronStorage.get_neurons()
    NeuronNetwork.config_sensors(network_id,sensors_array)
    NeuronNetwork.config_actuators(network_id,actuators_array)
    NeuronNetwork.config_neurons(network_id,neurons_array_layers)
    :timer.sleep(1)
    network_id
      |> NeuronNetwork.process_signals()
    :timer.sleep(1)
    result = network_id 
               |> NeuronNetwork.extract_output()
    :timer.sleep(1)
    network_id
      |> NeuronNetwork.stop_network()
    result
  end
    

end