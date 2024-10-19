defmodule Neurotick.Mutator.NeuronTopologyMutator do

  @moduledoc false

  alias Neurotick.Stochastic.NeuronStorage
  alias Neurotick.Stochastic.Selector
  
  
  def mutate_neurons_topology(stochastic_id) do
    neurons_array_layer = stochastic_id
                            |> NeuronStorage.get_neurons()
    neuron_names_to_disturb = neurons_array_layer
                                |> flattify_neurons_names()
                                |> Selector.select_elements()
    mutated_neurons_array_layer = neuron_names_to_disturb 
                                    |> duplicate_remove_neurons(neurons_array_layer)  
    stochastic_id
      |> NeuronStorage.set_neurons(mutated_neurons_array_layer)
  end

  defp duplicate_remove_neurons(neuron_names_to_disturb,neurons_array_layer) do
    cond do
      (Enum.empty?(neuron_names_to_disturb))
        -> neurons_array_layer
      true
        -> neuron_names_to_disturb
             |> duplicate_remove_neurons2(neurons_array_layer)
    end
  end
  
  defp duplicate_remove_neurons2(neuron_names_to_disturb,neurons_array_layer) do
    neuron_name = neuron_names_to_disturb
                    |> hd()
    neurons_array_layer = mutate_neurons_array_layers(neuron_name,neurons_array_layer)                             
    neuron_names_to_disturb
      |> tl()
      |> duplicate_remove_neurons(neurons_array_layer)
  end
  
  defp mutate_neurons_array_layers(neuron_name,neurons_array_layer,mutated_layers \\ []) do
    cond do
      (Enum.empty?(neurons_array_layer))
        -> mutated_layers
             |> Enum.reverse()
      true
        -> neuron_name
             |> mutate_neurons_array_layers(
                  neurons_array_layer
                    |> tl(),
                  [
                    neuron_name
                      |> mutate_neurons_array(
                           neurons_array_layer 
                             |> hd()
                         )
                      | mutated_layers
                  ]
                )
    end
  end
  
  defp mutate_neurons_array(neuron_name,neurons_array,mutated_neurons_array \\ []) do
    cond do
      (Enum.empty?(neurons_array))
        -> mutated_neurons_array
      true
        -> neuron_name
             |> mutate_neurons_array2(neurons_array,mutated_neurons_array)
    end
  end
  
  defp mutate_neurons_array2(neuron_name,neurons_array,mutated_neurons_array) do
    neuron = neurons_array
              |> hd()
    [_,name,_,_,_,_,_,_] = neuron
    cond do
      (neuron_name != name)
        -> neuron_name
             |> mutate_neurons_array(
                  neurons_array
                    |> tl(),
                  [
                    neuron 
                      | mutated_neurons_array
                  ]
                )
      true
        -> neuron_name
             |> mutate_neurons_array3(neurons_array,mutated_neurons_array)
    end
  end
  
  defp mutate_neurons_array3(neuron_name,neurons_array,mutated_neurons_array) do
    neuron_name
      |> mutate_neurons_array(
           neurons_array
             |> tl(),
           neurons_array
             |> hd()
             |> duplicate_or_disapear_neuron(mutated_neurons_array)
         )
  end
  
  defp duplicate_or_disapear_neuron(neuron,mutated_neurons_array) do
    rand = :rand.uniform(2)
    [
      "duplicate_or_disapear_neuron",
      rand
    ]
      |> IO.inspect()
    cond do
      (rand == 1)
        -> mutated_neurons_array
      true
        -> [neuron,neuron] 
             |> append_neurons(mutated_neurons_array)
    end
  end
  
  defp append_neurons(new_neurons,mutated_neurons_array) do
    cond do
      (Enum.empty?(new_neurons))
        -> mutated_neurons_array
      true
        -> new_neurons
             |> tl()
             |> append_neurons([new_neurons |> hd() | mutated_neurons_array])
    end
  end
  
  defp flattify_neurons_names(neurons_array_layers,flat_neurons_array_names \\ []) do
    cond do
      (neurons_array_layers |> length() < 2)
        -> flat_neurons_array_names
             |> Enum.reverse()
      (neurons_array_layers |> hd() |> length() < 2)
        -> neurons_array_layers
             |> tl()
             |> flattify_neurons_names(flat_neurons_array_names)
      true
        -> neurons_array_layers
             |> tl()
             |> flattify_neurons_names(
                  neurons_array_layers
                    |> hd()
                    |> flattify_neurons_names2(flat_neurons_array_names)
                )
    end
  end
  
  defp flattify_neurons_names2(neurons_array,flat_neurons_array_names) do
    cond do
      (Enum.empty?(neurons_array))
        -> flat_neurons_array_names
             |> Enum.reverse()
      true
        -> neurons_array
             |> tl()
             |> flattify_neurons_names2(
                  [
                    neurons_array 
                      |> hd() 
                      |> tl() 
                      |> hd() 
                      | flat_neurons_array_names
                  ]
                )
    end
  end
  
end
