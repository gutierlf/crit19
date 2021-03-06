defmodule CritBiz.ViewModels.Setup.ProcedureVM.LowerTowardRepoTest do
  use Crit.DataCase, async: true
  alias Crit.Exemplars.Params.BulkProcedures, as: Params

  describe "`lower_changesets` to schema structs" do
    test "only one interesting case" do
      Params.validate(:lowered, :two_species)
      # But it doesn't hurt to check the rest.
      Params.validate(:lowered, :valid)
    end
  end
end
