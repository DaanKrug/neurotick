defmodule Neurotick.Base.NeuronOperationParam do

  def extract_inputs(signals_array,inputs \\ []) do
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
  
  def add_all_operations(signals_array,operation,operation_params \\ []) do
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
    [
      [operation,weight]
        | operation_params
    ]
  end
  
  def calculate_inputs(inputs,operation_params,result \\ 0) do
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
                   |> calculate(operation_params |> hd())
    inputs
      |> tl()
      |> calculate_inputs(
           operation_params 
             |> tl(),
             result + calculated
         )
  end
  
  defp calculate(input,operation_param) do
    [operation,weight] = operation_param
    cond do
      (nil == input)
        -> 0
      true
        -> input 
             |> calculate_internal(operation,weight)
    end
  end
  
  defp calculate_internal(input,"+",weight) do
    input + weight
  end
  
  defp calculate_internal(input,"-",weight) do
    input - weight
  end
  
  defp calculate_internal(input,"/",weight) do
    input / weight
  end
  
  defp calculate_internal(input,_,weight) do
    input * weight
  end
    
end
