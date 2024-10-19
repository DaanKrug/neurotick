defmodule Neurotick.Mutator.NeuronMutator do

  @moduledoc false

  alias Neurotick.Stochastic.NeuronStorage
  alias Neurotick.Stochastic.Selector
  
  
  def mutate_neurons(stochastic_id) do
    neurons_array_layer = stochastic_id
                      |> NeuronStorage.get_neurons()
    neuron_names_to_disturb = neurons_array_layer
                                |> flattify_neurons_names()
                                |> Selector.select_elements()
    mutated_neurons_array_layer = neurons_array_layer
                                    |> disturb_selected_neurons_array(neuron_names_to_disturb)  
    stochastic_id
      |> NeuronStorage.set_neurons(mutated_neurons_array_layer)
  end

  defp disturb_selected_neurons_array(neurons_array_layer,neuron_names_to_disturb,mutated_neurons \\ []) do
    cond do
      (Enum.empty?(neurons_array_layer))
        -> mutated_neurons
             |> Enum.reverse()
      true
        -> neurons_array_layer
             |> tl()
             |> disturb_selected_neurons_array(
                  neuron_names_to_disturb,
                  [
                    neurons_array_layer
                      |> hd()
                      |> disturb_selected_neurons(neuron_names_to_disturb)
                      | mutated_neurons
                  ] 
                )
    end
  end
  
  defp disturb_selected_neurons(neurons_array,neuron_names_to_disturb,mutated_neurons \\ []) do
    cond do
      (Enum.empty?(neurons_array))
        -> mutated_neurons
             |> Enum.reverse()
      true
        -> neurons_array
             |> tl()
             |> disturb_selected_neurons(
                  neuron_names_to_disturb,
                  [
                    neurons_array 
                      |> hd() 
                      |> disturb_neuron_weight(neuron_names_to_disturb)   
                      | mutated_neurons
                  ]
                )
    end
  end

  defp disturb_neuron_weight(neuron,neuron_names_to_disturb) do
    [module,name,layer,activation_functions,weight,bias,operation,debugg] = neuron
    cond do
      (!(Enum.member?(neuron_names_to_disturb,name)))
        -> neuron
      true
        -> [
             module,
             name,
             layer,
             activation_functions,
             weight + Selector.choose_weight_perturbation(),
             bias,
             operation,
             debugg
           ]
    end
  end  
  
  defp flattify_neurons_names(neurons_array_layers,flat_neurons_array_names \\ []) do
    cond do
      (Enum.empty?(neurons_array_layers))
        -> flat_neurons_array_names
             |> Enum.reverse()
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
