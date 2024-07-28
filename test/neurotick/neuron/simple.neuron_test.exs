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
      SimpleNeuron.new(0,activation_functions,2.5,"*",false), #activation_functions,bias,operation,debugg
      SimpleNeuron.new(0,activation_functions,0,"*",false), #activation_functions,bias,operation,debugg
      SimpleNeuron.new(0,[],2.5,"*",false), #activation_functions,bias,operation,debugg
      SimpleNeuron.new(0,[],0,"*",false)  #activation_functions,bias,operation,debugg
    ]
    
    neurons_array_1 = [
      SimpleNeuron.new(1,activation_functions,0,"*",false),
      SimpleNeuron.new(1,activation_functions,0,"*",false),
      SimpleNeuron.new(1,activation_functions,0,"*",false),
      SimpleNeuron.new(1,activation_functions,0,"*",false)
    ]
    
    neurons_array_2 = [
      SimpleNeuron.new(2,[],0,"*",false),
      SimpleNeuron.new(2,[],0,"*",false)
    ]
    
    neurons_array_3 = [
      SimpleNeuron.new(3,[],0.5,"*",false),
      SimpleNeuron.new(3,activation_functions,0,"*",false),
      SimpleNeuron.new(3,[],0,"*",false)
    ]
    
    sensors_array = [
      SimpleSensor.new(false), #debugg
      SimpleSensor.new(false), #debugg
      SimpleSensor.new(false), #debugg
      SimpleSensor.new(false)  #debugg
    ]
        
    actuators_array = [
      SimpleActuator.new(false), #debugg
      SimpleActuator.new(false), #debugg
      SimpleActuator.new(false)  #debugg
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
      
    NeuronNetwork.debugg(network_id)
    
      
    :timer.sleep(2000)
    
    network_id
      |> NeuronNetwork.stop_network()
      
    :timer.sleep(5000)
    
  end
  
end
  