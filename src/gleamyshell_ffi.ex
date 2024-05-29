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

  def cwd() do
    try do
      result =
        case :os.type() do
          {:win32, _} -> System.cmd("powershell", ["$pwd.Path"])
          {:unix, _} -> System.cmd("sh", ["-c", "pwd"])
        end

      case result do
        {dir, 0} -> {:some, dir}
        _ -> :none
      end
    rescue
      _ -> :none
    end
  end

  def os() do
    case :os.type() do
      {:win32, _} -> {"win32", ""}
      {:unix, operating_system} -> {"unix", to_string(operating_system)}
    end
  end

  def home_directory() do
    case System.user_home() do
      nil -> :none
      dir -> {:some, dir}
    end
  end
end
