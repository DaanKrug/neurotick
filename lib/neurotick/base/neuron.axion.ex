defmodule Neurotick.Base.NeuronAxion do

  @callback spawn_sensor_module() :: Pid.t()
  
  @callback new() :: Pid.t()

  defmacro __using__(_opts) do
  
    quote do
    
      alias Neurotick.Base.OperationParam
      alias Krug.EtsUtil
      
      @tablename_sensors :neurotick_ets_sensors
      
      def sensor_receptor() do
        receive do
          ({:config,number_of_sensors})
            -> config(number_of_sensors)
          ({:start})
            -> read_signals()
          ({sensor_pid,signals_array})
            -> received_signal(sensor_pid,signals_array)
        end
      end
      
      defp config(number_of_sensors) do
        EtsUtil.new(@tablename_sensors)
	    children = number_of_sensors
	                 |> create_sensors()
	    EtsUtil.store_in_cache(@tablename_sensors,Kernel.self(),children)             
	  end
	  
	  defp create_sensors(number_of_sensors,children \\ []) do
	    cond do
	      (length(children) >= number_of_sensors)
	        -> children
	      true
	        -> number_of_sensors
	             |> create_sensors(
	                  [
	                    spawn_sensor_module()
	                      | children
	                  ]
	                )
	    end
	  end
	  
      def read_signals(signals_array \\ []) do
        pids = sensor_pids()
        position = signals_array
                     |> length()
        cond do
          (position >= length(pids))
            -> signals_array
                 |> Enum.reverse()
                 |> process_signals()
          true
            -> pids
                 |> Enum.at(position)
                 |> request_signal(signals_array)
        end
      end
      
      def request_signal(sensor_pid,signals_array) do
        Process.send(sensor_pid,{Kernel.self(),signals_array},[:noconnect])
      end
      
      defp received_signal(sensor_pid,signals_array) do
        [
          "received_signal",
          sensor_pid,
          signals_array
        ]
          |> IO.inspect()
        read_signals(signals_array)
      end
      
      defp sensor_pids() do
        children = EtsUtil.read_from_cache(@tablename_sensors,Kernel.self())
        cond do
          (nil == children)
            -> []
          true
            -> children
        end
      end
	 
      # process calculations
	  # operation_params = neuron
	
	  def process_signals(signals_array,bias \\ 0,operation \\ "*") do
	    operation_params = add_all_operations(signals_array,operation)
	    inputs = extract_inputs(signals_array)
	    result = calculate_inputs(inputs,operation_params)
	    [result + bias,operation_params,signals_array,bias]
	  end
	  
	  def process_activations(activation_functions,signals_result) do
	    cond do
	      (Enum.empty?(activation_functions))
	        -> signals_result
	      true
	        -> activation_functions
	             |> process_activation(signals_result)
	    end
	  end
	  
	  defp process_activation(activation_functions,signals_result) do
	    [result,operation_params,signals_array,bias] = signals_result
	    function = activation_functions
	                 |> hd()
	    activation_result = function.process_activation(result)
	    activation_functions
	      |> tl()
	      |> process_activations(
	           [activation_result,operation_params,signals_array,bias]
	         )
	  end
	  
	  defp extract_inputs(signals_array,inputs \\ []) do
	    cond do
	      (Enum.empty?(signals_array))
	        -> inputs
	      true
	        -> signals_array
	             |> tl()
	             |> extract_inputs(
	                  [
	                    signals_array
	                      |> hd()
	                      |> extract_input()
	                      | inputs
	                  ]
	                )
	    end
	  end
	  
	  defp extract_input(signals_array) do
	    [value,_] = signals_array
	    value
	  end
	  
	  defp add_all_operations(signals_array,operation,operation_params \\ []) do
	    cond do
	      (Enum.empty?(signals_array))
	        -> operation_params
	      true
	        -> signals_array
	             |> tl()
	             |> add_all_operations(
	                  operation,
	                  signals_array 
	                    |> hd()
	                    |> add_operation_signal(operation,operation_params)
	                )
	    end
	  end
	  
	  defp add_operation_signal(signal,operation,operation_params) do
	    [_,weight] = signal
	    add_operation(operation,weight,operation_params)
	  end
	  
	  defp add_operation(operation,weight,operation_params \\ []) do
	    id = operation_params 
	           |> length()
	    [
	      OperationParam.new_operation(id + 1,operation,weight)
	        | operation_params
	    ]
	  end
	  
	  defp remove_operation(id,operation_params) do
	    operation_params
	      |> clone([],[id])
	  end
	  
	  defp replace_operation(id,operation_params,new_operation_param) do
	    [
	      new_operation_param
	        | remove_operation(id,operation_params)
	    ]
	  end
	
	  defp calculate_inputs(inputs,operation_params,result \\ 0) do
	    cond do
	      (Enum.empty?(inputs))
	        -> result
	      true
	        -> inputs
	             |> calculate_input(operation_params,result)
	    end
	  end
	  
	  defp calculate_input(inputs,operation_params,result) do
	    calculated = inputs 
	                   |> hd() 
	                   |> OperationParam.calculate(operation_params |> hd())
	    inputs
	      |> tl()
	      |> calculate_inputs(
	           operation_params 
	             |> tl(),
	             result + calculated
	         )
	  end
	  
	  defp clone(operation_params,keep_ids,exclude_ids \\ []) do
	    cond do
	      (Enum.empty?(operation_params)
	        or (Enum.empty?(keep_ids) 
	          and Enum.empty?(exclude_ids)))
	            -> []
	      true
	        -> operation_params
	             |> clone_operation_params(keep_ids,exclude_ids) 
	    end
	  end
	  
	  defp clone_operation_params(operation_params,keep_ids,exclude_ids,cloned_operation_params \\ []) do
	    cond do
	      (Enum.empty?(operation_params))
	        -> cloned_operation_params
	      true
	        -> operation_params
	             |> clone_operation_params2(keep_ids,exclude_ids,cloned_operation_params)
	    end
	  end
	  
	  defp clone_operation_params2(operation_params,keep_ids,exclude_ids,cloned_operation_params) do
	    operation_param = operation_params
	                        |> hd()
	    [id,operation,weight] = operation_param
	    cond do
	      (!(Enum.empty?(exclude_ids))
	        and Enum.member?(exclude_ids,id))
	          -> operation_params 
	               |> tl()
	               |> clone_operation_params(keep_ids,exclude_ids,cloned_operation_params)
	      (!(Enum.member?(keep_ids,id))
	        and Enum.empty?(exclude_ids))
	          -> operation_params 
	               |> tl()
	               |> clone_operation_params(keep_ids,exclude_ids,cloned_operation_params)
	      true
	        -> operation_params 
	             |> tl()
	             |> clone_operation_params(keep_ids,exclude_ids,[operation_param | cloned_operation_params])
	    end
	  end

    end
  
  end
  
end
