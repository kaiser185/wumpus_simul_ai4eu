:- encoding('UTF-8').
/*******************************************************************************
Author: Jacques Robin, Camilo Correa Restrepo, 2021.

World state specification for WUMPUS

Defines the simulator state parametric object. In charge of linking the simulation
with the special fluent calculus implementation, of handling state updates,
of determining certain dynamic world properties that haven't been reified,
and of pretty printing the state for debugging purposes.

version: 0.1
*******************************************************************************/
:- object(wwstate(_FluentState_, _WorldProperties_), 
	implements(wwstatep), imports(sflux)).

	:- use_module(clpfd, [
		op(760, xfy, #<==>), op(750, xfy, #==>), op(700, xfx, #=), op(700, xfx, #>=), op(700, xfx, #=<), op(700, xfx, in), op(450, xfx, ..),
		op(740, yfx, #\/), op(730, yfx, #\), op(720, yfx, #/\), op(710,  fy, #\), op(700, xfx, ins), op(700, xfx, #>), op(700, xfx, #<), op(700, xfx, #\=),
		(=<)/2, (ins)/2, (in)/2, (#>=)/2, (#<==>)/2, (#==>)/2, (#=)/2, sum/3, chain/2, labeling/2, (#\)/1, (#\/)/2, (#\)/2, (#/\)/2, (#>)/2, (#<)/2, (#\=)/2
	]).
	:- use_module(lists, [length/2, member/2, subtract/3, union/3, select/3, last/2]).
	
	%% Check state consistency
	%% To be fixed in next version
	consistent :-
		type::check(non_empty_list(feature), _FluentState_).
	
	%% Determine if a fluent holds in the current state (checks it through the fluent calculus implementation)
	holds(Fluent) :-
		::holds(Fluent, _FluentState_).

	/* update_fluents(
		bump, [], [], 
		wwstate(_FluentState_, _WorldProperties_)
	) :-
		%::update(_FluentState_, ThetaP, ThetaN, NewZ),
		gen_percept(bump, NewPercepts). */

	/* update_fluents(
		grab, [], [], 
		wwstate(_FluentState_, _WorldProperties_, NewPercepts)
	) :-
		::update(_FluentState_, ThetaP, ThetaN, NewZ),
		gen_percept(grab, NewPercepts). */
	
	%% Update the current state (updates it through the fluent calculus implementation)
	update_fluents(
		%% ThetaP -> Fluents to add
		%% ThetaN -> Fluents to remove
		ThetaP, ThetaN, 
		wwstate(NewZ,_WorldProperties_)
	) :-
		::update(_FluentState_, ThetaP, ThetaN, NewZ)
		/* wwstate(NewZ,_WorldProperties_, _)::gen_percept(Action, NewPercepts) */.

	%% Determine if a property holds in the current static world (checks it through the fluent calculus implementation)
	world_prop(Prop) :-
		::holds(Prop, _WorldProperties_).

	%% Return the list of fluents
	fluent_state(_FluentState_).

	%percepts(_Percepts_).
	
	%% Return the list of static world properties
	eternal_state(_WorldProperties_).
	
	%% Determine what room the agent will step into given his current direction
	%% This will necessarily have to satisfy one of the four conditions of direction
	%% which differentiates the cases.
	%% This basically calculates the next X,Y for the room and looks at
	%% the world properties (rooms) to determine which one it is
	%% Since the agent is always inside the maze (and can't go on the walls)
	%% This will always find a new room. Cuts are to avoid checking the other
	%% cases when the next room has been found.
	:- public(next_room/1).
	next_room(NRoom) :- 
		::holds(agent_dir(north)),
		%Direction = north,
		::holds(at(agent, Position)),
		Position::(x(X0),y(Y0)),
		::world_prop(NRoom),
		X #= X0 #/\ Y #= Y0 + 1,
		NRoom::(x(X),y(Y)), !.
	next_room(NRoom) :- 
		::holds(agent_dir(east)),
		%Direction = east,
		::holds(at(agent, Position)),
		Position::(x(X0),y(Y0)),
		::world_prop(NRoom),
		X #= X0 + 1 #/\ Y #= Y0,
		NRoom::(x(X),y(Y)), !.
	next_room(NRoom) :- 
		::holds(agent_dir(south)),
		%Direction = south,
		::holds(at(agent, Position)),
		Position::(x(X0),y(Y0)),
		::world_prop(NRoom),
		X #= X0 #/\ Y #= Y0 - 1,
		NRoom::(x(X),y(Y)), !.
	next_room(NRoom) :- 
		::holds(agent_dir(west)),
		%Direction = west,
		::holds(at(agent, Position)),
		Position::(x(X0),y(Y0)),
		::world_prop(NRoom),
		X #= X0 - 1 #/\ Y #= Y0,
		NRoom::(x(X),y(Y)), !.

	%% Currently deprecated
	:- public(in_direction/0).
	in_direction :-
		::holds(agent_dir(north)),
		::holds(at(agent, Position)),
		Position::(x(XP),y(YP)),
		::holds(at(wumpus(_), WPosition)),
		WPosition::(x(XW),y(YW)),
		XP #= XW #/\ YP #< YW,
		!.
	in_direction :-
		::holds(agent_dir(east)),
		::holds(at(agent, Position)),
		Position::(x(XP),y(YP)),
		::holds(at(wumpus, WPosition)),
		WPosition::(x(XW),y(YW)),
		XP #< XW #/\ YP #= YW,
		!.
	in_direction :-
		::holds(agent_dir(south)),
		::holds(at(agent, Position)),
		Position::(x(XP),y(YP)),
		::holds(at(wumpus, WPosition)),
		WPosition::(x(XW),y(YW)),
		XP #= XW #/\ YP #> YW,
		!.
	in_direction :-
		::holds(agent_dir(west)),
		::holds(at(agent, Position)),
		Position::(x(XP),y(YP)),
		::holds(at(wumpus, WPosition)),
		WPosition::(x(XW),y(YW)),
		XP #> XW #/\ YP #= YW,
		!.

	%% New version of the previous predicate
	%% Determines if there is a wumpus in the direction that the agent is facing
	%% and if there is, returns both the position and the id of that wumpus
	%% so that it's state can be updated after shooting (and to check if the shot)
	%% has an effect at all. The first clause is commented in detail but the idea
	%% is the same for all the others where what varies is the constraint on
	%% whether x or y must be either the same or resp bigger or smaller.
	:- public(in_direction/2).
	in_direction(WId, WPositionP) :-
		::holds(agent_dir(north)),
		%% agent position and coordinates
		::holds(at(agent, Position)),
		Position::(x(XP),y(YP)),
		%% Find all the wumpuses that are in the same direction (same X coordinate in this case since it is looking up)
		%% and that have a larger Y position (since it is looking up)
		findall(
			at(wumpus(Id), WPosition), 
			(
				::holds(at(wumpus(Id), WPosition)),
				WPosition::(x(XP),y(YW)),
				YP #< YW
			), 
			Ws
		),
		%% This is the equivalent of "there exists" one wumpus (and select tries all the possibilites of those found)
		%% this is to deal with which do we hit if there are several in the same straight line
		select(at(wumpus(WId), WPositionP), Ws, WsP),
		%% Determine the Y position of this wumpus
		WPositionP::y(YWP),
		%% and determine the distance between the wumpus and the player.
		D #= abs(YP - YWP),
		%% now comes the such that part,
		%% it must be the case that for all other wumpuses, they must be further away,
		%% i.e. the distance from them to the player must be larger than the distance
		%% calculated above
		forall(
			(
				member(at(wumpus(_), WPositionPP),WsP), 
				WPositionPP::y(YWPP)
			), (
				abs(YP - YWPP) #> D
			) 
		),
		%Closest = WPositionP,
		logtalk::print_message(help, core, @'Closest North'),
		%% Since these calculations are very expensive, we do a cut to (a) avoid leaving a choice point
		%% checking other possibilities, since the cases are always differentiated by agent's direction
		!.

	in_direction(WId, WPositionP) :-
		::holds(agent_dir(east)),
		::holds(at(agent, Position)),
		Position::(x(XP),y(YP)),
		findall(
			at(wumpus(Id), WPosition), 
			(
				::holds(at(wumpus(Id), WPosition)),
				WPosition::(x(XW),y(YP)),
				XP #< XW
			), 
			Ws
		),
		select(at(wumpus(WId), WPositionP), Ws, WsP),
		WPositionP::x(XWP),
		D #= abs(XP - XWP),
		forall(
			(
				member(at(wumpus(_), WPositionPP),WsP), 
				WPositionPP::x(XWPP)
			), (
				abs(XP - XWPP) #> D
			) 
		),
		%Closest = WPositionP,
		logtalk::print_message(help, core, @'Closest East'),
		!.

	in_direction(WId, WPositionP) :-
		::holds(agent_dir(south)),
		::holds(at(agent, Position)),
		Position::(x(XP),y(YP)),
		findall(
			at(wumpus(Id), WPosition), 
			(
				::holds(at(wumpus(Id), WPosition)),
				WPosition::(x(XP),y(YW)),
				YP #> YW
			), 
			Ws
		),
		select(at(wumpus(WId), WPositionP), Ws, WsP),
		WPositionP::y(YWP),
		D #= abs(YP - YWP),
		forall(
			(
				member(at(wumpus(_), WPositionPP),WsP), 
				WPositionPP::y(YWPP)
			), (
				abs(YP - YWPP) #> D
			) 
		),
		%Closest = WPositionP,
		logtalk::print_message(help, core, @'Closest South'),
		!.

	in_direction(WId, WPositionP) :-
		::holds(agent_dir(west)),
		::holds(at(agent, Position)),
		Position::(x(XP),y(YP)),
		findall(
			at(wumpus(Id), WPosition), 
			(
				::holds(at(wumpus(Id), WPosition)),
				WPosition::(x(XW),y(YP)),
				XP #> XW
			), 
			Ws
		),
		select(at(wumpus(WId), WPositionP), Ws, WsP),
		WPositionP::x(XWP),
		D #= abs(XP - XWP),
		forall(
			(
				member(at(wumpus(_), WPositionPP),WsP), 
				WPositionPP::x(XWPP)
			), (
				abs(XP - XWPP) #> D
			) 
		),
		%Closest = WPositionP,
		logtalk::print_message(help, core, @'Closest West'),
		!.
	
		/* in_direction :-
			::holds(agent_dir(east)),
			::holds(at(agent, Position)),
			Position::(x(XP),y(YP)),
			::holds(at(wumpus, WPosition)),
			WPosition::(x(XW),y(YW)),
			XP #< XW #/\ YP #= YW,
			!.
		in_direction :-
			::holds(agent_dir(south)),
			::holds(at(agent, Position)),
			Position::(x(XP),y(YP)),
			::holds(at(wumpus, WPosition)),
			WPosition::(x(XW),y(YW)),
			XP #= XW #/\ YP #> YW,
			!.
		in_direction :-
			::holds(agent_dir(west)),
			::holds(at(agent, Position)),
			Position::(x(XP),y(YP)),
			::holds(at(wumpus, WPosition)),
			WPosition::(x(XW),y(YW)),
			XP #> XW #/\ YP #= YW,
			!. */
	
	%% calculate the difference between two states
	%% This one (implicitly) and some other state
	:- public(state_diff/2).
	state_diff(OtherState, Diff) :-
		OtherState::fluent_state(OtherFluents),
		%% Basically first calculate set difference in both directions
		subtract(_FluentState_, OtherFluents, S1),
		subtract(OtherFluents, _FluentState_, S2),
		%% Then perform the union of these differences.
		union(S1,S2, Diff).

	%% See below
	:- public(pretty_print/0).
	pretty_print :-
		%%Determine how large the space is
		last(_WorldProperties_, wall(XMax,YMax)),
		_ #= YMax - 1, Width #= XMax - 1,
		meta::exclude([Term]>>(
			\+ \+ (Term = wall(_,_))
		), _WorldProperties_, EternalsClean),
		%{lists:reverse(EternalsClean, EtsPrint)},
		integer::sequence(1,Width, Seq),
		format("  ",[]),
		meta::map([Int]>>(
			((Int #< 10) -> 
				format("   ~w   ", [Int]) ; 
				format("   ~w  ", [Int])
			)
		), Seq),
		format("\n",[]),
		meta::map({Width}/[Term]>>(
			((Term::x(1)) -> (
				Term::y(Y), 
				((Y #< 10) -> format("~w ",[Y]) ; format("~w",[Y]))
			) ; true),
			(Term = exit(_,_) -> Exit = "E";Exit = " "),
			(Term = pit(_,_) -> Pit = "P";Pit = " "),
			(::holds(at(wumpus(_),Term)) -> Wumpus = "W";Wumpus = " "),
			(::holds(at(agent,Term)) -> (
				(::holds(agent_dir(north)) -> (
					Agent = "\u2193"
				);(
					(::holds(agent_dir(east)) -> (
						Agent = "\u2192"
					);(
						(::holds(agent_dir(south)) -> (
							Agent = "\u2191"
						);(
							Agent = "\u2190"
						))
					))
				))	
			);Agent = " "),
			(::holds(at(gold,Term)) -> Gold = "G";Gold = " "),
			format("|~w~w~w~w~w|",[Pit,Wumpus,Agent,Gold,Exit]),
			(Term::x(Width) -> nl; true)
		), EternalsClean),
		format("P = Pit, W = Wumpus, A = Agent, G = Gold, E = Exit \n",[]),
		format("Top left corner is (1,1), x augments to the right \ny augments down, north is down \n", []).
	
	%% Pretty print for the logfile
	%% pretty hacky but it works
	:- public(pretty_log/0).
	pretty_log :-
		%%Determine how large the space is
		%% here we cheat since we know that the world's
		%% disposition doesn't change and we know that the last
		%% corner with the largest coordinates is generated last
		last(_WorldProperties_, wall(XMax,YMax)),
		_ #= YMax - 1, Width #= XMax - 1,
		%% Remove all terms that are walls so that we only get
		%% the playable area
		meta::exclude([Term]>>(
			\+ \+ (Term = wall(_,_))
		), _WorldProperties_, EternalsClean),
		%% Create a sequence of numbers from 1 to the highest x coordinate
		integer::sequence(1,Width, Seq),
		%% Print out the numbers with the appropiate padding
		%% some special padding if they are 2 digits
		%% it breaks for bigger numbers but they don't fit in the terminal anyways
		{http_log:http_log("  ",[])},
		meta::map([Int]>>(
			((Int #< 10) -> 
				{http_log:http_log("   ~w   ", [Int])} ; 
				{http_log:http_log("   ~w  ", [Int])}
			)
		), Seq),
		{http_log:http_log("\n",[])},
		%{lists:reverse(EternalsClean, EtsPrint)},
		%Now take all the playable area terms
		meta::map({Width}/[Term]>>(
			%% if its the first term of a row (print the row number)
			((Term::x(1)) -> (
				Term::y(Y), 
				((Y #< 10) -> 
					{http_log:http_log("~w ",[Y])} ; 
					{http_log:http_log("~w",[Y])}
				)
			) ; true),
			%If its the exit add the E
			(Term = exit(_,_) -> Exit = "E";Exit = " "),
			% idem for pits
			(Term = pit(_,_) -> Pit = "P";Pit = " "),
			%if there is a wumpus, check if its alive
			(::holds(at(wumpus(Id),Term)) -> (
				(::holds(alive(wumpus(Id)))) -> Wumpus = "W" ; Wumpus = "X"
			) ; Wumpus = " " ),
			%(::holds(at(agent,Term)) -> Agent = "A";Agent = " "),
			%check agent direction to determine what arrow to draw
			(::holds(at(agent,Term)) -> (
				(::holds(agent_dir(north)) -> (
					%Agent = "\u2193"
					Agent = "v"
				);(
					(::holds(agent_dir(east)) -> (
						%Agent = "\u2192"
						Agent = ">"
					);(
						(::holds(agent_dir(south)) -> (
							%Agent = "\u2191"
							Agent = "^"
						);(
							%Agent = "\u2190"
							Agent = "<"
						))
					))
				))	
			);Agent = " "),
			%Check for gold
			(::holds(at(gold,Term)) -> Gold = "G";Gold = " "),
			%Now use all that's been found to build the ascii art,
			%if the things are there there will be a letter or if not a space
			{http_log:http_log("|~w~w~w~w~w|",[Pit,Wumpus,Agent,Gold,Exit])},
			%%if we're at the last one in a row, add a linejump
			(Term::x(Width) -> {http_log:http_log("\n",[])}; true)
		), EternalsClean),
		% add the legend.
		{http_log:http_log("P = Pit, (W/X) = (Alive/Dead) Wumpus,\n(^/>/</v) = Agent, G = Gold, E = Exit \n",[])},
		{http_log:http_log("Top left corner is (1,1), x augments to the right \ny augments down, north is down, east is to the right\n", [])}.
:- end_object.
