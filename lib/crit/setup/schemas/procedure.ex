defmodule Crit.Setup.Schemas.Procedure do
  use Ecto.Schema
  import Ecto.Changeset
  alias Crit.Ecto.TrimmedString
  alias Crit.Setup.Schemas.{Species,ProcedureFrequency}
  alias Crit.Sql
  alias Crit.Sql

  schema "procedures" do
    field :name, TrimmedString
    belongs_to :species, Species
    belongs_to :frequency, ProcedureFrequency

    timestamps()
  end

  def preloads, do: [:species, :frequency]

  @required [:name, :species_id, :frequency_id]

  def changeset(procedure, attrs) do
    procedure
    |> cast(attrs, @required)
    |> validate_required(@required)
    |> unique_constraint(:name, name: "unique_to_species")
  end

  def insert(attrs, institution) do
    %__MODULE__{}
    |> changeset(attrs)
    |> Sql.insert(institution)
  end
end
