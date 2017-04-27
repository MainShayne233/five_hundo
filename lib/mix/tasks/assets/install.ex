defmodule Mix.Tasks.Assets.Install do

  def run(_args \\ []) do
    File.cd! "./assets"
    [
      "npm i",
      "elm package install -y",
    ]
    |> Enum.each(&Mix.Shell.IO.cmd/1)
    File.cd! ".."
  end
end
