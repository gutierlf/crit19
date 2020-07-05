defmodule Crit.Ecto.NameList do
  alias Crit.Ecto.TrimmedString
  use Ecto.Type

  @impl Ecto.Type
  def type, do: {:array, TrimmedString}

  @impl Ecto.Type
  def cast(comma_separated) when is_binary(comma_separated) do
    array = 
      comma_separated
      |> String.split(",")
      |> Enum.map(&TrimmedString.cast/1)
      |> Enum.map(fn {:ok, val} -> val end)
      |> Enum.reject(fn s -> s == "" end)
      |> Enum.uniq
    {:ok, array}
  end
  def cast(_), do: :error

  # This is only intended for virtual fields.
  @impl Ecto.Type
  def load(_string), do: :error
  @impl Ecto.Type
  def dump(_string), do: :error
end
