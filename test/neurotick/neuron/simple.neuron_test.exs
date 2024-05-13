defmodule Neurotick.SimpleNeuronTest do
  
  use ExUnit.Case
  
  doctest Neurotick.Example.SimpleNeuron
  
  alias Neurotick.Example.SimpleSensor
  alias Neurotick.Example.SimpleNeuron
  alias Neurotick.Example.SimpleActuator
  alias Neurotick.Example.TanhFunction
  alias Neurotick.Base.NeuronStorage
  alias Neurotick.Base.NeuronNetwork
   
  test "[NeuronNetwork]" do
    "testing neuron network ... "
      |> IO.inspect()
      
    neurons_array_0 = [
      SimpleNeuron.new(),
      SimpleNeuron.new(),
      SimpleNeuron.new(),
      SimpleNeuron.new()
    ]
    
    neurons_array_1 = [
      SimpleNeuron.new(),
      SimpleNeuron.new(),
      SimpleNeuron.new(),
      SimpleNeuron.new()
    ]
    
    neurons_array_2 = [
      SimpleNeuron.new(),
      SimpleNeuron.new()
    ]
    
    sensors_array = [
      SimpleSensor.new(),
      SimpleSensor.new(),
      SimpleSensor.new(),
      SimpleSensor.new()
    ]
    
    activation_functions = [
      TanhFunction
    ]
    
    actuators_array = [
      SimpleActuator.new(),
      SimpleActuator.new(),
      SimpleActuator.new()
    ]
    
    network_id = NeuronNetwork.start_network()
    NeuronNetwork.add_sensors(network_id,sensors_array)
    NeuronNetwork.add_actuators(network_id,actuators_array)
    NeuronNetwork.add_neurons(network_id,neurons_array_0,0)
    NeuronNetwork.add_neurons(network_id,neurons_array_1,1)
    NeuronNetwork.add_neurons(network_id,neurons_array_2,2)
    NeuronNetwork.config_neuron_layer(network_id,0,activation_functions,2.5,"*",false)    
    NeuronNetwork.config_neuron_layer(network_id,1,activation_functions,0,"*",false)
    NeuronNetwork.config_neuron_layer(network_id,2,activation_functions,1,"*",true)
    
    network_id
      |> NeuronNetwork.process_signals()
      
    :timer.sleep(2000)
    
    network_id
      |> NeuronNetwork.stop_network()
      
    :timer.sleep(5000)
    
  end
  
end
  