%%--------------------------------------------------------------------
%% Copyright (c) 2020 EMQ Technologies Co., Ltd. All Rights Reserved.
%%
%% Licensed under the Apache License, Version 2.0 (the "License");
%% you may not use this file except in compliance with the License.
%% You may obtain a copy of the License at
%%
%%     http://www.apache.org/licenses/LICENSE-2.0
%%
%% Unless required by applicable law or agreed to in writing, software
%% distributed under the License is distributed on an "AS IS" BASIS,
%% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%% See the License for the specific language governing permissions and
%% limitations under the License.
%%--------------------------------------------------------------------

-module(emqx_plugin_template_app).

-behaviour(application).

-emqx_plugin(?MODULE).

-export([ start/2
        , stop/1
        ]).

start(_StartType, _StartArgs) ->

    %% manually pre-set the envs to avoid the eredis_pool crashes
    PoolOpts = [{size, 10}, {max_overflow, 20}],
    RedisOpts = [{host, "127.0.0.1"},
                 {port, 6379},
                 {database, 0},
                 %{password, "abc"},
                 {reconnect_sleep, 100}
                ],
    application:set_env(eredis_pool, pools, [{default, PoolOpts, RedisOpts}]),
    application:set_env(eredis_pool, global_or_local, local),
    application:ensure_all_started(eredis_pool),

    {ok, Sup} = emqx_plugin_template_sup:start_link(),
    emqx_plugin_template:load(application:get_all_env()),
    {ok, Sup}.

stop(_State) ->
    %application:unset_env(eredis_pool, pools),
    %application:unset_env(eredis_pool, global_or_local),
    %application:stop(eredis_pool),
    emqx_plugin_template:unload().
