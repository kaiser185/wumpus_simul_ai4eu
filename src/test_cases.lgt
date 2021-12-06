/*******************************************************************************
Author: Jacques Robin, Camilo Correa Restrepo, 2021.

Test case bank for the wumpus world

This file contains a set of simulation states that are either used for debugging
pruposes or for automated test. Their purpose is to avoid the random generation
of environments to easily create tests with known effects.

version: 0.1
*******************************************************************************/
:- object(test_env).
:- use_module(lists, [member/2]).
:- public([
	aima_case_default/1,
	aima_case_at_pos/3,
	mini/1,
	mini_one_w/1,
	mini_no_w/1,
	mini_no_w_facingsouth/1,
	mini_pit/1,
	tiny_pit/1,
	tiny_gold/1,
	tiny_gold_already/1,
	tiny_no_pit/1,
	mini2/1,
	mini2_east/1,
	mini2_west/1,
	mini2_south/1,
	mini2_sand/1
]).


aima_case_default(S) :-
	S = wwstate(
		[
			at(agent,exit(1,1)),
			agent_dir(north),
			at(wumpus(1),wwplace(1,3)),
			at(gold,wwplace(2,3)),
			carries(agent,arrow,1),
			alive(agent),
			alive(wumpus(1))
		],[
			wall(0,0),wall(1,0),wall(2,0),wall(3,0),wall(4,0),wall(5,0),
			wall(0,1),exit(1,1),wwplace(2,1),pit(3,1),wwplace(4,1),wall(5,1),
			wall(0,2),wwplace(1,2),wwplace(2,2),wwplace(3,2),wwplace(4,2),wall(5,2),
			wall(0,3),wwplace(1,3),wwplace(2,3),pit(3,3),wwplace(4,3),wall(5,3),
			wall(0,4),wwplace(1,4),wwplace(2,4),wwplace(3,4),pit(4,4),wall(5,4),
			wall(0,5),wall(1,5),wall(2,5),wall(3,5),wall(4,5),wall(5,5)
		]
	).

aima_case_at_pos(X,Y, S) :-
	Places = [
		wall(0,0),wall(1,0),wall(2,0),wall(3,0),wall(4,0),wall(5,0),
		wall(0,1),exit(1,1),wwplace(2,1),pit(3,1),wwplace(4,1),wall(5,1),
		wall(0,2),wwplace(1,2),wwplace(2,2),wwplace(3,2),wwplace(4,2),wall(5,2),
		wall(0,3),wwplace(1,3),wwplace(2,3),pit(3,3),wwplace(4,3),wall(5,3),
		wall(0,4),wwplace(1,4),wwplace(2,4),wwplace(3,4),pit(4,4),wall(5,4),
		wall(0,5),wall(1,5),wall(2,5),wall(3,5),wall(4,5),wall(5,5)
	],
	member(Elem, Places),
	arg(1, Elem, X), arg(2, Elem, Y),
	S = wwstate(
		[
			at(agent,Elem),
			agent_dir(north),
			at(wumpus(1),wwplace(1,3)),
			at(gold,wwplace(2,3)),
			carries(agent,arrow,1),
			alive(agent),
			alive(wumpus(1))
		],Places
	).

mini(S) :-
	S = wwstate(
		[
			at(agent,exit(1,1)),
			agent_dir(north),
			at(wumpus(1),wwplace(1,2)),
			at(wumpus(2),wwplace(2,2)),
			%at(gold,wwplace(2,3)),
			carries(agent,arrow,1),
			alive(agent),
			alive(wumpus(1)),
			alive(wumpus(2))
		],[
			wall(0,0),wall(1,0),wall(2,0),wall(3,0),
			wall(0,1),exit(1,1),wwplace(2,1),wall(3,1),
			wall(0,2),wwplace(1,2),wwplace(2,2),wall(3,2),
			wall(0,3),wall(1,3),wall(2,3),wall(3,3)
		]
	).

mini_one_w(S) :-
	S = wwstate(
		[
			at(agent,exit(1,1)),
			agent_dir(north),
			at(wumpus(1),wwplace(1,2)),
			%at(wumpus(2),wwplace(2,2)),
			%at(gold,wwplace(2,3)),
			carries(agent,arrow,1),
			alive(agent),
			alive(wumpus(1))
			%alive(wumpus(2))
		],[
			wall(0,0),wall(1,0),wall(2,0),wall(3,0),
			wall(0,1),exit(1,1),wwplace(2,1),wall(3,1),
			wall(0,2),wwplace(1,2),wwplace(2,2),wall(3,2),
			wall(0,3),wall(1,3),wall(2,3),wall(3,3)
		]
	).

