defmodule Neurotick.SimpleNeuronTest do
  use ExUnit.Case
  
  doctest Neurotick.Example.SimpleNeuron
  
  alias Neurotick.Example.SimpleSensor
  alias Neurotick.Example.SimpleNeuron
  alias Neurotick.Example.SimpleActuator
  alias Neurotick.Example.TanhFunction
  
  
  test "[single neuron]" do
    pid = SimpleNeuron.new()
    
    sensors_array = [
      SimpleSensor.new(),
      SimpleSensor.new(),
      SimpleSensor.new(),
      SimpleSensor.new(),
    ]
    
    activation_functions = [
      TanhFunction
    ]
    
    actuators_array = [
      SimpleActuator.new(),
      SimpleActuator.new(),
      SimpleActuator.new()
    ]
    
    bias = 2.5
    
    operation = "*"
    
    debugg = true
    
    params_array = [
      sensors_array,
      activation_functions,
      actuators_array,
      bias,
      operation,
      debugg
    ]
    
    Process.send(
      pid,
      {:config,params_array},
      [:noconnect]
    )
    
    Process.send(pid,{:read_signals},[:noconnect])
    
    Process.send(pid,{:read_signals},[:noconnect])
    
    Process.send(pid,{:read_signals},[:noconnect])
    
    :timer.sleep(600000)
  end
  
end
  