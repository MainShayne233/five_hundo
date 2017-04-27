defmodule FiveHundo.DateTime do

  def current_working_day do
    timezone()
    |> Calendar.DateTime.now!
    |> adjust_for_cutoff
    |> Calendar.DateTime.to_date
    |> Map.take([:day, :month, :year])
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

  def timezone do
    :five_hundo
    |> Application.get_env(:timezone)
  end

  def cutoff_time do
    :five_hundo
    |> Application.get_env(:cutoff_time)
  end
end