mini_no_w(S) :-
	S = wwstate(
		[
			at(agent,exit(1,1)),
			agent_dir(north),
			%at(wumpus(1),wwplace(1,2)),
			%at(wumpus(2),wwplace(2,2)),
			%at(gold,wwplace(2,3)),
			carries(agent,arrow,1),
			alive(agent)
			%alive(wumpus(1))
			%alive(wumpus(2))
		],[
			wall(0,0),wall(1,0),wall(2,0),wall(3,0),
			wall(0,1),exit(1,1),wwplace(2,1),wall(3,1),
			wall(0,2),wwplace(1,2),wwplace(2,2),wall(3,2),
			wall(0,3),wall(1,3),wall(2,3),wall(3,3)
		]
	).

	mini_no_w_facingsouth(S) :-
		S = wwstate(
			[
				at(agent,exit(1,1)),
				agent_dir(south),
				%at(wumpus(1),wwplace(1,2)),
				%at(wumpus(2),wwplace(2,2)),
				%at(gold,wwplace(2,3)),
				carries(agent,arrow,1),
				alive(agent)
				%alive(wumpus(1))
				%alive(wumpus(2))
			],[
				wall(0,0),wall(1,0),wall(2,0),wall(3,0),
				wall(0,1),exit(1,1),wwplace(2,1),wall(3,1),
				wall(0,2),wwplace(1,2),wwplace(2,2),wall(3,2),
				wall(0,3),wall(1,3),wall(2,3),wall(3,3)
			]
		).

mini_pit(S) :-
	S = wwstate(
		[
			at(agent,exit(1,1)),
			agent_dir(north),
			at(wumpus(1),pit(1,2)),
			at(wumpus(2),pit(2,2)),
			%at(gold,wwplace(2,3)),
			carries(agent,arrow,1),
			alive(agent),
			alive(wumpus(1)),
			alive(wumpus(2))
		],[
			wall(0,0),wall(1,0),wall(2,0),wall(3,0),
			wall(0,1),exit(1,1),pit(2,1),wall(3,1),
			wall(0,2),pit(1,2),pit(2,2),wall(3,2),
			wall(0,3),wall(1,3),wall(2,3),wall(3,3)
		]
	).

tiny_pit(S) :-
	S = wwstate(
		[
			at(agent,exit(1,1)),
			agent_dir(north),
			%at(wumpus(1),pit(1,2)),
			%at(wumpus(2),pit(2,2)),
			%at(gold,wwplace(2,3)),
			carries(agent,arrow,1),
			alive(agent)
			%alive(wumpus(1)),
			%alive(wumpus(2))
		],[
			wall(0,0),wall(1,0),wall(2,0),wall(3,0),
			wall(0,1),exit(1,1),pit(2,1),wall(3,1),
			wall(0,2),wwplace(1,2),wwplace(2,2),wall(3,2),
			wall(0,3),wall(1,3),wall(2,3),wall(3,3)
		]
	).

	tiny_gold(S) :-
		S = wwstate(
			[
				at(agent,exit(1,1)),
				agent_dir(north),
				%at(wumpus(1),pit(1,2)),
				%at(wumpus(2),pit(2,2)),
				at(gold,exit(1,1)),
				carries(agent,arrow,1),
				alive(agent)
				%alive(wumpus(1)),
				%alive(wumpus(2))
			],[
				wall(0,0),wall(1,0),wall(2,0),wall(3,0),
				wall(0,1),exit(1,1),wwplace(2,1),wall(3,1),
				wall(0,2),wwplace(1,2),wwplace(2,2),wall(3,2),
				wall(0,3),wall(1,3),wall(2,3),wall(3,3)
			]
		).
	tiny_gold_already(S) :-
		S = wwstate(
			[
				at(agent,exit(1,1)),
				agent_dir(north),
				%at(wumpus(1),pit(1,2)),
				%at(wumpus(2),pit(2,2)),
				at(gold,exit(1,1)),
				carries(agent,arrow,1),
				carries(agent,gold,1),
				alive(agent)
				%alive(wumpus(1)),
				%alive(wumpus(2))
			],[
				wall(0,0),wall(1,0),wall(2,0),wall(3,0),
				wall(0,1),exit(1,1),wwplace(2,1),wall(3,1),
				wall(0,2),wwplace(1,2),wwplace(2,2),wall(3,2),
				wall(0,3),wall(1,3),wall(2,3),wall(3,3)
			]
		).

tiny_no_pit(S) :-
	S = wwstate(
		[
			at(agent,exit(1,1)),
			agent_dir(north),
			%at(wumpus(1),pit(1,2)),
			%at(wumpus(2),pit(2,2)),
			%at(gold,wwplace(2,3)),
			carries(agent,arrow,1),
			alive(agent)
			%alive(wumpus(1)),
			%alive(wumpus(2))
		],[
			wall(0,0),wall(1,0),wall(2,0),wall(3,0),
			wall(0,1),exit(1,1),wwplace(2,1),wall(3,1),
			wall(0,2),wwplace(1,2),wwplace(2,2),wall(3,2),
			wall(0,3),wall(1,3),wall(2,3),wall(3,3)
		]
	).

