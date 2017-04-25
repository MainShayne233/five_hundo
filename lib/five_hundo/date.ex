defmodule FiveHundo.DateTime do

  def now do
    timezone()
    |> Calendar.DateTime.now!
    |> format_datetime
  end

  def timezone do
    :five_hundo
    |> Application.get_env(:timezone)
  end

  def format_datetime(%DateTime{
    year: year,
    month: month,
    day: day,
    hour: hours,
     minute: minutes,
     second: seconds
  }) do
    {
      { hours, minutes, seconds } |> format_time,
      { year, month, day },
    }
  end

  def format_time({hours, minutes, seconds}) when hours > 12 do
    { hours - 12, minutes, seconds, :PM }
  end

  def format_time({hours, minutes, seconds}) do
    { hours, minutes, seconds, :AM }
  end
end
