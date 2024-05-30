-module(gleamyshell_ffi).
-export([os/0, home_directory/0]).

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