mini2(S) :-
	S = wwstate(
		[
			at(agent,exit(1,1)),
			agent_dir(north),
			at(wumpus(1),wwplace(1,2)),
			at(wumpus(2),wwplace(1,3)),
			at(wumpus(3),wwplace(2,2)),
			%at(gold,wwplace(2,3)),
			carries(agent,arrow,2),
			alive(agent),
			alive(wumpus(1)),
			alive(wumpus(2)),
			alive(wumpus(3))
		],[
			wall(0,0),wall(1,0),wall(2,0),wall(3,0),wall(4,0),
			wall(0,1),exit(1,1),wwplace(2,1),wwplace(3,1),wall(4,1),
			wall(0,2),wwplace(1,2),wwplace(2,2),wwplace(3,2),wall(4,2),
			wall(0,3),wwplace(1,3),wwplace(2,3),wwplace(3,3),wall(4,3),
			wall(0,4),wall(1,4),wall(2,4),wall(3,4),wall(4,4)
		]
	).

mini2_east(S) :-
	S = wwstate(
		[
			at(agent,exit(1,1)),
			agent_dir(east),
			at(wumpus(1),wwplace(2,1)),
			at(wumpus(2),wwplace(3,1)),
			at(wumpus(3),wwplace(2,2)),
			%at(gold,wwplace(2,3)),
			carries(agent,arrow,2),
			alive(agent),
			alive(wumpus(1)),
			alive(wumpus(2)),
			alive(wumpus(3))
		],[
			wall(0,0),wall(1,0),wall(2,0),wall(3,0),wall(4,0),
			wall(0,1),exit(1,1),wwplace(2,1),wwplace(3,1),wall(4,1),
			wall(0,2),wwplace(1,2),wwplace(2,2),wwplace(3,2),wall(4,2),
			wall(0,3),wwplace(1,3),wwplace(2,3),wwplace(3,3),wall(4,3),
			wall(0,4),wall(1,4),wall(2,4),wall(3,4),wall(4,4)
		]
	).


mini2_west(S) :-
	S = wwstate(
		[
			at(agent,exit(3,1)),
			agent_dir(west),
			at(wumpus(1),wwplace(2,1)),
			at(wumpus(2),wwplace(1,1)),
			at(wumpus(3),wwplace(2,2)),
			%at(gold,wwplace(2,3)),
			carries(agent,arrow,2),
			alive(agent),
			alive(wumpus(1)),
			alive(wumpus(2)),
			alive(wumpus(3))
		],[
			wall(0,0),wall(1,0),wall(2,0),wall(3,0),wall(4,0),
			wall(0,1),exit(1,1),wwplace(2,1),wwplace(3,1),wall(4,1),
			wall(0,2),wwplace(1,2),wwplace(2,2),wwplace(3,2),wall(4,2),
			wall(0,3),wwplace(1,3),wwplace(2,3),wwplace(3,3),wall(4,3),
			wall(0,4),wall(1,4),wall(2,4),wall(3,4),wall(4,4)
		]
	).


mini2_south(S) :-
	S = wwstate(
		[
			at(agent,exit(1,3)),
			agent_dir(south),
			at(wumpus(1),wwplace(1,2)),
			at(wumpus(2),wwplace(1,1)),
			at(wumpus(3),wwplace(2,2)),
			%at(gold,wwplace(2,3)),
			carries(agent,arrow,2),
			alive(agent),
			alive(wumpus(1)),
			alive(wumpus(2)),
			alive(wumpus(3))
		],[
			wall(0,0),wall(1,0),wall(2,0),wall(3,0),wall(4,0),
			wall(0,1),exit(1,1),wwplace(2,1),wwplace(3,1),wall(4,1),
			wall(0,2),wwplace(1,2),wwplace(2,2),wwplace(3,2),wall(4,2),
			wall(0,3),wwplace(1,3),wwplace(2,3),wwplace(3,3),wall(4,3),
			wall(0,4),wall(1,4),wall(2,4),wall(3,4),wall(4,4)
		]
	).

mini2_sand(S) :-
	S = wwstate(
		[
			at(agent,wwplace(2,2)),
			agent_dir(north),
			at(wumpus(1),wwplace(2,1)),
			at(wumpus(2),wwplace(2,3)),
			%at(wumpus(3),wwplace(2,2)),
			%at(gold,wwplace(2,3)),
			carries(agent,arrow,2),
			alive(agent),
			alive(wumpus(1)),
			alive(wumpus(2))
			%alive(wumpus(3))
		],[
			wall(0,0),wall(1,0),wall(2,0),wall(3,0),wall(4,0),
			wall(0,1),exit(1,1),wwplace(2,1),wwplace(3,1),wall(4,1),
			wall(0,2),wwplace(1,2),wwplace(2,2),wwplace(3,2),wall(4,2),
			wall(0,3),wwplace(1,3),wwplace(2,3),wwplace(3,3),wall(4,3),
			wall(0,4),wall(1,4),wall(2,4),wall(3,4),wall(4,4)
		]
	).

:- end_object.