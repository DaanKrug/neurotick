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
  max_attemps = 1000
  round_precision = 3
    
  stochastic_id
    |> StochasticNeuronNetwork.config(
         fixed_sensors_array,
         neurons_array_layers,
         actuators_array,
         max_attemps,
         round_precision
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
  alias Neurotick.Stochastic.StochasticMutator
  
  
  @mutating_element_neuron_weight "mutating_element_neuron_weight"
  @mutating_element_neurons [
  	@mutating_element_neuron_weight
  ]
  

    
  @doc """
  Initializes the SHC-RR parameters.
  
  stochastic_id: Identifier of SHC-RR, used to map values. 
  sensors_array: Sensors of Neural Network.
  neurons_array: Neurons Layers of Neural Network.
  actuators_array: Actuators of Neural Network.
  max_attemps \\ nil: Max Attemps to find better weights disturbation. When nil will be calculated based on Neurons size.
  round_precision \\ 2: Round decimal digits to be used on difference calculation between expected results and calculated results.
  """
  def config(stochastic_id,sensors_array,neurons_array,actuators_array,max_attemps \\ nil,round_precision \\ 2) do
    stochastic_id
      |> NeuronStorage.config(sensors_array,neurons_array,actuators_array,max_attemps,round_precision)
    stochastic_id
      |> NeuronStorage.set_mutating_element_type(@mutating_element_neuron_weight)
  end
  
  
  
  @doc """
  Runt the SHC-RR for configured Neural Network parameters with the received "expected_result".
  """
  def run_stochastic_mutations(stochastic_id,expected_result) do
    mutating_element = stochastic_id
                         |> NeuronStorage.read_mutating_element_type()
    cond do
      (Enum.member?(@mutating_element_neurons,mutating_element)
        and !(stochastic_id |> NeuronStorage.left_neurons_attemps()))
          -> stochastic_id
               |> change_mutating_element_and_continue(expected_result,mutating_element)
      true
        -> stochastic_id
             |> run_stochastic_mutations2(expected_result)
    end
  end
  
  
  
  defp change_mutating_element_and_continue(stochastic_id,_expected_result,mutating_element_type) do
    ["mutating_element_type => ",mutating_element_type]
      |> IO.inspect()
    cond do
      (mutating_element_type == @mutating_element_neuron_weight)
        -> stochastic_id
             |> NeuronStorage.get_neurons()
      true
        -> stochastic_id
             |> NeuronStorage.get_neurons()
    end
  end
  
  
  
  defp change_mutating_element_and_continue2(stochastic_id,expected_result,mutating_element_type) do
    stochastic_id
      |> NeuronStorage.set_mutating_element_type(mutating_element_type)
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
      |> StochasticMutator.mutate_elements()
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
