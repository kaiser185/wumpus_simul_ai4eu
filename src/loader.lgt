/*******************************************************************************
Author: Jacques Robin, Camilo Correa Restrepo, 2021.

WUMPUS base loader file

This file contains all the loader code for the simulator and its dependencies.

version: 0.1
*******************************************************************************/

%Base SWI libs
:- use_module(library(clpfd), []).
:- use_module(library(lists), []).
:- use_module(library(dif), []).

%SWI HTTP Libs
:- use_module(library(http/thread_httpd), []).
:- use_module(library(http/http_dispatch), []).
:- use_module(library(http/http_client), []).
:- use_module(library(http/http_json), []).
:- use_module(library(http/json), []).
:- use_module(library(http/http_unix_daemon), []).

%Logging Libs
:- use_module(library(http/http_client), []).
:- use_module(library(http/http_log), []).

% Init script
:- initialization((
	% Event system/ not fully implemented
	set_logtalk_flag(events, allow),
	% Make metapredicates go a lot faster
	logtalk_load(meta_compiler(loader)),
	set_logtalk_flag(hook, meta_compiler),
	% Logtalk stuff
	logtalk_load([
		%uncomment to allow debugging
		%debugger(loader),
		types(loader),
		meta(loader),
		random(loader),
		uuid(loader)
	]),
	% Local files
	% TODO: Check ordering to avoid warnings
	logtalk_load([
		sflux,
		wwconfigp,
		wwconfig,
		wwsimulatorp,
		wwsimulator,
		wwfeaturep,
		wwfeature,
		wwplacep,
		wwplace,
		wwstatep,
		wwstate,
		wwaction,
		wwpercept,
		server,
		test_cases
	],[])
	% Uncomment and comment out above line to enable debugging mode
	%],[debug(on)])		
)).
