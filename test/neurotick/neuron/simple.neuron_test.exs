defmodule Neurotick.SimpleNeuronTest do
  use ExUnit.Case
  
  doctest Neurotick.SimpleNeuron
  
  alias Neurotick.SimpleSensor
  
  
  test "[single neuron]" do
    pid = Neurotick.SimpleNeuron.new()
    
    sensors_array = [
      SimpleSensor.new(),
      SimpleSensor.new(),
      SimpleSensor.new(),
      SimpleSensor.new(),
    ]
    
    activation_functions = [
      Neurotick.TanhFunction
    ]
    
    actuators_array = []
    
    bias = 2.5
    
    operation = "*"
    
    debugg = false
    
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
  