/*******************************************************************************
Author: Jacques Robin, Camilo Correa Restrepo, 2021.

World state protocol specification for WUMPUS

Defines the World state's public interface

TODO: migrate predicate declarations when stable to here

version: 0.1
*******************************************************************************/
:- protocol(wwstatep).

	:- public(consistent/0).

	:- public(holds/1).

	:- public(world_prop/1).

	:- public(fluent_state/1).

	:- public(eternal_state/1).

	:- public(percepts/1).

	:- public(update_fluents/3).

	:- public(delta/2).

:- end_protocol.