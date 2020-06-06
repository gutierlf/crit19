defmodule CritWeb.ViewModels.Setup.ServiceGapTest do
  use Crit.DataCase, async: true
  alias CritWeb.ViewModels.Setup, as: ViewModels
  alias Crit.Setup.Schemas
  alias Ecto.Datespan

  @id "any old id"
  @reason "some reason"

  def create(%Datespan{} = span) do
    %Schemas.ServiceGap{
      id: @id,
      animal_id: [:irrelevant],
      span: span,
      reason: @reason
    }
  end

  describe "to_web" do 
    test "common fields" do
      create(Datespan.customary(@date_2, @date_3))
      |> ViewModels.ServiceGap.to_web(@institution)
      |> assert_fields(id: @id,
                       reason: @reason,
                       institution: @institution,
                       delete: false)
    end

    test "datespan" do
       create(Datespan.customary(@date_2, @date_3))
       |> ViewModels.ServiceGap.to_web(@institution)
       |> assert_fields(in_service_datestring: @iso_date_2,
                        out_of_service_datestring: @iso_date_3)
    end
  end


  describe "changesettery" do
    defp handle(attrs, model \\ %ViewModels.ServiceGap{}),
      do: ViewModels.ServiceGap.changeset(model, attrs)
    
    test "all values are valid" do
      given = %{in_service_datestring: @iso_date_1,
                out_of_service_datestring: @iso_date_2,
                institution: @institution,
                reason: "reason"}
      
      handle(given)
      |> assert_valid
      |> assert_changes(in_service_datestring: @iso_date_1,
                        out_of_service_datestring: @iso_date_2,
                        reason: "reason")
    end
    

    # Error checking

    test "required fields are must be present" do
      handle(%{})
      |> assert_errors([:in_service_datestring, :out_of_service_datestring, :reason])
    end

    test "dates must be in the right order" do
      given = %{in_service_datestring: @iso_date_1,
                out_of_service_datestring: @iso_date_1,
                institution: @institution,
                reason: "reason"}
      handle(given)
      |> assert_error(out_of_service_datestring: @date_misorder_message)

      # Other fields are available to fill form fields
      |> assert_changes(in_service_datestring: @iso_date_1,
                        out_of_service_datestring: @iso_date_1,
                        reason: "reason")
    end


    test "existing changeset fields are retained if not replaced" do
      existing = %ViewModels.ServiceGap{reason: "x", in_service_datestring: "y"}
        
      given = %{in_service_datestring: "REPLACE",
                institution: @institution}
      handle(given, existing)
      |> assert_error(out_of_service_datestring: @blank_message)
      |> assert_changes(in_service_datestring: "REPLACE")
      |> assert_data(reason: "x")
    end
  end


  describe "from_web" do
  end
end
