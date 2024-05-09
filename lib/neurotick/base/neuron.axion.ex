defmodule Neurotick.Base.NeuronAxion do

  defmacro __using__(_opts) do
  
    quote do
    
      alias Neurotick.Base.OperationParam
      alias Krug.EtsUtil
      
      @tablename_sensors :neurotick_ets_sensors
      @tablename_sensors_data :neurotick_ets_sensors_data
      @tablename_activation_functions :neurotick_ets_activation_functions
      @tablename_actuators :neurotick_ets_actuators
      @tablename_config :neurotick_ets_config
      
      
      def sensor_receptor() do
        receive do
          ({:config,params_array})
            -> params_array
                 |> config()
          ({:read_signals})
            -> read_signals()
          ({sensor_pid,signals_array})
            -> received_signal(sensor_pid,signals_array)
        end
        sensor_receptor()  
      end
      
      defp config(params_array) do
        [
          sensors_array,
          activation_functions_array,
          actuators_array,
          bias,
          operation,
          debugg
        ] = params_array
        EtsUtil.new(@tablename_sensors)
        EtsUtil.new(@tablename_sensors_data)
        EtsUtil.new(@tablename_activation_functions)
        EtsUtil.new(@tablename_actuators)
        EtsUtil.new(@tablename_config)
	    EtsUtil.store_in_cache(@tablename_sensors,Kernel.self(),sensors_array)
	    EtsUtil.store_in_cache(@tablename_activation_functions,Kernel.self(),activation_functions_array)
	    EtsUtil.store_in_cache(@tablename_actuators,Kernel.self(),actuators_array)
	    EtsUtil.store_in_cache(@tablename_config,Kernel.self(),[bias,operation,debugg])             
	  end
	  
      defp read_signals() do
        pids = sensor_pids()
        signals_array = get_sensors_data()
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
                 |> request_signal()
        end
      end
      
      defp request_signal(sensor_pid) do
        Process.send(sensor_pid,{Kernel.self()},[:noconnect])
      end
      
      defp received_signal(sensor_pid,signal_array) do
        store_sensor_data(signal_array)
        read_signals()
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
      
      defp store_sensor_data(data) do
        EtsUtil.store_in_cache(@tablename_sensors_data,Kernel.self(),[data | get_sensors_data()])
      end
      
      defp get_sensors_data() do
        data = EtsUtil.read_from_cache(@tablename_sensors_data,Kernel.self())
        cond do
          (nil == data)
            -> []
          true
            -> data
        end
      end
      
      defp get_activation_functions() do
        functions = EtsUtil.read_from_cache(@tablename_activation_functions,Kernel.self())
        cond do
          (nil == functions)
            -> []
          true
            -> functions
        end
      end
      
      defp get_actuators() do
        actuators = EtsUtil.read_from_cache(@tablename_actuators,Kernel.self())
        cond do
          (nil == actuators)
            -> []
          true
            -> actuators
        end
      end
      
      defp get_config() do
        EtsUtil.read_from_cache(@tablename_config,Kernel.self())
      end
      
      defp clear_sensor_data() do
        EtsUtil.remove_from_cache(@tablename_sensors_data,Kernel.self())
      end
	 
      # process calculations
	
	  defp process_signals(signals_array) do
	    [bias,operation,debugg] = get_config()
	    
        debugg_info(
          ["process_signals => ",signals_array,bias],
          debugg
        )   
        
        clear_sensor_data()
	    operation_params = add_all_operations(signals_array,operation)
	    inputs = extract_inputs(signals_array)
	    result = calculate_inputs(inputs,operation_params)
	    
	    debugg_info(
	      ["result => ",result,"result + bias => ",result + bias],
	      debugg
	    )
	    result = get_activation_functions()
	               |> process_activations(result + bias)
	               
	    debugg_info(
	      ["result => ",result,"actuators => ",get_actuators()],
	      debugg
	    )
	    
	    result
	  end
	  
	  defp debugg_info(info,debugg) do
	    cond do
	      (!debugg)
	        -> :ok
	      true
	        -> info
	             |> IO.inspect()
	    end
	  end
	  
	  defp process_activations(activation_functions,result) do
	    cond do
	      (Enum.empty?(activation_functions))
	        -> result
	      true
	        -> activation_functions
	             |> process_activation(result)
	    end
	  end
	  
	  defp process_activation(activation_functions,result) do
	    function = activation_functions
	                 |> hd()
	    activation_result = function.process_activation(result)
	    activation_functions
	      |> tl()
	      |> process_activations(activation_result)
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
	  
    end
  
  end
  
end
