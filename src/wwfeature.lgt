/*******************************************************************************
Author: Jacques Robin, Camilo Correa Restrepo, 2021.

Feature specification for the WUMPUS simulator

This file implements certain relations among fluents or world properties as reified objects.

version: 0.1
*******************************************************************************/
/* :- object(wwfeature(_TERM_), implements(featurep)).

	term(_TERM_).

	:- multifile(type::type/1).
	type::type(wwfeature).
	:- multifile(type::check/2).
	type::check(wwfeature, Feature) :-
		Feature::term(Term), type::check(term, Term).

:- end_object.


%%wwfluent(at(1,2))
:- object(wwfluent(_TERM_), extends(wwfeature(_TERM_))).
	
	:- multifile(type::type/1).
	type::type(wwfluent).
	:- multifile(type::check/2).
	type::check(wwfluent, Fluent) :-
		type::check(wwfeature, Fluent).

:- end_object.

:- object(wweternal(_TERM_), extends(wwfeature(_TERM_))).
	
	:- multifile(type::type/1).
	type::type(wweternal).
	:- multifile(type::check/2).
	type::check(wweternal, Eternal) :-
		type::check(wwfeature, Eternal).

:- end_object.

:- object(wweternalrelation(_TERM_), extends(wweternal(_TERM_))).

	:- multifile(type::type/1).
	type::type(wweternal).
	:- multifile(type::check/2).
	type::check(wweternal, Eternal) :-
		type::check(wwfeature, Eternal).

:- end_object. */

%So according to https://logtalk.org/2019/11/13/many-worlds-design-pattern.html it makes sense to parametrize this with the particular world in this way.

%sample(CFG), wwsimulator::init(CFG, S), adjacent(S)::adjacent(exit(1,1), P).
%Here the semantics change though, this describes, in essence a theory of adjacency in some possible parametrized world.
:- object(adjacent(_WWSIM_)/* , extends(wweternalrelation(_)) */).
	
	:- use_module(clpfd, [
		op(760, xfy, #<==>), op(750, xfy, #==>), op(700, xfx, #=), op(700, xfx, #>=), op(700, xfx, #=<), op(700, xfx, in), op(450, xfx, ..),
		op(740, yfx, #\/), op(730, yfx, #\), op(720, yfx, #/\), op(710,  fy, #\), op(700, xfx, ins), op(700, xfx, #>), op(700, xfx, #<), op(700, xfx, #\=),
		(=<)/2, (ins)/2, (in)/2, (#>=)/2, (#<==>)/2, (#==>)/2, (#=)/2, sum/3, chain/2, labeling/2, (#\)/1, (#\/)/2, (#\)/2, (#/\)/2, (#>)/2, (#<)/2, (#\=)/2
	]).

	:- public(adjacent/2).
	adjacent(Place, AdjacentPlaces) :-
		%% Placeholder for now
		_WWSIM_::eternal_state(Places),
		meta::include({Place}/[AdjPlace]>>(
			Place::(x(X0),y(Y0)), AdjPlace::(x(X),y(Y)),
			(	1 #<==> (
				(abs(X0 - X) #= 1 #/\ Y0 #= Y) #\ 
				(abs(Y0 - Y) #= 1 #/\ X0 #= X) )
			)	
		),Places,AdjacentPlaces).
		
	
	/*
	:- multifile(type::type/1).
	type::type(wweternal).
	:- multifile(type::check/2).
	type::check(wweternal, Eternal) :-
		type::check(wwfeature, Eternal). */

:- end_object.


