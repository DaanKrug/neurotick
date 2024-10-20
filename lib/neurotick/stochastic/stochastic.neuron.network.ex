defmodule Neurotick.Stochastic.StochasticNeuronNetwork do

  @moduledoc """
  A module to apply the SHC-RR (Stochastic Hill Climb with Random Restart)
  method to a "Neurotick.Base.NeuronNetwork".  
  
  ## Examples
  
  ```elixir
  # start a Neural Network with initial parameters to obtain initial result
  network_id = NeuronNetwork.start_network()
  NeuronNetwork.config_sensors(network_id,fixed_sensors_array)
  NeuronNetwork.config_actuators(network_id,actuators_array)
  NeuronNetwork.config_neurons(network_id,neurons_array_layers)
  network_id
    |> NeuronNetwork.process_signals()
  :timer.sleep(100)  
  #initial result
  original_result = network_id 
                      |> NeuronNetwork.extract_output()
  network_id
      |> NeuronNetwork.stop_network()
  
  ...
                      
  # original_result
  #                 [[102.5], [102.5], [102.5]]   << = original_result          
  expected_result = [[105.0], [105.0], [105.0]]                    
 
  stochastic_id = "my_stochastic_network_id"
  max_attemps_neuron = 1000
  max_attemps_topology = 10
  round_precision = 3
    
  stochastic_id
    |> StochasticNeuronNetwork.config(
         fixed_sensors_array,
         neurons_array_layers,
         actuators_array,
         round_precision,
         max_attemps_neuron,
         max_attemps_topology
       )
     
  # find better Neuron Layers mutated weights 
  mutated_neurons = stochastic_id
                      |> StochasticNeuronNetwork.run_stochastic_mutations(
                           expected_result
                         )
    
  # apply the mutated Neuron Layers to a Neural Network
  network_id = NeuronNetwork.start_network()
  NeuronNetwork.config_sensors(network_id,fixed_sensors_array)
  NeuronNetwork.config_actuators(network_id,actuators_array)
  NeuronNetwork.config_neurons(network_id,mutated_neurons)
  network_id
    |> NeuronNetwork.process_signals()
  :timer.sleep(100)  
  final_result = network_id 
                   |> NeuronNetwork.extract_output()
  network_id
    |> NeuronNetwork.stop_network()
    
  # final result =~ [[105.00015977946396], [105.00015977946396], [105.00015977946396]]
  ...
  ```
  """
  @moduledoc since: "0.0.4"


  alias Neurotick.Base.NeuronNetwork
  alias Neurotick.Stochastic.NeuronStorage
  alias Neurotick.Stochastic.StochasticMath
  alias Neurotick.Mutator.NeuronMutator
  alias Neurotick.Mutator.NeuronTopologyMutator
  
  
    
  @doc """
  Initializes the SHC-RR parameters.
  
  stochastic_id: Identifier of SHC-RR, used to map values. 
  sensors_array: Sensors of Neural Network.
  neurons_array: Neurons Layers of Neural Network.
  actuators_array: Actuators of Neural Network.
  round_precision \\ 2: Round decimal digits to be used on difference calculation between expected results and calculated results.
  max_attemps_neuron \\ nil: Maximum Attemps to find better weights disturbation. When nil will be calculated based on Neurons size.
  max_attemps_topology \\ nil: Maximum Attemps to find better weights disturbation. When nil will be default to 1.
  max_neurons_on_layer \\ 10: Maximum layers to be in a neuron layer (for dynamic topology mutation).
  """
  def config(stochastic_id,sensors_array,neurons_array,actuators_array,
             round_precision \\ 2,max_attemps_neuron \\ nil,max_attemps_topology \\ 1,max_neurons_on_layer \\ 10) do
    stochastic_id
      |> NeuronStorage.config(sensors_array,neurons_array,actuators_array,
                              round_precision,max_attemps_neuron,max_attemps_topology,max_neurons_on_layer)
  end
  
  
  
  @doc """
  Runt the SHC-RR for configured Neural Network parameters with the received "expected_result".
  """
  def run_stochastic_mutations(stochastic_id,expected_result) do
    cond do
      (!(stochastic_id |> NeuronStorage.left_topology_attemps())
        and !(stochastic_id |> NeuronStorage.left_neurons_attemps()))
          -> stochastic_id
               |> NeuronStorage.get_neurons()
      (!(stochastic_id |> NeuronStorage.left_neurons_attemps()))
        -> stochastic_id
             |> mutate_topology_and_continue(expected_result)
      true
        -> stochastic_id
             |> run_stochastic_mutations2(expected_result)
    end
  end
  
  
  
  defp mutate_topology_and_continue(stochastic_id,expected_result) do
    stochastic_id
      |> NeuronTopologyMutator.mutate_neurons_topology()
    stochastic_id
      |> NeuronStorage.increment_topology_attemps()
    stochastic_id
      |> NeuronStorage.reset_neurons_attemps()
    stochastic_id
      |> run_stochastic_mutations2(expected_result)
  end
  
  
  
  defp run_stochastic_mutations2(stochastic_id,expected_result) do
    round_precision = stochastic_id
                        |> NeuronStorage.get_round_precision()
    current_result = stochastic_id
                       |> run_network()
    stochastic_id
      |> NeuronMutator.mutate_neurons()
    new_result = stochastic_id
                   |> run_network()  
    [
      better_result,
      better_result_diff_from_expected
    ] = expected_result
          |> StochasticMath.compare_results(current_result,new_result,round_precision)
    stochastic_id 
      |> rollback_stochastic_neurons_mutation(better_result)  
    stochastic_id
      |> run_stochastic_mutations3(expected_result,better_result_diff_from_expected)
  end
  
  
  
  def run_stochastic_mutations3(stochastic_id,expected_result,better_result_diff_from_expected) do
    cond do
      (better_result_diff_from_expected == 0)
        -> stochastic_id
             |> NeuronStorage.get_neurons()
      true
        -> stochastic_id
             |> run_stochastic_mutations(expected_result)
    end
  end
  
  
  
  defp rollback_stochastic_neurons_mutation(stochastic_id,:current) do
    stochastic_id
      |> NeuronStorage.rollback_neurons()
  end
  
  
  
  defp rollback_stochastic_neurons_mutation(_stochastic_id,_better_result) do
    :ok
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
    max_neurons_on_layer = stochastic_id
                             |> NeuronStorage.get_max_neurons_on_layer()
    max_neurons_on_layer
      |> div(10) 
      |> :timer.sleep()
    network_id
      |> NeuronNetwork.process_signals()
    ((max_neurons_on_layer * 2) + 5) 
      |> :timer.sleep()
    result = network_id 
               |> NeuronNetwork.extract_output()
    max_neurons_on_layer
      |> div(10) 
      |> :timer.sleep()
    network_id
      |> NeuronNetwork.stop_network()
    result
  end
    
end
