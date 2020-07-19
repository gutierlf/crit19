defmodule Crit.Extras.SqlT do
  @moduledoc """
  Shorthand Sql functions for use in tests.
  """

  use Crit.TestConstants
  alias Crit.Sql

  def all_ids(schema) do
    schema
    |> Sql.all(@institution)
    |> EnumX.ids
  end
end
