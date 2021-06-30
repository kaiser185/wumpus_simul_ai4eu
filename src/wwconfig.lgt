/*******************************************************************************
Author: Jacques Robin, Camilo Correa Restrepo, 2021.

Configuration specification for the WUMPUS Simulator

This file implements the configuration object and defines its associated
type for further validation.

version: 0.1
*******************************************************************************/

/* sample(wwconfig(_CONFIG_)) :-
	_CONFIG_ = _{height:2, width:2, arrow_num:1}.

sample2(wwconfig(_CONFIG_)) :-
	_CONFIG_ = _{height:3, width:3, arrow_num:1}.

sample4(wwconfig(_CONFIG_)) :-
	_CONFIG_ = _{height:4, width:4, arrow_num:1}.

fsample(wwconfig(_CONFIG_)) :-
	_CONFIG_ = _{
		height:7, width:7, arrow_num:1,
		gold_density:0.0625,
		wumpus_density:0.0625,
		pit_density:0.2
	}. */

:- object(wwconfig(_CONFIG_), implements(wwconfigp)).
	
	height(_CONFIG_.height).
	width(_CONFIG_.width).
	gold_density(_CONFIG_.gold_density).
	pit_density(_CONFIG_.pit_density).
	wumpus_density(_CONFIG_.wumpus_density).
	arrow_num(_CONFIG_.arrow_num).

	:- multifile(type::type/1).
	type::type(wwconfig).
	:- multifile(type::check/2).
	type::check(wwconfig, WWConfig) :-
		WWConfig::height(H), type::check(positive_number, H),
		WWConfig::width(W), type::check(positive_number, W),
		WWConfig::arrow_num(A), type::check(positive_number, A),
		WWConfig::pit_density(PD), type::check(probability, PD),
		WWConfig::gold_density(GD), type::check(probability, GD),
		WWConfig::wumpus_density(WD), type::check(probability, WD).
	
:- end_object.
