defmodule Crit.Exemplars.Params do
  alias Crit.Exemplars, as: Ex
  

  def put_nested(top_params, field, nary) when is_list(nary) do
    param_map = 
      nary
      |> Enum.with_index
      |> Enum.map(fn {lower_params, index} -> {to_string(index), lower_params} end)
      |> Map.new
    %{ top_params | field => param_map}
  end


  # ---------Animal forms -------------------------------------------------------

  @base_vm_animal %{
      "id" => "1",
      "lock_version" => "2",
      "name" => "Bossie",
      "species_name" => "species name",
      "service_gaps" => %{}
  } |> Ex.Datespan.put_datestrings(:widest_finite)

  @service_gaps %{
    empty: %{
      "reason" => "",
      "in_service_datestring" => "",
      "out_of_service_datestring" => "",
    }, 

    first: Ex.Datespan.put_datestrings(%{"reason" => "first reason"}, :first)
  }

  def vm_animal(service_gap_descriptors) do
    service_gaps = 
      service_gap_descriptors
      |> Enum.with_index
      |> Enum.reduce(%{}, fn {descriptor, index}, acc ->
           Map.put(acc, to_string(index), @service_gaps[descriptor])
         end)

      Map.put(@base_vm_animal, "service_gaps", service_gaps)
  end

  # ---------Bulk procedure forms ----------------------------------------------

  defmodule BulkProcedures do
    @moduledoc """
      %{
        "0" => %{"frequency_id" => "32", "index" => "0", "name" => ""},
        "1" => %{
          "frequency_id" => "32",
          "index" => "1",
          "name" => "",
          "species_ids" => ["1"]
        },
        "2" => %{"frequency_id" => "32", "index" => "2", "name" => ""}
      }
    """
    use Crit.TestConstants
    alias Ecto.Changeset
    alias CritBiz.ViewModels.Setup, as: VM

    @default_cast_fields [:name, :species_ids, :frequency_id]
  
    @options %{
      valid: %{
        params: %{
          "name" => "haltering",
          "species_ids" => [to_string(@bovine_id)],
          "frequency_id" => "32"},
        },

      two_species: %{
        params: %{
          "name" => "haltering",
          "species_ids" => [to_string(@bovine_id),
                            to_string(@equine_id)],
          "frequency_id" => "32"},
      },
      
      all_blank: %{
        params: %{
          "name" => "",
          # no value for species_id will be sent by the browser.
          "frequency_id" => "32"
        }
      },

      # Because there's a "click here to select this species in
      # all subforms button, it's valid to have a species chosen,
      # but not a name. But those create nothing in the database.
      blank_with_species: %{
        params: %{
          "name" => "",
          "species_ids" => [to_string(@bovine_id)],
          "frequency_id" => "32"
        }
      }
    }


    defp only([descriptor | opts]) do
      only(descriptor)
      |> Map.merge(exceptions(opts))
      |> Map.drop(deleted_keys(opts))
    end
    
    defp only(descriptor), do: @options[descriptor].params

    defp exceptions(opts), do: Keyword.get(opts, :except, %{})
    defp without(opts), do: Keyword.get(opts, :without, [])
    defp deleted_keys(opts), do: Keyword.get(opts, :deleting, [])

    defp fields_to_check(descriptor, opts) do
      pure_fields = Map.get(@options[descriptor], :to_cast, @default_cast_fields)
      extras = exceptions(opts) |> Map.keys

      pure_fields
      |> Enum.concat(extras)
      |> ListX.delete(without(opts))
    end

    def as_cast(descriptor, opts \\ []) do
      cast_value = 
        %VM.BulkProcedure{}
        |> Changeset.cast(only(descriptor), VM.BulkProcedure.fields())
        |> Changeset.apply_changes
        |> Map.merge(exceptions(opts))
        |> Map.drop(without(opts))
      
      for field <- fields_to_check(descriptor, opts), 
        do: {field, Map.get(cast_value, field)}
    end

    def that_are(descriptors) when is_list(descriptors) do
      descriptors
      |> Enum.map(&only/1)
      |> Enum.with_index
      |> Enum.map(fn {entry, index} ->
           key = to_string(index)
           value = Map.put(entry, "index", to_string(index))
           {key, value}
         end)
      |> Map.new
    end

    def that_are(descriptor), do: that_are([descriptor])

    def that_are(descriptor, opts), do: that_are([[descriptor | opts]])


    def accept_form(descriptor),
      do: that_are(descriptor) |> VM.BulkProcedure.accept_form

    def lower_changesets(descriptor) do
      {:ok, vm_changesets} = accept_form(descriptor)
      VM.BulkProcedure.lower_changesets(vm_changesets)
    end
  end
end
