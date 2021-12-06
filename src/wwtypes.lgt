:- category(functor_handling).

	:- private(handle_functor/2).
	handle_functor(at, at(Entity, Place)) :-
		random::member(EntityBase, [agent, wumpus]),
		random::member(PlaceBase, [exit, wwplace, pit]),
		type::arbitrary(list(positive_integer,3),[X,Y,Id]),
		Entity=..[EntityBase, Id],
		Place=..[PlaceBase, X, Y].

	handle_functor(out, out(Entity)) :-
		random::member(EntityBase, [agent, wumpus]),
		type::arbitrary(list(positive_integer,1),[Id]),
		Entity=..[EntityBase, Id].

	handle_functor(carries, carries(Entity, Thing, N)) :-
		random::member(EntityBase, [agent, wumpus]),
		random::member(Thing, [arrow, gold]),
		type::arbitrary(list(positive_integer,2),[N,Id]),
		Entity=..[EntityBase, Id].
	
	handle_functor(alive, alive(Entity)) :-
		random::member(EntityBase, [agent, wumpus]),
		type::arbitrary(list(positive_integer,1),[Id]),
		Entity=..[EntityBase, Id].

	handle_functor(dead, dead(Entity)) :-
		random::member(EntityBase, [agent, wumpus]),
		type::arbitrary(list(positive_integer,1),[Id]),
		Entity=..[EntityBase, Id].

:- end_category.

:- object(wwtypes, imports(functor_handling)).

	:- use_module(lists, [member/2]).

	:- multifile(type::type/1).
	type::type(fluent).
	:- multifile(type::check/2).
	type::check(fluent, Fluent) :-
		type::check(term, Fluent),
		functor(Fluent, Functor, _),
		member(Functor,[at, out, carries, alive, dead]).

	:- multifile(arbitrary::arbitrary/1).
	arbitrary::arbitrary(fluent).
	:- multifile(arbitrary::arbitrary/2).
	arbitrary::arbitrary(fluent, Arbitrary) :- 
		random::member(Functor, [at, out, carries, alive, dead]),
		::handle_functor(Functor, Arbitrary).

:- end_object.

