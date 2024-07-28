defmodule Neurotick.Base.NeuronCortex do

  alias Neurotick.Base.NeuronStorage
  
  @sensors_id "sensors"
  

  def process_signals(network_id) do
    network_id
      |> NeuronStorage.get_network_element(@sensors_id)
      |> handle_signals()
  end
  
  defp handle_signals(sensors) do
    cond do
      (Enum.empty?(sensors))
        -> :ok
      true
        -> sensors
             |> handle_signals2()
    end
  end
  
  defp handle_signals2(sensors) do
    sensors
      |> hd()
      |> Process.send({:do_sense},[:noconnect])
    sensors
      |> tl()
      |> handle_signals()
  end

end