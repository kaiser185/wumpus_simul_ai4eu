/*******************************************************************************
Author: Jacques Robin, Camilo Correa Restrepo, 2021.

Action specification for the WUMPUS Simulator

This file contains all the formalizations of the actions that can be done in
the simulator. They include their precondition and effect calculation 
predicates, as well as a series of auxiliary objects.

version: 0.1
*******************************************************************************/
:- object(direction).
	:- public([right/1,left/1]).
:- end_object.

:- object(north, extends(direction)).
	right(east).
	left(west).
:- end_object.

:- object(east, extends(direction)).
	right(south).
	left(north).
:- end_object.

:- object(south, extends(direction)).
	right(west).
	left(east).
:- end_object.

:- object(west, extends(direction)).
	right(north).
	left(south).
:- end_object.


:- object(action(_WWSIMSTATE_)).
	:- public(precond/0).
	:- public(effect/1).
:- end_object.

:- object(forward(_WWSIMSTATE_), extends(action(_WWSIMSTATE_))).
	:- use_module(dif, [dif/2]).

	precond.

	effect(_WWSIMSTATE_) :- 
		_WWSIMSTATE_::(
			next_room(NewRoom)
		),
		NewRoom = wall(_,_),
		logtalk::print_message(help, core, @'Move Cond 1'),
		!.
	%%FOR NOW THE DEATH CONDITIONS ARE DIRECT EFFECTS
	effect(NewState) :- 
		_WWSIMSTATE_::(holds(at(agent,Position)),next_room(NewRoom)),
		NewRoom = pit(_,_), 
		\+ (
			_WWSIMSTATE_::holds(at(wumpus(_),NewRoom))
		),
		_WWSIMSTATE_::update_fluents([at(agent,NewRoom)],[alive(agent),at(agent,Position)], NewState),
		logtalk::print_message(help, core, @'Move Cond 2'),
		!.

	effect(NewState) :- 
		_WWSIMSTATE_::(
			holds(at(agent,Position)),
			next_room(NewRoom), 
			holds(at(wumpus(Id),NewRoom)), 
			holds(alive(wumpus(Id)))
		),
		_WWSIMSTATE_::update_fluents([at(agent,NewRoom)],[alive(agent),at(agent,Position)], NewState),
		logtalk::print_message(help, core, @'Move Cond 3'),
		!.
	%%FOR NOW THE DEATH CONDITIONS ARE DIRECT EFFECTS
	
	effect(NewState) :- 
		_WWSIMSTATE_::(
			holds(at(agent,Position)),
			next_room(NewRoom),
			update_fluents([at(agent,NewRoom)],[at(agent,Position)], NewState)
		), 
		logtalk::print_message(help, core, @'Move Cond 4'),!.
		

:- end_object.

:- object(left(_WWSIMSTATE_), extends(action(_WWSIMSTATE_))).
	
	precond.

	%%Try to check if this could be purely declarative in SWI
	effect(NewState) :-
		_WWSIMSTATE_::holds(agent_dir(Direction)),
		%If we take this to be a module identifier, the behaviour is the same.
		% a far more declarative alternative would be to write only have the
		% direction object, and have a left/2 and right/2 rule, that would be 
		% something like, direction::left(north, west), where left(north,west)
		% would be a fact, and if this were SWI then this would still make sense, and
		% in both cases, this would probably mean that declarativity would be 
		% retained far better.
		Direction::left(NewDir),
		_WWSIMSTATE_::update_fluents([agent_dir(NewDir)],[agent_dir(Direction)], NewState), !.
:- end_object.

:- object(right(_WWSIMSTATE_), extends(action(_WWSIMSTATE_))).
	
	precond.

	effect(NewState) :-
		_WWSIMSTATE_::holds(agent_dir(Direction)),
		Direction::right(NewDir),
		_WWSIMSTATE_::update_fluents([agent_dir(NewDir)],[agent_dir(Direction)], NewState), !.

:- end_object.

