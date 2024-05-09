defmodule Neurotick.Base.NeuronActuator do

  @callback activated(source_pid :: Pid.t(), data :: Float.t()) :: Float.t()
    
  defmacro __using__(_opts) do
  
    quote do
        
      def actuate() do
        receive do
          ({source_pid,data})
            -> source_pid
                 |> activated(data)
        end
        actuate()
      end
        
    end
    
  end
  
end
