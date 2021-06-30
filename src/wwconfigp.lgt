/*******************************************************************************
Author: Jacques Robin, Camilo Correa Restrepo, 2021.

Configuration protocol for WUMPUS

This file defines the public interface of the configuration object.

version: 0.1
*******************************************************************************/
:- protocol(wwconfigp).
	:- public(height/1).
	:- public(width/1).
	:- public(gold_density/1).
	:- public(pit_density/1).
	:- public(wumpus_density/1).
	:- public(arrow_num/1).
	%% Everything from here down is probably not going to get included
	%% in the first version, this is the variability in
	%% the environment that will be somewhat difficult to deal with
	%% at first.
	:- public(fully_observable/1).
	:- public(agent_number/1).
	:- public(episodic/1).
	:- public(static/1).
	:- public(discrete/1).
	:- public(known/1).
	:- public(stationay/1).
:- end_protocol.