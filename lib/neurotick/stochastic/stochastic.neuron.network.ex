defmodule Neurotick.Stochastic.StochasticNeuronNetwork do

  alias Neurotick.Base.NeuronNetwork
  alias Neurotick.Stochastic.NeuronStorage
  alias Neurotick.Stochastic.StochasticMath
  alias Neurotick.Stochastic.StochasticMutator
  
  
  def config(stochastic_id,sensors_array,neurons_array,actuators_array) do
    stochastic_id
      |> NeuronStorage.config(sensors_array,neurons_array,actuators_array)
  end
  
  def run_stochastic_neurons_mutation(stochastic_id,expected_result) do
    cond do
      (!(stochastic_id |> NeuronStorage.left_neurons_attemps()))
        -> stochastic_id
             |> NeuronStorage.get_neurons()
      true
        -> stochastic_id
             |> run_stochastic_neurons_mutation2(expected_result)
    end
  end
  
  defp run_stochastic_neurons_mutation2(stochastic_id,expected_result) do
    current_result = stochastic_id
                       |> run_network()
    stochastic_id
      |> StochasticMutator.mutate_neurons()
    new_result = stochastic_id
                   |> run_network()  
    better_result = expected_result
                      |> StochasticMath.compare_results(current_result,new_result)
    cond do
      (better_result == 0)
        -> stochastic_id
             |> NeuronStorage.rollback_neurons()
      true
        -> :ok
    end
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
    :timer.sleep(100)
    network_id
      |> NeuronNetwork.process_signals()
    :timer.sleep(100)
    result = network_id 
               |> NeuronNetwork.extract_output()
    :timer.sleep(100)
    network_id
      |> NeuronNetwork.stop_network()
    result
  end
    

end