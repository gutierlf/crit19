defmodule Crit.Exemplars.Background do
  use ExUnit.CaseTemplate
  use Crit.TestConstants
  alias Crit.Exemplars.ReservationFocused
  alias Crit.Setup.ProcedureApi
  import DeepMerge
  alias Crit.Factory
  alias Ecto.Datespan

  #-----------------------------------------------------

  def background(species_id \\ @bovine_id) do
    %{species_id: species_id}
  end

  def procedure_frequency(data, calculation_name) do
    schema = :procedure_frequency
    
    addition = Factory.sql_insert!(schema,
      name: calculation_name <> " procedure frequency",
      calculation_name: calculation_name)

    deep_merge(data, %{schema => %{calculation_name => addition}})
  end

  defp lazy_get(data, top_level, name) do
    with(
      category <- data[top_level],
      value <- category[name]
    ) do
      value
    end
  end
  
  defp lazy_get(data, top_level, name, putter) do
    lazy_get(data, top_level, name)
    || putter.(data) |> lazy_get(top_level, name, putter)
  end

  defp lazy_frequency(data, calculation_name) do
    lazy_get(data, :procedure_frequency, calculation_name,
      &(procedure_frequency(&1, calculation_name)))
  end

  def procedure(data, procedure_name, opts \\ []) do 
    opts = Enum.into(opts, %{frequency: "unlimited"})

    frequency = lazy_frequency(data, opts.frequency)
    species_id = data.species_id

    %{id: id} = Factory.sql_insert!(:procedure,
      name: procedure_name,
      species_id: species_id,
      frequency_id: frequency.id)
    addition = ProcedureApi.one_by_id(id, @institution, preload: [:frequency])

    assemble(data, :procedure, procedure_name, addition)
  end

  def procedures(data, descriptors) do
    Enum.reduce(descriptors, data, fn {key, opts}, acc ->
      apply &procedure/3, [acc, key, opts]
    end)
  end

  def animal(data, animal_name, opts \\ []) do
    opts =
      Enum.into(opts, %{
            available_on: @earliest_date,
            species_id: data.species_id})

    in_service_date = opts.available_on
    span = Datespan.customary(in_service_date, @latest_date)

    addition = Factory.sql_insert!(:animal,
      name: animal_name,
      span: span,
      species_id: opts.species_id)

    assemble(data, :animal, animal_name, addition)
  end

  def reservation_for(data, purpose, animal_names, procedure_names, opts \\ []) do
    schema = :reservation
    species_id = data.species_id
    
    addition =
      ReservationFocused.reserved!(species_id, animal_names, procedure_names, opts)

    deep_merge(data, %{schema => %{purpose => addition}})
  end

  #-----------------------------------------------------

  defp assemble(data, schema, name, addition) do
    atom = name |> String.downcase |> String.to_atom
    
    data
    |> deep_merge(%{schema => %{name => addition}})
    |> Map.put(atom, addition)
  end
end
