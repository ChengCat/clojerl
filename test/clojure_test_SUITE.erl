-module(clojure_test_SUITE).

-include("clj_test_utils.hrl").

-export([ all/0
        , init_per_suite/1
        ]).

-export([run/1]).

-spec all() -> [atom()].
all() -> clj_test_utils:all(?MODULE).

-spec init_per_suite(config()) -> config().
init_per_suite(Config) -> clj_test_utils:init_per_suite(Config).

%%------------------------------------------------------------------------------
%% Test Cases
%%------------------------------------------------------------------------------

-spec run(config()) -> result().
run(_Config) ->
  SrcPath  = clj_test_utils:relative_path(<<"src/clj/">>),
  RootPath = clj_test_utils:relative_path(<<"test/clj/">>),
  true     = code:add_path(binary_to_list(SrcPath)),
  true     = code:add_path(binary_to_list(RootPath)),

  compile(<<"src/clj/clojure/core.clj">>),
  compile(<<"src/clj/clojure/main.clj">>),
  'clojure.core':'in-ns'(clj_core:gensym(<<"temp-ns">>)),
  'clojure.core':'use'([clj_core:symbol(<<"clojure.core">>)]),
  compile(<<"test/clj/examples/run_tests.clj">>),

  TestsPath = <<RootPath/binary, "/clojure/test_clojure/">>,
  Result    = 'examples.run-tests':'-main'([TestsPath, RootPath]),

  0 = clj_core:get(Result, fail),
  %% There are two tests that fail because of atoms not being implemented
  2 = clj_core:get(Result, error),

  {comments, ""}.

%%------------------------------------------------------------------------------
%% Helper
%%------------------------------------------------------------------------------

compile(Path) ->
  RelativePath = clj_test_utils:relative_path(Path),
  clj_compiler:compile_file(RelativePath, #{time => true}).
