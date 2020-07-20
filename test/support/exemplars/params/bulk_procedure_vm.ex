defmodule Crit.Exemplars.Params.BulkProcedures do

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
  alias CritBiz.ViewModels.Setup, as: VM
  use Crit.ParamDSL,
    view_module: VM.BulkProcedure,
    default_cast_fields: [:name, :species_ids, :frequency_id],
    data: %{
      valid: %{
        categories: [:valid, :filled],
        params: paramify(%{name: "valid", 
                           species_ids: [@bovine_id],
                           frequency_id: @once_per_week_frequency_id}),
      },
      
      two_species: %{
        categories: [:valid, :filled],
        params: paramify(%{name: "two species",
                           species_ids: [@bovine_id, @equine_id],
                           frequency_id: @once_per_week_frequency_id}),
      },
      
      all_blank: %{
        categories: [:valid, :blank],
        params: paramify(%{name: "", 
                           # no value for species_ids will be sent by the browser.
                           frequency_id: @unlimited_frequency_id}),
        unchanged: [:name, :species_ids],
      },
      
      # Because there's a "click here to select this species in
      # all subforms button, it's valid to have a species chosen,
      # but not a name. But those create nothing in the database.
      blank_with_species: %{
        categories: [:valid, :blank],
        params: paramify(%{name: "",
                           species_ids: [@bovine_id],
                           frequency_id: @unlimited_frequency_id}),
      },
      
      #-----------------
      # Only one way to be invalid
      name_but_no_species: %{
        params: paramify(%{name: "xxlxl",
                           frequency_id: @unlimited_frequency_id}),
        unchanged: [:species_ids],
        categories: [:invalid, :filled]
      },
    }
  
end
