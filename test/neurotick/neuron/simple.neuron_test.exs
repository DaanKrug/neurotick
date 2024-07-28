defmodule Neurotick.SimpleNeuronTest do
  
  use ExUnit.Case
  
  doctest Neurotick.Example.SimpleNeuron
  
  alias Neurotick.Example.SimpleSensor
  alias Neurotick.Example.SimpleNeuron
  alias Neurotick.Example.SimpleActuator
  alias Neurotick.Example.TanhFunction
  alias Neurotick.Base.NeuronNetwork
  
   
  test "[NeuronNetwork]" do
    "testing neuron network ... "
      |> IO.inspect()
      
    network_id = NeuronNetwork.start_network()
      
    activation_functions = [
      TanhFunction
    ]
      
    neurons_array_0 = [
      SimpleNeuron.new("N1",0,activation_functions,2.5,"*",false), #name,layer,activation_functions,bias,operation,debugg
      SimpleNeuron.new("N2",0,activation_functions,0,"*",false), 
      SimpleNeuron.new("N3",0,[],2.5,"*",false),
      SimpleNeuron.new("N4",0,[],0,"*",false)  
    ]
    
    neurons_array_1 = [
      SimpleNeuron.new("N5",1,activation_functions,0,"*",false),
      SimpleNeuron.new("N6",1,activation_functions,0,"*",false),
      SimpleNeuron.new("N7",1,activation_functions,0,"*",false),
      SimpleNeuron.new("N8",1,activation_functions,0,"*",false)
    ]
    
    neurons_array_2 = [
      SimpleNeuron.new("N9",2,[],0,"*",false),
      SimpleNeuron.new("N10",2,[],0,"*",false)
    ]
    
    neurons_array_3 = [
      SimpleNeuron.new("N11",3,[],0.5,"*",false),
      SimpleNeuron.new("N12",3,activation_functions,0,"*",false),
      SimpleNeuron.new("N13",3,[],0,"*",false)
    ]
    
    sensors_array = [
      SimpleSensor.new("S1",false), #name,debugg
      SimpleSensor.new("S2",false), 
      SimpleSensor.new("S3",false), 
      SimpleSensor.new("S4",false)  
    ]
        
    actuators_array = [
      SimpleActuator.new("A1",false), #name,debugg
      SimpleActuator.new("A2",false), 
      SimpleActuator.new("A3",false)  
    ]
    
    neurons_array_layers = [
      neurons_array_0,
      neurons_array_1,
      neurons_array_2,
      neurons_array_3
    ]
    
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
    
    results
      |> IO.inspect()
      
    :timer.sleep(1000)
    
    network_id
      |> NeuronNetwork.stop_network()
      
    :timer.sleep(5000)
    
  end
  
end
  