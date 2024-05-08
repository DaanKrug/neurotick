defmodule Neurotick.ChildStarter do

  @callback child_module() :: Module.t()
  
  defmacro __using__(_opts) do
  
    quote do
  
	  alias Krug.SanitizerUtil
	  
	  def child_spec(opts) do
	    id = {__MODULE__,SanitizerUtil.generate_random_filename(20)}
	    %{id: id,start: {__MODULE__, :start_link, [opts]}}
	  end
	  
	  def start_link(opts) do
	    Supervisor.start_link([{child_module(),opts}],strategy: :one_for_one)
	  end
  
    end
    
  end
    
end