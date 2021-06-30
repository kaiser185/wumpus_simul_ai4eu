/*******************************************************************************
Author: Jacques Robin, Camilo Correa Restrepo, 2021.

AI4EU Wumpus Server object

This object defines the server that will expose a REST API for consumption
by the external components. It is automatically loaded at startup and defines
the predicates that will be called when receiving an HTTP request.

version: 0.0.1
*******************************************************************************/ 

:- object(server).
	:- threaded.

	%Route handling
	%Here we connect each handler predicate to the route
	%% root(xx) -> <host>:8081/xx
	{:- http_handler(root(init), [Request]>>(server::init_sim(Request)), [])}.
	{:- http_handler(root(debug), [Request]>>(server::init_debug(Request)), [])}.
	{:- http_handler(root(halt), [Request]>>(server::halt_sim(Request)), [])}.
	{:- http_handler(root(forward), [Request]>>(server::fwd(Request)), [])}.
	{:- http_handler(root(right), [Request]>>(server::right(Request)), [])}.
	{:- http_handler(root(left), [Request]>>(server::left(Request)), [])}.
	{:- http_handler(root(grab), [Request]>>(server::grab(Request)), [])}.
	{:- http_handler(root(shoot), [Request]>>(server::shoot(Request)), [])}.
	{:- http_handler(root(climb), [Request]>>(server::climb(Request)), [])}.

	%% Run the server as a thread (and retain the top-level)
	:- public(run/0).
	run :-
		{ thread_httpd:http_server(http_dispatch:http_dispatch, [port(8081)]) }.
	
	%% Get an initial configuration 
	:- public(init_sim/1).	
	init_sim(Request) :-
		{ 
			http_json:http_read_json(Request, Data, [json_object(dict), value_string_as(atom)])
		},
		type::check(wwconfig, wwconfig(Data)),
		wwsimulator::create_simulation_session(wwconfig(Data), UUID, SIMSTATE),
		wwpercept::gen_percept(SIMSTATE, Percepts),
		SIMSTATE::pretty_log,
		atomize(Percepts, AP),
		{http_json:reply_json(_{
			status:"Simulation Created",
			uuid:UUID,
			percepts:AP
		}
		)}.

	:- public(init_debug/1).	
	init_debug(_) :-
		/* { 
			http_json:http_read_json(Request, Data, [json_object(dict), value_string_as(atom)])
		},
		type::check(wwconfig, Data), */
		wwsimulator::create_debug_session(UUID, SIMSTATE),
		wwpercept::gen_percept(SIMSTATE, Percepts),
		SIMSTATE::pretty_log,
		{http_json:reply_json(_{
			status:"AIMA Simulation Created",
			uuid:UUID,
			percepts:Percepts
		}
		)}.

	:- public(halt_sim/1).
	halt_sim(Request) :-
		{ 
			http_json:http_read_json(Request, Data, [json_object(dict), value_string_as(atom)])
		},
		{http_log:http_log('Received data ~w \n', [Data])},
		_{uuid:UUID} :< Data,
		wwsimulator::halt_sim(UUID),
		{http_json:reply_json(_{
			status:"Simulation Halted",
			uuid:UUID
		}
		)}.
	
	:- public(fwd/1).
	fwd(Request) :-
		handle_action(Request, forward).

	:- public(right/1).
	right(Request) :-
		handle_action(Request, right).

	:- public(left/1).
	left(Request) :-
		handle_action(Request, left).

	:- public(grab/1).
	grab(Request) :-
		handle_action(Request, grab).

	:- public(shoot/1).
	shoot(Request) :-
		handle_action(Request, shoot).

	:- public(climb/1).
	climb(Request) :-
		handle_action(Request, climb).

	:- private(handle_action/2).
	%% Generic handler method for all action types
	%% TODO: add some better error handling when given incorrect UUIDs
	handle_action(Request, Action) :-
		{ 
			http_json:http_read_json(Request, Data, [json_object(dict), value_string_as(atom)])
		},
		{http_log:http_log('Received data ~w \n', [Data])},
		_{uuid:UUID} :< Data,
		%%atomize(Z, ZData),
		%%logtalk::print_message(help, core, 'State ~w'+[Z]),
		wwsimulator::simulation(UUID, WWSIMSTATE0, _),
		%{http_log:http_log('Found Simulation ~w \n', [WWSIMSTATE0])},
		wwsimulator::do(Action, WWSIMSTATE0, WWSIMSTATE),
		%{http_log:http_log('Performed Action ~w @ ~w \n', [Action, WWSIMSTATE0])},
		%% This whole if then else block simply handles what the
		%% response to the action request will be
		((
			%% Check end condition hasn't been reached
			wwsimulator::can_continue(WWSIMSTATE)
		) -> (
			%%Do percept generation and update the simulation state
			%{http_log:http_log('Branch1 Start \n', [])},
			wwpercept::gen_percept(Action, WWSIMSTATE, WWSIMSTATE0, Percepts),
			%{http_log:http_log('Branch1 Percept Gen \n', [])},
			wwsimulator::update_simulation(
				UUID, WWSIMSTATE0, WWSIMSTATE, Tick
			),
			WWSIMSTATE::pretty_log,
			%{http_log:http_log('Branch1 Simul Update \n', [])},
			Response = _{
				status:ok,
				percepts:Percepts,
				tick:Tick
			}
			%{http_log:http_log('Branch1 End \n', [])}
		) ; (
			%{http_log:http_log('Branch2 Start \n', [])},
			((
				wwsimulator::win(WWSIMSTATE)
			) -> (
				%{http_log:http_log('Branch2.1 Win State \n', [])},
				wwsimulator::halt_sim(UUID),
				Response = _{
					status:"Simulation Halted - You Win"
				}
			) ; (
				%{http_log:http_log('Branch2.2 No Win State \n', [])},
				((
					wwsimulator::finished(WWSIMSTATE)
				) -> (
					%{http_log:http_log('Branch2.2.1 Out-No-Win \n', [])},
					wwsimulator::halt_sim(UUID),
					Response = _{
						status:"Simulation Halted - You Lose (No gold)"
					}
				) ; (
					%{http_log:http_log('Branch2.2.2 Dead \n', [])},
					wwsimulator::halt_sim(UUID),
					Response = _{
					status:"Simulation Halted - Agent Dead"
					}
				))
			))
		)),
		logtalk::print_message(help, core, 'Response Dict ~w'+[Response]),
		{http_json:reply_json(Response, [status(200), json_object(dict)])}.
		
	:- private(atomize/2).
	atomize(State, AtomizedState) :-
		meta::map([Elem0, Elem]>>(term_to_atom(Elem0, Elem)),State,AtomizedState).

:- end_object.