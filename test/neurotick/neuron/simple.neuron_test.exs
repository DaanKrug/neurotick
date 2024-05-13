defmodule Neurotick.SimpleNeuronTest do
  
  use ExUnit.Case
  
  doctest Neurotick.Example.SimpleNeuron
  
  alias Neurotick.Example.SimpleSensor
  alias Neurotick.Example.SimpleNeuron
  alias Neurotick.Example.SimpleActuator
  alias Neurotick.Example.TanhFunction
  alias Neurotick.Base.NeuronStorage
  alias Neurotick.Base.NeuronNetwork
  
  
  test "[single neuron]" do
    NeuronStorage.config_storage()
  
    sensor_1 = SimpleSensor.new()
    sensor_2 = SimpleSensor.new()
    sensor_3 = SimpleSensor.new()
    sensor_4 = SimpleSensor.new()
  
    neuron_1 = SimpleNeuron.new()
    
    neurons_array = [
      neuron_1
    ]
    
    sensors_array = [
      sensor_1,
      sensor_2,
      sensor_3,
      sensor_4
    ]
    
    activation_functions = [
      TanhFunction
    ]
    
    actuator_1 = SimpleActuator.new()
    actuator_2 = SimpleActuator.new()
    actuator_3 = SimpleActuator.new()
    
    actuators_array = [
      actuator_1,
      actuator_2,
      actuator_3
    ]
    
    bias = 2.5
    
    operation = "*"
    
    debugg = true
    
    params_array_neuron = [
      sensors_array,
      activation_functions,
      actuators_array,
      bias,
      operation,
      debugg
    ]
    
    params_array_sensor = [
      neurons_array,
      debugg
    ]
    
    Process.send(
      neuron_1,
      {:config,params_array_neuron},
      [:noconnect]
    )
    
    Process.send(
      sensor_1,
      {:config,params_array_sensor},
      [:noconnect]
    )
    
    Process.send(
      sensor_2,
      {:config,params_array_sensor},
      [:noconnect]
    )
    
    Process.send(
      sensor_3,
      {:config,params_array_sensor},
      [:noconnect]
    )
    
    Process.send(
      sensor_4,
      {:config,params_array_sensor},
      [:noconnect]
    )
    
    Process.send(sensor_1,{:do_sense},[:noconnect])
    
    Process.send(sensor_2,{:do_sense},[:noconnect])
    
    Process.send(sensor_3,{:do_sense},[:noconnect])
    
    Process.send(sensor_4,{:do_sense},[:noconnect])
    
    :timer.sleep(2000)
    
    Process.send(sensor_1,{:terminate},[:noconnect])
    
    Process.send(sensor_2,{:terminate},[:noconnect])
    
    Process.send(sensor_3,{:terminate},[:noconnect])
    
    Process.send(sensor_4,{:terminate},[:noconnect])
    
    Process.send(actuator_1,{:terminate},[:noconnect])
    
    Process.send(actuator_2,{:terminate},[:noconnect])
    
    Process.send(actuator_3,{:terminate},[:noconnect])
    
    Process.send(neuron_1,{:terminate},[:noconnect])
    
    
    :timer.sleep(2000)
 
    #                   test "[multi neuron]" do
    
    sensor_1 = SimpleSensor.new()
    sensor_2 = SimpleSensor.new()
    sensor_3 = SimpleSensor.new()
    sensor_4 = SimpleSensor.new()
  
    neuron_1 = SimpleNeuron.new()
    neuron_2 = SimpleNeuron.new()
    neuron_3 = SimpleNeuron.new()
    neuron_4 = SimpleNeuron.new()
    
    neuron_5 = SimpleNeuron.new()
    neuron_6 = SimpleNeuron.new()
    neuron_7 = SimpleNeuron.new()
    neuron_8 = SimpleNeuron.new()
    
    
    neurons_array_layer_0 = [
      neuron_1,
      neuron_2,
      neuron_3,
      neuron_4
    ]
    
    neurons_array_layer_1 = [
      neuron_5,
      neuron_6,
      neuron_7,
      neuron_8
    ]
    
    sensors_array = [
      sensor_1,
      sensor_2,
      sensor_3,
      sensor_4
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
    
    params_array_neuron_layer_0 = [
      sensors_array,
      activation_functions,
      neurons_array_layer_1,
      bias,
      operation,
      debugg
    ]
    
    params_array_neuron_layer_1 = [
      neurons_array_layer_0,
      activation_functions,
      actuators_array,
      10,
      operation,
      debugg
    ]
    
    params_array_sensor = [
      neurons_array_layer_0,
      debugg
    ]
    
    Process.send(
      sensor_1,
      {:config,params_array_sensor},
      [:noconnect]
    )
    
    Process.send(
      sensor_2,
      {:config,params_array_sensor},
      [:noconnect]
    )
    
    Process.send(
      sensor_3,
      {:config,params_array_sensor},
      [:noconnect]
    )
    
    Process.send(
      sensor_4,
      {:config,params_array_sensor},
      [:noconnect]
    )
    
    
    Process.send(
      neuron_1,
      {:config,params_array_neuron_layer_0},
      [:noconnect]
    )
    
    Process.send(
      neuron_2,
      {:config,params_array_neuron_layer_0},
      [:noconnect]
    )
    
    Process.send(
      neuron_3,
      {:config,params_array_neuron_layer_0},
      [:noconnect]
    )
    
    Process.send(
      neuron_4,
      {:config,params_array_neuron_layer_0},
      [:noconnect]
    )
    
    Process.send(
      neuron_5,
      {:config,params_array_neuron_layer_1},
      [:noconnect]
    )
    
    Process.send(
      neuron_6,
      {:config,params_array_neuron_layer_1},
      [:noconnect]
    )
    
    Process.send(
      neuron_7,
      {:config,params_array_neuron_layer_1},
      [:noconnect]
    )
    
    Process.send(
      neuron_8,
      {:config,params_array_neuron_layer_1},
      [:noconnect]
    )
    
    
    
    Process.send(sensor_1,{:do_sense},[:noconnect])
    
    Process.send(sensor_2,{:do_sense},[:noconnect])
    
    Process.send(sensor_3,{:do_sense},[:noconnect])
    
    Process.send(sensor_4,{:do_sense},[:noconnect])
    
    :timer.sleep(10000)
    
    
    Process.send(sensor_1,{:terminate},[:noconnect])
    Process.send(sensor_2,{:terminate},[:noconnect])
    Process.send(sensor_3,{:terminate},[:noconnect])
    Process.send(sensor_4,{:terminate},[:noconnect])
    
    Process.send(actuator_1,{:terminate},[:noconnect])
    Process.send(actuator_2,{:terminate},[:noconnect])
    Process.send(actuator_3,{:terminate},[:noconnect])
    
    Process.send(neuron_1,{:terminate},[:noconnect])
    Process.send(neuron_2,{:terminate},[:noconnect])
    Process.send(neuron_3,{:terminate},[:noconnect])
    Process.send(neuron_4,{:terminate},[:noconnect])
    Process.send(neuron_5,{:terminate},[:noconnect])
    Process.send(neuron_6,{:terminate},[:noconnect])
    Process.send(neuron_7,{:terminate},[:noconnect])
    Process.send(neuron_8,{:terminate},[:noconnect])
    
  # end
  
  # test "[NeuronNetwork]" do
    # :timer.sleep(45000)
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
    NeuronNetwork.config_neuron_layer(network_id,0,activation_functions,2.5,"*",true)    
    NeuronNetwork.config_neuron_layer(network_id,1,activation_functions,0,"*",true)
    network_id
      |> NeuronNetwork.process_signals()
    network_id
      |> NeuronNetwork.stop_network()
  end
  
end
  