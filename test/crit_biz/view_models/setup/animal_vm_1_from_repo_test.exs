defmodule CritBiz.ViewModels.Setup.AnimalVM.FromRepoTest do
  use Crit.DataCase, async: true
  alias CritBiz.ViewModels.Setup, as: VM
  import Crit.Exemplars.Bossie, only: [repo_has_bossie: 1]
  alias Crit.RepoState
  alias Crit.Exemplars, as: Ex
  alias Ecto.Changeset
  alias Crit.Schemas

  setup :repo_has_bossie

  # These tests are all about proceding VM.Animal structs

  # ----------------------------------------------------------------------------

  describe "lift" do
    test "a lifting without service gaps)", %{repo: repo} do
      repo.bossie.id
      |> Schemas.Animal.Get.one_by_id(@institution, preload: [:species])
      |> VM.Animal.lift(@institution)
      |> Ex.Bossie.assert_view_model_for(id: repo.bossie.id)
      |> refute_assoc_loaded(:service_gaps)
    end

    test "lifting with service gaps", %{repo: repo} do
      Ex.Bossie.put_service_gap(repo, span: :first)

      repo.bossie.id
      |> Schemas.Animal.Get.one_by_id(@institution, preload: [:species, :service_gaps])
      |> VM.Animal.lift(@institution)
      
      |> Ex.Bossie.assert_view_model_for(id: repo.bossie.id)
       
      |> with_singleton(:service_gaps)
         |> assert_shape(%VM.ServiceGap{})
         |> Ex.Datespan.assert_datestrings(:first)
    end
  end

  # ----------------------------------------------------------------------------
  describe "`fetch` from database" do 
    test "fetching a list of animals does not produce service gaps",
      %{repo: repo} do
      
      VM.Animal.fetch(:all_possible, @institution)
      |> singleton_payload
      |> Ex.Bossie.assert_view_model_for(id: repo.bossie.id)
      |> refute_assoc_loaded(:service_gaps)
    end

    test "fetching a list of specific animals does not produce service gaps",
      %{repo: repo} do
      
      VM.Animal.fetch(:all_for_summary_list, [repo.bossie.id], @institution)
      |> singleton_payload
      |> Ex.Bossie.assert_view_model_for(id: repo.bossie.id)
      |> refute_assoc_loaded(:service_gaps)
    end

    test "fetching an animal for a summary does not produce a service gap",
      %{repo: repo} do 

      VM.Animal.fetch(:one_for_summary, repo.bossie.id, @institution)
      |> Ex.Bossie.assert_view_model_for(id: repo.bossie.id)
      |> refute_assoc_loaded(:service_gaps)
    end

    test "fetching an animal for editing does include service gaps",
      %{repo: repo} do 

      VM.Animal.fetch(:one_for_edit, repo.bossie.id, @institution)
      |> Ex.Bossie.assert_view_model_for(id: repo.bossie.id)
      |> assert_assoc_loaded(:service_gaps)
    end

    test "fetching is in alphabetical order", %{repo: repo} do
      ["bz", "b", "a"] |> Enum.map(&RepoState.animal(repo, &1))

      actual = 
        VM.Animal.fetch(:all_possible, @institution) |> EnumX.names

      assert actual == ["a", "b", "Bossie", "bz"]
    end
  end

  describe "constructing a form changeset from an animal" do
    test "fresh form changeset - no service gaps", %{repo: repo} do
      VM.Animal.fetch(:one_for_edit, repo.bossie.id, @institution)
      |> VM.Animal.fresh_form_changeset
      |> assert_no_changes
      |> with_singleton(:fetch_field!, :service_gaps)
         |> assert_fields(reason: "",
                          in_service_datestring: "",
                          out_of_service_datestring: "")
    end

    test "fresh form changeset - a service gap", %{repo: repo} do
      Ex.Bossie.put_service_gap(repo, span: :first, reason: "exists")
      
      animal = 
        VM.Animal.fetch(:one_for_edit, repo.bossie.id, @institution)
        |> VM.Animal.fresh_form_changeset
        |> assert_no_changes
      
      [empty, only] = Changeset.fetch_field!(animal, :service_gaps)

      empty
      |> assert_fields(reason: "",
                       in_service_datestring: "",
                       out_of_service_datestring: "")

      only
      |> assert_field(reason: "exists")
      |> Ex.Datespan.assert_datestrings(:first)
    end
  end
end
