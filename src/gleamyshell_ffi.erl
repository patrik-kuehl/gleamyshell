-module(gleamyshell_ffi).
-export([cwd/0, os/0, home_directory/0]).

cwd() ->
    try
        {ok, Cwd} = file:get_cwd(),

        case os() of
            windows -> {some, sanitize_cwd_on_windows(Cwd)};
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

% Erlang's file:get_cwd/0 function returns a POSIX-style path, even on Windows.
% To keep the return value consistent with Node.js' os:homedir/0 function and thus
% also consistent with all supported targets, some sanitization needs to be done.
sanitize_cwd_on_windows(Cwd) ->
    DirWithSanitizedDrive = case re:split(Cwd, "^([a-zA-Z0-9]*):", [{return, list}]) of
        [_, Drive, RemainingPath] -> [string:to_upper(Drive), ":" | RemainingPath];
        [RemainingPath] -> RemainingPath
    end,

    unicode:characters_to_binary(string:replace(DirWithSanitizedDrive, "/", "\\", all), utf8).