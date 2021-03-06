%% Copyright (c) 2018 EMQ Technologies Co., Ltd. All Rights Reserved.
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

-module(emqx_banned_SUITE).

-compile(export_all).
-compile(nowarn_export_all).

-include("emqx.hrl").

-include("emqx_mqtt.hrl").

-include_lib("eunit/include/eunit.hrl").

all() -> [t_banned_all].

t_banned_all(_) ->
    emqx_ct_broker_helpers:run_setup_steps(),
    emqx_banned:start_link(),
    {MegaSecs, Secs, MicroSecs} = erlang:timestamp(),
    ok = emqx_banned:add(#banned{key = {client_id, <<"TestClient">>}, 
                                 reason = <<"test">>,
                                 by = <<"banned suite">>,
                                 desc = <<"test">>, 
                                 until = {MegaSecs, Secs + 10, MicroSecs}}),
    % here is not expire banned test because its check interval is greater than 5 mins, but its effect has been confirmed
    timer:sleep(100),
    ?assert(emqx_banned:check(#{client_id => <<"TestClient">>, username => undefined, peername => {undefined, undefined}})),
    emqx_banned:del({client_id, <<"TestClient">>}),
    ?assertNot(emqx_banned:check(#{client_id => <<"TestClient">>, username => undefined, peername => {undefined, undefined}})).