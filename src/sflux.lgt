/*******************************************************************************
Author: Jacques Robin, Camilo Correa Restrepo, 2021.

Special Flux Kernel For Logtalk

This file contains a logtalk port of Michael Thielscher's Special Flux Kernel
for declarative reasoning about state change.

version: 0.1
*******************************************************************************/
:- category(sflux).

	:- info([
		version is 0:1:0,
		author is 'Camilo Correa',
		date is 2021-03-17,
		comment is 'Special Flux Kernel For Logtalk'
	]).

	%% Module directives
	:- use_module(dif, [dif/2]).

	:- public(holds/2).
	%:- mode(holds(Arguments), Solutions).
	:- info(holds/2, [
		comment is 'Denotes that a fluent holds in a given state. Recursively traverses the state to determine it.',
		arguments is [
			'Fluent'-'A particular fluent (not necessarily ground)', 
			'State'-'A list of fluents representing a state'
		]
	]).
	%% Clause 1
	holds(F, [F|_]).
	%% Clause 2
	%% Original: holds(F, Z) :- Z=[F1|Z1], F\==F1, holds(F, Z1).
	holds(F, Z) :- Z=[F1|Z1], F\==F1, holds(F, Z1).
	%% Reasoning for Change: dif/2 is the purely declarative constraint counterpart to (\==)/2
	%% holds(F, Z) :- Z=[F1|Z1], dif(F,F1), holds(F, Z1).

	:- public(holds/3).
	%:- mode(holds(Arguments), Solutions).
	:- info(holds/3, [
		comment is 'Denotes that a fluent holds in a given state (second argument) and that the other state is the first without the fluent in question.',
		arguments is [
			'Fluent'-'A particular fluent (not necessarily ground)', 
			'State'-'A list of fluents representing a state',
			'StatePrime'-'A list of fluents representing the first state without the fluent'
		]
	]).
	%% Clause 1
	holds(F, [F|Z], Z).
	%% Clause 2
	%% Original: holds(F, Z, [F1|Zp]) :- Z=[F1|Z1], F\==F1, holds(F, Z1, Zp).
	holds(F, Z, [F1|Zp]) :- Z=[F1|Z1], F\==F1, holds(F, Z1, Zp).
	%% Reasoning for Change: dif/2 is the purely declarative constraint counterpart to (\==)/2
	%%holds(F, Z, [F1|Zp]) :- Z=[F1|Z1], dif(F,F1), holds(F, Z1, Zp).

	:- public(minus/3).
	%:- mode(holds(Arguments), Solutions).
	:- info(minus/3, [
		comment is 'Removes the fluents from a state',
		arguments is [
			'Initial State'-'The state whence the fluents are to be removed',
			'Fluents'-'A list of fluents', 
			'Resulting State'-'A list of fluents representing the state without said fluents'
		]
	]).
	minus(Z, [], Z).
	minus(Z, [F|Fs], Zp) :-
		(\+ holds(F, Z) -> Z1=Z ; holds(F, Z, Z1)),
		minus(Z1, Fs, Zp).

	:- public(plus/3).
	%:- mode(holds(Arguments), Solutions).
	:- info(plus/3, [
		comment is 'Adds a list of fluents to a state',
		arguments is [
			'Initial State'-'The state to whom the fluents are to be added',
			'Fluents'-'A list of fluents', 
			'Resulting State'-'A list of fluents representing the state with said fluents'
		]
	]).
	plus(Z, [], Z).
	plus(Z, [F|Fs], Zp) :-
		(\+ holds(F, Z) -> Z1=[F|Z] ; holds(F, Z), Z1=Z),
		plus(Z1, Fs, Zp).

	:- public(update/4).
	%:- mode(holds(Arguments), Solutions).
	:- info(update/4, [
		comment is 'Performs the update of a state by adding a set of positive fluents and removing a set of negative fluents',
		arguments is [
			'Initial State'-'A list of fluents representing the initial state',
			'ThetaP'-'A list of fluents to be added to the resulting state',
			'ThetaN'-'A list of fluents to be removed from the resulting state', 
			'Resulting State'-'A list of fluents representing the resulting state'
		]
	]).
	update(Z1, ThetaP, ThetaN, Z2) :-
		minus(Z1, ThetaN, Z), plus(Z, ThetaP, Z2).
	
	%%%% CURRENTLY UNUSED - IMPLEMENTED ELSEWHERE
	:- public(execute/3).
	%:- mode(holds(Arguments), Solutions).
	:- info(execute/3, [
		comment is 'Denotes that a fluent holds in a given state. Recursively traverses the state to determine it.',
		arguments is [
			'Action'-'The action to be perfomed to transform the state', 
			'Initial State'-'A list of fluents representing a state',
			'Resulting State'-'A list of fluents representing a state'
		],
		constraint is 'The object that imports this category MUST have definitions of perform/1 and state_update/3 in the background theory.'
	]).
	%% By prepending :: to perform/1 and state_update/3, we are explicitly
	%% saying that they must be accesible from the object importing the
	%% category.
	execute(A, Z1, Z2) :- /*::perform(A),*/ ::state_update(Z1, A, Z2).

:- end_category.
