/*******************************************************************************
Author: Jacques Robin, Camilo Correa Restrepo, 2021.

Implementation of percept calculation for WUMPUS

version: 0.1
*******************************************************************************/
:- object(wwpercept).
	
	:- use_module(lists, [length/2, member/2, append/3]).
	:- use_module(dif, [dif/2]).

	:- public(gen_percept/4).
	gen_percept(Action, WWState, WWStatePrev, Percepts) :-
		gen_base_percept(WWState, BasePercepts),
		bump_percept(Action, WWState, WWStatePrev, BasePercepts, Percepts1),
		scream_percept(WWState, WWStatePrev, Percepts1, Percepts).
	
	:- public(gen_percept/2).
	%% In case the action did not meet the precondition.
	gen_percept(WWState, Percepts) :-
		gen_base_percept(WWState, Percepts).

	:- private(bump_percept/5).
	bump_percept(forward, CurrentState, PrevState, Percepts0, [bump|Percepts0]) :-
		CurrentState::state_diff(PrevState, []).
	bump_percept(forward, CurrentState, PrevState, Percepts0, Percepts0) :-
		\+ (CurrentState::state_diff(PrevState, [])).
	bump_percept(Action, _, _, Percepts0, Percepts0) :-
		dif(Action, forward).

	:- private(scream_percept/4).
	scream_percept(CurrentState, PrevState, Percepts0, [scream|Percepts0]) :-
		CurrentState::state_diff(PrevState, Diff),
		member(alive(wumpus(_)), Diff).
	scream_percept(CurrentState, PrevState, Percepts0, Percepts0) :-
		CurrentState::state_diff(PrevState, Diff),
		\+ (member(alive(wumpus(_)), Diff)).

	:- private(gen_base_percept/2).
	gen_base_percept(
		CurrentState,
		Percepts
	) :-
		stench_percept(CurrentState, [], Percepts1),
		breeze_percept(CurrentState, Percepts1, Percepts2),
		glitter_percept(CurrentState, Percepts2, Percepts).

	:- private(stench_percept/3).
	stench_percept(CurrentState, Percepts0, [stench|Percepts0]) :-
		CurrentState::holds(at(agent,Position)),
		adjacent(CurrentState)::adjacent(Position, AdjacentPlaces),
		member(Place, AdjacentPlaces),
		CurrentState::holds(at(wumpus(_), Place)).
	stench_percept(CurrentState, Percepts, Percepts) :-
		CurrentState::holds(at(agent,Position)),
		\+ ( adjacent(CurrentState)::adjacent(Position, AdjacentPlaces),
		member(Place, AdjacentPlaces),
		CurrentState::holds(at(wumpus(_), Place)) ).
	
	:- private(breeze_percept/3).
	breeze_percept(CurrentState, Percepts0, [breeze|Percepts0]) :-
		CurrentState::holds(at(agent,Position)),
		adjacent(CurrentState)::adjacent(Position, AdjacentPlaces),
		member(pit(_,_), AdjacentPlaces).
	breeze_percept(CurrentState, Percepts, Percepts) :-
		CurrentState::holds(at(agent,Position)), 
		\+ (adjacent(CurrentState)::adjacent(Position, AdjacentPlaces),
		member(pit(_,_), AdjacentPlaces)).

	:- private(glitter_percept/3).
	glitter_percept(CurrentState, Percepts0, [glitter|Percepts0]) :-
		CurrentState::holds(at(agent,Position)), 
		CurrentState::holds(at(gold, Position)).
	glitter_percept(CurrentState, Percepts, Percepts) :- 
		CurrentState::holds(at(agent,Position)), 
		\+ ( CurrentState::holds(at(gold, Position)) ).

:- end_object.
