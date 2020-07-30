defmodule Pile.TimeHelper do
  import Pile.Aspect, only: [some: 1]

  @doc ~S"""
  Produces a `Date` for today *in the given `timezone`*. That is, if a
  person asks for *today* a bit after midnight Wednesday in
  Manchester, England for a client in California, they'll get the
  `Date` for Tuesday.
  """
  def today_date(timezone) do
    {:ok, datetime} = some(DateTime).now(timezone)
    DateTime.to_date(datetime)
  end

  def date_string(date), do: Calendar.Strftime.strftime!(date, "%B %e, %Y")
  def date_string_without_year(date), do: Calendar.Strftime.strftime!(date, "%B %e")

  # Default date conversions are only accurate to microseconds. Using
  # them means that values round-tripped through Postgres would come
  # back with extra digits of zeroes, which breaks tests.
  
  def millisecond_precision(%NaiveDateTime{} = time) do
    as_erl = NaiveDateTime.to_erl(time)
    NaiveDateTime.from_erl!(as_erl, {0, 6})
  end

  def millisecond_precision(%Date{} = date) do
    zero_in_milliseconds = Time.from_erl!({0, 0, 0}, {0, 6})
    {:ok, result} = NaiveDateTime.new(date, zero_in_milliseconds)
    result
  end

  def week_dates(date) do
    day_of_week = Calendar.Date.day_of_week_zb(date)
    { Calendar.Date.subtract!(date, day_of_week),
      Calendar.Date.advance!(date, 6 - day_of_week)
    }
  end
end
