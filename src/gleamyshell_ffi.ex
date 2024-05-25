defmodule GleamyShell do
  def execute(command, args) do
    try do
      {output, exit_code} = System.cmd(command, args, stderr_to_stdout: true)

      case exit_code do
        0 -> {:ok, output}
        _ -> {:error, {output, {:some, exit_code}}}
      end
    rescue
      error in ErlangError -> {:error, {error.original |> to_string(), :none}}
    end
  end

  def cwd() do
    case File.cwd() do
      {:ok, path} -> {:some, path}
      {:error, _} -> :none
    end
  end
end
