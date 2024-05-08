defmodule Neurotick.SimpleSensorStarter do

  use Neurotick.ChildStarter
  
  @behaviour Neurotick.ChildStarter
  
  @impl Neurotick.ChildStarter
  def child_module() do
    Neurotick.SimpleSensor  
  end
    
end