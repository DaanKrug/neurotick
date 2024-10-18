defmodule Neurotick.Base.NeuronStarter do

  @moduledoc false

  def start_pid_layers(layers,started_pids \\ []) do
    cond do
      (Enum.empty?(layers))
        -> started_pids 
             |> Enum.reverse()
      true
        -> layers
             |> tl()
             |> start_pid_layers([layers |> hd() |> start_pids() | started_pids])
    end
  end

  def start_pids(array_params,started_pids \\ []) do
    cond do
      (Enum.empty?(array_params))
        -> started_pids
             |> Enum.reverse()
      true
        -> array_params
             |> tl()
             |> start_pids([array_params |> hd() |> start_pid() | started_pids]) 
    end
  end
  
  defp start_pid(params) do
    module = params
               |> hd()
    params = params
               |> tl()
    module.new(params)
  end
  
end