:- object(grab(_WWSIMSTATE_), extends(action(_WWSIMSTATE_))).
	:- use_module(clpfd, [
		op(760, xfy, #<==>), op(750, xfy, #==>), op(700, xfx, #=), op(700, xfx, #>=), op(700, xfx, #=<), op(700, xfx, in), op(450, xfx, ..),
		op(740, yfx, #\/), op(730, yfx, #\), op(720, yfx, #/\), op(710,  fy, #\), op(700, xfx, ins), op(700, xfx, #>), op(700, xfx, #<), op(700, xfx, #\=),
		(=<)/2, (ins)/2, (in)/2, (#>=)/2, (#<==>)/2, (#==>)/2, (#=)/2, sum/3, chain/2, labeling/2, (#\)/1, (#\/)/2, (#\)/2, (#/\)/2, (#>)/2, (#<)/2, (#\=)/2
	]).
	precond :-
		_WWSIMSTATE_::(holds(at(agent,Loc)),holds(at(gold,Loc))).

	effect(NewState) :-
		%%%Needs to be updated
		_WWSIMSTATE_::(
			holds(at(agent,Loc)),
			holds(at(gold,Loc)),
			holds(carries(agent, gold, N))
		),
		N1 #= N + 1,
		_WWSIMSTATE_::update_fluents(
			[carries(agent, gold, N1)],
			[at(gold, Loc)], 
			NewState
		), !.

	effect(NewState) :-
		%%%Needs to be updated
		_WWSIMSTATE_::(
			holds(at(agent,Loc)),
			holds(at(gold,Loc))
		),
		\+ ( _WWSIMSTATE_::holds(carries(agent, gold, _)) ),
		_WWSIMSTATE_::update_fluents([carries(agent, gold, 1)],[at(gold, Loc)], NewState), !.
:- end_object.

:- object(shoot(_WWSIMSTATE_), extends(action(_WWSIMSTATE_))).
	:- use_module(clpfd, [
		op(760, xfy, #<==>), op(750, xfy, #==>), op(700, xfx, #=), op(700, xfx, #>=), op(700, xfx, #=<), op(700, xfx, in), op(450, xfx, ..),
		op(740, yfx, #\/), op(730, yfx, #\), op(720, yfx, #/\), op(710,  fy, #\), op(700, xfx, ins), op(700, xfx, #>), op(700, xfx, #<), op(700, xfx, #\=),
		(=<)/2, (ins)/2, (in)/2, (#>=)/2, (#<==>)/2, (#==>)/2, (#=)/2, sum/3, chain/2, labeling/2, (#\)/1, (#\/)/2, (#\)/2, (#/\)/2, (#>)/2, (#<)/2, (#\=)/2
	]).
	precond :-
		_WWSIMSTATE_::(holds(carries(agent, arrow, N))), N #>=1, !.

	effect(NewState) :-
		_WWSIMSTATE_::(
			holds(carries(agent, arrow, N)), 
			in_direction(WumpusId, _)
		),
		N #> 1 #/\ N1 #= N - 1,
		_WWSIMSTATE_::update_fluents([/* dead(wumpus), */ carries(agent, arrow, N1)],[alive(wumpus(WumpusId)), carries(agent, arrow, N)], NewState), 
		logtalk::print_message(help, core, @'Shot and hit 1'), !.

	effect(NewState) :-
		_WWSIMSTATE_::(
			holds(carries(agent, arrow, N)), 
			in_direction(WumpusId, _)
		),
		N #= 1,
		_WWSIMSTATE_::update_fluents([/* dead(wumpus) */],[alive(wumpus(WumpusId)), carries(agent, arrow, N)], NewState),
		logtalk::print_message(help, core, @'Shot and hit 2'), !.

	effect(NewState) :-
		_WWSIMSTATE_::holds(carries(agent, arrow, N)),
		N #> 1 #/\ N1 #= N - 1,
		_WWSIMSTATE_::update_fluents([carries(agent, arrow, N1)],[carries(agent, arrow, N)], NewState), 
		logtalk::print_message(help, core, @'Shot and no hit 1'),!.
	
	effect(NewState) :-
		_WWSIMSTATE_::holds(carries(agent, arrow, N)),
		N #= 1,
		_WWSIMSTATE_::update_fluents([],[carries(agent, arrow, N)], NewState), 
		logtalk::print_message(help, core, @'Shot and no hit 2'), !.
:- end_object.

:- object(climb(_WWSIMSTATE_), extends(action(_WWSIMSTATE_))).
	precond :-
		_WWSIMSTATE_::holds(at(agent, exit(1,1))).

	effect(NewState) :-
		logtalk::print_message(help, core, @'I got here'),
		_WWSIMSTATE_::(holds(at(agent, exit(1,1))), update_fluents([out(agent)],[at(agent, exit(1,1))], NewState)),
		logtalk::print_message(help, core, @'I got here 2').
:- end_object.
