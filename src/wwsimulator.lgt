/*******************************************************************************
Author: Jacques Robin, Camilo Correa Restrepo, 2021.

Simulator specification for WUMPUS

This implements the simulator's top level object, i.e. that which is directly interacted
with by the server. This takes care (for now) of world generation from the
configuration, of tracking a simultion session's progression, and of doing the
high level handling of the actions.

version: 0.1
*******************************************************************************/
:- object(wwsimulator, implements([monitoring, wwsimulatorp])).

	:- initialization(define_events(before, wwsimulator, init(_), _, wwsimulator)).
	:- use_module(clpfd, [
		op(760, xfy, #<==>), op(750, xfy, #==>), op(700, xfx, #=), op(700, xfx, #>=), op(700, xfx, #=<), op(700, xfx, in), op(450, xfx, ..),
		op(740, yfx, #\/), op(730, yfx, #\), op(720, yfx, #/\), op(710,  fy, #\), op(700, xfx, ins), op(700, xfx, #>), op(700, xfx, #<), op(700, xfx, #\=),
		(=<)/2, (ins)/2, (in)/2, (#>=)/2, (#<==>)/2, (#==>)/2, (#=)/2, sum/3, chain/2, labeling/2, (#\)/1, (#\/)/2, (#\)/2, (#/\)/2, (#>)/2, (#<)/2, (#\=)/2
	]).
	:- use_module(lists, [length/2, member/2, append/2, select/3]).
	:- use_module(dif, [dif/2]).

	before(wwsimulator, init(WWConfig, _), _) :-
		{http_log:http_log('Received data ~w \n', [coucou])},
		type::check(wwconfig, WWConfig).


	%%Taken and adapted from the flyweight programming pattern%%%%
	:- public(simulation/3).
	%%Determine the latest simulation for the given uuid
	%%uses the same trick as in_direction/2
	%%it finds them all (maybe too expensive?)
	%%and checks that it's the highest tick
	%%I think this simply won't scale well...
	simulation(UUID, SIMState, TickState) :-
		findall((SIM-Tick), simulation_(UUID, SIM, Tick), Sims),
		select((SIMState-TickState),Sims,SimsP),
		forall(member((_-TickP), SimsP), TickP #< TickState).
	
	%%Add a new entry for the simulation
	:- public(update_simulation/4).
	update_simulation(UUID, CurrentState, NewState, Tick1) :-
		%retractall(simulation_(UUID, CurrentState)),
		::simulation(UUID, CurrentState, Tick),
		Tick1 #= Tick + 1,
		assertz(simulation_(UUID, NewState, Tick1)).
	
	%%Create a new simulation, by first generating a new random user uuid
	%%and then asserting the new world state
	:- public(create_simulation_session/3).
	create_simulation_session(WWConfig, UUID, WWState) :-
		%retractall(simulation_(Brand, _)),
		uuid::uuid_v4(UUID),
		::init(WWConfig, WWState),
		assertz(simulation_(UUID, WWState, 1)).
	
	%% Create a simulation with the fixed world from AIMA but a unique id
	:- public(create_debug_session/2).
	create_debug_session(UUID, WWState) :-
		%retractall(simulation_(Brand, _)),
		uuid::uuid_v4(UUID),
		test_env::aima_case_default(WWState),
		assertz(simulation_(UUID, WWState, 1)).

	%% Remove all the facts from the given config
	:- public(halt_sim/1).
	halt_sim(UUID) :-
		retractall(simulation_(UUID, _, _)).
		
	:- private(simulation_/3).
	:- dynamic(simulation_/3).
	%%%%%%%%%%

	:- public(do/3).
	%There are no preconditions for left/right/fwd
	/* do(Action, WWState0, WWState) :-
		Action = climb,
		DO =..[Action, WWState0],
		DO::(precond, effect(WWState)). */
		%wwpercept::gen_percept(WWState, WWState0, Percepts)
	%Once an action has been received
	%% assemble an action object term
	%% like forward(WWSTATE) and then call the
	%% precondition predicates
	%% if it succeeds then we get a new state
	%% otherwise nothing happens.
	do(Action, WWState0, WWState) :-
		DO =..[Action, WWState0],
		DO::(precond, effect(WWState)).
	do(Action, WWState0, WWState0) :-
		DO =..[Action, WWState0],
		\+ DO::precond.
		%wwpercept::gen_percept(WWState0, Percepts).
	
	%% Check that we are not in an end state
	:- public(can_continue/1).
	can_continue(WWState) :-
		WWState::holds(alive(agent)),
		\+ WWState::holds(out(agent)).
	%% Check whether the agent has won 
	:- public(win/1).
	win(WWState) :-
		WWState::(
			holds(out(agent)), 
			holds(carries(agent, gold, _))
		).
	%% Check whether the simulation has finished.
	:- public(finished/1).
	finished(WWState) :-
		WWState::holds(out(agent)).
	/* do(forward, WWState0, WWState) :-
		forward(WWState0)::effect(WWState).
	do(left, WWState0, WWState) :-
		left(WWState0)::effect(WWState).
	do(right, WWState0, WWState) :-
		right(WWState0)::effect(WWState).
	do(grab, WWState0, WWState) :-
		grab(WWState0)::precond,
		grab(WWState0)::effect(WWState).
	do(grab, WWState0, _) :-
		\+ grab(WWState0)::precond,
		throw(illegal_action).
	do(shoot, WWState0, WWState) :-
		shoot(WWState0)::precond,
		shoot(WWState0)::effect(WWState).
	do(shoot, WWState0, _) :-
		\+ shoot(WWState0)::precond,
		throw(illegal_action). */

	init(WWConfig, wwstate(Fluents, Eternals)) :-
		init_eternals(WWConfig, Eternals),
		init_fluents(WWConfig, Eternals, Fluents).
	
	%% Initialize all the static world properties (basically rooms for now)
	:- private(init_eternals/2).
	init_eternals(WWConfig, Eternals) :-
		%% The config involved in this is
		%% height, width, wumpus density, gold density.
		WWConfig::(height(Height), width(Width), pit_density(PitDen)),
		init_places(Height, Width, PitDen, RoomEternals),
		Eternals = RoomEternals.
		%% through the type checker we know that H and W are
		%% of the right type.
	
	%?- wwsimulator<<init_places(4,4,R), write(R).
	:- private(init_places/4).
	init_places(Height, Width, PitDen, Rooms) :-
		%%build a list of places and their positions
		(WorldSize #= (Height + 2) * (Width + 2) #/\
		LimXInf #= 0 #/\ LimYInf #= 0 #/\ 
		LimXSup #= Width + 1 #/\ LimYSup #= Height + 1),
		%%calculate all the world limits and the amount of elements in the list of world properties
		length(Rooms, WorldSize),
		%Rooms = [wall(-1,-1)|_],
		%% iteratively build the list
		%% here we need a fold because we're building the list so that it covers in order
		%% every row of the world
		meta::fold_left(
			{
				LimXInf,LimXSup, 
				LimYInf, LimYSup,PitDen
			}/[
				[X0,Y0], Room, [X1,Y1]
			]>>(
				%% create the room as a term depending on what type it ends up being
				create_room(
					X0, LimXInf, LimXSup, 
					Y0, LimYInf, LimYSup, 
					PitDen, Room
				),
				%% Since we need to cover every row with x,y coords,
				%% we calculate the next one based on the last one
				%% in this case if we're at the x limit
				%% we restart in the next row above.
				calc_coords(X0, Y0, LimXSup, X1, Y1)
			), 
			%% We don't care about the final accumulator
			%% maybe this is a job for dcgs?
			[LimXInf,LimYInf], Rooms, _
		).
	
	%% here we basically determine what term a room will be based on
	%% its coordinates
	%% if it is 1,1 it is always the exit
	%% if it is at any limit (either top, bottow, left, right) it must be a wall
	%% so if the world is 4x4 we generate a from 0,0 to 5,5 with all those that have
	%% 0 or 5 as walls
	%% then we do a random check to see if we pass the pit check with its given probability
	%% and if we do its a pit, otherwise it's a normal room.
	:- private(create_room/8).
	create_room(1, _, _, 1, _, _, _, exit(1,1)) :- !.
	create_room(X, X, _, Y, _, _, _, wall(X,Y)) :- !.
	create_room(X, _, X, Y, _, _, _, wall(X,Y)) :- !.
	create_room(X, _, _, Y, Y, _, _, wall(X,Y)) :- !.
	create_room(X, _, _, Y, _, Y, _, wall(X,Y)) :- !.
	create_room(X, _, _, Y, _, _, PitDen, pit(X,Y)) :- 
		fast_random::maybe(PitDen), !.
	create_room(X, _, _, Y, _, _, _, wwplace(X,Y)) :- !.

	%% This predicate allows us to determine the next coordinate 
	%% so that we can build a list whose elements all have the right x,y as explained above
	:- private(calc_coords/5).
	calc_coords(X0, Y0, LimXSup, X1, Y1) :-
		(( X0 #= LimXSup) #==> (X1 #= 0 #/\ Y1 #= Y0 + 1) ) #/\
		(( X0 #\=  LimXSup) #==> (X1 #= X0 +1 #/\ Y1 #= Y0)).

	:- private(init_fluents/3).
	init_fluents(WWConfig, Eternals, Fluents) :-
		WWConfig::(
			gold_density(GoldDen), 
			wumpus_density(WumpusDen), 
			arrow_num(AN)
		),
		Fluents0 = [
			at(agent, exit(1,1)),
			agent_dir(north), 
			/* at(wumpus, RandomRoomWumpus),
			at(gold, RandomRoomGold), */
			carries(agent, arrow, AN),
			alive(agent),
			alive(wumpus)
		],
		meta::exclude([Term]>>(
			\+ \+ (Term = wall(_,_)); 
			\+ \+ (Term = exit(_,_))
		), Eternals, EternalsClean),
		init_wumpus_fluents(EternalsClean, WumpusDen, WumpusFluents),
		init_gold_fluents(EternalsClean, GoldDen, GoldFluents),
		append([WumpusFluents, GoldFluents, Fluents0], Fluents).
		/* fast_random::member(RandomRoomWumpus, EternalsClean),
		fast_random::member(RandomRoomGold, EternalsClean). */
		%fast_random::between(1,Height,RandomY),
		%format('X ~w, Y ~w', [RandomX, RandomY]),
		%(RandomX #= 1 #==> RandomY #\= 1) #/\ 
		%(RandomY #= 1 #==> RandomX #\= 1),
		%WPOS = wwplace(RandomX, RandomY).

	:- private(init_wumpus_fluents/3).
	init_wumpus_fluents(EternalsClean, WumpusDen, WumpusFluents) :-
		meta::fold_left({WumpusDen}/[Fs0, Room, Fs]>>(
			((fast_random::maybe(WumpusDen)) -> (
				length(Fs0,Len),
				Id #= (Len//2) + 1,
				Fs = [at(wumpus(Id),Room), alive(wumpus(Id))|Fs0]
			) ; (
				Fs = Fs0
			))	
		), [], EternalsClean, WumpusFluents).
	:- private(init_gold_fluents/3).
	init_gold_fluents(EternalsClean, GoldDen, GoldFluents) :-
		meta::fold_left({GoldDen}/[Fs0, Room, Fs]>>(
			((fast_random::maybe(GoldDen)) -> (
				Fs = [at(gold,Room)|Fs0]
			) ; (
				Fs = Fs0
			))	
		), [], EternalsClean, GoldFluents).
	%:- private(do/3).

:- end_object.
