defmodule Neurotick.SimpleNeuronTest do
  
  use ExUnit.Case
  
  doctest Neurotick.Example.SimpleNeuron
  
  alias Neurotick.Example.SimpleSensor
  alias Neurotick.Example.SimpleNeuron
  alias Neurotick.Example.SimpleActuator
  alias Neurotick.Example.TanhFunction
  alias Neurotick.Base.NeuronNetwork
  alias Neurotick.Stochastic.StochasticNeuronNetwork
  
   
  test "[NeuronNetwork]" do
    "testing neuron network ... "
      |> IO.inspect()
        
    activation_functions = [
      TanhFunction
    ]
    
    # module, name,layer,activation_functions,weight,bias,operation,debugg
    neurons_array_0 = [
      [SimpleNeuron,"N1",0,activation_functions,1,2.5,"*",false], 
      [SimpleNeuron,"N2",0,activation_functions,1,0,"*",false], 
      [SimpleNeuron,"N3",0,[],0.5,2.5,"*",false],
      [SimpleNeuron,"N4",0,[],2,0,"*",false]  
    ]
    
    neurons_array_1 = [
      [SimpleNeuron,"N5",1,activation_functions,1,0,"*",false],
      [SimpleNeuron,"N6",1,activation_functions,1,0,"*",false],
      [SimpleNeuron,"N7",1,activation_functions,1,0,"*",false],
      [SimpleNeuron,"N8",1,activation_functions,1,0,"*",false]
    ]
    
    neurons_array_2 = [
      [SimpleNeuron,"N9",2,[],1,0,"*",false],
      [SimpleNeuron,"N10",2,[],1,0,"*",false]
    ]
    
    neurons_array_3 = [
      [SimpleNeuron,"N11",3,[],1,0.5,"*",false],
      [SimpleNeuron,"N12",3,activation_functions,1,0,"*",false],
      [SimpleNeuron,"N13",3,[],1,0,"*",false]
    ]
    
    # module, name,debugg
    sensors_array = [
      [SimpleSensor,"S1",false], 
      [SimpleSensor,"S2",false], 
      [SimpleSensor,"S3",false], 
      [SimpleSensor,"S4",false]  
    ]
     
    # module, name,debugg   
    actuators_array = [
      [SimpleActuator,"A1",false],
      [SimpleActuator,"A2",false], 
      [SimpleActuator,"A3",false]  
    ]
    
    neurons_array_layers = [
      neurons_array_0,
      neurons_array_1,
      neurons_array_2,
      neurons_array_3
    ]
    
    network_id = NeuronNetwork.start_network()
    NeuronNetwork.config_sensors(network_id,sensors_array)
    NeuronNetwork.config_actuators(network_id,actuators_array)
    NeuronNetwork.config_neurons(network_id,neurons_array_layers)
 
    network_id
      |> NeuronNetwork.process_signals()
      
    :timer.sleep(100)
    
    # NeuronNetwork.debugg(network_id,nil)
    # NeuronNetwork.debugg(network_id,"./network_struct.txt")
    
    results = network_id 
                |> NeuronNetwork.extract_output()
    
    ["results",results]
      |> IO.inspect()
      
    :timer.sleep(1000)
    
    network_id
      |> NeuronNetwork.stop_network()
      
    :timer.sleep(5000)
    
    "testing stochastic neuron network mutation ... "
      |> IO.inspect()
    
    expected_result = [
      [8.1, 0.9, 8.7],
      [8.1, 0.9, 8.7],
      [8.1, 0.9, 8.7]
    ]
    
    stochastic_id = "echo_test"
    
    stochastic_id
      |> StochasticNeuronNetwork.config(sensors_array,neurons_array_layers,actuators_array)
      
    mutated_neurons = stochastic_id
                        |> StochasticNeuronNetwork.run_stochastic_neurons_mutation(
                             expected_result
                           )
                           
    [
      "neurons_array_layers",
      neurons_array_layers,
      "mutated_neurons",
      mutated_neurons
    ]
      |> IO.inspect()
    
  end
  
end
  
  
  
  