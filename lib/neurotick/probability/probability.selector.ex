defmodule Neurotick.Probability.Selector do

  alias Krug.NumberUtil

  def select(elements,probability) do
    cond do
      (nil == elements 
        or Enum.empty?(elements))
          -> elements
      (Enum.empty?(elements |> tl())
        or !(probability > 0)
          or probability > 1)
            -> elements
      true
        -> elements
             |> select2(probability)
    end
  end
  
  defp select2(elements,probability) do
    total = elements 
              |> length()
    max = (total * probability)
            |> NumberUtil.to_integer()
    cond do
      (max >= total)
        -> elements
      (max < 1)
        -> elements
             |> select3([],[],1)
      true
        -> elements
             |> select3([],[],max)
    end
  end
  
  defp select3(elements,selected_elements,already_sorted,max) do
    cond do
      (selected_elements |> length() >= max)
        -> selected_elements
             |> Enum.reverse()
      true
        -> elements
             |> select4(selected_elements,already_sorted,max)
    end
  end
  
  defp select4(elements,selected_elements,already_sorted,max) do
    rand = :rand.uniform(max) - 1
    cond do
      (Enum.member?(already_sorted,rand))
        -> elements
             |> select4(selected_elements,already_sorted,max)
      true
        -> elements
             |> select3(
                  [elements |> Enum.at(rand) | selected_elements],
                  [rand | already_sorted],
                  max
                )
    end
  end

end



