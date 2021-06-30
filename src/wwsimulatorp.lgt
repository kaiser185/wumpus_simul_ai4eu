/*******************************************************************************
Author: Jacques Robin, Camilo Correa Restrepo, 2021.

Simulator protocol specification for WUMPUS

Defines the simulator's public interface

TODO: migrate predicate declarations when stable to here

version: 0.1
*******************************************************************************/
:- protocol(wwsimulatorp).

	:- info([
		version is 0:1:0,
		author is 'Camilo Correa',
		date is 2021-04-15,
		comment is 'Simulator protocol'
	]).

	:- public(init/2).
	
	:- public(next_step/0).

	%% halt()
	:- public(stop/0).
	
	:- public(get_state/2).
	
	:- public(get_latest_fluent_change/2).
	
:- end_protocol.