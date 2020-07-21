defmodule Crit.Params.Builder do

  # convert shorthand into the kind of parameters delivered to
  # controller actions.
  
  def to_strings(map) when is_map(map) do
    map
    |> Enum.map(fn {k,v} -> {to_string(k), to_string_value(v)} end)
    |> Map.new
  end

  defp to_string_value(value) when is_list(value), do: Enum.map(value, &to_string/1)
  defp to_string_value(value) when is_map(value), do: to_strings(value)
  defp to_string_value(value), do: to_string(value)


  # ----------------------------------------------------------------------------

  def data_source(), do: Process.get(:data_source)
  def one_value(name), do: Map.fetch!(data_source().data(), name)
  
  defp exceptions(opts), do: Keyword.get(opts, :except, %{})
  defp deleted_keys(opts), do: Keyword.get(opts, :deleting, [])

  def make_numbered_params(descriptors) when is_list(descriptors) do
    descriptors
    |> Enum.map(&only/1)
    |> combine_into_numbered_params
  end
  
  defp combine_into_numbered_params(exemplars) do
    exemplars
    |> Enum.with_index
    |> Enum.map(fn {entry, index} ->
      key = to_string(index)
      value = Map.put(entry, "index", to_string(index))
      {key, value}
    end)
    |> Map.new  
  end

  def only([descriptor | opts]) do
    only(descriptor)
    |> Map.merge(exceptions(opts))
    |> Map.drop(deleted_keys(opts))
  end
  
  def only(descriptor), do: one_value(descriptor).params
end
