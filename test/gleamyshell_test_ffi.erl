-module(gleamyshell_test_ffi).
-export([set_env/2, unset_env/1]).

set_env(Identifier, Value) ->
    os:putenv(binary_to_list(Identifier), binary_to_list(Value)),

    nil.

unset_env(Identifier) ->
    os:unsetenv(binary_to_list(Identifier)),

    nil.
