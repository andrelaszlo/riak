%% This file is provided to you under the Apache License,
%% Version 2.0 (the "License"); you may not use this file
%% except in compliance with the License.  You may obtain
%% a copy of the License at

%%   http://www.apache.org/licenses/LICENSE-2.0

%% Unless required by applicable law or agreed to in writing,
%% software distributed under the License is distributed on an
%% "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
%% KIND, either express or implied.  See the License for the
%% specific language governing permissions and limitations
%% under the License.

%% @doc Convenience functions for setting up the HTTP interface
%%      of Riak.  This module loads parameters from the application
%%      environment:
%%
%%<dl><dt>  web_ip
%%</dt><dd>   IP address that the Webmachine node should listen to
%%</dd><dt> web_port
%%</dt><dd>   port that the Webmachine node should listen to
%%</dd><dt> web_logdir
%%</dt><dd>   directory under which the access log will be stored
%%</dd><dt> raw_name
%%</dt><dd>   the base path under which the riak_kv_wm_raw
%%            should be exposed; defaulted to "raw"
%%</dd></dl>
-module(riak_kv_web).

-export([config/0]).

%% @spec config() -> [{Key :: atom(), Value :: term()}]
%% @doc Returns the standard Webmachine configuration.
%%      pass the return of this function to
%%      webmachine_mochiweb:start/1 to start up a Webmachine
%%      resource serving out of
%%      http://{web_ip}:{web_port}/raw/
config() ->
    [{ip, app_helper:get_env(riak_kv, web_ip)},
     {port, app_helper:get_env(riak_kv, web_port)},
     {log_dir, app_helper:get_env(riak_kv, web_logdir, "log")},
     {backlog, 128},
     {dispatch, dispatch_table()}].

dispatch_table() ->
    RawProps = raw_props(),
    MapredProps = mapred_props(),
    StatsProps = stats_props(),

    [{[proplists:get_value(prefix, RawProps),bucket],
      riak_kv_wm_raw,RawProps},
     {[proplists:get_value(prefix, RawProps),bucket,key],
      riak_kv_wm_raw, RawProps},
     {[proplists:get_value(prefix, RawProps),bucket,key,'*'],
      riak_kv_wm_link_walker, RawProps},

     {[proplists:get_value(prefix, MapredProps)],
      riak_kv_wm_mapred, MapredProps},
     
     {[proplists:get_value(prefix, StatsProps)],
      riak_kv_wm_stats, StatsProps},

     {["ping"], riak_kv_wm_ping, []}].

raw_props() ->
    [{prefix, app_helper:get_env(riak_kv, raw_name, "raw")},
     {riak, local}].

mapred_props() ->
    [{prefix, app_helper:get_env(riak_kv, mapred_name, "mapred")}].

stats_props() ->
    [{prefix, app_helper:get_env(riak_kv, stats_urlpath, "stats")}].