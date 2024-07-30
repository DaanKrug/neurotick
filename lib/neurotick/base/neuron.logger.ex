defmodule Neurotick.Base.NeuronLogger do

  defmacro __using__(_opts) do
  
    quote do
    
      alias Neurotick.Base.NeuronStorage
    
      defp debugg_info(pid,info) do
        [_,_,_,debugg] = NeuronStorage.get_config(pid)
        cond do
          (!debugg)
	        -> :ok
	      true
	        -> info
	             |> IO.inspect()
	    end
	    :ok
      end
    
    end
    
  end

end