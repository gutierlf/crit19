defmodule Crit.Sql.Router do
  alias Crit.Schemas.Institution

  @type arg :: any

  @callback adjust([arg], keyword, Institution.t) :: any
  @callback forward(atom, [arg], keyword, Institution.t) :: any
  @callback multi_opts(keyword, Institution.T) :: keyword
end

