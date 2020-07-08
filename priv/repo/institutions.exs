alias Crit.Schemas.{Institution,Timeslot}
alias Crit.Repo
alias Crit.Global.Constants
alias Crit.Global.SeedConstants

{:ok, _} = Repo.insert Constants.default_institution
Repo.insert_all(Timeslot, SeedConstants.default_timeslots,
  prefix: Constants.default_prefix)

{:ok, _} = Repo.insert %Institution{
  display_name: "University of Illinois",
  short_name: "illinois",
  prefix: "illinois",
  timezone: "America/Chicago"
}

Repo.insert_all(Timeslot, SeedConstants.default_timeslots, prefix: "illinois")

