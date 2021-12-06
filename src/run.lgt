/*******************************************************************************
Author: Jacques Robin, Camilo Correa Restrepo, 2021.

CARMAS daemon runner adapted for WUMPUS

This file sets appropriate prolog setting and initializes the  http_daemon after
all dependencies have been loaded.

This is the main entrypoint of the application and is run by daemon.sh

version: 0.1
*******************************************************************************/

:- use_module(library(http/http_unix_daemon), [http_daemon/1]).
:- use_module(library(settings), [set_setting/2]).
:- use_module(library(http/http_log), [http_log_stream/1]).
:- use_module(library(main)).

{:- set_setting(http:logfile, '/root/httpd.log')}.

%% This sets the application entrypoint to run.
:- initialization(run, main).

%% When running as a deamon this is the application entrypoint (main)
run :-
    set_logtalk_flag(events, allow),
    logtalk_load(meta_compiler(loader)),
    set_logtalk_flag(hook, meta_compiler),
    logtalk_load(loader),
    http_log_stream(_),
    debug(http(_)),
    http_daemon([fork(false), interactive(false), port(8081), user(logtalk)]). 
