defmodule Neurotick.SimpleNeuronTest do
  use ExUnit.Case
  
  doctest Neurotick.SimpleNeuron
  
  alias Neurotick.SimpleNeuron
  
  test "[process_signals(signals_array,bias \\ 0,operation \\ *)]" do
    signals_array = [
      [2,0.6],
      [1.7,0.5],
      [2,0.4],
      [2,0.8],
      [3,1.6],
      [4,0.2],
      [5,0.7],
      [8,0.05],
    ]
    result_0 = [
      13.95,
      [
        [8, "*", 0.05], [7, "*", 0.7], [6, "*", 0.2], 
        [5, "*", 1.6], [4, "*", 0.8], [3, "*", 0.4], 
        [2, "*", 0.5], [1, "*", 0.6]
      ],
      [
        [2, 0.6], [1.7, 0.5], [2, 0.4], [2, 0.8], [3, 1.6], [4, 0.2], [5, 0.7], [8, 0.05]
      ],
      0
    ]
    result_1 = [
      14.95,
      [
        [8, "*", 0.05], [7, "*", 0.7], [6, "*", 0.2], 
        [5, "*", 1.6], [4, "*", 0.8], [3, "*", 0.4], 
        [2, "*", 0.5], [1, "*", 0.6]
      ],
      [
        [2, 0.6], [1.7, 0.5], [2, 0.4], [2, 0.8], [3, 1.6], [4, 0.2], [5, 0.7], [8, 0.05]
      ],
      1
    ]
    result_2 = [
      204.2511904761905,
      [
        [8, "/", 0.05], [7, "/", 0.7], [6, "/", 0.2], 
        [5, "/", 1.6], [4, "/", 0.8], [3, "/", 0.4], 
        [2, "/", 0.5], [1, "/", 0.6]
      ],
      [
        [2, 0.6], [1.7, 0.5], [2, 0.4], [2, 0.8], [3, 1.6], [4, 0.2], [5, 0.7], [8, 0.05]
      ],
      1
    ]
    assert SimpleNeuron.process_signals(signals_array) == result_0
    assert SimpleNeuron.process_signals(signals_array,1) == result_1
    assert SimpleNeuron.process_signals(signals_array,1,"/") == result_2
  end
  
  test "[process_activations(activation_functions,signals_result)]" do
    signals_array = [
      [1.5,0.6],
      [0.7,0.5]
    ]
    signals_result_0 = [
      1.25,
      [[2, "*", 0.5],[1, "*", 0.6]],
      [[1.5, 0.6],[0.7, 0.5]],
      0
    ]
    signals_result_1 = [
      1.6,
      [[2, "*", 0.5],[1, "*", 0.6]],
      [[1.5, 0.6],[0.7, 0.5]],
      0.35
    ]
    assert SimpleNeuron.process_signals(signals_array,0) == signals_result_0
    assert SimpleNeuron.process_signals(signals_array,0.35) == signals_result_1
    
    activation_functions = [
      Neurotick.TanhFunction
    ]
    
    activation_result = SimpleNeuron.process_activations(activation_functions,signals_result_0)
    expected_activation_result_0 = [
      0.8482836399575129, 
      [[2, "*", 0.5], [1, "*", 0.6]], 
      [[1.5, 0.6], [0.7, 0.5]], 
      0
    ]
    assert activation_result == expected_activation_result_0
    
    activation_result = SimpleNeuron.process_activations(activation_functions,signals_result_1)
    expected_activation_result_1 = [
      0.9216685544064713, 
      [[2, "*", 0.5], [1, "*", 0.6]], 
      [[1.5, 0.6], [0.7, 0.5]], 
      0.35
    ]
    assert activation_result == expected_activation_result_1
    
    signals_result_2 = SimpleNeuron.process_signals(signals_array,0)
    expected_activation_result_2 = SimpleNeuron.process_activations(activation_functions,signals_result_2)
    assert expected_activation_result_0 == expected_activation_result_2
    
    signals_result_3 = SimpleNeuron.process_signals(signals_array,0.35)
    expected_activation_result_3 = SimpleNeuron.process_activations(activation_functions,signals_result_3)
    assert expected_activation_result_1 == expected_activation_result_3
  end
  
  test "[start_link(init_args)]" do
    pid = Neurotick.SimpleNeuron.new()
    
    Process.send(pid,{:config,3},[:noconnect])
    
    Process.send(pid,{:start},[:noconnect])
    
    :timer.sleep(600000)
  end
  
end
  