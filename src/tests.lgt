/*******************************************************************************
Author: Jacques Robin, Camilo Correa Restrepo, 2021.

WUMPUS tests for C4IIoT

This file contains all unit tests for WUMPUS

version: 0.1
*******************************************************************************/
:- object(tests, extends(lgtunit)).

	:- use_module(lists, [flatten/2, length/2]).
	:- use_module(clpfd, [
		op(760, xfy, #<==>), op(750, xfy, #==>), op(700, xfx, #=), op(700, xfx, #>=), op(700, xfx, #=<), op(700, xfx, in), op(450, xfx, ..),
		op(740, yfx, #\/), op(730, yfx, #\), op(720, yfx, #/\), op(710,  fy, #\), op(700, xfx, ins), op(700, xfx, #>), op(700, xfx, #<), op(700, xfx, #\=),
		(=<)/2, (ins)/2, (in)/2, (#>=)/2, (#<==>)/2, (#==>)/2, (#=)/2, sum/3, chain/2, labeling/2, (#\)/1, (#\/)/2, (#\)/2, (#/\)/2, (#>)/2, (#<)/2, (#\=)/2,
		fd_var/1
	]).

	test(breeze_percept_present) :- 
		user::tiny_pit(S),
		wwpercept<<breeze_percept(S, [], [breeze]).

	test(breeze_percept_not_present) :- 
		user::tiny_no_pit(S),
		wwpercept<<breeze_percept(S, [], []).

	test(stench_percept_present) :-
		user::mini_one_w(S),
		wwpercept<<stench_percept(S, [], [stench]).

	test(stench_percept_not_present) :-
		user::mini_no_w(S),
		wwpercept<<stench_percept(S, [], []).
	
	test(glitter_percept_present) :-
		user::tiny_gold(S),
		wwpercept<<glitter_percept(S, [], [glitter]).
	
	test(glitter_percept_not_present) :-
		user::tiny_no_pit(S),
		wwpercept<<glitter_percept(S, [], []).

	test(scream_percept_present) :-
		user::mini_one_w(S),
		shoot(S)::effect(S1),
		wwpercept<<scream_percept(S1,S,[],[scream]).

	test(scream_percept_not_present) :-
		user::mini_no_w(S),
		shoot(S)::effect(S1),
		wwpercept<<scream_percept(S1,S,[],[]).

	test(bump_percep_present) :-
		user::mini_no_w_facingsouth(S),
		forward(S)::effect(S1),
		wwpercept<<bump_percept(forward,S1, S, [], [bump]).

	test(bump_percept_not_present) :-
		user::mini_no_w(S),
		forward(S)::effect(S1),
		wwpercept<<bump_percept(forward,S1, S, [], []).

	test(find_closest_wumpus_north) :-
		user::mini2(S),
		S::in_direction(1, wwplace(1,2)).

	test(find_closest_wumpus_east) :-
		user::mini2_east(S),
		S::in_direction(1,wwplace(2,1)).

	test(find_closest_wumpus_south) :-
		user::mini2_south(S),
		S::in_direction(1, wwplace(1,2)).

	test(find_closest_wumpus_west) :-
		user::mini2_west(S),
		S::in_direction(1, wwplace(2,1)).

	test(find_closest_sandwiched) :-
		user::mini2_sand(S),
		S::in_direction(2, wwplace(2,3)).
:- end_object.