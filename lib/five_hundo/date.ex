defmodule FiveHundo.DateTime do

  def current_day_day do
    {
      { hours, minutes, seconds, meridian },
      { year, month, day },
    } = now()
    meridian
    |> case do
      :AM ->
        
    end
  end

  def now do
    timezone()
    |> Calendar.DateTime.now!
    |> format_datetime
  end

  def timezone do
    :five_hundo
    |> Application.get_env(:timezone)
  end

  def cutoff_time do
    :five_hundo
    |> Application.get_env(:cutoff_time)
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

# mix phx.gen.model Entry entries text:text word_count:integer year:integer month:integer day:integer hours:integer minutes:integer seconds:integer meridiem
