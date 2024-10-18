defmodule Neurotick.Example.SimpleActuator do

  @moduledoc false

  use Neurotick.Base.NeuronActuator
  
  @behaviour Neurotick.Base.NeuronActuator
  
    
  @impl Neurotick.Base.NeuronActuator
  def activated(_signals_array) do
    #[
    #  "activated(signals_array) => ",
    #  signals_array 
    #]
    #  |> IO.inspect()
  end
      
    
end