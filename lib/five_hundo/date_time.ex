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
      |> Calendar.DateTime.subtract!(days_back * one_day())
    end)
  end


  def current_week do
    current_week_dates()
    |> Enum.map(&to_simple_date/1)
  end


  defp current_week_dates(days \\ [], current_date \\ current_working_date())
  defp current_week_dates([], current_date) do
    if current_date |> day_of_the_week == start_day() do
      current_week_dates([current_date], current_date |> one_day_forward)
    else
      current_week_dates([], current_date |> one_day_back)
    end
  end
  defp current_week_dates(days, current_date) do
    updated_days = days |> Enum.concat([current_date])
    if updated_days |> Enum.count == 7 do
      updated_days
    else
      updated_days
      |> current_week_dates(current_date |> one_day_forward)
    end
  end


  defdelegate day_of_the_week(date_time), to: Calendar.Date, as: :day_of_week_name


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


  defp one_day_back(date_time) do
    date_time
    |> Calendar.DateTime.subtract!(one_day())
  end


  defp one_day_forward(date_time) do
    date_time
    |> Calendar.DateTime.add!(one_day())
  end


  defp to_simple_date(date) do
    date
    |> Calendar.DateTime.to_date
    |> Map.take([:day, :month, :year])
  end


  defp one_day, do: 24 * 60 * 60


  def timezone do
    :five_hundo
    |> Application.get_env(:timezone)
  end


  def cutoff_time do
    :five_hundo
    |> Application.get_env(:cutoff_time)
  end


  def start_day do
    :five_hundo
    |> Application.get_env(:start_day)
  end
end
