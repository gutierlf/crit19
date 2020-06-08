defmodule CritWeb.ViewModels.FieldValidators do
  import Ecto.Changeset
  alias Ecto.ChangesetX
  use Crit.Errors

  def date_order(%{valid?: false} = changeset), do: changeset
  def date_order(changeset) do
    [in_service, out_of_service] =
      changeset
      |> ChangesetX.values([:in_service_datestring, :out_of_service_datestring])
        
    case in_service < out_of_service do  # Works: ISO8601
      true ->
        changeset
      false ->
        add_error(changeset, :out_of_service_datestring, @date_misorder_message)
    end
  end

  # This is tested through use. See, for example, ViewModels.Setup.Animal
  def cast_subarray(changeset, field, validator) do
    changesets = 
      get_change(changeset, field, [])
      |> Enum.map(validator)

    validity = Enum.all?(changesets, &(&1.valid?))

    changeset
    |> put_change(field, changesets)
    |> Map.put(:valid?, validity)
  end
end
