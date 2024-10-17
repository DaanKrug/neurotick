defmodule Neurotick.Stochastic.StochasticMutator do

  alias Neurotick.Stochastic.NeuronStorage
  alias Neurotick.Stochastic.Selector
  
  
  def mutate_neurons(stochastic_id) do
    neurons_array = stochastic_id
                      |> NeuronStorage.get_neurons()
    neuron_names_to_disturb = neurons_array
                                |> flattify_neurons_names()
                                |> Selector.select_elements()
    mutated_neurons = neurons_array
                        |> disturb_selected_neurons_array(neuron_names_to_disturb)
    [
      "neurons_array",
      neurons_array,
      "mutated_neurons",
      mutated_neurons
    ]
      |> IO.inspect()
    stochastic_id
      |> NeuronStorage.set_neurons(mutated_neurons)
  end

  defp disturb_selected_neurons_array(neurons_array,neuron_names_to_disturb,mutated_neurons \\ []) do
    cond do
      (Enum.empty?(neurons_array))
        -> mutated_neurons
             |> Enum.reverse()
      true
        -> neurons_array
             |> tl()
             |> disturb_selected_neurons_array(
                  neuron_names_to_disturb,
                  [
                    neurons_array
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
    [module,name,layer,activation_functions,_weight,bias,operation,debugg] = neuron
    cond do
      (!(Enum.member?(neuron_names_to_disturb,name)))
        -> neuron
      true
        -> [
             module,
             name,
             layer,
             activation_functions,
             Selector.choose_weight_perturbation(),
             bias,
             operation,
             debugg
           ]
    end
  end  
  
  defp flattify_neurons_names(neurons_array,flat_neurons_array \\ []) do
    cond do
      (Enum.empty?(neurons_array))
        -> flat_neurons_array
             |> Enum.reverse()
      true
        -> neurons_array
             |> tl()
             |> flattify_neurons_names([neurons_array |> hd() |> tl() |> hd() | flat_neurons_array])
    end
  end

end