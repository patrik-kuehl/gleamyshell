-module(gleamyshell_test_ffi).
-export([unset_env/1]).

unset_env(Identifier) ->
    os:unsetenv(binary_to_list(Identifier)),

    nil.
