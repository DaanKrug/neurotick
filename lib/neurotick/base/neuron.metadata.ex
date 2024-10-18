defmodule Neurotick.Base.NeuronMetadata do

  @moduledoc false

  alias Krug.EtsUtil
  alias Krug.MapUtil
  alias Krug.FileUtil
  alias Krug.StringUtil
  
  @tablename_metadata :neurotick_ets_metadata
  
  
  def debugg_pids(pids,file_path) do
    cond do
      (Enum.empty?(pids))
        -> :ok
      true
        -> pids
             |> debugg_pid(file_path)
    end
  end
  
  defp debugg_pid(pids,file_path) do
    metadata = pids
                 |> hd()
                 |> read_metadata()
    cond do
      (nil == file_path)
        -> metadata
             |> IO.inspect()
      true
        -> metadata
             |> metadata_to_file(file_path)
    end
    pids
      |> tl()
      |> debugg_pids(file_path)
  end
  
  defp metadata_to_file(metadata,file_path) do
    content = file_path 
                |> FileUtil.read_file()
    metadata = metadata
                 |> prepare_metadata_to_file()
                 |> Poison.encode!()
                 |> StringUtil.replace("{","{\n\t")
                 |> StringUtil.replace("\",","\",\n\t")
                 |> StringUtil.replace("],","],\n\t")
                 |> StringUtil.replace("}","\n}")
                 |> StringUtil.replace(",\"",",\n\t\"")
    cond do
      (nil == content)
        -> file_path
             |> FileUtil.write(metadata)
      true
        -> file_path
             |> FileUtil.write("#{content}\n#{metadata}")
    end
  end
  
  def read_metadata(pid) do
    EtsUtil.read_from_cache(@tablename_metadata,pid) 
  end
 
  def store_metadata(pid,name,type) do
    metadata = %{
      pid: pid,
      name: name,
      type: type
    }
    EtsUtil.store_in_cache(@tablename_metadata,pid,metadata)
  end
  
  def store_metadata(pid,name,type,layer,activation_functions,weight,bias,operation) do
    metadata = %{
      pid: pid,
      name: name,
      type: type,
      layer: layer,
      activation_functions: activation_functions,
      weight: weight,
      bias: bias,
      operation: operation
    }
    EtsUtil.store_in_cache(@tablename_metadata,pid,metadata)
  end 
  
  def update_metadata(pid,input,output) do
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
  
  def update_metadata_bindings(pid,input_bindings,output_bindings) do
    metadata = pid 
                 |> read_metadata()
    cond do
      (nil == metadata)
        -> :ok
      true
        -> metadata
             |> replace_metadata_bindings(pid,input_bindings,output_bindings)
    end
  end
  
  defp replace_metadata_bindings(metadata,pid,input_bindings,output_bindings) do
    metadata = metadata
                 |> MapUtil.replace(:input_bindings,input_bindings)
                 |> MapUtil.replace(:output_bindings,output_bindings)
    EtsUtil.store_in_cache(@tablename_metadata,pid,metadata)
  end
  
  defp replace_metadata(metadata,pid,input,output) do
    metadata = metadata
                 |> MapUtil.replace(:input,input)
                 |> MapUtil.replace(:output,output)
    EtsUtil.store_in_cache(@tablename_metadata,pid,metadata)
  end
  
  defp prepare_metadata_to_file(metadata) do
    pid = metadata 
            |> MapUtil.get(:pid)
            |> prepare_pid_name()
    input_bindings = metadata 
                       |> MapUtil.get(:input_bindings)
                       |> prepare_binding_pid_names()
    output_bindings = metadata 
                        |> MapUtil.get(:output_bindings)
                        |> prepare_binding_pid_names()
    metadata
      |> MapUtil.replace(:pid,pid)
      |> MapUtil.replace(:input_bindings,input_bindings)
      |> MapUtil.replace(:output_bindings,output_bindings)
  end
  
  defp prepare_binding_pid_names(pids,pid_names \\ []) do
    cond do
      (nil == pids 
        or Enum.empty?(pids))
          -> pid_names
               |> Enum.reverse()
      true
        -> pids
             |> tl()
             |> prepare_binding_pid_names(
                  [
                    pids 
                      |> hd() 
                      |> prepare_pid_name() 
                      | pid_names
                  ]
                )
    end
  end
  
  defp prepare_pid_name(pid) do
    pid 
      |> :erlang.pid_to_list() 
      |> to_string()
  end
 
end

