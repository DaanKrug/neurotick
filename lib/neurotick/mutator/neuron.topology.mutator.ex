defmodule Neurotick.Mutator.NeuronTopologyMutator do

  @moduledoc false

  alias Neurotick.Stochastic.NeuronStorage
  alias Neurotick.Stochastic.Selector
  alias Krug.StringUtil
  alias Krug.DateUtil
  
  
  def mutate_neurons_topology(stochastic_id,only_for_add \\ false) do
    neurons_array_layers = stochastic_id
                             |> NeuronStorage.get_neurons()
    neuron_names_to_disturb = neurons_array_layers
                                |> flattify_neurons_names(only_for_add)
    cond do
      (Enum.empty?(neuron_names_to_disturb))
        -> stochastic_id
             |> mutate_neurons_topology(true)
      true
        -> stochastic_id 
             |> mutate_neurons_topology2(neuron_names_to_disturb,neurons_array_layers,only_for_add)
    end     
  end
  
  def mutate_neurons_topology2(stochastic_id,neuron_names_to_disturb,neurons_array_layers,only_for_add) do    
    neuron_names_to_disturb = neuron_names_to_disturb                           
                                |> Selector.select_elements()
    mutated_neurons_array_layer = neuron_names_to_disturb 
                                    |> duplicate_remove_neurons(neurons_array_layers,only_for_add)  
    stochastic_id
      |> NeuronStorage.set_neurons(mutated_neurons_array_layer)
  end

  defp duplicate_remove_neurons(neuron_names_to_disturb,neurons_array_layers,only_for_add) do
    cond do
      (Enum.empty?(neuron_names_to_disturb))
        -> neurons_array_layers
      true
        -> neuron_names_to_disturb
             |> duplicate_remove_neurons2(neurons_array_layers,only_for_add)
    end
  end
  
  defp duplicate_remove_neurons2(neuron_names_to_disturb,neurons_array_layers,only_for_add) do
    neuron_name = neuron_names_to_disturb
                    |> hd()
    neurons_array_layers = neuron_name
                            |> mutate_neurons_array_layers(
                                 neurons_array_layers,
                                 only_for_add
                               )                             
    neuron_names_to_disturb
      |> tl()
      |> duplicate_remove_neurons(neurons_array_layers,only_for_add)
  end
  
  defp mutate_neurons_array_layers(neuron_name,neurons_array_layers,only_for_add,mutated_layers \\ []) do
    cond do
      (Enum.empty?(neurons_array_layers))
        -> mutated_layers
             |> Enum.reverse()
      true
        -> neuron_name
             |> mutate_neurons_array_layers2(neurons_array_layers,only_for_add,mutated_layers)
    end
  end
  
  defp mutate_neurons_array_layers2(neuron_name,neurons_array_layers,only_for_add,mutated_layers) do
    neurons_array = neurons_array_layers 
                      |> hd()
    only_for_add = only_for_add or (neurons_array |> length() < 2)      
    mutated_neurons_array = neuron_name
                              |> mutate_neurons_array(neurons_array,only_for_add)   
    neuron_name
      |> mutate_neurons_array_layers(
           neurons_array_layers
             |> tl(),
           only_for_add,
           [mutated_neurons_array | mutated_layers]
         )
  end
  
  defp mutate_neurons_array(neuron_name,neurons_array,only_for_add,mutated_neurons_array \\ []) do
    cond do
      (Enum.empty?(neurons_array))
        -> mutated_neurons_array
      true
        -> neuron_name
             |> mutate_neurons_array2(neurons_array,only_for_add,mutated_neurons_array)
    end
  end
  
  defp mutate_neurons_array2(neuron_name,neurons_array,only_for_add,mutated_neurons_array) do
    neuron = neurons_array
              |> hd()
    [_,name,_,_,_,_,_,_] = neuron
    cond do
      (neuron_name != name)
        -> neuron_name
             |> mutate_neurons_array(
                  neurons_array
                    |> tl(),
                  only_for_add,
                  [
                    neuron 
                      | mutated_neurons_array
                  ]
                )
      true
        -> neuron_name
             |> mutate_neurons_array3(neurons_array,only_for_add,mutated_neurons_array)
    end
  end
  
  defp mutate_neurons_array3(neuron_name,neurons_array,only_for_add,mutated_neurons_array) do
    neuron_name
      |> mutate_neurons_array(
           neurons_array
             |> tl(),
           only_for_add,
           neurons_array
             |> hd()
             |> duplicate_or_disapear_neuron(only_for_add,mutated_neurons_array)
         )
  end
  
  defp duplicate_or_disapear_neuron(neuron,only_for_add,mutated_neurons_array) do
    rand = :rand.uniform(2)
    cond do
      (rand == 1
        and !only_for_add)
          -> mutated_neurons_array
      true
        -> [
             neuron,
             neuron 
               |> clone_neuron()
           ] 
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
  
  defp flattify_neurons_names(neurons_array_layers,only_for_add,flat_neurons_array_names \\ []) do
    cond do
      (neurons_array_layers |> length() < 2)
        -> flat_neurons_array_names
             |> Enum.reverse()
      (!only_for_add 
        and neurons_array_layers |> hd() |> length() < 2)
          -> neurons_array_layers
               |> tl()
               |> flattify_neurons_names(only_for_add,flat_neurons_array_names)
      true
        -> neurons_array_layers
             |> tl()
             |> flattify_neurons_names(
                  only_for_add,
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

  defp clone_neuron(neuron) do
    [module,name,layer,activation_functions,weight,_bias,operation,debugg] = neuron
    new_name = name 
                 |> StringUtil.split("_")
                 |> hd()
    new_name = "#{new_name}_#{DateUtil.get_date_time_now_millis()}"
    [module,new_name,layer,activation_functions,weight,0,operation,debugg]
  end  
end
