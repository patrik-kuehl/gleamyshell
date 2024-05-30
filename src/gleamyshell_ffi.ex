defmodule GleamyShell do
  def execute(command, args, working_directory) do
    opts =
      case working_directory do
        {:some, dir} -> [{:stderr_to_stdout, true}, {:cd, dir}]
        :none -> [{:stderr_to_stdout, true}]
      end

    try do
      {output, exit_code} = System.cmd(command, args, opts)

      case exit_code do
        0 -> {:ok, output}
        _ -> {:error, {output, {:some, exit_code}}}
      end
    rescue
      error in ErlangError -> {:error, {to_string(error.original), :none}}
    end
  end
end
