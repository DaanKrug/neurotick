defmodule Neurotick.Base.OperationParam do

  def new_operation(id,operation,weight) do
    [id,operation,weight]
  end
  
  def calculate(input,operation_param) do
    [_,operation,weight] = operation_param
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

