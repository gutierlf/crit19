defmodule Crit.InstitutionsTest do
  use Crit.DataCase
  alias Crit.Institutions
  alias Crit.Institutions.Institution
  use Crit.Institutions.Default

  test "the default user changeset contains permissions" do
    assert [preloaded] = Repo.all(Institution)
    assert [retrieved] = Institutions.all()
    assert preloaded == retrieved
    assert retrieved.short_name == @default_short_name
    assert retrieved.prefix == Institutions.Default.institution.prefix
    assert retrieved.display_name == Institutions.Default.institution.display_name
  end
end
