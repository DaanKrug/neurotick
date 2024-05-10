defmodule Neurotick.Base.NeuronActuator do

  @callback activated(source_pid :: Pid.t(), data :: Float.t()) :: Float.t()
    
  defmacro __using__(_opts) do
  
    quote do
    
      use Neurotick.Base.NeuronLogger
        
      def actuate() do
        receive do
          ({neuron_pid,:terminate})
            -> neuron_pid
                 |> debugg_info(["Terminated Actuator => ",Kernel.self()]) 
          ({neuron_pid,data})
            -> neuron_pid
                 |> do_actuate(data)
        end
      end
      
      defp do_actuate(neuron_pid,data) do
        neuron_pid
          |> activated(data)
        actuate()
      end
        
    end
    
  end
  
end
