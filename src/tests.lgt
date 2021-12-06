/*******************************************************************************
Author: Jacques Robin, Camilo Correa Restrepo, 2021.

WUMPUS tests for C4IIoT

This file contains all unit tests for WUMPUS

version: 0.1
*******************************************************************************/
:- object(tests, extends(lgtunit), imports(sflux)).

	:- use_module(lists, [flatten/2, length/2, member/2]).
	:- use_module(clpfd, [
		op(760, xfy, #<==>), op(750, xfy, #==>), op(700, xfx, #=), op(700, xfx, #>=), op(700, xfx, #=<), op(700, xfx, in), op(450, xfx, ..),
		op(740, yfx, #\/), op(730, yfx, #\), op(720, yfx, #/\), op(710,  fy, #\), op(700, xfx, ins), op(700, xfx, #>), op(700, xfx, #<), op(700, xfx, #\=),
		(=<)/2, (ins)/2, (in)/2, (#>=)/2, (#<==>)/2, (#==>)/2, (#=)/2, sum/3, chain/2, labeling/2, (#\)/1, (#\/)/2, (#\)/2, (#/\)/2, (#>)/2, (#<)/2, (#\=)/2,
		fd_var/1
	]).

	:- public(holds_prop/1).
	holds_prop(Fluents) :-
		forall(member(Fluent, Fluents),::holds(Fluent, Fluents)).

	quick_check(holds_prop, holds_prop(+non_empty_list(fluent))).

	test(breeze_percept_present, true(( BreezeAtom = breeze ))) :- 
		test_env::tiny_pit(S),
		wwpercept<<breeze_percept(S, [], [BreezeAtom]).

	test(breeze_percept_not_present) :- 
		test_env::tiny_no_pit(S),
		wwpercept<<breeze_percept(S, [], []).

	test(stench_percept_present) :-
		test_env::mini_one_w(S),
		wwpercept<<stench_percept(S, [], [stench]).

	test(stench_percept_not_present) :-
		test_env::mini_no_w(S),
		wwpercept<<stench_percept(S, [], []).
	
	test(glitter_percept_present) :-
		test_env::tiny_gold(S),
		wwpercept<<glitter_percept(S, [], [glitter]).
	
	test(glitter_percept_not_present) :-
		test_env::tiny_no_pit(S),
		wwpercept<<glitter_percept(S, [], []).

	test(scream_percept_present) :-
		test_env::mini_one_w(S),
		shoot(S)::effect(S1),
		wwpercept<<scream_percept(S1,S,[],[scream]).

	test(scream_percept_not_present) :-
		test_env::mini_no_w(S),
		shoot(S)::effect(S1),
		wwpercept<<scream_percept(S1,S,[],[]).

	test(bump_percep_present) :-
		test_env::mini_no_w_facingsouth(S),
		forward(S)::effect(S1),
		wwpercept<<bump_percept(forward,S1, S, [], [bump]).

	test(bump_percept_not_present) :-
		test_env::mini_no_w(S),
		forward(S)::effect(S1),
		wwpercept<<bump_percept(forward,S1, S, [], []).

	test(find_closest_wumpus_north) :-
		test_env::mini2(S),
		S::in_direction(1, wwplace(1,2)).

	test(find_closest_wumpus_east) :-
		test_env::mini2_east(S),
		S::in_direction(1,wwplace(2,1)).

	test(find_closest_wumpus_south) :-
		test_env::mini2_south(S),
		S::in_direction(1, wwplace(1,2)).

	test(find_closest_wumpus_west) :-
		test_env::mini2_west(S),
		S::in_direction(1, wwplace(2,1)).

	test(find_closest_sandwiched) :-
		test_env::mini2_sand(S),
		S::in_direction(2, wwplace(2,3)).
:- end_object.