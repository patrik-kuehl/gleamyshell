defmodule GleamyShell do
  def execute(command, args) do
    command_with_args = "#{command} #{Enum.join(args, " ")}"

    {output, exit_code} = System.shell(command_with_args)

    case exit_code do
      0 -> {:ok, output}
      _ -> {:error, {output, exit_code}}
    end
  end
end
