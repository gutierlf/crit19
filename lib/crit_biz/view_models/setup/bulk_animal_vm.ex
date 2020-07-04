defmodule CritBiz.ViewModels.Setup.BulkAnimalNew do
  use Ecto.Schema
  import Ecto.Changeset
  import Pile.ChangesetFlow
  alias Crit.FieldConverters.{ToSpan, ToNameList}
  alias Ecto.Datespan


  embedded_schema do
    # user-supplied fields
    field :names, :string
    field :species_id, :integer
    field :in_service_datestring, :string
    field :out_of_service_datestring, :string
    # The institition is needed to determine the timezone to see
    # way day "today" is.
    field :institution, :string


    # computed fields
    field :span, Datespan
    field :computed_names, {:array, :string}
  end

  @form_fields [:names, :species_id, :institution,
                :in_service_datestring, :out_of_service_datestring]

  def changeset(bulk, attrs) do
    bulk
    |> cast(attrs, @form_fields)
    |> validate_required(@form_fields)
  end

  def creation_changeset(attrs) do
    given_all_form_values_are_present(changeset(%__MODULE__{}, attrs),
      fn changeset ->
        changeset
        |> ToNameList.split_names(from: :names, to: :computed_names)
        |> ToSpan.synthesize
      end)
  end
end
