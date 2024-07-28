defmodule Neurotick.Base.NeuronMetadata do

  alias Krug.EtsUtil
  alias Krug.MapUtil
  
  @tablename_metadata :neurotick_ets_metadata
  
  def debugg_pids(pids) do
    cond do
      (Enum.empty?(pids))
        -> :ok
      true
        -> pids
             |> debugg_pid()
    end
  end
  
  defp debugg_pid(pids) do
    pids
      |> hd()
      |> read_metadata()
      |> Poison.encode!()
      |> IO.inspect()
    pids
      |> tl()
      |> debugg_pids()
  end
  
  def read_metadata(pid) do
    EtsUtil.read_from_cache(@tablename_metadata,pid) 
  end
 
  def store_metadata(pid,type) do
    metadata = %{
      pid: pid |> :erlang.pid_to_list() |> to_string(),
      type: type
    }
    EtsUtil.store_in_cache(@tablename_metadata,pid,metadata)
  end
  
  def store_metadata(pid,type,layer,activation_functions,bias,operation) do
    metadata = %{
      pid: pid |> :erlang.pid_to_list() |> to_string(),
      type: type,
      layer: layer,
      activation_functions: activation_functions,
      bias: bias,
      operation: operation
    }
    EtsUtil.store_in_cache(@tablename_metadata,pid,metadata)
  end 
  
  def store_metadata(pid,input,output) do
    metadata = pid 
                 |> read_metadata()
    cond do
      (nil == metadata)
        -> :ok
      true
        -> metadata
             |> replace_metadata(pid,input,output)
    end
  end
  
  defp replace_metadata(metadata,pid,input,output) do
    metadata = metadata
                 |> MapUtil.replace(:input,input)
                 |> MapUtil.replace(:output,output)
    EtsUtil.store_in_cache(@tablename_metadata,pid,metadata)
  end
 
end
