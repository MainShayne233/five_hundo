defmodule FiveHundo.DateTime do

  def current_working_day do
    current_working_date()
    |> to_simple_date
  end
  
  def current_working_date do
    timezone()
    |> Calendar.DateTime.now!
    |> adjust_for_cutoff
  end

  def last_n_days(n) do
    n
    |> last_n_dates
    |> Enum.map(&to_simple_date/1)
  end

  def last_n_dates(n) when n < 1, do: []
  def last_n_dates(n) do
    today = current_working_date()
    (0..(n - 1))
    |> Enum.map(fn days_back -> 
      today
      |> Calendar.DateTime.subtract!(days_back * days())
    end)
  end

  defp adjust_for_cutoff(date_time) do
    cutoff_time()
    |> case do
      {hour, min, :AM} ->
        date_time
        |> Calendar.DateTime.subtract!(3600 * hour + 60 * min)
      {hour, min, :PM} ->
        date_time
        |> Calendar.DateTime.add!(3600 * hour + 60 * min)
    end
  end

  defp to_simple_date(date) do
    date
    |> Calendar.DateTime.to_date
    |> Map.take([:day, :month, :year]) 
  end

  defp days, do: 24 * 60 * 60

  def timezone do
    :five_hundo
    |> Application.get_env(:timezone)
  end

  def cutoff_time do
    :five_hundo
    |> Application.get_env(:cutoff_time)
  end
end
