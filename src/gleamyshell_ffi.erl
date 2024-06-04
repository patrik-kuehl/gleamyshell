-module(gleamyshell_ffi).
-export([execute/3, cwd/0, os/0, home_directory/0, env/1, set_env/2, unset_env/1, which/1]).

execute(Executable, WorkingDirectory, Args) ->
    case which(Executable) of
        none ->
            {error, {abort, enoent}};
        {some, ExecutablePath} ->
            try
                do_execute(ExecutablePath, WorkingDirectory, Args)
            catch
                _:Reason ->
                    case Reason of
                        enomem ->
                            {error, {abort, enomem}};
                        eagain ->
                            {error, {abort, eagain}};
                        enametoolong ->
                            {error, {abort, enametoolong}};
                        emfile ->
                            {error, {abort, emfile}};
                        enfile ->
                            {error, {abort, enfile}};
                        eacces ->
                            {error, {abort, eacces}};
                        OtherReason ->
                            {error,
                                {abort, {other_abort_reason, atom_to_binary(OtherReason, utf8)}}}
                    end
            end
    end.

cwd() ->
    try
        {ok, Cwd} = file:get_cwd(),

        case os() of
            windows -> {some, sanitize_path_on_windows(Cwd)};
            _ -> {some, unicode:characters_to_binary(Cwd, utf8)}
        end
    catch
        _ -> none
    end.

os() ->
    case os:type() of
        {win32, _} -> windows;
        {unix, darwin} -> {unix, darwin};
        {unix, freebsd} -> {unix, free_bsd};
        {unix, openbsd} -> {unix, open_bsd};
        {unix, linux} -> {unix, linux};
        {unix, sunos} -> {unix, sun_os};
        {_, OperatingSystem} -> {unix, {other_os, atom_to_binary(OperatingSystem, utf8)}}
    end.

home_directory() ->
    case init:get_argument(home) of
        {ok, [[Dir] | _]} -> {some, unicode:characters_to_binary(Dir, utf8)};
        _ -> none
    end.

env(Identifier) ->
    case os:getenv(binary_to_list(Identifier)) of
        false -> none;
        Value -> {some, unicode:characters_to_binary(Value, utf8)}
    end.

set_env(Identifier, Value) ->
    os:putenv(binary_to_list(Identifier), binary_to_list(Value)),

    case env(Identifier) of
        none -> false;
        {some, _} -> true
    end.

unset_env(Identifier) ->
    os:unsetenv(binary_to_list(Identifier)),

    case env(Identifier) of
        none -> true;
        {some, _} -> false
    end.

which(Executable) ->
    case {os(), os:find_executable(binary_to_list(Executable))} of
        {_, false} -> none;
        {{unix, _}, Dir} -> {some, unicode:characters_to_binary(Dir, utf8)};
        {windows, Dir} -> {some, sanitize_path_on_windows(Dir)}
    end.

do_execute(ExecutablePath, WorkingDirectory, Args) ->
    Port = open_port(
        {spawn_executable, binary_to_list(ExecutablePath)},
        [
            {cd, binary_to_list(WorkingDirectory)},
            {args, Args},
            stderr_to_stdout,
            exit_status,
            hide,
            eof,
            in
        ]
    ),

    case port_result(Port, []) of
        {Output, 0} ->
            {ok, unicode:characters_to_binary(Output, utf8)};
        {Output, ExitCode} ->
            {error, {failure, unicode:characters_to_binary(Output, utf8), ExitCode}}
    end.

port_result(Port, IntermediateOutput) ->
    receive
        {Port, {data, {Flag, Bytes}}} ->
            write_to_stdout(Flag, Bytes),

            port_result(Port, [IntermediateOutput | Bytes]);
        {Port, {data, Bytes}} ->
            port_result(Port, [IntermediateOutput | Bytes]);
        {Port, eof} ->
            Port ! {self(), close},

            receive
                {Port, closed} -> true
            end,

            receive
                {"EXIT", Port, _} -> ok
            after 1 ->
                ok
            end,

            ExitCode =
                receive
                    {Port, {exit_status, ReceivedExitCode}} -> ReceivedExitCode
                end,

            {lists:flatten(IntermediateOutput), ExitCode}
    end.

write_to_stdout(Flag, Bytes) ->
    io:format("~ts", [
        list_to_binary(
            case Flag of
                eol -> [Bytes, $\n];
                noeol -> [Bytes]
            end
        )
    ]).

% Erlang's file:get_cwd/0 and os:find_executable/1 functions return a POSIX-style path,
% even on Windows. To keep the return value consistent with the Node.js FFI implementation
% and thus also consistent with all supported targets, some sanitization needs to be done.
sanitize_path_on_windows(Path) ->
    PathWithSanitizedDrive =
        case re:split(Path, "^([a-zA-Z0-9]*):", [{return, list}]) of
            [_, Drive, RemainingPath] -> [string:to_upper(Drive), ":" | RemainingPath];
            [RemainingPath] -> RemainingPath
        end,

    unicode:characters_to_binary(string:replace(PathWithSanitizedDrive, "/", "\\", all), utf8).
