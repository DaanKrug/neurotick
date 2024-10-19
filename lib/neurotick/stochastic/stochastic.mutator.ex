defmodule Neurotick.Stochastic.StochasticMutator do

  @moduledoc false

  alias Neurotick.Stochastic.NeuronStorage
  alias Neurotick.Mutator.NeuronMutator
  alias Neurotick.Mutator.NeuronTopologyMutator
  
  @mutating_element_neuron_weight "mutating_element_neuron_weight"
  @mutating_topology_neuron "mutating_topology_neuron"
  
  
  def mutate_elements(stochastic_id) do
    mutating_element_type = stochastic_id 
                              |> NeuronStorage.read_mutating_element_type()
    cond do
      (mutating_element_type == @mutating_element_neuron_weight)
        -> stochastic_id
             |> NeuronMutator.mutate_neurons()
      (mutating_element_type == @mutating_topology_neuron)
        -> stochastic_id
             |> NeuronTopologyMutator.mutate_neurons_topology()
      true
        -> :ok
    end
  end
    
end
